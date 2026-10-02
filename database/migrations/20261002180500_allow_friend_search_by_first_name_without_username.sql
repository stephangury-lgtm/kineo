create or replace function public.search_students_v1(p_query text)
returns table(id uuid, username text, first_name text, study_year integer, level integer)
language sql
security definer
set search_path to ''
as $function$
  select p.id, p.username::text, p.first_name, p.study_year, p.level
  from public.profiles p
  where (select auth.uid()) is not null
    and p.id <> (select auth.uid())
    and length(trim(coalesce(p_query, ''))) >= 2
    and (
      coalesce(p.username::text, '') ilike '%' || trim(p_query) || '%'
      or coalesce(p.first_name, '') ilike '%' || trim(p_query) || '%'
    )
  order by
    case when p.username is not null and lower(p.username::text) = lower(trim(p_query)) then 0
         when lower(coalesce(p.first_name,'')) = lower(trim(p_query)) then 1
         else 2 end,
    coalesce(p.username::text,p.first_name,'')
  limit 12;
$function$;
