-- Make friend challenges truly multi-curriculum and level-aware.
-- Existing legacy Kineo France challenge functions remain untouched.

alter table public.curriculum_friend_challenges
  add column if not exists academic_level_id uuid references public.academic_levels(id) on delete restrict;

create index if not exists idx_curriculum_friend_challenges_program_level
  on public.curriculum_friend_challenges(program_id, academic_level_id, created_at desc);

create or replace function public.create_curriculum_friend_challenge_v1(
  p_friend_id uuid,
  p_program_id text default 'ifsi-fr'
)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_id uuid;
  v_count integer;
  v_username text;
  v_program_name text;
  v_level_id uuid;
  v_friend_level_id uuid;
  v_level_code text;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_friend_id is null or p_friend_id = v_uid then raise exception 'Ami invalide'; end if;

  if not exists(
    select 1 from public.friendships f
    where f.status = 'accepted'
      and ((f.requester_id = v_uid and f.addressee_id = p_friend_id)
        or (f.requester_id = p_friend_id and f.addressee_id = v_uid))
  ) then
    raise exception 'Cet utilisateur ne fait pas partie de tes amis';
  end if;

  select pp.academic_level_id into v_level_id
  from public.profile_programs pp
  where pp.user_id = v_uid and pp.program_id = p_program_id;

  select pp.academic_level_id into v_friend_level_id
  from public.profile_programs pp
  where pp.user_id = p_friend_id and pp.program_id = p_program_id;

  if v_level_id is null or v_friend_level_id is null then
    raise exception 'Les deux participants doivent avoir ce cursus et un niveau sélectionné';
  end if;
  if v_level_id <> v_friend_level_id then
    raise exception 'Les défis sont disponibles entre étudiants du même niveau';
  end if;

  if exists(
    select 1 from public.curriculum_friend_challenges c
    where c.program_id = p_program_id
      and c.academic_level_id = v_level_id
      and c.status in ('pending','accepted','in_progress')
      and ((c.challenger_id = v_uid and c.challenged_id = p_friend_id)
        or (c.challenger_id = p_friend_id and c.challenged_id = v_uid))
  ) then
    raise exception 'Un défi est déjà en cours avec cet ami';
  end if;

  select count(*) into v_count
  from public.curriculum_quiz_questions q
  join public.curriculum_topics t on t.id = q.topic_id
  join public.curriculum_units u on u.id = t.unit_id
  where u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.is_active = true
    and t.is_active = true
    and q.is_published = true
    and q.validation_status = 'published';

  if v_count < 10 then
    raise exception 'Pas assez de questions validées pour créer un défi dans ce niveau';
  end if;

  insert into public.curriculum_friend_challenges(
    program_id, academic_level_id, challenger_id, challenged_id
  ) values (
    p_program_id, v_level_id, v_uid, p_friend_id
  ) returning id into v_id;

  insert into public.curriculum_friend_challenge_questions(challenge_id, question_id, display_order)
  select v_id, id, row_number() over(order by random())::integer
  from (
    select q.id
    from public.curriculum_quiz_questions q
    join public.curriculum_topics t on t.id = q.topic_id
    join public.curriculum_units u on u.id = t.unit_id
    where u.program_id = p_program_id
      and u.academic_level_id = v_level_id
      and u.is_active = true
      and t.is_active = true
      and q.is_published = true
      and q.validation_status = 'published'
    order by random()
    limit 10
  ) s;

  select coalesce(p.username::text, p.first_name, 'Un ami')
    into v_username
  from public.profiles p
  where p.id = v_uid;

  select coalesce(p.short_name, p.name, p_program_id)
    into v_program_name
  from public.programs p
  where p.id = p_program_id;

  select al.code into v_level_code
  from public.academic_levels al
  where al.id = v_level_id;

  insert into public.notifications(user_id, type, title, body, data)
  values(
    p_friend_id,
    'challenge_received',
    'Nouveau défi ⚔️',
    v_username || ' te défie sur 10 questions ' || coalesce(v_program_name, p_program_id) || ' · ' || coalesce(v_level_code, 'niveau sélectionné') || '.',
    jsonb_build_object(
      'curriculum_challenge_id', v_id,
      'program_id', p_program_id,
      'academic_level_id', v_level_id
    )
  );

  return v_id;
end;
$function$;

create or replace function public.get_curriculum_friend_challenges_v1(
  p_program_id text default 'ifsi-fr'
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id', c.id,
    'program_id', c.program_id,
    'academic_level_id', c.academic_level_id,
    'level_code', al.code,
    'status', c.status,
    'direction', case when c.challenger_id = v_uid then 'sent' else 'received' end,
    'challenger_id', c.challenger_id,
    'challenged_id', c.challenged_id,
    'challenger_score', c.challenger_score,
    'challenged_score', c.challenged_score,
    'created_at', c.created_at,
    'completed_at', c.completed_at,
    'has_played', case when c.challenger_id = v_uid then c.challenger_score is not null else c.challenged_score is not null end,
    'opponent_has_played', case when c.challenger_id = v_uid then c.challenged_score is not null else c.challenger_score is not null end,
    'my_session_id', null,
    'opponent', jsonb_build_object(
      'id', p.id,
      'username', p.username,
      'first_name', p.first_name,
      'study_year', p.study_year,
      'level', p.level,
      'avatar_url', p.avatar_url
    )
  ) order by c.created_at desc), '[]'::jsonb)
  into v_result
  from public.curriculum_friend_challenges c
  join public.profiles p
    on p.id = case when c.challenger_id = v_uid then c.challenged_id else c.challenger_id end
  left join public.academic_levels al on al.id = c.academic_level_id
  where c.program_id = p_program_id
    and (c.challenger_id = v_uid or c.challenged_id = v_uid);

  return v_result;
end;
$function$;

create or replace function public.get_curriculum_friend_challenge_questions_v1(p_challenge_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;

  if not exists(
    select 1 from public.curriculum_friend_challenges c
    where c.id = p_challenge_id
      and c.status in ('accepted','in_progress','completed')
      and (c.challenger_id = v_uid or c.challenged_id = v_uid)
  ) then
    raise exception 'Défi indisponible';
  end if;

  update public.curriculum_friend_challenges
  set status = 'in_progress'
  where id = p_challenge_id and status = 'accepted';

  select coalesce(jsonb_agg(jsonb_build_object(
    'id', q.id,
    'question_text', q.question_text,
    'options', (
      select jsonb_agg(jsonb_build_object('text', o->>'text'))
      from jsonb_array_elements(q.options) o
    ),
    'display_order', cq.display_order
  ) order by cq.display_order), '[]'::jsonb)
  into v_result
  from public.curriculum_friend_challenge_questions cq
  join public.curriculum_quiz_questions q on q.id = cq.question_id
  where cq.challenge_id = p_challenge_id
    and q.is_published = true
    and q.validation_status = 'published'
    and not exists(
      select 1 from public.curriculum_friend_challenge_answers a
      where a.challenge_id = p_challenge_id
        and a.user_id = v_uid
        and a.question_id = q.id
    );

  return v_result;
end;
$function$;
