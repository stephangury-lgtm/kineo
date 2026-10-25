-- Run after scripts/sql/feedback-oct25.sql; read-only acceptance checks.
begin;

do $check$
declare row record; sample text;
begin
 for row in select * from public.questions where id in ('49a764f4-82d5-4abd-b21e-b432bd3b53a4','dcca0028-46f1-4e73-a505-c11933fa33a7') loop
   foreach sample in array case when row.id='49a764f4-82d5-4abd-b21e-b432bd3b53a4'::uuid then array['crispation','le patient se crispe','un retrait'] else array['graduellement','petit à petit','de manière progressive'] end loop
     if not exists(select 1 from jsonb_array_elements_text(row.metadata->'accepted_answers') a(value) where public.quiz_text_equivalent_v1(sample,a.value)) then raise exception 'Expected alias not accepted: %', sample; end if;
   end loop;
   sample:=case when row.id='49a764f4-82d5-4abd-b21e-b432bd3b53a4'::uuid then 'détente' else 'brutalement' end;
   if exists(select 1 from jsonb_array_elements_text(row.metadata->'accepted_answers') a(value) where public.quiz_text_equivalent_v1(sample,a.value)) then raise exception 'Incorrect answer accepted: %',sample; end if;
 end loop;
end;
$check$;

rollback;
