-- Reject explicit polarity/number mismatches; retain reviewed per-question aliases.
DO $guard$ BEGIN
 IF md5(pg_get_functiondef('public.quiz_text_equivalent_v1(text,text)'::regprocedure)) <> '8eab1759d923aa67ec395f12227fe1cc' THEN
  RAISE EXCEPTION 'Concurrent grading function change: review required';
 END IF;
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
  v_given_negative boolean;
  v_expected_negative boolean;
  v_given_numbers text[];
  v_expected_numbers text[];
begin
  if v_given='' or v_expected='' then return false; end if;
  -- Do not let substring/token overlap erase negation or change a number.
  v_given_negative:=v_given ~ '(^| )(pas|non|jamais|aucun|aucune|aucuns|aucunes|sans|ni|absence|absent|absente|no|sin|nunca|ningun|ninguna|ninguno|not|without|never|neither|nor)( |$)';
  v_expected_negative:=v_expected ~ '(^| )(pas|non|jamais|aucun|aucune|aucuns|aucunes|sans|ni|absence|absent|absente|no|sin|nunca|ningun|ninguna|ninguno|not|without|never|neither|nor)( |$)';
  if v_given_negative is distinct from v_expected_negative then return false; end if;
  select pg_catalog.array_agg(pg_catalog.trim_scale(pg_catalog.replace(pg_catalog.replace(m[1],',','.'),'−','-')::numeric)::text order by ord)
    into v_given_numbers
    from pg_catalog.regexp_matches(coalesce(p_given,''),'([-+−]?[0-9]+(?:[.,][0-9]+)?)','g') with ordinality as n(m,ord);
  select pg_catalog.array_agg(pg_catalog.trim_scale(pg_catalog.replace(pg_catalog.replace(m[1],',','.'),'−','-')::numeric)::text order by ord)
    into v_expected_numbers
    from pg_catalog.regexp_matches(coalesce(p_expected,''),'([-+−]?[0-9]+(?:[.,][0-9]+)?)','g') with ordinality as n(m,ord);
  if v_given_numbers is distinct from v_expected_numbers then return false; end if;
  if coalesce(p_given,'') ~ '^\s*[-+−]?[0-9]+([.,][0-9]+)?\s*$' and coalesce(p_expected,'') ~ '^\s*[-+−]?[0-9]+([.,][0-9]+)?\s*$' then return v_given_numbers is not null; end if;
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
  -- Numeric and negative answers require exact normalized text or a reviewed alias.
  if v_given_negative or v_given_numbers is not null then return false; end if;
  if pg_catalog.length(v_g)>=6 and pg_catalog.length(v_e)>=6 and (pg_catalog.strpos(v_e,v_g)>0 or pg_catalog.strpos(v_g,v_e)>0) then return true; end if;
  select pg_catalog.array_agg(distinct w) into v_gw from pg_catalog.unnest(pg_catalog.string_to_array(v_g,' ')) w where pg_catalog.length(w)>=3 and w not in ('les','des','une','dans','pour','avec','sans','sur','sous','que','qui','est','sont','par','aux','ses','son','leur','leurs','cette','cela','comme','entre','plus','moins','cote','doit','etre','afin','tout','tous');
  select pg_catalog.array_agg(distinct w) into v_ew from pg_catalog.unnest(pg_catalog.string_to_array(v_e,' ')) w where pg_catalog.length(w)>=3 and w not in ('les','des','une','dans','pour','avec','sans','sur','sous','que','qui','est','sont','par','aux','ses','son','leur','leurs','cette','cela','comme','entre','plus','moins','cote','doit','etre','afin','tout','tous');
  if v_gw is null or v_ew is null then return false; end if;
  select pg_catalog.count(*) into v_common from pg_catalog.unnest(v_gw) x where x=any(v_ew);
  v_min:=least(pg_catalog.cardinality(v_gw),pg_catalog.cardinality(v_ew));
  return v_min>=2 and v_common::numeric/v_min>=0.80;
end;
$function$;
