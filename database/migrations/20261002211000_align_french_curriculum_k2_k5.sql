-- Align Kineo with the French IFMK year labels used in the app: K2 to K5.
-- K1 is kept only as an inactive legacy year to preserve historical references.

alter table public.profiles drop constraint if exists profiles_study_year_check;
update public.profiles set study_year = 2 where study_year = 1;
alter table public.profiles add constraint profiles_study_year_check check (study_year between 2 and 5);

alter table public.years drop constraint if exists years_number_check;
alter table public.years add constraint years_number_check check (number between 1 and 5);

update public.years
set is_active = false,
    name = 'K1 (legacy)',
    description = 'Ancienne année masquée du parcours français'
where number = 1;

update public.years set name = 'K2', description = '1re année du parcours IFMK affiché dans Kineo' where number = 2;
update public.years set name = 'K3', description = '2e année du parcours IFMK affiché dans Kineo' where number = 3;
update public.years set name = 'K4', description = '3e année du parcours IFMK affiché dans Kineo' where number = 4;

insert into public.years(id, number, name, description, is_active)
select gen_random_uuid(), 5, 'K5', '4e année du parcours IFMK affiché dans Kineo', true
where not exists (select 1 from public.years where number = 5);

create or replace function public.update_study_profile_v1(p_first_name text, p_username text, p_study_year integer)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := auth.uid();
  v_old_year integer;
  v_username text := nullif(trim(coalesce(p_username, '')), '');
  v_first_name text := nullif(trim(coalesce(p_first_name, '')), '');
  v_row public.profiles%rowtype;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_study_year not between 2 and 5 then raise exception 'Année d’étude invalide'; end if;
  if v_username is not null and (length(v_username) < 3 or length(v_username) > 24 or v_username !~ '^[A-Za-z0-9._-]+$') then
    raise exception 'Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore';
  end if;

  select study_year into v_old_year from public.profiles where id = v_uid for update;
  if not found then raise exception 'Profil introuvable'; end if;

  begin
    update public.profiles
    set first_name = v_first_name,
        username = v_username,
        study_year = p_study_year,
        updated_at = now()
    where id = v_uid
    returning * into v_row;
  exception when unique_violation then
    raise exception 'Ce pseudo est déjà utilisé';
  end;

  if v_old_year is distinct from p_study_year then
    update public.revision_sessions
    set abandoned_at = coalesce(abandoned_at, now())
    where user_id = v_uid
      and completed_at is null
      and abandoned_at is null
      and challenge_id is null;
  end if;

  return jsonb_build_object(
    'id', v_row.id,
    'first_name', v_row.first_name,
    'username', v_row.username::text,
    'avatar_url', v_row.avatar_url,
    'study_year', v_row.study_year
  );
end;
$function$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  generated_username text;
begin
  generated_username := coalesce(new.raw_user_meta_data ->> 'username', 'user_' || substr(new.id::text, 1, 8));

  insert into public.profiles (id, first_name, username, study_year)
  values (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    generated_username,
    case
      when (new.raw_user_meta_data ->> 'study_year') ~ '^[2-5]$'
      then (new.raw_user_meta_data ->> 'study_year')::integer
      else null
    end
  )
  on conflict (id) do nothing;

  insert into public.user_streaks (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$function$;
