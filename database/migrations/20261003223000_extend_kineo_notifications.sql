create or replace function public.notify_badge_earned_v1()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_badge public.badges%rowtype;
begin
  select * into v_badge from public.badges where id = new.badge_id;
  if v_badge.id is not null then
    insert into public.notifications(user_id,type,title,body,data)
    values(
      new.user_id,
      'badge_earned',
      'Nouveau badge ' || coalesce(v_badge.icon,'🏅'),
      'Tu as débloqué « ' || v_badge.name || ' ».' || case when nullif(v_badge.description,'') is not null then ' ' || v_badge.description else '' end,
      jsonb_build_object('badge_id',new.badge_id,'badge_name',v_badge.name)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_badge_earned_v1 on public.user_badges;
create trigger trg_notify_badge_earned_v1
after insert on public.user_badges
for each row execute function public.notify_badge_earned_v1();

create or replace function public.notify_streak_milestone_v1()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
begin
  if new.current_streak in (3,7,14,30,60,100)
     and (tg_op = 'INSERT' or old.current_streak is distinct from new.current_streak) then
    insert into public.notifications(user_id,type,title,body,data)
    values(
      new.user_id,
      'streak_milestone',
      'Série de ' || new.current_streak || ' jours 🔥',
      case
        when new.current_streak = 3 then 'Bon départ : 3 jours de révision consécutifs.'
        when new.current_streak = 7 then 'Une semaine complète de régularité.'
        when new.current_streak = 14 then 'Deux semaines de suite : ta routine est bien installée.'
        when new.current_streak = 30 then '30 jours consécutifs : superbe régularité.'
        when new.current_streak = 60 then '60 jours consécutifs : tu gardes un rythme remarquable.'
        when new.current_streak = 100 then '100 jours consécutifs : cap symbolique atteint !'
      end,
      jsonb_build_object('streak',new.current_streak)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_streak_milestone_v1 on public.user_streaks;
create trigger trg_notify_streak_milestone_v1
after insert or update of current_streak on public.user_streaks
for each row execute function public.notify_streak_milestone_v1();

create or replace function public.notify_level_up_v1()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
begin
  if old.level is not null and new.level > old.level then
    insert into public.notifications(user_id,type,title,body,data)
    values(
      new.id,
      'level_up',
      'Niveau ' || new.level || ' atteint 🎉',
      'Tes révisions t’ont fait progresser d’un niveau.',
      jsonb_build_object('level',new.level,'previous_level',old.level)
    );
  end if;
  return new;
end;
$$;

drop trigger if exists trg_notify_level_up_v1 on public.profiles;
create trigger trg_notify_level_up_v1
after update of level on public.profiles
for each row execute function public.notify_level_up_v1();
