-- Synthetic conversations only; no real messages or test rows persist.
begin;
set local statement_timeout='45s';
do $test$
declare
 a uuid:=gen_random_uuid(); b uuid:=gen_random_uuid(); outsider uuid:=gen_random_uuid();
 duel uuid; pending_duel uuid; msg uuid; request_id uuid:=gen_random_uuid(); result jsonb;
 rejected boolean; level_id uuid; program text; n integer;
begin
 insert into auth.users(id,email,raw_user_meta_data,raw_app_meta_data) values
 (a,'duel-message-a-'||a||'@example.invalid','{}','{}'),
 (b,'duel-message-b-'||b||'@example.invalid','{}','{}'),
 (outsider,'duel-message-c-'||outsider||'@example.invalid','{}','{}');
 update public.profiles set first_name='Duel fixture' where id in(a,b,outsider);
 insert into public.friendships(requester_id,addressee_id,status) values(a,b,'accepted');
 insert into public.challenges(challenger_id,challenged_id,status,challenger_score,challenged_score,completed_at)
 values(a,b,'completed',80,60,now()) returning id into duel;
 insert into public.challenges(challenger_id,challenged_id,status) values(a,b,'pending') returning id into pending_duel;
 perform set_config('request.jwt.claim.sub',a::text,true); execute 'set local role authenticated';
 result:=public.read_friend_challenge_messages_v1(duel,'kineo-fr');
 if not(result->>'can_send')::boolean or jsonb_array_length(result->'messages')<>0 then raise exception 'Initial thread incorrect'; end if;
 msg:=public.send_friend_challenge_message_v1(duel,'kineo-fr','  Bien joué !  ',request_id);
 if public.send_friend_challenge_message_v1(duel,'kineo-fr','Bien joué !',request_id)<>msg then raise exception 'Retry not idempotent'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Different',request_id); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Reused request accepted different body'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(pending_duel,'kineo-fr','Too soon',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Pending duel can send'; end if;
 rejected:=false; begin perform public.read_friend_challenge_messages_v1(pending_duel,'kineo-fr'); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Pending duel can read'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','  ',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Empty message accepted'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr',repeat('x',241),gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Long message accepted'; end if;
 rejected:=false; begin insert into public.friend_challenge_messages(challenge_id,program_id,sender_id,client_request_id,body)values(duel,'kineo-fr',a,gen_random_uuid(),'Direct'); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Client direct insert permitted'; end if;
 rejected:=false; begin update public.friend_challenge_messages set body='edited' where id=msg; exception when others then rejected:=true; end;
 if not rejected then raise exception 'Client direct update permitted'; end if;
 execute 'reset role';
 if(select count(*) from public.friend_challenge_messages where id=msg)<>1 then raise exception 'Message missing'; end if;
 if(select count(*) from public.notifications where type='challenge_message' and data->>'duel_message_id'=msg::text and user_id=b)<>1 then raise exception 'Missing or duplicated notification'; end if;
 if exists(select 1 from public.notifications where data->>'duel_message_id'=msg::text and body like '%Bien joué%') then raise exception 'Private message preview copied'; end if;
 perform set_config('request.jwt.claim.sub',outsider::text,true); execute 'set local role authenticated';
 if exists(select 1 from public.friend_challenge_messages where id=msg)then raise exception 'Outsider table read'; end if;
 rejected:=false; begin perform public.read_friend_challenge_messages_v1(duel,'kineo-fr'); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Outsider read RPC'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Intrusion',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Outsider send RPC'; end if;
 execute 'reset role';
 perform set_config('request.jwt.claim.sub',b::text,true); execute 'set local role authenticated';
 result:=public.read_friend_challenge_messages_v1(duel,'kineo-fr');
 if jsonb_array_length(result->'messages')<>1 or (result->'messages'->0->>'is_mine')::boolean then raise exception 'Recipient thread incorrect'; end if;
 perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Revanche !',gen_random_uuid());
 execute 'reset role';
 if exists(select 1 from public.notifications where user_id=b and type='challenge_message' and data->>'duel_message_id'=msg::text and read_at is null) then raise exception 'Read notification still unread'; end if;
 perform set_config('request.jwt.claim.sub',a::text,true); execute 'set local role authenticated';
 perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Deux',gen_random_uuid());
 perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Trois',gen_random_uuid());
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Quatre',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Minute rate cap ignored'; end if;
 execute 'reset role';
 update public.friend_challenge_messages set created_at=now()-interval '2 minutes' where sender_id=a;
 insert into public.friend_challenge_messages(challenge_id,program_id,sender_id,client_request_id,body,created_at)
 select duel,'kineo-fr',a,gen_random_uuid(),'Daily limit fixture',now()-interval '3 minutes' from generate_series(1,17);
 execute 'set local role authenticated';
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Daily21',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Daily rate cap ignored'; end if;
 execute 'reset role';
 delete from public.friendships where requester_id=a and addressee_id=b;
 execute 'set local role authenticated'; result:=public.read_friend_challenge_messages_v1(duel,'kineo-fr');
 if(result->>'can_send')::boolean or jsonb_array_length(result->'messages')<>21 then raise exception 'Removed friend history incorrect'; end if;
 rejected:=false; begin perform public.send_friend_challenge_message_v1(duel,'kineo-fr','Removed friend',gen_random_uuid()); exception when others then rejected:=true; end;
 if not rejected then raise exception 'Removed friend can send'; end if;
 execute 'reset role';
 insert into public.friendships(requester_id,addressee_id,status) values(a,b,'accepted');
 -- Both curriculum engines, program isolation and participant-specific views.
 foreach program in array array['kineo-es','ifsi-fr'] loop
  select id into level_id from public.academic_levels where program_id=program order by id limit 1;
  insert into public.curriculum_friend_challenges(program_id,academic_level_id,challenger_id,challenged_id,status,challenger_score,challenged_score,completed_at)
  values(program,level_id,a,b,'completed',50,50,now()) returning id into duel;
  perform set_config('request.jwt.claim.sub',b::text,true); execute 'set local role authenticated';
  msg:=public.send_friend_challenge_message_v1(duel,program,'¡Bien jugado! 📚',gen_random_uuid());
  rejected:=false; begin perform public.read_friend_challenge_messages_v1(duel,'kineo-fr'); exception when others then rejected:=true; end;
  if not rejected then raise exception 'Wrong program read permitted'; end if;
  execute 'reset role'; perform set_config('request.jwt.claim.sub',a::text,true); execute 'set local role authenticated';
  result:=public.read_friend_challenge_messages_v1(duel,program);
  if jsonb_array_length(result->'messages')<>1 or (result->'messages'->0->>'is_mine')::boolean then raise exception 'Curriculum isolation incorrect'; end if;
  execute 'reset role';
 end loop;
 if has_function_privilege('anon','public.send_friend_challenge_message_v1(uuid,text,text,uuid)','EXECUTE')
 or has_function_privilege('anon','public.read_friend_challenge_messages_v1(uuid,text)','EXECUTE')
 or has_table_privilege('anon','public.friend_challenge_messages','SELECT') then raise exception 'Anonymous access allowed'; end if;
 raise notice 'PASS: private conversations, real authenticated roles, all 3 programs, idempotency, notifications, caps and friendship removal';
end;
$test$;
rollback;
