alter table duel_private.tiebreak_rounds drop constraint tiebreak_rounds_challenger_id_fkey, drop constraint tiebreak_rounds_challenged_id_fkey;
alter table duel_private.tiebreak_rounds add constraint tiebreak_rounds_challenger_id_fkey foreign key(challenger_id) references public.profiles(id) on delete cascade, add constraint tiebreak_rounds_challenged_id_fkey foreign key(challenged_id) references public.profiles(id) on delete cascade;
create or replace function duel_private.tiebreak_step(p_challenge_id uuid,p_program_id text,p_round integer default null,p_answer text default null,p_next boolean default false)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare
 uid uuid:=auth.uid(); a uuid; b uuid; lev uuid; yr integer; ver text; r duel_private.tiebreak_rounds%rowtype;
 qid uuid; prompt text; opts jsonb; correct_key text; explanation text; next_round integer; mine text; theirs text; closed boolean; winner uuid; fresh boolean:=false;
begin
 if uid is null then raise exception 'Connexion requise / Inicia sesión.'; end if;
 if p_program_id='kineo-fr' then
  select c.challenger_id,c.challenged_id into a,b from public.challenges c
   where c.id=p_challenge_id and c.status='completed' and c.challenger_score=c.challenged_score
   and c.challenger_score is not null and uid in(c.challenger_id,c.challenged_id);
  select y.number into yr from public.challenge_questions cq join public.questions q on q.id=cq.question_id join public.chapters ch on ch.id=q.chapter_id join public.subjects s on s.id=ch.subject_id join public.years y on y.id=s.year_id where cq.challenge_id=p_challenge_id limit 1;
 elsif p_program_id in('kineo-es','ifsi-fr') then
  select c.challenger_id,c.challenged_id,c.academic_level_id into a,b,lev from public.curriculum_friend_challenges c
   where c.id=p_challenge_id and c.program_id=p_program_id and c.status='completed' and c.challenger_score=c.challenged_score
   and c.challenger_score is not null and uid in(c.challenger_id,c.challenged_id);
  select coalesce(u.curriculum_version,'default') into ver from public.curriculum_friend_challenge_questions cq join public.curriculum_quiz_questions q on q.id=cq.question_id join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id where cq.challenge_id=p_challenge_id limit 1;
 end if;
 if a is null then raise exception 'Départage réservé aux participants d’un duel terminé à égalité.'; end if;
 perform pg_advisory_xact_lock(hashtextextended(p_program_id||':'||p_challenge_id::text,0));
 select * into r from duel_private.tiebreak_rounds t where t.challenge_id=p_challenge_id and t.program_id=p_program_id order by t.round desc limit 1 for update;
 if (r.challenge_id is null or p_next or p_answer is not null) and not exists(select 1 from public.friendships f where f.status='accepted' and ((f.requester_id=a and f.addressee_id=b)or(f.requester_id=b and f.addressee_id=a))) then raise exception 'Vous devez être amis pour jouer le départage.'; end if;
 if r.challenge_id is null or (p_next and r.challenger_answer is not null and r.challenged_answer is not null and r.winner_id is null) then
  if p_answer is not null then raise exception 'Ouvre la manche avant de répondre.'; end if;
  next_round:=coalesce(r.round,0)+1;
  if next_round>50 then raise exception 'Départage terminé à égalité. Lancez une revanche classique.'; end if;
  if p_program_id='kineo-fr' then
   select q.id,q.question_text,q.explanation into qid,prompt,explanation from public.questions q join public.chapters ch on ch.id=q.chapter_id join public.subjects s on s.id=ch.subject_id join public.years y on y.id=s.year_id
    where y.number=yr and y.is_active and s.is_active and ch.is_active and q.is_published and q.validation_status='published' and q.type='mcq'
    and (select count(*) from public.question_options o where o.question_id=q.id and o.is_correct)=1
    and (select count(*) from public.question_options o where o.question_id=q.id)>=2
    and not exists(select 1 from public.challenge_questions cq where cq.challenge_id=p_challenge_id and cq.question_id=q.id)
    and not exists(select 1 from duel_private.tiebreak_rounds t where t.challenge_id=p_challenge_id and t.program_id=p_program_id and t.question_id=q.id)
    order by random() limit 1;
   select jsonb_agg(jsonb_build_object('id',o.id::text,'text',o.option_text) order by o.display_order,o.id),max(o.id::text) filter(where o.is_correct) into opts,correct_key from public.question_options o where o.question_id=qid;
  else
   select q.id,q.question_text,q.explanation,q.options into qid,prompt,explanation,opts from public.curriculum_quiz_questions q join public.curriculum_topics t on t.id=q.topic_id join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id and u.academic_level_id=lev and coalesce(u.curriculum_version,'default')=ver and u.is_active and t.is_active and q.is_published and q.validation_status='source_validated' and q.question_type='mcq'
    and jsonb_array_length(q.options)>=2 and (select count(*) from jsonb_array_elements(q.options) o where coalesce((o->>'correct')::boolean,false))=1
    and not exists(select 1 from public.curriculum_friend_challenge_questions cq where cq.challenge_id=p_challenge_id and cq.question_id=q.id)
    and not exists(select 1 from duel_private.tiebreak_rounds tr where tr.challenge_id=p_challenge_id and tr.program_id=p_program_id and tr.question_id=q.id)
    order by random() limit 1;
   select jsonb_agg(jsonb_build_object('id',ord::text,'text',o->>'text') order by ord),max(ord::text) filter(where coalesce((o->>'correct')::boolean,false)) into opts,correct_key from jsonb_array_elements(opts) with ordinality as x(o,ord);
  end if;
  if qid is null or opts is null or correct_key is null then raise exception 'Pas de nouvelle question validée disponible. Une revanche classique reste possible.'; end if;
  insert into duel_private.tiebreak_rounds(challenge_id,program_id,round,challenger_id,challenged_id,question_id,prompt,options,correct_key,explanation)
   values(p_challenge_id,p_program_id,next_round,a,b,qid,prompt,opts,correct_key,explanation) returning * into r;
  fresh:=true;
  insert into public.notifications(user_id,type,title,body,data) values(case when uid=a then b else a end,'tiebreak_received','Départage du duel ⚡','Une même question pour vous départager. Chacun joue quand il veut.',jsonb_build_object('challenge_id',p_challenge_id,'program_id',p_program_id,'round',r.round));
 end if;
 if p_answer is not null then
  if p_round is distinct from r.round then raise exception 'Cette manche a changé. Actualise le départage.'; end if;
  if not exists(select 1 from jsonb_array_elements(r.options) o where o->>'id'=p_answer) then raise exception 'Réponse invalide.'; end if;
  mine:=case when uid=a then r.challenger_answer else r.challenged_answer end;
  if mine is not null and mine<>p_answer then raise exception 'Ta réponse est déjà enregistrée.'; end if;
  if mine is null then
   update duel_private.tiebreak_rounds t set challenger_answer=case when uid=a then p_answer else t.challenger_answer end,challenged_answer=case when uid=b then p_answer else t.challenged_answer end
    where t.challenge_id=p_challenge_id and t.program_id=p_program_id and t.round=r.round returning * into r;
   if r.challenger_answer is not null and r.challenged_answer is not null then
    winner:=case when (r.challenger_answer=r.correct_key)<>(r.challenged_answer=r.correct_key) then case when r.challenger_answer=r.correct_key then a else b end end;
    update duel_private.tiebreak_rounds t set winner_id=winner where t.challenge_id=p_challenge_id and t.program_id=p_program_id and t.round=r.round returning * into r;
    insert into public.notifications(user_id,type,title,body,data) select participant,'tiebreak_completed',case when winner is null then 'Départage : nouvelle manche possible ⚡' else 'Résultat du départage ⚡' end,'Les deux réponses sont enregistrées. Découvre le résultat.',jsonb_build_object('challenge_id',p_challenge_id,'program_id',p_program_id,'round',r.round) from unnest(array[a,b]) participant;
   end if;
  end if;
 end if;
 mine:=case when uid=a then r.challenger_answer else r.challenged_answer end;
 theirs:=case when uid=a then r.challenged_answer else r.challenger_answer end;
 closed:=mine is not null and theirs is not null;
 return jsonb_build_object('round',r.round,'question',r.prompt,'options',r.options,'my_answered',mine is not null,'other_answered',theirs is not null,'round_closed',closed,
  'outcome',case when not closed then 'waiting' when r.winner_id is null then 'draw' when r.winner_id=uid then 'win' else 'loss' end,
  'my_correct',case when closed then mine=r.correct_key end,'other_correct',case when closed then theirs=r.correct_key end,
  'correct_answer',case when closed then (select o->>'text' from jsonb_array_elements(r.options) o where o->>'id'=r.correct_key) end,
  'explanation',case when closed then r.explanation end,'can_next',closed and r.winner_id is null and r.round<50);
end;$fn$;