-- Additive rollout: apply before deploying the new frontend. The next migration
-- removes raw question reads only after the safe API is in use.
alter table public.profiles drop constraint profiles_study_year_check;
alter table public.profiles add constraint profiles_study_year_check
  check (study_year between 1 and 5);

create or replace function public.setup_student_profile_v1(
  p_program_id text, p_level_code text, p_first_name text, p_username text
) returns jsonb
language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_profile public.profiles%rowtype;
  v_level public.academic_levels%rowtype;
  v_existing public.profile_programs%rowtype;
  v_year integer;
  v_username text := nullif(btrim(coalesce(p_username, '')), '');
  v_first_name text := nullif(btrim(coalesce(p_first_name, '')), '');
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if v_username is not null and (length(v_username) not between 3 and 24 or v_username !~ '^[A-Za-z0-9._-]+$') then
    raise exception 'Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore';
  end if;
  if length(v_first_name) > 100 then raise exception 'Le prénom est trop long'; end if;

  -- Serialize two setup requests for the same user, including first assignment.
  select * into v_profile from public.profiles where id = v_uid for update;
  if not found then raise exception 'Profil introuvable'; end if;
  select al.* into v_level
  from public.academic_levels al join public.programs pr on pr.id = al.program_id
  where al.program_id = p_program_id and al.code = p_level_code
    and al.is_active and pr.is_active;
  if not found then raise exception 'Choisis un niveau d’étude valide pour ton cursus'; end if;
  if p_program_id not in ('kineo-fr', 'kineo-es', 'ifsi-fr') then
    raise exception 'Cursus indisponible';
  end if;

  select * into v_existing from public.profile_programs
  where user_id = v_uid and is_primary for update;
  if found and (v_existing.program_id <> p_program_id or
    (v_existing.academic_level_id is not null and v_existing.academic_level_id <> v_level.id)) then
    raise exception 'Ton cursus est déjà défini. Modifie ton niveau depuis ton profil';
  end if;
  v_year := case when p_program_id = 'ifsi-fr' then (v_level.level_number + 1) / 2 else v_level.level_number end;

  begin
    update public.profiles set first_name = v_first_name, username = v_username,
      study_year = v_year, updated_at = now()
    where id = v_uid returning * into v_profile;
  exception when unique_violation then raise exception 'Ce pseudo est déjà utilisé';
  end;

  if v_existing.user_id is null then
    insert into public.profile_programs(user_id, program_id, academic_level_id, is_primary, curriculum_version)
    values(v_uid, p_program_id, v_level.id, true, case when p_program_id = 'ifsi-fr' then '2009' else 'default' end);
  elsif v_existing.academic_level_id is null then
    update public.profile_programs set academic_level_id = v_level.id, updated_at = now()
    where user_id = v_uid and program_id = p_program_id;
  end if;

  return jsonb_build_object('id', v_profile.id, 'first_name', v_profile.first_name,
    'username', v_profile.username::text, 'avatar_url', v_profile.avatar_url,
    'study_year', v_profile.study_year, 'role', v_profile.role);
end;
$function$;
revoke all on function public.setup_student_profile_v1(text,text,text,text) from public, anon;
grant execute on function public.setup_student_profile_v1(text,text,text,text) to authenticated;

create or replace function public.update_study_profile_v1(p_first_name text, p_username text, p_study_year integer)
returns jsonb language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_old_year integer;
  v_program text;
  v_min integer := 2;
  v_max integer := 5;
  v_username text := nullif(btrim(coalesce(p_username, '')), '');
  v_first_name text := nullif(btrim(coalesce(p_first_name, '')), '');
  v_row public.profiles%rowtype;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select study_year into v_old_year from public.profiles where id = v_uid for update;
  if not found then raise exception 'Profil introuvable'; end if;
  select program_id into v_program from public.profile_programs where user_id = v_uid and is_primary;
  if v_program = 'ifsi-fr' then v_min := 1; v_max := 3;
  elsif v_program = 'kineo-es' then v_min := 1; v_max := 4;
  end if;
  if p_study_year is null or p_study_year not between v_min and v_max then
    raise exception 'Année d’étude invalide pour ton cursus';
  end if;
  if v_username is not null and (length(v_username) not between 3 and 24 or v_username !~ '^[A-Za-z0-9._-]+$') then
    raise exception 'Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore';
  end if;
  if length(v_first_name) > 100 then raise exception 'Le prénom est trop long'; end if;
  begin
    update public.profiles set first_name = v_first_name, username = v_username,
      study_year = p_study_year, updated_at = now() where id = v_uid returning * into v_row;
  exception when unique_violation then raise exception 'Ce pseudo est déjà utilisé';
  end;
  if v_old_year is distinct from p_study_year then
    update public.revision_sessions set abandoned_at = coalesce(abandoned_at, now())
    where user_id = v_uid and completed_at is null and abandoned_at is null and challenge_id is null;
  end if;
  return jsonb_build_object('id', v_row.id, 'first_name', v_row.first_name,
    'username', v_row.username::text, 'avatar_url', v_row.avatar_url, 'study_year', v_row.study_year);
