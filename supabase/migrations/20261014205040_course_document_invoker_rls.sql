-- The reader already has SELECT under RLS; no elevated execution is necessary.
alter function public.get_course_document_v1(uuid) security invoker;
alter function public.get_course_documents_v1() security invoker;
