-- Restore only this known grading version; do not erase any attempts.
DO $guard$ BEGIN
 IF md5(pg_get_functiondef('public.quiz_text_equivalent_v1(text,text)'::regprocedure)) <> 'f17b04d41335f2485d8e44912fb206c9' THEN RAISE EXCEPTION 'Concurrent grading change: rollback refused'; END IF;
END $guard$;
CREATE OR REPLACE FUNCTION public.quiz_text_equivalent_v1(p_given text, p_expected text)
 RETURNS boolean
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO ''
AS $function$
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
$function$;
