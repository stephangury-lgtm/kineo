create or replace function public.quiz_text_equivalent_v1(p_given text,p_expected text)
returns boolean
language plpgsql
immutable
set search_path=''
as $$
declare
  v_given text:=public.normalize_quiz_text_v1(p_given);
  v_expected text:=public.normalize_quiz_text_v1(p_expected);
  v_g text;
  v_e text;
  v_gw text[];
  v_ew text[];
  v_common integer:=0;
  v_min integer:=0;
begin
  if v_given='' or v_expected='' then return false; end if;
  if v_given=v_expected then return true; end if;
  v_g:=pg_catalog.regexp_replace(v_given,'([0-9]+)sec','\1 seconde','g');
  v_g:=pg_catalog.regexp_replace(v_g,'([0-9]+)s( |$)','\1 seconde\2','g');
  v_g:=pg_catalog.regexp_replace(v_g,'secondes?','seconde','g');
  v_g:=pg_catalog.regexp_replace(v_g,'(^| )a( |$)',' ','g');
  v_g:=pg_catalog.regexp_replace(v_g,'[[:space:]]+',' ','g');
  v_e:=pg_catalog.regexp_replace(v_expected,'([0-9]+)sec','\1 seconde','g');
  v_e:=pg_catalog.regexp_replace(v_e,'([0-9]+)s( |$)','\1 seconde\2','g');
  v_e:=pg_catalog.regexp_replace(v_e,'secondes?','seconde','g');
  v_e:=pg_catalog.regexp_replace(v_e,'(^| )a( |$)',' ','g');
  v_e:=pg_catalog.regexp_replace(v_e,'[[:space:]]+',' ','g');
  v_g:=btrim(v_g); v_e:=btrim(v_e);
  if v_g=v_e then return true; end if;
  if pg_catalog.length(v_g)>=6 and pg_catalog.length(v_e)>=6 and (pg_catalog.strpos(v_e,v_g)>0 or pg_catalog.strpos(v_g,v_e)>0) then return true; end if;
  select pg_catalog.array_agg(distinct w) into v_gw from pg_catalog.unnest(pg_catalog.string_to_array(v_g,' ')) w where pg_catalog.length(w)>=3 and w not in ('les','des','une','dans','pour','avec','sans','sur','sous','que','qui','est','sont','par','aux','ses','son','leur','leurs','cette','cela','comme','entre','plus','moins','cote','doit','etre','afin','tout','tous');
  select pg_catalog.array_agg(distinct w) into v_ew from pg_catalog.unnest(pg_catalog.string_to_array(v_e,' ')) w where pg_catalog.length(w)>=3 and w not in ('les','des','une','dans','pour','avec','sans','sur','sous','que','qui','est','sont','par','aux','ses','son','leur','leurs','cette','cela','comme','entre','plus','moins','cote','doit','etre','afin','tout','tous');
  if v_gw is null or v_ew is null then return false; end if;
  select pg_catalog.count(*) into v_common from pg_catalog.unnest(v_gw) x where x=any(v_ew);
  v_min:=least(pg_catalog.cardinality(v_gw),pg_catalog.cardinality(v_ew));
  return v_min>=2 and v_common::numeric/v_min>=0.80;
end;
$$;

create or replace function public.submit_quiz_answer(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer default null::integer)
returns jsonb
language plpgsql
security definer
set search_path=''
as $$
declare
  v_user_id uuid; v_question_type text; v_metadata jsonb; v_is_correct boolean:=false; v_xp integer:=0;
  v_attempt_count integer:=0; v_correct_count integer:=0; v_mastery integer:=0; v_expected text; v_given text;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  select rs.user_id into v_user_id from public.revision_sessions rs where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is null and rs.abandoned_at is null;
  if v_user_id is null then raise exception 'Session inexistante, terminée, abandonnée ou accès non autorisé'; end if;
  select q.type,coalesce(q.metadata,'{}'::jsonb) into v_question_type,v_metadata from public.revision_session_questions rsq join public.questions q on q.id=rsq.question_id where rsq.session_id=p_session_id and rsq.question_id=p_question_id and q.is_published=true and q.validation_status='published';
  if v_question_type is null then raise exception 'Cette question ne fait pas partie de cette session'; end if;
  if exists(select 1 from public.question_attempts qa where qa.session_id=p_session_id and qa.question_id=p_question_id and qa.user_id=v_user_id) then raise exception 'Cette question a déjà reçu une réponse'; end if;
  if v_question_type in ('mcq','true_false') or (v_question_type='clinical_case' and nullif(p_answer->>'option_id','') is not null) then
    select exists(select 1 from public.question_options qo where qo.question_id=p_question_id and qo.id::text=p_answer->>'option_id' and qo.is_correct=true) into v_is_correct;
  elsif v_question_type in ('fill_blank','short_answer','translation','clinical_case') then
    v_given:=coalesce(p_answer->>'text',''); v_expected:=coalesce(v_metadata->>'answer','');
    v_is_correct:=public.quiz_text_equivalent_v1(v_given,v_expected) or exists(select 1 from pg_catalog.jsonb_array_elements_text(case when pg_catalog.jsonb_typeof(v_metadata->'accepted_answers')='array' then v_metadata->'accepted_answers' else '[]'::jsonb end) a(value) where public.quiz_text_equivalent_v1(v_given,a.value));
  elsif v_question_type='matching' then
    if pg_catalog.jsonb_typeof(v_metadata->'pairs')='array' and pg_catalog.jsonb_typeof(p_answer->'pairs')='array' then v_is_correct:=pg_catalog.jsonb_array_length(v_metadata->'pairs')=pg_catalog.jsonb_array_length(p_answer->'pairs') and (v_metadata->'pairs')@>(p_answer->'pairs') and (p_answer->'pairs')@>(v_metadata->'pairs'); end if;
  else v_is_correct:=false; end if;
  if v_is_correct then v_xp:=case v_question_type when 'matching' then 15 when 'fill_blank' then 12 when 'short_answer' then 15 when 'translation' then 15 when 'clinical_case' then 20 else 10 end; end if;
  insert into public.question_attempts(user_id,question_id,session_id,answer,is_correct,response_time_ms,xp_earned) values(v_user_id,p_question_id,p_session_id,p_answer,v_is_correct,p_response_time_ms,v_xp);
  update public.revision_session_questions set answered_at=now() where session_id=p_session_id and question_id=p_question_id;
  select coalesce(attempt_count,0),coalesce(correct_count,0) into v_attempt_count,v_correct_count from public.user_question_mastery where user_id=v_user_id and question_id=p_question_id;
  v_attempt_count:=coalesce(v_attempt_count,0)+1; v_correct_count:=coalesce(v_correct_count,0); if v_is_correct then v_correct_count:=v_correct_count+1; end if;
  v_mastery:=least(4,floor((v_correct_count::numeric/v_attempt_count::numeric)*4)::integer);
  insert into public.user_question_mastery(user_id,question_id,mastery_score,attempt_count,correct_count,last_attempt_at,next_review_at) values(v_user_id,p_question_id,v_mastery,v_attempt_count,v_correct_count,now(),case when v_is_correct and v_mastery>=3 then now()+interval '7 days' when v_is_correct then now()+interval '3 days' else now()+interval '1 day' end) on conflict(user_id,question_id) do update set mastery_score=excluded.mastery_score,attempt_count=excluded.attempt_count,correct_count=excluded.correct_count,last_attempt_at=excluded.last_attempt_at,next_review_at=excluded.next_review_at;
  return pg_catalog.jsonb_build_object('correct',v_is_correct,'xp_earned',v_xp,'mastery_score',v_mastery,'question_type',v_question_type,'question_id',p_question_id,'session_id',p_session_id);
