DO $normalize$
DECLARE definition text;
BEGIN
 definition:=pg_get_functiondef('public.get_quiz_questions_v4(uuid)'::regprocedure);
 IF md5(definition) NOT IN ('9a20749b26959e4201f487e1d67627de','11b2951ffb09938ddf1c9d644bc4cab1') OR md5(replace(definition,chr(13),''))<>'11b2951ffb09938ddf1c9d644bc4cab1' THEN RAISE EXCEPTION 'Concurrent resume definition change'; END IF;
 IF position(chr(13) in definition)>0 THEN EXECUTE replace(definition,chr(13),''); END IF;
 IF md5(pg_get_functiondef('public.get_quiz_questions_v4(uuid)'::regprocedure))<>'11b2951ffb09938ddf1c9d644bc4cab1' THEN RAISE EXCEPTION 'Normalization failed'; END IF;
END $normalize$;
