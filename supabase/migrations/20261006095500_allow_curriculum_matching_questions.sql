alter table public.curriculum_quiz_questions
  drop constraint if exists curriculum_quiz_questions_question_type_check;

alter table public.curriculum_quiz_questions
  add constraint curriculum_quiz_questions_question_type_check
  check (question_type = any (array[
    'mcq'::text,
    'fill_blank'::text,
    'visual_hotspot'::text,
    'clinical_case'::text,
    'matching'::text
  ]));
