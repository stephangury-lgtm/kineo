create or replace function public.submit_feedback_v1(p_kind text, p_message text, p_page_path text default null::text)
returns uuid
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid:=auth.uid();
  v_id uuid;
  v_message text:=trim(coalesce(p_message,''));
  v_path text:=left(nullif(trim(coalesce(p_page_path,'')),''),500);
  v_recent_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_kind not in ('bug','content','suggestion') then raise exception 'Type de retour invalide'; end if;
  if length(v_message)<10 then raise exception 'Décris ton retour en au moins 10 caractères'; end if;
  if length(v_message)>2000 then raise exception 'Le message doit faire moins de 2000 caractères'; end if;

  select count(*) into v_recent_count
  from public.feedback
  where user_id=v_uid
    and created_at>=now()-interval '1 hour';

  if v_recent_count>=30 then
    raise exception 'Limite de 30 retours par heure atteinte. Réessaie un peu plus tard.';
  end if;

  insert into public.feedback(user_id,kind,message,page_path)
  values(v_uid,p_kind,v_message,v_path)
  returning id into v_id;

  return v_id;
end;
$function$;

revoke all on function public.submit_feedback_v1(text,text,text) from public, anon;
grant execute on function public.submit_feedback_v1(text,text,text) to authenticated, service_role;
