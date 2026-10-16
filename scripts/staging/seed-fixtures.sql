-- STAGING ONLY: synthetic, non-medical examples. No real accounts or documents.
begin;
set local search_path=public,extensions;
do $fixtures$
declare p record; lv record; v_level uuid; v_unit uuid; v_topic uuid;
 v_year uuid; v_subject uuid; v_chapter uuid; v_lesson uuid; v_doc uuid; v_question uuid;
 v_version text; v_code text; i integer; n integer;
begin
 if exists(select 1 from public.programs) then raise exception 'Fixtures require an empty catalog'; end if;
 for p in select * from (values
 ('kineo-fr','Kiné France [TEST]','Kiné France','FR','fr','year',2,5),
 ('kineo-es','Kiné Espagne [TEST]','Kiné Espagne','ES','es','year',1,4),
 ('ifsi-fr','IFSI [TEST]','IFSI','FR','fr','semester',1,6)
 ) x(id,name,short_name,country,lang,kind,first_level,last_level) loop
  insert into public.programs(id,name,short_name,country_code,primary_language,level_kind,status)
  values(p.id,p.name,p.short_name,p.country,p.lang,p.kind,'live');
  for n in p.first_level..p.last_level loop
   v_code:=case p.id when 'kineo-fr' then 'K' when 'kineo-es' then 'ES' else 'S' end||n;
   insert into public.academic_levels(program_id,code,label,level_number,display_order,language)
   values(p.id,v_code,v_code||' [TEST]',n,n,p.lang) returning id into v_level;
   for v_version in select unnest(case when p.id='ifsi-fr' then array['2009','2026'] else array['default'] end) loop
    insert into public.curriculum_units(program_id,academic_level_id,code,name,unit_type,content_language,curriculum_version)
    values(p.id,v_level,'test-basics','Exercices synthétiques [TEST]','subject',p.lang,v_version) returning id into v_unit;
    insert into public.curriculum_topics(unit_id,name,slug,description,content_language)
    values(v_unit,'Calcul simple [TEST]','test-calcul','Données fictives pour vérifier le logiciel ; aucun contenu médical.',p.lang) returning id into v_topic;
    for i in 1..12 loop
     insert into public.curriculum_quiz_questions(topic_id,question_text,explanation,options,source_label,display_order,is_published,validation_status)
     values(v_topic,'[TEST] '||i||' + 1 = ?', 'Exemple synthétique : addition de deux entiers.',
      jsonb_build_array(jsonb_build_object('text',(i+1)::text,'correct',true),jsonb_build_object('text',(i+2)::text,'correct',false)),
      'Fixture logicielle synthétique',i,true,'source_validated');
    end loop;
   end loop;
  end loop;
 end loop;
 for n in 2..5 loop
  insert into public.years(number,name) values(n,'K'||n||' [TEST]') returning id into v_year;
  insert into public.subjects(year_id,name,slug) values(v_year,'Calcul synthétique [TEST]','test-calcul-k'||n) returning id into v_subject;
  insert into public.chapters(subject_id,name,slug) values(v_subject,'Chapitre de recette [TEST]','test-chapitre-k'||n) returning id into v_chapter;
  insert into public.lessons(chapter_id,title,slug,content,is_published,validation_status)
  values(v_chapter,'Cours de recette [TEST]','test-cours-k'||n,'# Document fictif de recette
Ce contenu vérifie le fonctionnement du logiciel. Il ne constitue pas un cours médical.',true,'published') returning id into v_lesson;
  insert into public.course_documents(title,year_id,subject_id,chapter_id,file_name,storage_path,mime_type,document_type,processing_status,validation_status)
  values('Document synthétique K'||n||' [TEST]',v_year,v_subject,v_chapter,'fixture-k'||n||'.pdf','staging-fixtures/k'||n||'.pdf','application/pdf','course','processed','validated') returning id into v_doc;
  insert into public.lesson_sources(lesson_id,document_id) values(v_lesson,v_doc);
  for i in 1..12 loop
   insert into public.questions(chapter_id,lesson_id,type,question_text,explanation,source)
   values(v_chapter,v_lesson,'mcq','[TEST] '||i||' + 1 = ?','Exemple synthétique : addition de deux entiers.','Fixture logicielle synthétique') returning id into v_question;
   insert into public.question_options(question_id,option_text,is_correct,display_order)
   values(v_question,(i+1)::text,true,1),(v_question,(i+2)::text,false,2);
   insert into public.question_sources(question_id,document_id,lesson_id,page_number,source_excerpt)
   values(v_question,v_doc,v_lesson,1,'Addition synthétique : '||i||' + 1 = '||(i+1));
   update public.questions set is_published=true,validation_status='published' where id=v_question;
  end loop;
 end loop;
end;
$fixtures$;
commit;
