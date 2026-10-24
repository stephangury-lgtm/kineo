-- Private post-duel conversations. Client writes only through guarded, idempotent RPCs.
create table public.friend_challenge_messages (
 id uuid primary key default gen_random_uuid(),
 challenge_id uuid references public.challenges(id) on delete cascade,
 curriculum_challenge_id uuid references public.curriculum_friend_challenges(id) on delete cascade,
 program_id text not null references public.programs(id),
 sender_id uuid not null references public.profiles(id) on delete cascade,
 client_request_id uuid not null,
 body text not null check(char_length(body) between 1 and 240),
 created_at timestamptz not null default now(),
 unique(sender_id,client_request_id),
 check((program_id='kineo-fr' and challenge_id is not null and curriculum_challenge_id is null)
 or(program_id in('kineo-es','ifsi-fr') and curriculum_challenge_id is not null and challenge_id is null))
);
create index friend_messages_fr_thread_idx on public.friend_challenge_messages(challenge_id,created_at) where challenge_id is not null;
create index friend_messages_curriculum_thread_idx on public.friend_challenge_messages(curriculum_challenge_id,created_at) where curriculum_challenge_id is not null;
create index friend_messages_sender_time_idx on public.friend_challenge_messages(sender_id,created_at);
create index friend_messages_program_idx on public.friend_challenge_messages(program_id);
alter table public.friend_challenge_messages enable row level security;
revoke all on public.friend_challenge_messages from public,anon,authenticated;
grant select on public.friend_challenge_messages to authenticated;
create policy participants_read_completed_messages on public.friend_challenge_messages for select to authenticated using (
 exists(select 1 from public.challenges c where c.id=challenge_id and c.status='completed' and c.challenger_score is not null and c.challenged_score is not null
 and (select auth.uid()) in(c.challenger_id,c.challenged_id) and sender_id in(c.challenger_id,c.challenged_id))
 or exists(select 1 from public.curriculum_friend_challenges c where c.id=curriculum_challenge_id and c.program_id=friend_challenge_messages.program_id
 and c.status='completed' and c.challenger_score is not null and c.challenged_score is not null
 and (select auth.uid()) in(c.challenger_id,c.challenged_id) and sender_id in(c.challenger_id,c.challenged_id))
);

create function public.read_friend_challenge_messages_v1(p_challenge_id uuid,p_program_id text) returns jsonb
language plpgsql security definer set search_path='' as $function$
declare v_uid uuid:=auth.uid(); v_other uuid; v_messages jsonb; v_can_send boolean;
begin

 if v_uid is null then raise exception 'Connexion requise / Inicia sesión.'; end if;
 if p_program_id='kineo-fr' then
  select case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end into v_other
  from public.challenges c where c.id=p_challenge_id and c.status='completed'
   and c.challenger_score is not null and c.challenged_score is not null and v_uid in(c.challenger_id,c.challenged_id);
 elsif p_program_id in('kineo-es','ifsi-fr') then
  select case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end into v_other
  from public.curriculum_friend_challenges c where c.id=p_challenge_id and c.program_id=p_program_id and c.status='completed'
   and c.challenger_score is not null and c.challenged_score is not null and v_uid in(c.challenger_id,c.challenged_id);
 end if;
 if v_other is null then raise exception 'Discussion réservée aux participants d’un défi terminé / Solo participantes de un reto terminado.'; end if;

 select exists(select f.id from public.friendships f where f.status='accepted' and
 ((f.requester_id=v_uid and f.addressee_id=v_other) or(f.requester_id=v_other and f.addressee_id=v_uid))) into v_can_send;
 update public.notifications set read_at=now() where user_id=v_uid and type='challenge_message' and read_at is null
 and data->>'program_id'=p_program_id and
 (data->>'challenge_id'=p_challenge_id::text or data->>'curriculum_challenge_id'=p_challenge_id::text);
 select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'body',m.body,'is_mine',m.sender_id=v_uid,
 'sender_name',coalesce(nullif(p.first_name,''),p.username,'Ami'),'created_at',m.created_at) order by m.created_at,m.id),'[]'::jsonb)
 into v_messages from (select * from public.friend_challenge_messages
 where program_id=p_program_id and (challenge_id=p_challenge_id or curriculum_challenge_id=p_challenge_id)
 order by created_at desc,id desc limit 100)m join public.profiles p on p.id=m.sender_id;
 return jsonb_build_object('messages',v_messages,'can_send',v_can_send);
end;
$function$;