end;
$$;

update public.questions set metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{accepted_answers}',coalesce(metadata->'accepted_answers','[]'::jsonb) || '["les résultats doivent être comparables entre examinateurs","pour que deux kinés trouvent la même mesure","pour que les mesures soient comparables quel que soit l’examinateur","pour retrouver le même résultat avec un autre kiné"]'::jsonb,true) where id='bd80aaab-4b5e-4bf8-a2c2-462db9da3d28';
update public.questions set question_text='Dans quels cas faut-il interrompre immédiatement l’examen ?',metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{accepted_answers}','["douleur importante","gêne importante","si le patient demande d’arrêter","à la demande du patient","si la situation dépasse l’étudiant","douleur ou gêne importante","si le patient a mal"]'::jsonb,true) where id='84581a93-56b5-43c2-88a3-aecd29fa1387';
update public.questions set metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{accepted_answers}',coalesce(metadata->'accepted_answers','[]'::jsonb) || '["forces externes","forces exterieures","du côté extérieur","côté des forces extérieures"]'::jsonb,true) where id='0154cc24-afc5-481b-87dd-cf2b004f1935';

update public.questions set question_text='Cite un ligament collatéral du genou.' where id='e4c7a343-3d55-440b-9a6a-c3cabfb873c8';
update public.questions set question_text='Le contact corporel et l’intimité font partie des spécificités de la relation de soin en kinésithérapie.' where id='e8e7475b-c407-4f03-82b5-160b651a94f4';
update public.questions set question_text='Le grand fessier est un extenseur de hanche.' where id='0ae49c96-2c38-4f2d-8a84-14913659b779';
update public.questions set question_text='Le ligament collatéral fibulaire fait partie des structures palpables du genou.' where id='06be760b-7cc0-4c38-a629-af21ea7d4459';
update public.questions set question_text='Pourquoi le genou est-il fléchi lors de la mesure de flexion dorsale de cheville ?' where id='0ec0fd4f-cd7f-4cc9-8b08-c41ccb74889c';
update public.questions set question_text='Quel muscle est abducteur de hanche ?' where id='7123f23b-fb95-4daf-9bae-7b092775c3bc';
update public.questions set question_text='Quel muscle fléchisseur de hanche est situé sous le droit de l’abdomen ?' where id='4c45765e-d4f9-45b8-9a63-48650a253f49';
update public.questions set question_text='Quel principe fait partie du bilan articulaire ?' where id='b71a0ece-eeb6-4958-9cf8-33b52c945b2c';
update public.questions set question_text='Quelle durée indicative est recommandée pour maintenir un étirement ?' where id='d3a914ad-0888-4889-8526-71f1eeff6a49';
update public.questions set question_text='Quelle amplitude de flexion de hanche est retenue comme valeur de référence ?' where id='cf8aa99d-02fb-4aff-a3e3-5f8044287f39';
update public.questions set question_text='Quels muscles forment le plan profond du trigone fémoral ?' where id='3608724f-9312-4da8-adc5-ddd453c13489';
update public.questions set question_text='Quels sont les trois axes du bilan articulaire ?' where id='efa1c8ca-32be-483f-8239-45e5abc24798';
update public.questions set question_text='Quels sont les trois verbes qui résument le pétrissage ?' where id='e71d08a5-1820-41be-8309-9e6cc77e739d';