end;
$function$;
revoke all on function public.update_study_profile_v1(text,text,integer) from public, anon;
grant execute on function public.update_study_profile_v1(text,text,integer) to authenticated;

-- SECURITY DEFINER is necessary because the raw answer columns will no longer
-- be readable by students. Recheck ownership, level and curriculum in this API.
create or replace function public.get_curriculum_quiz_questions_v1(p_topic_ids uuid[])
returns table(id uuid, topic_id uuid, question_text text, explanation text, options jsonb,
  difficulty smallint, source_label text, display_order integer, question_type text,
  image_url text, metadata jsonb)
language plpgsql security definer set search_path = ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_admin boolean;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if coalesce(cardinality(p_topic_ids), 0) > 200 then raise exception 'Trop de chapitres demandés'; end if;
  select role = 'admin' into v_admin from public.profiles where profiles.id = v_uid;
  return query
  select q.id, q.topic_id, q.question_text, null::text,
    coalesce((select jsonb_agg(jsonb_build_object('text', o.value->>'text') order by random())
      from jsonb_array_elements(q.options) o(value)), '[]'::jsonb),
    q.difficulty, q.source_label, q.display_order, q.question_type, q.image_url,
    case q.question_type
      when 'visual_hotspot' then jsonb_build_object('hotspots', coalesce((
        select jsonb_agg(jsonb_build_object('id', h.value->'id', 'label', h.value->'label',
          'x', h.value->'x', 'y', h.value->'y') order by h.ord)
        from jsonb_array_elements(coalesce(q.metadata->'hotspots', '[]'::jsonb)) with ordinality h(value,ord)
      ), '[]'::jsonb))
      when 'matching' then jsonb_build_object(
        'left_items', coalesce((select jsonb_agg(p.value->'left' order by p.ord)
          from jsonb_array_elements(coalesce(q.metadata->'pairs', '[]'::jsonb)) with ordinality p(value,ord)), '[]'::jsonb),
        'right_items', coalesce((select jsonb_agg(p.value->'right' order by random())
          from jsonb_array_elements(coalesce(q.metadata->'pairs', '[]'::jsonb)) p(value)), '[]'::jsonb))
      else '{}'::jsonb
    end
  from public.curriculum_quiz_questions q
  join public.curriculum_topics t on t.id = q.topic_id and t.is_active
  join public.curriculum_units u on u.id = t.unit_id and u.is_active
  join public.academic_levels target on target.id = u.academic_level_id and target.program_id = u.program_id and target.is_active
  where q.topic_id = any(p_topic_ids) and q.is_published and q.validation_status = 'source_validated'
    and (coalesce(v_admin, false) or exists(
      select 1 from public.profile_programs pp
      join public.academic_levels assigned on assigned.id = pp.academic_level_id and assigned.program_id = pp.program_id
      where pp.user_id = v_uid and pp.program_id = u.program_id
        and target.display_order <= assigned.display_order
        and coalesce(pp.curriculum_version, 'default') = coalesce(u.curriculum_version, 'default')
    ))
  order by q.difficulty, q.display_order, q.id;
end;
$function$;
revoke all on function public.get_curriculum_quiz_questions_v1(uuid[]) from public, anon;
grant execute on function public.get_curriculum_quiz_questions_v1(uuid[]) to authenticated;

-- The existing submission applies authorization and daily XP/idempotency locks.
-- Only add the explanation after that submission has succeeded.
create or replace function public.submit_curriculum_topic_answer_v3(p_question_id uuid, p_answer jsonb)
returns jsonb language plpgsql security definer set search_path = ''
as $function$
declare v_result jsonb; v_explanation text;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  v_result := public.submit_curriculum_topic_answer_v2(p_question_id, p_answer);
  select explanation into v_explanation from public.curriculum_quiz_questions where id = p_question_id;
  return v_result || jsonb_build_object('explanation', v_explanation);
end;
$function$;
revoke all on function public.submit_curriculum_topic_answer_v3(uuid,jsonb) from public, anon;
grant execute on function public.submit_curriculum_topic_answer_v3(uuid,jsonb) to authenticated;

notify pgrst, 'reload schema';