create function public.send_friend_challenge_message_v1(p_challenge_id uuid,p_program_id text,p_body text,p_request_id uuid) returns uuid
language plpgsql security definer set search_path='' as $function$
declare v_uid uuid:=auth.uid(); v_other uuid; v_body text; v_existing public.friend_challenge_messages%rowtype;
 v_id uuid; v_friendship uuid; v_name text;
begin

 if v_uid is null then raise exception 'Connexion requise / Inicia sesión.'; end if;
 if p_program_id='kineo-fr' then
  select case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end into v_other
  from public.challenges c where c.id=p_challenge_id and c.status='completed'
   and c.challenger_score is not null and c.challenged_score is not null and v_uid in(c.challenger_id,c.challenged_id);
 elsif p_program_id in('kineo-es','ifsi-fr') then
  select case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end into v_other
  from public.curriculum_friend_challenges c where c.id=p_challenge_id and c.program_id=p_program_id and c.status='completed'
   and c.challenger_score is not null and c.challenged_score is not null and v_uid in(c.challenger_id,c.challenged_id);
 end if;
 if v_other is null then raise exception 'Discussion réservée aux participants d’un défi terminé / Solo participantes de un reto terminado.'; end if;

 v_body:=btrim(regexp_replace(p_body,'[[:space:]]+',' ','g'));
 if v_body is null or char_length(v_body) not between 1 and 240 or p_request_id is null then
 raise exception 'Écris entre 1 et 240 caractères / Escribe entre 1 y 240 caracteres.'; end if;
 -- Serialize sender requests across all threads, including retries and rate checks.
 perform 1 from public.profiles where id=v_uid for no key update;
 select * into v_existing from public.friend_challenge_messages where sender_id=v_uid and client_request_id=p_request_id;
 if found then
  if v_existing.program_id=p_program_id and coalesce(v_existing.challenge_id,v_existing.curriculum_challenge_id)=p_challenge_id and v_existing.body=v_body then return v_existing.id; end if;
  raise exception 'Identifiant d’envoi déjà utilisé / Identificador de envío ya utilizado.';
 end if;
 select f.id from public.friendships f where f.status='accepted' and
 ((f.requester_id=v_uid and f.addressee_id=v_other) or(f.requester_id=v_other and f.addressee_id=v_uid)) into v_friendship for share;
 if v_friendship is null then raise exception 'Vous devez encore être amis pour écrire / Debéis seguir siendo amigos para escribir.'; end if;
 if(select count(*) from public.friend_challenge_messages where sender_id=v_uid and created_at>now()-interval '1 minute')>=3 then
 raise exception 'Petite pause : trois messages par minute / Una pausa: tres mensajes por minuto.'; end if;
 if(select count(*) from public.friend_challenge_messages where sender_id=v_uid and program_id=p_program_id
 and(challenge_id=p_challenge_id or curriculum_challenge_id=p_challenge_id) and created_at>now()-interval '24 hours')>=20 then
 raise exception 'Vingt messages par duel en 24 h : place à la revanche ! / Veinte mensajes por duelo en 24 h: ¡hora de la revancha!'; end if;
 insert into public.friend_challenge_messages(challenge_id,curriculum_challenge_id,program_id,sender_id,client_request_id,body)
 values(case when p_program_id='kineo-fr' then p_challenge_id end,case when p_program_id<>'kineo-fr' then p_challenge_id end,p_program_id,v_uid,p_request_id,v_body) returning id into v_id;
 select coalesce(nullif(first_name,''),username,'Ton ami') into v_name from public.profiles where id=v_uid;
 insert into public.notifications(user_id,type,title,body,data) values(v_other,'challenge_message',
 case when p_program_id='kineo-es' then 'Un mensaje después del duelo 💬' else 'Un message d’après-match 💬' end,
 case when p_program_id='kineo-es' then v_name||' te ha dejado unas palabras. ¿Se prepara una revancha?' else v_name||' t’a laissé un petit mot. Une revanche se prépare ?' end,
 jsonb_build_object('duel_message_id',v_id,'program_id',p_program_id)||
 case when p_program_id='kineo-fr' then jsonb_build_object('challenge_id',p_challenge_id) else jsonb_build_object('curriculum_challenge_id',p_challenge_id) end);
 return v_id;
end;
$function$;
revoke all on function public.read_friend_challenge_messages_v1(uuid,text) from public,anon,authenticated;
revoke all on function public.send_friend_challenge_message_v1(uuid,text,text,uuid) from public,anon,authenticated;
grant execute on function public.read_friend_challenge_messages_v1(uuid,text) to authenticated;
grant execute on function public.send_friend_challenge_message_v1(uuid,text,text,uuid) to authenticated;
