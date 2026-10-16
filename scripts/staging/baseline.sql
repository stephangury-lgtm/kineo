-- STAGING ONLY. Target: cyzdivbdgpvhwpmikeqh. No production rows, secrets, jobs or extensions copied.
-- External mail/worker invocation routines are disabled explicitly below.
SET search_path = public, extensions;
SET check_function_bodies = false;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA extensions;
CREATE SCHEMA IF NOT EXISTS "public";
REVOKE ALL ON SCHEMA "public" FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;
CREATE SCHEMA IF NOT EXISTS "private";
REVOKE ALL ON SCHEMA "private" FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "private" REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "private" REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;
CREATE SCHEMA IF NOT EXISTS "app_security";
REVOKE ALL ON SCHEMA "app_security" FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_security" REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "app_security" REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;
CREATE SCHEMA IF NOT EXISTS "kineo_internal";
REVOKE ALL ON SCHEMA "kineo_internal" FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "kineo_internal" REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "kineo_internal" REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;
CREATE SCHEMA IF NOT EXISTS "retention";
REVOKE ALL ON SCHEMA "retention" FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "retention" REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "retention" REVOKE ALL ON FUNCTIONS FROM PUBLIC, anon, authenticated, service_role;
CREATE TABLE "app_security"."operations_health_status" (
 "id" smallint NOT NULL,
 "payload" jsonb NOT NULL,
 "checked_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "app_security"."operations_health_status" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "app_security"."request_windows" (
 "user_id" uuid NOT NULL,
 "action" text NOT NULL,
 "window_start" timestamp with time zone NOT NULL,
 "requests" integer NOT NULL
);
ALTER TABLE "app_security"."request_windows" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "private"."weekly_friend_email_queue" (
 "id" bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
 "user_id" uuid NOT NULL,
 "program_id" text NOT NULL,
 "week_start" date NOT NULL,
 "payload" jsonb NOT NULL,
 "status" text DEFAULT 'pending'::text NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "sent_at" timestamp with time zone
);
CREATE TABLE "public"."academic_levels" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "program_id" text NOT NULL,
 "code" text NOT NULL,
 "label" text NOT NULL,
 "level_number" integer NOT NULL,
 "display_order" integer DEFAULT 0 NOT NULL,
 "language" text NOT NULL,
 "secondary_language" text,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."academic_levels" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."anatomy_visual_assets" (
 "asset_key" text NOT NULL,
 "mime_type" text DEFAULT 'image/webp'::text NOT NULL,
 "data_base64" text NOT NULL,
 "source_title" text NOT NULL,
 "source_page" integer NOT NULL,
 "crop_label" text,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."anatomy_visual_assets" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."atlas_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "session_id" uuid NOT NULL,
 "area" text NOT NULL,
 "question_count" integer NOT NULL,
 "correct_count" integer NOT NULL,
 "accuracy_percent" integer NOT NULL,
 "duration_ms" integer NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."atlas_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."authenticated_contract_status" (
 "id" smallint NOT NULL,
 "payload" jsonb NOT NULL,
 "checked_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."authenticated_contract_status" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."badges" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "name" text NOT NULL,
 "description" text,
 "icon" text,
 "condition_type" text NOT NULL,
 "condition_value" jsonb DEFAULT '{}'::jsonb NOT NULL
);
ALTER TABLE "public"."badges" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."business_health_status" (
 "id" smallint NOT NULL,
 "payload" jsonb NOT NULL,
 "checked_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."business_health_status" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."challenge_questions" (
 "challenge_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "display_order" integer NOT NULL
);
ALTER TABLE "public"."challenge_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."challenges" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "challenger_id" uuid NOT NULL,
 "challenged_id" uuid NOT NULL,
 "status" text DEFAULT 'pending'::text NOT NULL,
 "challenger_score" integer,
 "challenged_score" integer,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "completed_at" timestamp with time zone
);
ALTER TABLE "public"."challenges" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."chapters" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "subject_id" uuid NOT NULL,
 "name" text NOT NULL,
 "slug" text NOT NULL,
 "description" text,
 "display_order" integer DEFAULT 0 NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."chapters" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."client_error_logs" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "message" text NOT NULL,
 "component_stack" text,
 "page_path" text,
 "app_version" text,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."client_error_logs" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."course_documents" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "title" text NOT NULL,
 "year_id" uuid,
 "subject_id" uuid,
 "chapter_id" uuid,
 "file_name" text NOT NULL,
 "storage_path" text NOT NULL,
 "mime_type" text,
 "file_size" bigint,
 "document_type" text DEFAULT 'course'::text NOT NULL,
 "processing_status" text DEFAULT 'uploaded'::text NOT NULL,
 "validation_status" text DEFAULT 'draft'::text NOT NULL,
 "uploaded_by" uuid,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "file_sha256" text
);
ALTER TABLE "public"."course_documents" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_daily_challenge_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "program_id" text NOT NULL,
 "challenge_date" date DEFAULT CURRENT_DATE NOT NULL,
 "question_ids" uuid[] NOT NULL,
 "answered_ids" uuid[] DEFAULT '{}'::uuid[] NOT NULL,
 "correct_count" integer DEFAULT 0 NOT NULL,
 "total_questions" integer DEFAULT 5 NOT NULL,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "completed_at" timestamp with time zone
);
ALTER TABLE "public"."curriculum_daily_challenge_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_friend_challenge_answers" (
 "challenge_id" uuid NOT NULL,
 "user_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "answer_text" text NOT NULL,
 "is_correct" boolean NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."curriculum_friend_challenge_answers" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_friend_challenge_questions" (
 "challenge_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "display_order" integer NOT NULL
);
ALTER TABLE "public"."curriculum_friend_challenge_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_friend_challenges" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "program_id" text NOT NULL,
 "challenger_id" uuid NOT NULL,
 "challenged_id" uuid NOT NULL,
 "status" text DEFAULT 'pending'::text NOT NULL,
 "challenger_score" integer,
 "challenged_score" integer,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "completed_at" timestamp with time zone,
 "academic_level_id" uuid
);
ALTER TABLE "public"."curriculum_friend_challenges" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_lessons" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "topic_id" uuid NOT NULL,
 "title" text NOT NULL,
 "summary" text,
 "content" text NOT NULL,
 "key_points" jsonb DEFAULT '[]'::jsonb NOT NULL,
 "source_files" jsonb DEFAULT '[]'::jsonb NOT NULL,
 "display_order" integer DEFAULT 1 NOT NULL,
 "validation_status" text DEFAULT 'source_validated'::text NOT NULL,
 "is_published" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."curriculum_lessons" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_question_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "topic_id" uuid NOT NULL,
 "answer_text" text NOT NULL,
 "is_correct" boolean NOT NULL,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."curriculum_question_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_quiz_questions" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "topic_id" uuid NOT NULL,
 "question_text" text NOT NULL,
 "explanation" text,
 "options" jsonb NOT NULL,
 "difficulty" smallint DEFAULT 1 NOT NULL,
 "source_label" text,
 "display_order" integer DEFAULT 1 NOT NULL,
 "validation_status" text DEFAULT 'source_validated'::text NOT NULL,
 "is_published" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "question_type" text DEFAULT 'mcq'::text NOT NULL,
 "accepted_answers" jsonb DEFAULT '[]'::jsonb NOT NULL,
 "image_url" text,
 "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL
);
ALTER TABLE "public"."curriculum_quiz_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_topic_completions" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "topic_id" uuid NOT NULL,
 "score_percent" integer DEFAULT 0 NOT NULL,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "completed_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."curriculum_topic_completions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_topics" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "unit_id" uuid NOT NULL,
 "name" text NOT NULL,
 "slug" text NOT NULL,
 "description" text,
 "display_order" integer DEFAULT 0 NOT NULL,
 "content_language" text NOT NULL,
 "translation_language" text,
 "translation_mode" text DEFAULT 'none'::text NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."curriculum_topics" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."curriculum_units" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "program_id" text NOT NULL,
 "academic_level_id" uuid NOT NULL,
 "code" text,
 "name" text NOT NULL,
 "unit_type" text DEFAULT 'subject'::text NOT NULL,
 "description" text,
 "icon" text,
 "display_order" integer DEFAULT 0 NOT NULL,
 "content_language" text NOT NULL,
 "translation_language" text,
 "translation_mode" text DEFAULT 'none'::text NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "curriculum_version" text DEFAULT 'default'::text NOT NULL
);
ALTER TABLE "public"."curriculum_units" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."daily_challenge_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "challenge_id" uuid NOT NULL,
 "user_id" uuid NOT NULL,
 "score" integer DEFAULT 0 NOT NULL,
 "total_questions" integer DEFAULT 10 NOT NULL,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "completed_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."daily_challenge_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."daily_challenge_questions" (
 "challenge_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "display_order" integer NOT NULL
);
ALTER TABLE "public"."daily_challenge_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."daily_challenges" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "challenge_date" date NOT NULL,
 "title" text NOT NULL,
 "description" text,
 "xp_reward" integer DEFAULT 100 NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "study_year" integer
);
ALTER TABLE "public"."daily_challenges" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."exam_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "exam_id" uuid NOT NULL,
 "user_id" uuid NOT NULL,
 "score" numeric(5,2),
 "correct_count" integer DEFAULT 0 NOT NULL,
 "total_questions" integer DEFAULT 0 NOT NULL,
 "duration_seconds" integer,
 "started_at" timestamp with time zone DEFAULT now() NOT NULL,
 "completed_at" timestamp with time zone
);
ALTER TABLE "public"."exam_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."exam_questions" (
 "exam_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "display_order" integer DEFAULT 0 NOT NULL
);
ALTER TABLE "public"."exam_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."exams" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "year_id" uuid,
 "title" text NOT NULL,
 "description" text,
 "duration_seconds" integer,
 "question_count" integer DEFAULT 0 NOT NULL,
 "passing_score" numeric(5,2),
 "is_published" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."exams" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."favorites" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "content_type" text NOT NULL,
 "content_id" uuid NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."favorites" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."feedback" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "kind" text NOT NULL,
 "message" text NOT NULL,
 "page_path" text,
 "status" text DEFAULT 'new'::text NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."feedback" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."friendships" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "requester_id" uuid NOT NULL,
 "addressee_id" uuid NOT NULL,
 "status" text DEFAULT 'pending'::text NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."friendships" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."inactivity_email_log" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "inactivity_anchor" timestamp with time zone NOT NULL,
 "queued_at" timestamp with time zone DEFAULT now() NOT NULL,
 "provider" text DEFAULT 'resend'::text NOT NULL,
 "provider_request_id" text,
 "status" text DEFAULT 'queued'::text NOT NULL,
 "error_message" text,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."inactivity_email_log" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."inactivity_email_preferences" (
 "user_id" uuid NOT NULL,
 "opted_in" boolean DEFAULT false NOT NULL,
 "opted_out_at" timestamp with time zone,
 "opted_in_at" timestamp with time zone,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."inactivity_email_preferences" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."lesson_sources" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "lesson_id" uuid NOT NULL,
 "document_id" uuid NOT NULL,
 "page_start" integer,
 "page_end" integer,
 "source_excerpt" text,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."lesson_sources" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."lessons" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "chapter_id" uuid NOT NULL,
 "title" text NOT NULL,
 "slug" text NOT NULL,
 "content" text,
 "summary" text,
 "key_points" jsonb DEFAULT '[]'::jsonb NOT NULL,
 "sources" jsonb DEFAULT '[]'::jsonb NOT NULL,
 "image_url" text,
 "display_order" integer DEFAULT 0 NOT NULL,
 "is_published" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "validation_status" text DEFAULT 'draft'::text NOT NULL,
 "source_document" text,
 "validated_at" timestamp with time zone,
 "validated_by" uuid
);
ALTER TABLE "public"."lessons" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."levels" (
 "level" integer NOT NULL,
 "name" text NOT NULL,
 "required_xp" integer NOT NULL,
 "icon" text
);
ALTER TABLE "public"."levels" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."notifications" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "type" text NOT NULL,
 "title" text NOT NULL,
 "body" text,
 "data" jsonb DEFAULT '{}'::jsonb NOT NULL,
 "read_at" timestamp with time zone,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."profile_programs" (
 "user_id" uuid NOT NULL,
 "program_id" text NOT NULL,
 "academic_level_id" uuid,
 "is_primary" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "curriculum_version" text DEFAULT 'default'::text NOT NULL
);
ALTER TABLE "public"."profile_programs" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."profiles" (
 "id" uuid NOT NULL,
 "first_name" text,
 "username" citext,
 "avatar_url" text,
 "study_year" integer,
 "role" text DEFAULT 'student'::text NOT NULL,
 "xp" integer DEFAULT 0 NOT NULL,
 "level" integer DEFAULT 1 NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "last_seen_at" timestamp with time zone,
 "last_app_open_at" timestamp with time zone
);
ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."programs" (
 "id" text NOT NULL,
 "name" text NOT NULL,
 "short_name" text NOT NULL,
 "country_code" text NOT NULL,
 "primary_language" text NOT NULL,
 "secondary_language" text,
 "level_kind" text NOT NULL,
 "status" text DEFAULT 'foundation'::text NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."programs" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."question_attempts" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "session_id" uuid,
 "answer" jsonb,
 "is_correct" boolean DEFAULT false NOT NULL,
 "response_time_ms" integer,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."question_attempts" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."question_options" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "question_id" uuid NOT NULL,
 "option_text" text NOT NULL,
 "is_correct" boolean DEFAULT false NOT NULL,
 "display_order" integer DEFAULT 0 NOT NULL
);
ALTER TABLE "public"."question_options" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."question_sources" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "question_id" uuid NOT NULL,
 "document_id" uuid NOT NULL,
 "lesson_id" uuid,
 "page_number" integer,
 "source_excerpt" text,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."question_sources" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."questions" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "chapter_id" uuid NOT NULL,
 "lesson_id" uuid,
 "type" text NOT NULL,
 "question_text" text NOT NULL,
 "explanation" text,
 "difficulty" integer DEFAULT 2 NOT NULL,
 "image_url" text,
 "metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
 "source" text,
 "is_published" boolean DEFAULT false NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL,
 "validation_status" text DEFAULT 'draft'::text NOT NULL,
 "source_document" text,
 "validated_at" timestamp with time zone,
 "validated_by" uuid
);
ALTER TABLE "public"."questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."release_health_status" (
 "id" smallint NOT NULL,
 "payload" jsonb NOT NULL,
 "checked_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."release_health_status" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."revision_session_questions" (
 "session_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "display_order" integer NOT NULL,
 "answered_at" timestamp with time zone
);
ALTER TABLE "public"."revision_session_questions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."revision_sessions" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "mode" text NOT NULL,
 "question_count" integer DEFAULT 0 NOT NULL,
 "correct_count" integer DEFAULT 0 NOT NULL,
 "xp_earned" integer DEFAULT 0 NOT NULL,
 "started_at" timestamp with time zone DEFAULT now() NOT NULL,
 "completed_at" timestamp with time zone,
 "daily_challenge_id" uuid,
 "challenge_id" uuid,
 "abandoned_at" timestamp with time zone
);
ALTER TABLE "public"."revision_sessions" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."security_health_status" (
 "id" smallint NOT NULL,
 "payload" jsonb NOT NULL,
 "checked_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."security_health_status" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."subjects" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "year_id" uuid NOT NULL,
 "name" text NOT NULL,
 "slug" text NOT NULL,
 "description" text,
 "icon" text,
 "display_order" integer DEFAULT 0 NOT NULL,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."subjects" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."user_badges" (
 "user_id" uuid NOT NULL,
 "badge_id" uuid NOT NULL,
 "earned_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."user_badges" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."user_notes" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "lesson_id" uuid,
 "question_id" uuid,
 "content" text NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."user_notes" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."user_question_mastery" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "question_id" uuid NOT NULL,
 "mastery_score" integer DEFAULT 0 NOT NULL,
 "attempt_count" integer DEFAULT 0 NOT NULL,
 "correct_count" integer DEFAULT 0 NOT NULL,
 "last_attempt_at" timestamp with time zone,
 "next_review_at" timestamp with time zone,
 "mastery_percent" integer DEFAULT 0 NOT NULL,
 "interval_days" integer DEFAULT 1 NOT NULL,
 "consecutive_correct" integer DEFAULT 0 NOT NULL,
 "lapse_count" integer DEFAULT 0 NOT NULL,
 "ease_factor" numeric(4,2) DEFAULT 2.50 NOT NULL
);
ALTER TABLE "public"."user_question_mastery" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."user_streaks" (
 "user_id" uuid NOT NULL,
 "current_streak" integer DEFAULT 0 NOT NULL,
 "longest_streak" integer DEFAULT 0 NOT NULL,
 "last_activity_date" date,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."user_streaks" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."visual_asset_bundle_chunks" (
 "bundle_id" text NOT NULL,
 "seq" integer NOT NULL,
 "payload" text NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."visual_asset_bundle_chunks" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."visual_reviewers" (
 "user_id" uuid NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL,
 "created_by" uuid
);
ALTER TABLE "public"."visual_reviewers" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."weekly_friend_email_preferences" (
 "user_id" uuid NOT NULL,
 "opted_in" boolean DEFAULT false NOT NULL,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."weekly_friend_email_preferences" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "public"."years" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "number" integer NOT NULL,
 "name" text NOT NULL,
 "description" text,
 "is_active" boolean DEFAULT true NOT NULL,
 "created_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "public"."years" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "retention"."invocations" (
 "token_hash" text NOT NULL,
 "expires_at" timestamp with time zone NOT NULL
);
ALTER TABLE "retention"."invocations" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "retention"."notices" (
 "id" uuid DEFAULT gen_random_uuid() NOT NULL,
 "user_id" uuid NOT NULL,
 "anchor" timestamp with time zone NOT NULL,
 "recipient" text NOT NULL,
 "state" text DEFAULT 'pending'::text NOT NULL,
 "started_at" timestamp with time zone,
 "provider_id" text,
 "delivered_at" timestamp with time zone,
 "delete_after" timestamp with time zone,
 "hold_reason" text,
 "updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE "retention"."notices" ENABLE ROW LEVEL SECURITY;
CREATE TABLE "retention"."worker" (
 "id" boolean DEFAULT true NOT NULL,
 "lease" uuid,
 "lease_until" timestamp with time zone,
 "last_run_at" timestamp with time zone,
 "last_result" jsonb
);
ALTER TABLE "retention"."worker" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_type_check" CHECK (type = ANY (ARRAY['mcq'::text, 'true_false'::text, 'fill_blank'::text, 'matching'::text, 'image'::text, 'hotspot'::text, 'short_answer'::text, 'clinical_case'::text, 'translation'::text]));
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_difficulty_check" CHECK (difficulty >= 1 AND difficulty <= 5);
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."question_options" ADD CONSTRAINT "question_options_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."levels" ADD CONSTRAINT "levels_required_xp_check" CHECK (required_xp >= 0);
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_role_check" CHECK (role = ANY (ARRAY['student'::text, 'admin'::text]));
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_xp_check" CHECK (xp >= 0);
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_level_check" CHECK (level >= 1);
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_username_key" UNIQUE (username);
ALTER TABLE "public"."years" ADD CONSTRAINT "years_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."years" ADD CONSTRAINT "years_number_key" UNIQUE (number);
ALTER TABLE "public"."subjects" ADD CONSTRAINT "subjects_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."subjects" ADD CONSTRAINT "subjects_year_id_slug_key" UNIQUE (year_id, slug);
ALTER TABLE "public"."chapters" ADD CONSTRAINT "chapters_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."chapters" ADD CONSTRAINT "chapters_subject_id_slug_key" UNIQUE (subject_id, slug);
ALTER TABLE "public"."lessons" ADD CONSTRAINT "lessons_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."lessons" ADD CONSTRAINT "lessons_chapter_id_slug_key" UNIQUE (chapter_id, slug);
ALTER TABLE "public"."revision_sessions" ADD CONSTRAINT "revision_sessions_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."question_attempts" ADD CONSTRAINT "question_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_mastery_score_check" CHECK (mastery_score >= 0 AND mastery_score <= 4);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_user_id_question_id_key" UNIQUE (user_id, question_id);
ALTER TABLE "public"."exams" ADD CONSTRAINT "exams_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."exam_questions" ADD CONSTRAINT "exam_questions_pkey" PRIMARY KEY (exam_id, question_id);
ALTER TABLE "public"."exam_questions" ADD CONSTRAINT "exam_questions_exam_id_display_order_key" UNIQUE (exam_id, display_order);
ALTER TABLE "public"."exam_attempts" ADD CONSTRAINT "exam_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."daily_challenges" ADD CONSTRAINT "daily_challenges_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."daily_challenge_questions" ADD CONSTRAINT "daily_challenge_questions_pkey" PRIMARY KEY (challenge_id, question_id);
ALTER TABLE "public"."daily_challenge_questions" ADD CONSTRAINT "daily_challenge_questions_challenge_id_display_order_key" UNIQUE (challenge_id, display_order);
ALTER TABLE "public"."daily_challenge_attempts" ADD CONSTRAINT "daily_challenge_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."daily_challenge_attempts" ADD CONSTRAINT "daily_challenge_attempts_challenge_id_user_id_key" UNIQUE (challenge_id, user_id);
ALTER TABLE "public"."user_streaks" ADD CONSTRAINT "user_streaks_pkey" PRIMARY KEY (user_id);
ALTER TABLE "public"."levels" ADD CONSTRAINT "levels_pkey" PRIMARY KEY (level);
ALTER TABLE "public"."badges" ADD CONSTRAINT "badges_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."badges" ADD CONSTRAINT "badges_name_key" UNIQUE (name);
ALTER TABLE "public"."user_badges" ADD CONSTRAINT "user_badges_pkey" PRIMARY KEY (user_id, badge_id);
ALTER TABLE "public"."favorites" ADD CONSTRAINT "favorites_content_type_check" CHECK (content_type = ANY (ARRAY['lesson'::text, 'question'::text]));
ALTER TABLE "public"."favorites" ADD CONSTRAINT "favorites_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."favorites" ADD CONSTRAINT "favorites_user_id_content_type_content_id_key" UNIQUE (user_id, content_type, content_id);
ALTER TABLE "public"."user_notes" ADD CONSTRAINT "user_notes_check" CHECK (lesson_id IS NOT NULL AND question_id IS NULL OR lesson_id IS NULL AND question_id IS NOT NULL);
ALTER TABLE "public"."user_notes" ADD CONSTRAINT "user_notes_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."friendships" ADD CONSTRAINT "friendships_status_check" CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text, 'blocked'::text]));
ALTER TABLE "public"."friendships" ADD CONSTRAINT "friendships_check" CHECK (requester_id <> addressee_id);
ALTER TABLE "public"."friendships" ADD CONSTRAINT "friendships_pkey" PRIMARY KEY (id);
ALTER TABLE "retention"."invocations" ADD CONSTRAINT "invocations_pkey" PRIMARY KEY (token_hash);
ALTER TABLE "public"."challenges" ADD CONSTRAINT "challenges_status_check" CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'in_progress'::text, 'completed'::text, 'declined'::text, 'cancelled'::text]));
ALTER TABLE "public"."challenges" ADD CONSTRAINT "challenges_check" CHECK (challenger_id <> challenged_id);
ALTER TABLE "public"."challenges" ADD CONSTRAINT "challenges_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."challenge_questions" ADD CONSTRAINT "challenge_questions_pkey" PRIMARY KEY (challenge_id, question_id);
ALTER TABLE "public"."challenge_questions" ADD CONSTRAINT "challenge_questions_challenge_id_display_order_key" UNIQUE (challenge_id, display_order);
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."revision_session_questions" ADD CONSTRAINT "revision_session_questions_pkey" PRIMARY KEY (session_id, question_id);
ALTER TABLE "public"."revision_session_questions" ADD CONSTRAINT "revision_session_questions_session_id_display_order_key" UNIQUE (session_id, display_order);
ALTER TABLE "public"."lessons" ADD CONSTRAINT "lessons_validation_status_check" CHECK (validation_status = ANY (ARRAY['draft'::text, 'review'::text, 'validated'::text, 'published'::text, 'archived'::text]));
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_validation_status_check" CHECK (validation_status = ANY (ARRAY['draft'::text, 'review'::text, 'validated'::text, 'published'::text, 'archived'::text]));
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_document_type_check" CHECK (document_type = ANY (ARRAY['course'::text, 'lecture_notes'::text, 'revision_sheet'::text, 'exercise'::text, 'exam'::text, 'correction'::text, 'reference'::text, 'other'::text]));
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_processing_status_check" CHECK (processing_status = ANY (ARRAY['uploaded'::text, 'processing'::text, 'processed'::text, 'error'::text]));
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_validation_status_check" CHECK (validation_status = ANY (ARRAY['draft'::text, 'review'::text, 'validated'::text, 'archived'::text]));
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_page_start_check" CHECK (page_start IS NULL OR page_start > 0);
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_page_end_check" CHECK (page_end IS NULL OR page_end > 0);
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_check" CHECK (page_start IS NULL OR page_end IS NULL OR page_end >= page_start);
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_lesson_id_document_id_page_start_page_end_key" UNIQUE (lesson_id, document_id, page_start, page_end);
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_page_number_check" CHECK (page_number IS NULL OR page_number > 0);
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_question_id_document_id_page_number_key" UNIQUE (question_id, document_id, page_number);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_mastery_percent_check" CHECK (mastery_percent >= 0 AND mastery_percent <= 100);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_interval_days_check" CHECK (interval_days >= 1 AND interval_days <= 365);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_consecutive_correct_check" CHECK (consecutive_correct >= 0);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_lapse_count_check" CHECK (lapse_count >= 0);
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_ease_factor_check" CHECK (ease_factor >= 1.30 AND ease_factor <= 3.00);
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_area_check" CHECK (area = ANY (ARRAY['Hanche'::text, 'Genou'::text, 'Cheville'::text, 'Pied'::text]));
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_counts_check" CHECK (question_count >= 0 AND correct_count >= 0 AND correct_count <= question_count);
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_accuracy_check" CHECK (accuracy_percent >= 0 AND accuracy_percent <= 100);
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_duration_check" CHECK (duration_ms >= 0);
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_session_id_key" UNIQUE (session_id);
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."daily_challenges" ADD CONSTRAINT "daily_challenges_study_year_check" CHECK (study_year >= 1 AND study_year <= 4);
ALTER TABLE "public"."feedback" ADD CONSTRAINT "feedback_kind_check" CHECK (kind = ANY (ARRAY['bug'::text, 'content'::text, 'suggestion'::text]));
ALTER TABLE "public"."feedback" ADD CONSTRAINT "feedback_status_check" CHECK (status = ANY (ARRAY['new'::text, 'reviewed'::text, 'resolved'::text]));
ALTER TABLE "public"."feedback" ADD CONSTRAINT "feedback_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_topic_id_display_order_key" UNIQUE (topic_id, display_order);
ALTER TABLE "public"."years" ADD CONSTRAINT "years_number_check" CHECK (number >= 1 AND number <= 5);
ALTER TABLE "public"."revision_sessions" ADD CONSTRAINT "revision_sessions_mode_check" CHECK (mode = ANY (ARRAY['smart'::text, 'mix'::text, 'mcq'::text, 'true_false'::text, 'fill_blank'::text, 'matching'::text, 'visual'::text, 'clinical_case'::text, 'translation'::text, 'exam'::text, 'daily'::text, 'weak'::text]));
ALTER TABLE "public"."programs" ADD CONSTRAINT "programs_level_kind_check" CHECK (level_kind = ANY (ARRAY['year'::text, 'semester'::text]));
ALTER TABLE "public"."programs" ADD CONSTRAINT "programs_status_check" CHECK (status = ANY (ARRAY['live'::text, 'foundation'::text]));
ALTER TABLE "public"."programs" ADD CONSTRAINT "programs_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."academic_levels" ADD CONSTRAINT "academic_levels_level_number_check" CHECK (level_number > 0);
ALTER TABLE "public"."academic_levels" ADD CONSTRAINT "academic_levels_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."academic_levels" ADD CONSTRAINT "academic_levels_program_id_code_key" UNIQUE (program_id, code);
ALTER TABLE "public"."profile_programs" ADD CONSTRAINT "profile_programs_pkey" PRIMARY KEY (user_id, program_id);
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_unit_type_check" CHECK (unit_type = ANY (ARRAY['subject'::text, 'ue'::text, 'module'::text]));
ALTER TABLE "public"."curriculum_question_attempts" ADD CONSTRAINT "curriculum_question_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_translation_mode_check" CHECK (translation_mode = ANY (ARRAY['none'::text, 'vocabulary'::text, 'bilingual'::text]));
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_topics" ADD CONSTRAINT "curriculum_topics_translation_mode_check" CHECK (translation_mode = ANY (ARRAY['none'::text, 'vocabulary'::text, 'bilingual'::text]));
ALTER TABLE "public"."curriculum_topics" ADD CONSTRAINT "curriculum_topics_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_topics" ADD CONSTRAINT "curriculum_topics_unit_id_slug_key" UNIQUE (unit_id, slug);
ALTER TABLE "public"."anatomy_visual_assets" ADD CONSTRAINT "anatomy_visual_assets_pkey" PRIMARY KEY (asset_key);
ALTER TABLE "public"."visual_asset_bundle_chunks" ADD CONSTRAINT "visual_asset_bundle_chunks_pkey" PRIMARY KEY (bundle_id, seq);
ALTER TABLE "public"."curriculum_lessons" ADD CONSTRAINT "curriculum_lessons_validation_status_check" CHECK (validation_status = ANY (ARRAY['draft'::text, 'source_validated'::text, 'review'::text, 'published'::text]));
ALTER TABLE "public"."curriculum_lessons" ADD CONSTRAINT "curriculum_lessons_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_lessons" ADD CONSTRAINT "curriculum_lessons_topic_id_display_order_key" UNIQUE (topic_id, display_order);
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_difficulty_check" CHECK (difficulty >= 1 AND difficulty <= 5);
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_validation_status_check" CHECK (validation_status = ANY (ARRAY['draft'::text, 'source_validated'::text, 'review'::text, 'published'::text]));
ALTER TABLE "public"."curriculum_topic_completions" ADD CONSTRAINT "curriculum_topic_completions_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_topic_completions" ADD CONSTRAINT "curriculum_topic_completions_user_id_topic_id_key" UNIQUE (user_id, topic_id);
ALTER TABLE "public"."curriculum_daily_challenge_attempts" ADD CONSTRAINT "curriculum_daily_challenge_attempts_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_daily_challenge_attempts" ADD CONSTRAINT "curriculum_daily_challenge_at_user_id_program_id_challenge__key" UNIQUE (user_id, program_id, challenge_date);
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_status_check" CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'in_progress'::text, 'completed'::text, 'declined'::text, 'cancelled'::text]));
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."curriculum_friend_challenge_questions" ADD CONSTRAINT "curriculum_friend_challenge_questions_pkey" PRIMARY KEY (challenge_id, question_id);
ALTER TABLE "public"."curriculum_friend_challenge_answers" ADD CONSTRAINT "curriculum_friend_challenge_answers_pkey" PRIMARY KEY (challenge_id, user_id, question_id);
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_academic_level_id_code_version_key" UNIQUE (academic_level_id, code, curriculum_version);
ALTER TABLE "public"."profile_programs" ADD CONSTRAINT "profile_programs_curriculum_version_check" CHECK (curriculum_version = ANY (ARRAY['default'::text, '2009'::text, '2026'::text]));
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_curriculum_version_check" CHECK (curriculum_version = ANY (ARRAY['default'::text, '2009'::text, '2026'::text]));
ALTER TABLE "public"."inactivity_email_log" ADD CONSTRAINT "inactivity_email_log_status_check" CHECK (status = ANY (ARRAY['queued'::text, 'sent'::text, 'failed'::text, 'skipped'::text]));
ALTER TABLE "public"."inactivity_email_log" ADD CONSTRAINT "inactivity_email_log_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."inactivity_email_log" ADD CONSTRAINT "inactivity_email_log_user_id_inactivity_anchor_key" UNIQUE (user_id, inactivity_anchor);
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_question_type_check" CHECK (question_type = ANY (ARRAY['mcq'::text, 'fill_blank'::text, 'visual_hotspot'::text, 'clinical_case'::text, 'matching'::text]));
ALTER TABLE "public"."client_error_logs" ADD CONSTRAINT "client_error_logs_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."visual_reviewers" ADD CONSTRAINT "visual_reviewers_pkey" PRIMARY KEY (user_id);
ALTER TABLE "public"."release_health_status" ADD CONSTRAINT "release_health_status_id_check" CHECK (id = 1);
ALTER TABLE "public"."release_health_status" ADD CONSTRAINT "release_health_status_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."security_health_status" ADD CONSTRAINT "security_health_status_id_check" CHECK (id = 1);
ALTER TABLE "public"."security_health_status" ADD CONSTRAINT "security_health_status_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."business_health_status" ADD CONSTRAINT "business_health_status_id_check" CHECK (id = 1);
ALTER TABLE "public"."business_health_status" ADD CONSTRAINT "business_health_status_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."authenticated_contract_status" ADD CONSTRAINT "authenticated_contract_status_id_check" CHECK (id = 1);
ALTER TABLE "public"."authenticated_contract_status" ADD CONSTRAINT "authenticated_contract_status_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."inactivity_email_preferences" ADD CONSTRAINT "valid_inactivity_consent" CHECK (NOT opted_in OR opted_in_at IS NOT NULL AND opted_out_at IS NULL);
ALTER TABLE "public"."inactivity_email_preferences" ADD CONSTRAINT "inactivity_email_preferences_pkey" PRIMARY KEY (user_id);
ALTER TABLE "private"."weekly_friend_email_queue" ADD CONSTRAINT "weekly_friend_email_queue_status_check" CHECK (status = ANY (ARRAY['pending'::text, 'sent'::text, 'failed'::text, 'skipped'::text]));
ALTER TABLE "private"."weekly_friend_email_queue" ADD CONSTRAINT "weekly_friend_email_queue_pkey" PRIMARY KEY (id);
ALTER TABLE "private"."weekly_friend_email_queue" ADD CONSTRAINT "weekly_friend_email_queue_user_id_program_id_week_start_key" UNIQUE (user_id, program_id, week_start);
ALTER TABLE "public"."weekly_friend_email_preferences" ADD CONSTRAINT "weekly_friend_email_preferences_pkey" PRIMARY KEY (user_id);
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_study_year_check" CHECK (study_year >= 1 AND study_year <= 5);
ALTER TABLE "retention"."notices" ADD CONSTRAINT "notices_state_check" CHECK (state = ANY (ARRAY['pending'::text, 'sending'::text, 'sent'::text, 'delivered'::text, 'blocked'::text, 'deleting'::text]));
ALTER TABLE "retention"."notices" ADD CONSTRAINT "notices_pkey" PRIMARY KEY (id);
ALTER TABLE "retention"."notices" ADD CONSTRAINT "notices_user_id_key" UNIQUE (user_id);
ALTER TABLE "retention"."worker" ADD CONSTRAINT "worker_id_check" CHECK (id);
ALTER TABLE "retention"."worker" ADD CONSTRAINT "worker_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_file_sha256_check" CHECK (file_sha256 IS NULL OR file_sha256 ~ '^[a-f0-9]{64}$'::text);
ALTER TABLE "app_security"."request_windows" ADD CONSTRAINT "request_windows_pkey" PRIMARY KEY (user_id, action, window_start);
ALTER TABLE "app_security"."operations_health_status" ADD CONSTRAINT "operations_health_status_id_check" CHECK (id = 1);
ALTER TABLE "app_security"."operations_health_status" ADD CONSTRAINT "operations_health_status_pkey" PRIMARY KEY (id);
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_chapter_id_fkey" FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE;
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL;
ALTER TABLE "public"."question_options" ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."profiles" ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."subjects" ADD CONSTRAINT "subjects_year_id_fkey" FOREIGN KEY (year_id) REFERENCES years(id) ON DELETE CASCADE;
ALTER TABLE "public"."chapters" ADD CONSTRAINT "chapters_subject_id_fkey" FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE;
ALTER TABLE "public"."lessons" ADD CONSTRAINT "lessons_chapter_id_fkey" FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_streaks" ADD CONSTRAINT "user_streaks_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."revision_sessions" ADD CONSTRAINT "revision_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_attempts" ADD CONSTRAINT "question_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_attempts" ADD CONSTRAINT "question_attempts_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_attempts" ADD CONSTRAINT "question_attempts_session_id_fkey" FOREIGN KEY (session_id) REFERENCES revision_sessions(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_question_mastery" ADD CONSTRAINT "user_question_mastery_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."exams" ADD CONSTRAINT "exams_year_id_fkey" FOREIGN KEY (year_id) REFERENCES years(id) ON DELETE SET NULL;
ALTER TABLE "public"."exam_questions" ADD CONSTRAINT "exam_questions_exam_id_fkey" FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE;
ALTER TABLE "public"."exam_questions" ADD CONSTRAINT "exam_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."exam_attempts" ADD CONSTRAINT "exam_attempts_exam_id_fkey" FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE;
ALTER TABLE "public"."exam_attempts" ADD CONSTRAINT "exam_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."daily_challenge_questions" ADD CONSTRAINT "daily_challenge_questions_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES daily_challenges(id) ON DELETE CASCADE;
ALTER TABLE "public"."daily_challenge_questions" ADD CONSTRAINT "daily_challenge_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."daily_challenge_attempts" ADD CONSTRAINT "daily_challenge_attempts_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES daily_challenges(id) ON DELETE CASCADE;
ALTER TABLE "public"."daily_challenge_attempts" ADD CONSTRAINT "daily_challenge_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_badges" ADD CONSTRAINT "user_badges_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_badges" ADD CONSTRAINT "user_badges_badge_id_fkey" FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE;
ALTER TABLE "public"."favorites" ADD CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_notes" ADD CONSTRAINT "user_notes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_notes" ADD CONSTRAINT "user_notes_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;
ALTER TABLE "public"."user_notes" ADD CONSTRAINT "user_notes_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."friendships" ADD CONSTRAINT "friendships_requester_id_fkey" FOREIGN KEY (requester_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."friendships" ADD CONSTRAINT "friendships_addressee_id_fkey" FOREIGN KEY (addressee_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."lessons" ADD CONSTRAINT "lessons_validated_by_fkey" FOREIGN KEY (validated_by) REFERENCES profiles(id) ON DELETE SET NULL;
ALTER TABLE "public"."questions" ADD CONSTRAINT "questions_validated_by_fkey" FOREIGN KEY (validated_by) REFERENCES profiles(id) ON DELETE SET NULL;
ALTER TABLE "public"."curriculum_question_attempts" ADD CONSTRAINT "curriculum_question_attempts_question_id_fkey" FOREIGN KEY (question_id) REFERENCES curriculum_quiz_questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."challenges" ADD CONSTRAINT "challenges_challenger_id_fkey" FOREIGN KEY (challenger_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."challenges" ADD CONSTRAINT "challenges_challenged_id_fkey" FOREIGN KEY (challenged_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."challenge_questions" ADD CONSTRAINT "challenge_questions_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE;
ALTER TABLE "public"."challenge_questions" ADD CONSTRAINT "challenge_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."revision_session_questions" ADD CONSTRAINT "revision_session_questions_session_id_fkey" FOREIGN KEY (session_id) REFERENCES revision_sessions(id) ON DELETE CASCADE;
ALTER TABLE "public"."revision_session_questions" ADD CONSTRAINT "revision_session_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."revision_sessions" ADD CONSTRAINT "revision_sessions_daily_challenge_id_fkey" FOREIGN KEY (daily_challenge_id) REFERENCES daily_challenges(id) ON DELETE SET NULL;
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_year_id_fkey" FOREIGN KEY (year_id) REFERENCES years(id) ON DELETE SET NULL;
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_subject_id_fkey" FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE SET NULL;
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_chapter_id_fkey" FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE SET NULL;
ALTER TABLE "public"."course_documents" ADD CONSTRAINT "course_documents_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES profiles(id) ON DELETE SET NULL;
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE;
ALTER TABLE "public"."lesson_sources" ADD CONSTRAINT "lesson_sources_document_id_fkey" FOREIGN KEY (document_id) REFERENCES course_documents(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_question_id_fkey" FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_document_id_fkey" FOREIGN KEY (document_id) REFERENCES course_documents(id) ON DELETE CASCADE;
ALTER TABLE "public"."question_sources" ADD CONSTRAINT "question_sources_lesson_id_fkey" FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE SET NULL;
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."atlas_attempts" ADD CONSTRAINT "atlas_attempts_session_id_fkey" FOREIGN KEY (session_id) REFERENCES revision_sessions(id) ON DELETE CASCADE;
ALTER TABLE "public"."revision_sessions" ADD CONSTRAINT "revision_sessions_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE SET NULL;
ALTER TABLE "public"."feedback" ADD CONSTRAINT "feedback_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_quiz_questions" ADD CONSTRAINT "curriculum_quiz_questions_topic_id_fkey" FOREIGN KEY (topic_id) REFERENCES curriculum_topics(id) ON DELETE CASCADE;
ALTER TABLE "public"."academic_levels" ADD CONSTRAINT "academic_levels_program_id_fkey" FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE;
ALTER TABLE "public"."profile_programs" ADD CONSTRAINT "profile_programs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."profile_programs" ADD CONSTRAINT "profile_programs_program_id_fkey" FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE;
ALTER TABLE "public"."profile_programs" ADD CONSTRAINT "profile_programs_academic_level_id_fkey" FOREIGN KEY (academic_level_id) REFERENCES academic_levels(id) ON DELETE SET NULL;
ALTER TABLE "public"."curriculum_question_attempts" ADD CONSTRAINT "curriculum_question_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_program_id_fkey" FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_units" ADD CONSTRAINT "curriculum_units_academic_level_id_fkey" FOREIGN KEY (academic_level_id) REFERENCES academic_levels(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_topics" ADD CONSTRAINT "curriculum_topics_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES curriculum_units(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_lessons" ADD CONSTRAINT "curriculum_lessons_topic_id_fkey" FOREIGN KEY (topic_id) REFERENCES curriculum_topics(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_question_attempts" ADD CONSTRAINT "curriculum_question_attempts_topic_id_fkey" FOREIGN KEY (topic_id) REFERENCES curriculum_topics(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_topic_completions" ADD CONSTRAINT "curriculum_topic_completions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_topic_completions" ADD CONSTRAINT "curriculum_topic_completions_topic_id_fkey" FOREIGN KEY (topic_id) REFERENCES curriculum_topics(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_daily_challenge_attempts" ADD CONSTRAINT "curriculum_daily_challenge_attempts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_daily_challenge_attempts" ADD CONSTRAINT "curriculum_daily_challenge_attempts_program_id_fkey" FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_program_id_fkey" FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_challenger_id_fkey" FOREIGN KEY (challenger_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_challenged_id_fkey" FOREIGN KEY (challenged_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenge_questions" ADD CONSTRAINT "curriculum_friend_challenge_questions_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES curriculum_friend_challenges(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenge_questions" ADD CONSTRAINT "curriculum_friend_challenge_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES curriculum_quiz_questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenge_answers" ADD CONSTRAINT "curriculum_friend_challenge_answers_challenge_id_fkey" FOREIGN KEY (challenge_id) REFERENCES curriculum_friend_challenges(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenge_answers" ADD CONSTRAINT "curriculum_friend_challenge_answers_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenge_answers" ADD CONSTRAINT "curriculum_friend_challenge_answers_question_id_fkey" FOREIGN KEY (question_id) REFERENCES curriculum_quiz_questions(id) ON DELETE CASCADE;
ALTER TABLE "public"."curriculum_friend_challenges" ADD CONSTRAINT "curriculum_friend_challenges_academic_level_id_fkey" FOREIGN KEY (academic_level_id) REFERENCES academic_levels(id) ON DELETE RESTRICT;
ALTER TABLE "public"."inactivity_email_log" ADD CONSTRAINT "inactivity_email_log_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."inactivity_email_preferences" ADD CONSTRAINT "inactivity_email_preferences_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."client_error_logs" ADD CONSTRAINT "client_error_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "public"."visual_reviewers" ADD CONSTRAINT "visual_reviewers_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;
ALTER TABLE "public"."visual_reviewers" ADD CONSTRAINT "visual_reviewers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL;
ALTER TABLE "public"."weekly_friend_email_preferences" ADD CONSTRAINT "weekly_friend_email_preferences_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "retention"."notices" ADD CONSTRAINT "notices_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE "app_security"."request_windows" ADD CONSTRAINT "request_windows_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
CREATE UNIQUE INDEX idx_one_daily_session_per_user ON public.revision_sessions USING btree (user_id, daily_challenge_id) WHERE (daily_challenge_id IS NOT NULL);
CREATE INDEX idx_attempts_created ON public.question_attempts USING btree (created_at);
CREATE INDEX idx_visual_reviewers_created_by ON public.visual_reviewers USING btree (created_by);
CREATE INDEX idx_course_documents_chapter ON public.course_documents USING btree (chapter_id);
CREATE INDEX idx_curriculum_completions_topic_id ON public.curriculum_topic_completions USING btree (topic_id);
CREATE INDEX idx_user_question_mastery_question_id ON public.user_question_mastery USING btree (question_id);
CREATE INDEX idx_curriculum_friend_questions_question_id ON public.curriculum_friend_challenge_questions USING btree (question_id);
CREATE INDEX client_error_logs_user_created_idx ON public.client_error_logs USING btree (user_id, created_at DESC);
CREATE INDEX idx_question_sources_document ON public.question_sources USING btree (document_id);
CREATE INDEX idx_exam_attempts_user ON public.exam_attempts USING btree (user_id);
CREATE INDEX idx_friendships_requester ON public.friendships USING btree (requester_id);
CREATE INDEX idx_curriculum_attempts_question_id ON public.curriculum_question_attempts USING btree (question_id);
CREATE INDEX idx_user_question_mastery_due ON public.user_question_mastery USING btree (user_id, next_review_at) WHERE (next_review_at IS NOT NULL);
CREATE INDEX idx_profile_programs_academic_level_id ON public.profile_programs USING btree (academic_level_id);
CREATE INDEX idx_lesson_sources_document ON public.lesson_sources USING btree (document_id);
CREATE INDEX idx_course_documents_year ON public.course_documents USING btree (year_id);
CREATE UNIQUE INDEX idx_question_attempts_user_session_question ON public.question_attempts USING btree (user_id, session_id, question_id);
CREATE INDEX idx_course_documents_subject ON public.course_documents USING btree (subject_id);
CREATE INDEX idx_user_badges_badge_id ON public.user_badges USING btree (badge_id);
CREATE INDEX client_error_logs_created_idx ON public.client_error_logs USING btree (created_at DESC);
CREATE INDEX idx_attempts_question ON public.question_attempts USING btree (question_id);
CREATE INDEX idx_revision_session_questions_session ON public.revision_session_questions USING btree (session_id);
CREATE INDEX idx_user_badges_user ON public.user_badges USING btree (user_id);
CREATE INDEX idx_curriculum_daily_program_id ON public.curriculum_daily_challenge_attempts USING btree (program_id);
CREATE INDEX anatomy_visual_assets_source_idx ON public.anatomy_visual_assets USING btree (source_title, source_page);
CREATE INDEX atlas_attempts_user_area_idx ON public.atlas_attempts USING btree (user_id, area, accuracy_percent DESC, duration_ms, created_at DESC);
CREATE INDEX revision_sessions_challenge_id_idx ON public.revision_sessions USING btree (challenge_id);
CREATE INDEX curriculum_quiz_topic_idx ON public.curriculum_quiz_questions USING btree (topic_id);
CREATE INDEX idx_favorites_user ON public.favorites USING btree (user_id);
CREATE INDEX idx_mastery_review ON public.user_question_mastery USING btree (next_review_at);
CREATE INDEX idx_lesson_sources_lesson ON public.lesson_sources USING btree (lesson_id);
CREATE INDEX idx_revision_sessions_user_started_at ON public.revision_sessions USING btree (user_id, started_at DESC);
CREATE INDEX idx_revision_sessions_daily_challenge ON public.revision_sessions USING btree (daily_challenge_id);
CREATE INDEX idx_curriculum_topics_unit ON public.curriculum_topics USING btree (unit_id, display_order);
CREATE INDEX idx_lessons_validated_by ON public.lessons USING btree (validated_by);
CREATE INDEX idx_user_notes_lesson_id ON public.user_notes USING btree (lesson_id);
CREATE INDEX idx_mastery_user ON public.user_question_mastery USING btree (user_id);
CREATE INDEX idx_curriculum_units_level_version ON public.curriculum_units USING btree (academic_level_id, curriculum_version);
CREATE INDEX idx_friendships_addressee ON public.friendships USING btree (addressee_id);
CREATE INDEX curriculum_lessons_topic_idx ON public.curriculum_lessons USING btree (topic_id);
CREATE INDEX idx_curriculum_friend_challenges_challenged_id ON public.curriculum_friend_challenges USING btree (challenged_id);
CREATE INDEX idx_questions_chapter ON public.questions USING btree (chapter_id);
CREATE INDEX idx_question_sources_lesson_id ON public.question_sources USING btree (lesson_id);
CREATE INDEX idx_exam_questions_question ON public.exam_questions USING btree (question_id);
CREATE UNIQUE INDEX daily_challenges_date_year_uidx ON public.daily_challenges USING btree (challenge_date, study_year) WHERE (study_year IS NOT NULL);
CREATE INDEX idx_attempts_user ON public.question_attempts USING btree (user_id);
CREATE INDEX idx_questions_validated_by ON public.questions USING btree (validated_by);
CREATE INDEX idx_curriculum_units_program_level ON public.curriculum_units USING btree (program_id, academic_level_id, display_order);
CREATE INDEX idx_curriculum_question_attempts_topic ON public.curriculum_question_attempts USING btree (user_id, topic_id);
CREATE INDEX idx_curriculum_friend_challenges_program_level ON public.curriculum_friend_challenges USING btree (program_id, academic_level_id, created_at DESC);
CREATE INDEX idx_course_documents_uploaded_by ON public.course_documents USING btree (uploaded_by);
CREATE INDEX idx_curriculum_friend_answers_user_id ON public.curriculum_friend_challenge_answers USING btree (user_id);
CREATE INDEX idx_question_options_question ON public.question_options USING btree (question_id);
CREATE INDEX idx_challenges_challenger ON public.challenges USING btree (challenger_id);
CREATE INDEX idx_user_notes_question_id ON public.user_notes USING btree (question_id);
CREATE INDEX idx_daily_challenge_questions_challenge ON public.daily_challenge_questions USING btree (challenge_id);
CREATE INDEX idx_feedback_status_created_at ON public.feedback USING btree (status, created_at DESC);
CREATE INDEX idx_exam_questions_exam ON public.exam_questions USING btree (exam_id);
CREATE INDEX idx_challenges_challenged ON public.challenges USING btree (challenged_id);
CREATE INDEX idx_curriculum_friend_challenges_academic_level_id ON public.curriculum_friend_challenges USING btree (academic_level_id);
CREATE INDEX idx_questions_lesson ON public.questions USING btree (lesson_id);
CREATE INDEX idx_profile_programs_program_version ON public.profile_programs USING btree (program_id, curriculum_version);
CREATE INDEX idx_curriculum_question_attempts_user ON public.curriculum_question_attempts USING btree (user_id, created_at DESC);
CREATE INDEX idx_exams_year_id ON public.exams USING btree (year_id);
CREATE INDEX idx_challenge_questions_question_id ON public.challenge_questions USING btree (question_id);
CREATE INDEX idx_curriculum_friend_challenges_users ON public.curriculum_friend_challenges USING btree (challenger_id, challenged_id, status);
CREATE INDEX idx_question_sources_question ON public.question_sources USING btree (question_id);
CREATE INDEX idx_question_attempts_session_id ON public.question_attempts USING btree (session_id);
CREATE INDEX profiles_last_seen_at_idx ON public.profiles USING btree (last_seen_at);
CREATE INDEX idx_feedback_user_id ON public.feedback USING btree (user_id);
CREATE INDEX idx_exam_attempts_exam ON public.exam_attempts USING btree (exam_id);
CREATE INDEX idx_daily_challenge_questions_question_id ON public.daily_challenge_questions USING btree (question_id);
CREATE INDEX idx_daily_challenge_attempts_user ON public.daily_challenge_attempts USING btree (user_id);
CREATE INDEX idx_notes_user ON public.user_notes USING btree (user_id);
CREATE INDEX idx_course_documents_status ON public.course_documents USING btree (processing_status);
CREATE INDEX idx_curriculum_attempts_topic_id ON public.curriculum_question_attempts USING btree (topic_id);
CREATE INDEX idx_curriculum_friend_answers_question_id ON public.curriculum_friend_challenge_answers USING btree (question_id);
CREATE INDEX idx_revision_session_questions_question ON public.revision_session_questions USING btree (question_id);
CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);
CREATE OR REPLACE FUNCTION public.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
  new.updated_at = now();
    return new;
    end;
    $function$
;
CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND role = 'admin'
  );
$function$
;
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  generated_username text;
begin
  generated_username := coalesce(new.raw_user_meta_data ->> 'username','user_' || substr(new.id::text, 1, 8));

  insert into public.profiles (id, first_name, username, study_year)
  values (
    new.id,
    new.raw_user_meta_data ->> 'first_name',
    generated_username,
    case
      when (new.raw_user_meta_data ->> 'study_year') ~ '^[2-5]$'
      then (new.raw_user_meta_data ->> 'study_year')::integer
      else null
    end
  )
  on conflict (id) do nothing;

  insert into public.user_streaks (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_quiz_answer(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid; v_question_type text; v_metadata jsonb; v_is_correct boolean:=false; v_xp integer:=0;
  v_attempt_count integer:=0; v_correct_count integer:=0; v_mastery integer:=0; v_expected text; v_given text;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  select rs.user_id into v_user_id from public.revision_sessions rs
  where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is null and rs.abandoned_at is null;
  if v_user_id is null then raise exception 'Session inexistante, terminée, abandonnée ou accès non autorisé'; end if;
  select q.type,coalesce(q.metadata,'{}'::jsonb) into v_question_type,v_metadata
  from public.revision_session_questions rsq join public.questions q on q.id=rsq.question_id
  where rsq.session_id=p_session_id and rsq.question_id=p_question_id and q.is_published=true and q.validation_status='published';
  if v_question_type is null then raise exception 'Cette question ne fait pas partie de cette session'; end if;
  if exists(select 1 from public.question_attempts qa where qa.session_id=p_session_id and qa.question_id=p_question_id and qa.user_id=v_user_id) then raise exception 'Cette question a déjà reçu une réponse'; end if;

  if v_question_type in ('mcq','true_false') or (v_question_type='clinical_case' and nullif(p_answer->>'option_id','') is not null) then
    select exists(select 1 from public.question_options qo where qo.question_id=p_question_id and qo.id::text=p_answer->>'option_id' and qo.is_correct=true) into v_is_correct;
  elsif v_question_type in ('fill_blank','short_answer','translation','clinical_case') then
    v_given:=coalesce(p_answer->>'text','');
    v_expected:=coalesce(v_metadata->>'answer','');
    v_is_correct:=public.quiz_text_equivalent_v1(v_given,v_expected)
      or exists(select 1 from pg_catalog.jsonb_array_elements_text(case when pg_catalog.jsonb_typeof(v_metadata->'accepted_answers')='array' then v_metadata->'accepted_answers' else '[]'::jsonb end) a(value)
                where public.quiz_text_equivalent_v1(v_given,a.value));
  elsif v_question_type='matching' then
    if pg_catalog.jsonb_typeof(v_metadata->'pairs')='array' and pg_catalog.jsonb_typeof(p_answer->'pairs')='array' then
      v_is_correct:=pg_catalog.jsonb_array_length(v_metadata->'pairs')=pg_catalog.jsonb_array_length(p_answer->'pairs') and (v_metadata->'pairs')@>(p_answer->'pairs') and (p_answer->'pairs')@>(v_metadata->'pairs');
    end if;
  else v_is_correct:=false; end if;

  if v_is_correct then v_xp:=case v_question_type when 'matching' then 15 when 'fill_blank' then 12 when 'short_answer' then 15 when 'translation' then 15 when 'clinical_case' then 20 else 10 end; end if;
  insert into public.question_attempts(user_id,question_id,session_id,answer,is_correct,response_time_ms,xp_earned)
  values(v_user_id,p_question_id,p_session_id,p_answer,v_is_correct,p_response_time_ms,v_xp);
  update public.revision_session_questions set answered_at=now() where session_id=p_session_id and question_id=p_question_id;
  select coalesce(attempt_count,0),coalesce(correct_count,0) into v_attempt_count,v_correct_count from public.user_question_mastery where user_id=v_user_id and question_id=p_question_id;
  v_attempt_count:=coalesce(v_attempt_count,0)+1; v_correct_count:=coalesce(v_correct_count,0); if v_is_correct then v_correct_count:=v_correct_count+1; end if;
  v_mastery:=least(4,floor((v_correct_count::numeric/v_attempt_count::numeric)*4)::integer);
  insert into public.user_question_mastery(user_id,question_id,mastery_score,attempt_count,correct_count,last_attempt_at,next_review_at)
  values(v_user_id,p_question_id,v_mastery,v_attempt_count,v_correct_count,now(),case when v_is_correct and v_mastery>=3 then now()+interval '7 days' when v_is_correct then now()+interval '3 days' else now()+interval '1 day' end)
  on conflict(user_id,question_id) do update set mastery_score=excluded.mastery_score,attempt_count=excluded.attempt_count,correct_count=excluded.correct_count,last_attempt_at=excluded.last_attempt_at,next_review_at=excluded.next_review_at;
  return pg_catalog.jsonb_build_object('correct',v_is_correct,'xp_earned',v_xp,'mastery_score',v_mastery,'question_type',v_question_type,'question_id',p_question_id,'session_id',p_session_id);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.update_user_progress(p_user_id uuid, p_xp_earned integer DEFAULT 0)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_total_xp integer;
  v_level integer;
  v_level_name text;
  v_today date := current_date;
  v_last_activity date;
  v_current_streak integer;
  v_longest_streak integer;
BEGIN

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;

  IF auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Accès non autorisé';
  END IF;

  IF p_xp_earned < 0 THEN
    RAISE EXCEPTION 'XP invalide';
  END IF;

  /*
    Autorise temporairement cette fonction serveur
    à modifier XP et niveau malgré protect_profile_data().
  */
  PERFORM set_config('kineo.internal_update', 'on', true);

  /* XP */
  UPDATE public.profiles
  SET xp = COALESCE(xp, 0) + p_xp_earned
  WHERE id = p_user_id
  RETURNING xp INTO v_total_xp;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Profil utilisateur introuvable';
  END IF;

  /* NIVEAU */
  SELECT
    level,
    name
  INTO
    v_level,
    v_level_name
  FROM public.levels
  WHERE required_xp <= v_total_xp
  ORDER BY required_xp DESC
  LIMIT 1;

  IF v_level IS NULL THEN
    v_level := 1;
    v_level_name := 'Débutant';
  END IF;

  UPDATE public.profiles
  SET level = v_level
  WHERE id = p_user_id;

  /* FLAMME */
  SELECT
    last_activity_date,
    current_streak,
    longest_streak
  INTO
    v_last_activity,
    v_current_streak,
    v_longest_streak
  FROM public.user_streaks
  WHERE user_id = p_user_id;

  IF v_last_activity IS NULL THEN

    v_current_streak := 1;
    v_longest_streak := GREATEST(
      COALESCE(v_longest_streak, 0),
      1
    );

  ELSIF v_last_activity = v_today THEN

    NULL;

  ELSIF v_last_activity = v_today - 1 THEN

    v_current_streak := COALESCE(v_current_streak, 0) + 1;

    v_longest_streak := GREATEST(
      COALESCE(v_longest_streak, 0),
      v_current_streak
    );

  ELSE

    v_current_streak := 1;

  END IF;

  UPDATE public.user_streaks
  SET
    current_streak = v_current_streak,
    longest_streak = v_longest_streak,
    last_activity_date = v_today,
    updated_at = now()
  WHERE user_id = p_user_id;

  /* RETOUR */
  RETURN jsonb_build_object(
    'xp_total', v_total_xp,
    'level', v_level,
    'level_name', v_level_name,
    'current_streak', v_current_streak,
    'longest_streak', v_longest_streak
  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.protect_profile_data()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  IF NOT public.is_admin()
     AND COALESCE(current_setting('kineo.internal_update', true), 'off') <> 'on'
  THEN
    NEW.role := OLD.role;
    NEW.xp := OLD.xp;
    NEW.level := OLD.level;
  END IF;

  RETURN NEW;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.start_quiz_session(p_user_id uuid, p_mode text DEFAULT 'mix'::text, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_session_id uuid;
  v_question_count integer;
BEGIN

  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Accès non autorisé';
  END IF;

  IF p_question_count < 1 OR p_question_count > 50 THEN
    RAISE EXCEPTION 'Nombre de questions invalide';
  END IF;

  IF p_mode NOT IN (
    'smart',
    'mix',
    'mcq',
    'true_false',
    'fill_blank',
    'matching',
    'visual',
    'clinical_case',
    'translation',
    'exam',
    'daily'
  ) THEN
    RAISE EXCEPTION 'Mode de quiz invalide';
  END IF;

  INSERT INTO public.revision_sessions (
    user_id,
    mode,
    question_count
  )
  VALUES (
    p_user_id,
    p_mode,
    p_question_count
  )
  RETURNING id INTO v_session_id;

  /*
    Sélection des questions.
    Pour le prototype, on utilise les questions publiées.
  */

  INSERT INTO public.revision_session_questions (
    session_id,
    question_id,
    display_order
  )
  SELECT
    v_session_id,
    q.id,
    ROW_NUMBER() OVER (ORDER BY random())::integer
  FROM public.questions q
  WHERE q.is_published = true
    AND (
      p_mode IN ('smart', 'mix', 'exam', 'daily')
      OR q.type = p_mode
    )
  ORDER BY random()
  LIMIT p_question_count;

  SELECT COUNT(*)
  INTO v_question_count
  FROM public.revision_session_questions
  WHERE session_id = v_session_id;

  IF v_question_count = 0 THEN
    DELETE FROM public.revision_sessions
    WHERE id = v_session_id;

    RAISE EXCEPTION 'Aucune question publiée disponible pour ce quiz';
  END IF;

  UPDATE public.revision_sessions
  SET question_count = v_question_count
  WHERE id = v_session_id;

  RETURN v_session_id;

END;
$function$
;
CREATE OR REPLACE FUNCTION public.check_and_award_badges(p_user_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_quiz_count integer := 0;
  v_correct_count integer := 0;
  v_streak integer := 0;
  v_daily_count integer := 0;
  v_daily_perfect boolean := false;

  v_new_badges jsonb := '[]'::jsonb;
BEGIN

  /* ==========================
     SÉCURITÉ
     ========================== */

  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Accès non autorisé';
  END IF;


  /* ==========================
     STATISTIQUES
     ========================== */

  SELECT COUNT(*)
  INTO v_quiz_count
  FROM public.revision_sessions
  WHERE user_id = p_user_id
    AND completed_at IS NOT NULL;


  SELECT COUNT(*)
  INTO v_correct_count
  FROM public.question_attempts
  WHERE user_id = p_user_id
    AND is_correct = true;


  SELECT COALESCE(current_streak, 0)
  INTO v_streak
  FROM public.user_streaks
  WHERE user_id = p_user_id;


  SELECT COUNT(*)
  INTO v_daily_count
  FROM public.daily_challenge_attempts
  WHERE user_id = p_user_id;


  SELECT EXISTS (
    SELECT 1
    FROM public.daily_challenge_attempts
    WHERE user_id = p_user_id
      AND score >= 100
  )
  INTO v_daily_perfect;


  /* ==========================
     ATTRIBUTION
     ========================== */

  WITH eligible AS (

    SELECT b.id
    FROM public.badges b

    WHERE

      (
        b.condition_type = 'quiz_completed'
        AND v_quiz_count >=
          COALESCE((b.condition_value->>'count')::integer, 0)
      )

      OR

      (
        b.condition_type = 'streak'
        AND v_streak >=
          COALESCE((b.condition_value->>'days')::integer, 0)
      )

      OR

      (
        b.condition_type = 'correct_answers'
        AND v_correct_count >=
          COALESCE((b.condition_value->>'count')::integer, 0)
      )

      OR

      (
        b.condition_type = 'daily_completed'
        AND v_daily_count >=
          COALESCE((b.condition_value->>'count')::integer, 0)
      )

      OR

      (
        b.condition_type = 'daily_perfect'
        AND v_daily_perfect = true
      )

  ),

  inserted AS (

    INSERT INTO public.user_badges (
      user_id,
      badge_id
    )

    SELECT
      p_user_id,
      eligible.id
    FROM eligible

    ON CONFLICT (user_id, badge_id)
    DO NOTHING

    RETURNING badge_id
  )

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', b.id,
        'name', b.name,
        'description', b.description,
        'icon', b.icon
      )
    ),
    '[]'::jsonb
  )

  INTO v_new_badges

  FROM inserted i
  JOIN public.badges b
    ON b.id = i.badge_id;


  /* ==========================
     RÉSULTAT
     ========================== */

  RETURN jsonb_build_object(
    'new_badges', v_new_badges,
    'new_badges_count',
      jsonb_array_length(v_new_badges),

    'stats',
      jsonb_build_object(
        'completed_quizzes', v_quiz_count,
        'correct_answers', v_correct_count,
        'current_streak', v_streak,
        'daily_challenges', v_daily_count
      )
  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.start_daily_challenge()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_id uuid;
  v_challenge_id uuid;
  v_session_id uuid;

  v_question_count integer;
  v_answered_count integer;
  v_completed_at timestamptz;
BEGIN

  /* ==========================
     AUTHENTIFICATION
     ========================== */

  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;


  /* ==========================
     CHALLENGE DU JOUR
     ========================== */

  v_challenge_id :=
    public.ensure_daily_challenge();


  /* ==========================
     SESSION EXISTANTE ?
     ========================== */

  SELECT
    rs.id,
    rs.completed_at
  INTO
    v_session_id,
    v_completed_at
  FROM public.revision_sessions rs
  WHERE rs.user_id = v_user_id
    AND rs.daily_challenge_id = v_challenge_id
  LIMIT 1;


  /* ==========================
     CRÉER LA SESSION
     ========================== */

  IF v_session_id IS NULL THEN

    INSERT INTO public.revision_sessions (
      user_id,
      mode,
      question_count,
      daily_challenge_id
    )
    VALUES (
      v_user_id,
      'daily',
      10,
      v_challenge_id
    )
    RETURNING id INTO v_session_id;


    /*
      Copier les 10 questions du challenge
      dans la session utilisateur.
    */

    INSERT INTO public.revision_session_questions (
      session_id,
      question_id,
      display_order
    )
    SELECT
      v_session_id,
      dcq.question_id,
      dcq.display_order
    FROM public.daily_challenge_questions dcq
    WHERE dcq.challenge_id = v_challenge_id
    ORDER BY dcq.display_order;

  END IF;


  /* ==========================
     PROGRESSION
     ========================== */

  SELECT COUNT(*)
  INTO v_question_count
  FROM public.revision_session_questions
  WHERE session_id = v_session_id;


  SELECT COUNT(*)
  INTO v_answered_count
  FROM public.revision_session_questions
  WHERE session_id = v_session_id
    AND answered_at IS NOT NULL;


  /* ==========================
     RÉSULTAT
     ========================== */

  RETURN jsonb_build_object(

    'challenge_id',
      v_challenge_id,

    'session_id',
      v_session_id,

    'question_count',
      v_question_count,

    'answered_count',
      v_answered_count,

    'remaining_count',
      v_question_count - v_answered_count,

    'completed',
      v_completed_at IS NOT NULL,

    'status',
      CASE
        WHEN v_completed_at IS NOT NULL
          THEN 'completed'

        WHEN v_answered_count > 0
          THEN 'in_progress'

        ELSE
          'ready'
      END
  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_daily_challenge(p_session_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_id uuid;
  v_challenge_id uuid;

  v_total integer := 0;
  v_answered integer := 0;
  v_correct integer := 0;

  v_question_xp integer := 0;
  v_bonus_xp integer := 0;
  v_total_xp integer := 0;

  v_score numeric := 0;

  v_existing_attempt uuid;
  v_progress jsonb;
  v_badges jsonb;
BEGIN

  /* AUTHENTIFICATION */

  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;


  /* RÉCUPÉRER ET VERROUILLER LA SESSION */

  SELECT rs.daily_challenge_id
  INTO v_challenge_id
  FROM public.revision_sessions rs
  WHERE rs.id = p_session_id
    AND rs.user_id = v_user_id
    AND rs.mode = 'daily'
    AND rs.completed_at IS NULL
  FOR UPDATE;

  IF v_challenge_id IS NULL THEN
    RAISE EXCEPTION
      'Challenge inexistant, déjà terminé ou accès non autorisé';
  END IF;


  /* EXACTEMENT 10 QUESTIONS */

  SELECT COUNT(*)
  INTO v_total
  FROM public.revision_session_questions
  WHERE session_id = p_session_id;

  IF v_total <> 10 THEN
    RAISE EXCEPTION
      'Le Challenge du jour doit contenir exactement 10 questions';
  END IF;


  /* TOUTES LES QUESTIONS DOIVENT ÊTRE RÉPONDUES */

  SELECT COUNT(*)
  INTO v_answered
  FROM public.revision_session_questions
  WHERE session_id = p_session_id
    AND answered_at IS NOT NULL;

  IF v_answered <> 10 THEN
    RAISE EXCEPTION
      'Challenge incomplet : % question(s) sur 10 répondue(s)',
      v_answered;
  END IF;


  /* EMPÊCHER UNE DOUBLE RÉCOMPENSE */

  SELECT id
  INTO v_existing_attempt
  FROM public.daily_challenge_attempts
  WHERE challenge_id = v_challenge_id
    AND user_id = v_user_id;

  IF v_existing_attempt IS NOT NULL THEN
    RAISE EXCEPTION
      'Le Challenge du jour a déjà été récompensé';
  END IF;


  /* SCORE + XP DES QUESTIONS */

  SELECT
    COUNT(*) FILTER (WHERE qa.is_correct = true),
    COALESCE(SUM(qa.xp_earned), 0)
  INTO
    v_correct,
    v_question_xp
  FROM public.question_attempts qa
  WHERE qa.session_id = p_session_id
    AND qa.user_id = v_user_id;


  v_score :=
    ROUND(
      (v_correct::numeric / 10::numeric) * 100,
      2
    );


  /* BONUS QUOTIDIEN */

  SELECT xp_reward
  INTO v_bonus_xp
  FROM public.daily_challenges
  WHERE id = v_challenge_id
    AND is_active = true;

  v_bonus_xp := COALESCE(v_bonus_xp, 0);

  v_total_xp :=
    v_question_xp + v_bonus_xp;


  /* ENREGISTRER LE CHALLENGE TERMINÉ */

  INSERT INTO public.daily_challenge_attempts (
    challenge_id,
    user_id,
    score,
    total_questions,
    xp_earned,
    completed_at
  )
  VALUES (
    v_challenge_id,
    v_user_id,
    v_score,
    10,
    v_total_xp,
    now()
  );


  /* TERMINER LA SESSION */

  UPDATE public.revision_sessions
  SET
    correct_count = v_correct,
    xp_earned = v_total_xp,
    completed_at = now()
  WHERE id = p_session_id;


  /* XP + NIVEAU + FLAMME */

  v_progress :=
    public.update_user_progress(
      v_user_id,
      v_total_xp
    );


  /* BADGES */

  v_badges :=
    public.check_and_award_badges(
      v_user_id
    );


  /* RÉSULTAT COMPLET */

  RETURN jsonb_build_object(

    'challenge_id',
      v_challenge_id,

    'session_id',
      p_session_id,

    'score',
      v_score,

    'correct_count',
      v_correct,

    'incorrect_count',
      10 - v_correct,

    'total_questions',
      10,

    'question_xp',
      v_question_xp,

    'bonus_xp',
      v_bonus_xp,

    'xp_earned',
      v_total_xp,

    'xp_total',
      v_progress->'xp_total',

    'level',
      v_progress->'level',

    'level_name',
      v_progress->'level_name',

    'current_streak',
      v_progress->'current_streak',

    'longest_streak',
      v_progress->'longest_streak',

    'new_badges',
      v_badges->'new_badges',

    'new_badges_count',
      v_badges->'new_badges_count',

    'completed',
      true
  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.ensure_daily_challenge()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_challenge_id uuid;
  v_available integer;
BEGIN

  /* Chercher le challenge du jour */

  SELECT id
  INTO v_challenge_id
  FROM public.daily_challenges
  WHERE challenge_date = current_date
    AND is_active = true
  LIMIT 1;


  /* S'il existe déjà, on le retourne */

  IF v_challenge_id IS NOT NULL THEN
    RETURN v_challenge_id;
  END IF;


  /* Vérifier qu'on dispose d'au moins 10 questions */

  SELECT COUNT(*)
  INTO v_available
  FROM public.questions
  WHERE is_published = true;


  IF v_available < 10 THEN
    RAISE EXCEPTION
      'Impossible de créer le challenge : seulement % question(s) publiée(s), 10 nécessaires',
      v_available;
  END IF;


  /* Créer le challenge */

  INSERT INTO public.daily_challenges (
    challenge_date,
    title,
    description,
    xp_reward,
    is_active
  )
  VALUES (
    current_date,
    'Challenge du jour',
    'Réponds aux 10 questions du jour et entretiens ta série 🔥',
    100,
    true
  )
  RETURNING id INTO v_challenge_id;


  /* Sélectionner exactement 10 questions */

  INSERT INTO public.daily_challenge_questions (
    challenge_id,
    question_id,
    display_order
  )
  SELECT
    v_challenge_id,
    selected.id,
    selected.rn
  FROM (
    SELECT
      q.id,
      ROW_NUMBER() OVER (ORDER BY random())::integer AS rn
    FROM public.questions q
    WHERE q.is_published = true
    ORDER BY random()
    LIMIT 10
  ) selected;


  RETURN v_challenge_id;

END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_lesson_progress(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_total_questions integer := 0;
  v_attempted_questions integer := 0;
  v_mastered_questions integer := 0;
  v_average_mastery numeric := 0;
  v_last_revision timestamptz;
BEGIN

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;

  /* Nombre total de questions publiées de la fiche */
  SELECT COUNT(*)
  INTO v_total_questions
  FROM public.questions q
  WHERE q.lesson_id = p_lesson_id
    AND q.is_published = true;

  /* Questions déjà travaillées */
  SELECT COUNT(*)
  INTO v_attempted_questions
  FROM public.user_question_mastery uqm
  JOIN public.questions q
    ON q.id = uqm.question_id
  WHERE uqm.user_id = auth.uid()
    AND q.lesson_id = p_lesson_id
    AND q.is_published = true
    AND uqm.attempt_count > 0;

  /* Une question est considérée maîtrisée à partir de 3/4 */
  SELECT COUNT(*)
  INTO v_mastered_questions
  FROM public.user_question_mastery uqm
  JOIN public.questions q
    ON q.id = uqm.question_id
  WHERE uqm.user_id = auth.uid()
    AND q.lesson_id = p_lesson_id
    AND q.is_published = true
    AND uqm.mastery_score >= 3;

  /* Maîtrise moyenne sur une échelle 0 → 4 */
  SELECT
    COALESCE(AVG(uqm.mastery_score), 0),
    MAX(uqm.last_attempt_at)
  INTO
    v_average_mastery,
    v_last_revision
  FROM public.user_question_mastery uqm
  JOIN public.questions q
    ON q.id = uqm.question_id
  WHERE uqm.user_id = auth.uid()
    AND q.lesson_id = p_lesson_id
    AND q.is_published = true;

  RETURN jsonb_build_object(
    'total_questions', v_total_questions,
    'attempted_questions', v_attempted_questions,
    'mastered_questions', v_mastered_questions,
    'average_mastery', ROUND(v_average_mastery, 2),
    'mastery_percent',
      ROUND((v_average_mastery / 4.0) * 100),
    'last_revision', v_last_revision
  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_quiz_questions_v2(p_session_id uuid)
 RETURNS TABLE(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  if not exists (
    select 1
    from public.revision_sessions rs
    where rs.id = p_session_id
      and rs.user_id = auth.uid()
  ) then
    raise exception 'Session inexistante ou accès non autorisé';
  end if;

  return query
  select
    q.id,
    q.type,
    q.question_text,
    q.explanation,
    q.difficulty,
    q.image_url,
    coalesce(q.metadata, '{}'::jsonb),
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'id', qo.id,
            'option_text', qo.option_text,
            'is_correct', qo.is_correct,
            'display_order', qo.display_order
          )
          order by qo.display_order
        )
        from public.question_options qo
        where qo.question_id = q.id
      ),
      '[]'::jsonb
    ) as question_options,
    rsq.display_order
  from public.revision_session_questions rsq
  join public.questions q on q.id = rsq.question_id
  where rsq.session_id = p_session_id
    and q.is_published = true
  order by rsq.display_order;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_lesson_quiz(p_lesson_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_session_id uuid;
  v_question_count integer;
BEGIN

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;

  IF p_question_count < 1 OR p_question_count > 50 THEN
    RAISE EXCEPTION 'Nombre de questions invalide';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.lessons
    WHERE id = p_lesson_id
      AND is_published = true
  ) THEN
    RAISE EXCEPTION 'Fiche inexistante ou non publiée';
  END IF;

  INSERT INTO public.revision_sessions (
    user_id,
    mode,
    question_count
  )
  VALUES (
    auth.uid(),
    'mcq',
    p_question_count
  )
  RETURNING id INTO v_session_id;

  INSERT INTO public.revision_session_questions (
    session_id,
    question_id,
    display_order
  )
  SELECT
    v_session_id,
    q.id,
    ROW_NUMBER() OVER (ORDER BY random())::integer
  FROM public.questions q
  WHERE q.lesson_id = p_lesson_id
    AND q.is_published = true
  ORDER BY random()
  LIMIT p_question_count;

  SELECT COUNT(*)
  INTO v_question_count
  FROM public.revision_session_questions
  WHERE session_id = v_session_id;

  IF v_question_count = 0 THEN
    DELETE FROM public.revision_sessions
    WHERE id = v_session_id;

    RAISE EXCEPTION
      'Aucune question publiée disponible pour cette fiche';
  END IF;

  UPDATE public.revision_sessions
  SET question_count = v_question_count
  WHERE id = v_session_id;

  RETURN v_session_id;

END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_quiz_questions(p_session_id uuid)
 RETURNS TABLE(question_id uuid, question_type text, question_text text, explanation text, difficulty integer, image_url text, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.revision_sessions rs
    WHERE rs.id = p_session_id
      AND rs.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Session inexistante ou accès non autorisé';
  END IF;

  RETURN QUERY
  SELECT
    q.id,
    q.type,
    q.question_text,
    q.explanation,
    q.difficulty,
    q.image_url,
    rsq.display_order
  FROM public.revision_session_questions rsq
  JOIN public.questions q
    ON q.id = rsq.question_id
  WHERE rsq.session_id = p_session_id
    AND q.is_published = true
  ORDER BY rsq.display_order;

END;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_quiz_session(p_session_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_id uuid;

  v_total_questions integer := 0;
  v_answered_questions integer := 0;
  v_correct_count integer := 0;

  v_xp integer := 0;
  v_score numeric := 0;

  v_progress jsonb;
  v_badges jsonb;
BEGIN

  /* AUTHENTIFICATION */

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;


  /* RÉCUPÉRER ET VERROUILLER LA SESSION */

  SELECT rs.user_id
  INTO v_user_id
  FROM public.revision_sessions rs
  WHERE rs.id = p_session_id
    AND rs.user_id = auth.uid()
    AND rs.completed_at IS NULL
  FOR UPDATE;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION
      'Session inexistante, déjà terminée ou accès non autorisé';
  END IF;


  /* NOMBRE DE QUESTIONS */

  SELECT COUNT(*)
  INTO v_total_questions
  FROM public.revision_session_questions
  WHERE session_id = p_session_id;

  IF v_total_questions = 0 THEN
    RAISE EXCEPTION 'Cette session ne contient aucune question';
  END IF;


  /* QUESTIONS RÉPONDUES */

  SELECT COUNT(*)
  INTO v_answered_questions
  FROM public.revision_session_questions
  WHERE session_id = p_session_id
    AND answered_at IS NOT NULL;

  IF v_answered_questions < v_total_questions THEN
    RAISE EXCEPTION
      'Quiz incomplet : % question(s) sur % répondue(s)',
      v_answered_questions,
      v_total_questions;
  END IF;


  /* SCORE + XP */

  SELECT
    COUNT(*) FILTER (WHERE qa.is_correct = true),
    COALESCE(SUM(qa.xp_earned), 0)
  INTO
    v_correct_count,
    v_xp
  FROM public.question_attempts qa
  WHERE qa.session_id = p_session_id
    AND qa.user_id = v_user_id;


  v_score :=
    ROUND(
      (
        v_correct_count::numeric
        /
        v_total_questions::numeric
      ) * 100,
      2
    );


  /* CLÔTURER LA SESSION */

  UPDATE public.revision_sessions
  SET
    correct_count = v_correct_count,
    xp_earned = v_xp,
    completed_at = now()
  WHERE id = p_session_id;


  /* XP + NIVEAU + FLAMME */

  v_progress :=
    public.update_user_progress(
      v_user_id,
      v_xp
    );


  /* BADGES */

  v_badges :=
    public.check_and_award_badges(
      v_user_id
    );


  /* RÉSULTAT COMPLET */

  RETURN jsonb_build_object(

    'session_id', p_session_id,

    'score', v_score,

    'correct_count', v_correct_count,

    'incorrect_count',
      v_total_questions - v_correct_count,

    'total_questions',
      v_total_questions,

    'xp_earned',
      v_xp,

    'xp_total',
      v_progress->'xp_total',

    'level',
      v_progress->'level',

    'level_name',
      v_progress->'level_name',

    'current_streak',
      v_progress->'current_streak',

    'longest_streak',
      v_progress->'longest_streak',

    'new_badges',
      v_badges->'new_badges',

    'new_badges_count',
      v_badges->'new_badges_count'

  );

END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_gamification_summary_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_xp integer;
  v_level integer;
  v_level_name text;
  v_level_icon text;
  v_required integer;
  v_next_level integer;
  v_next_name text;
  v_next_icon text;
  v_next_required integer;
  v_current_streak integer := 0;
  v_longest_streak integer := 0;
  v_earned integer := 0;
  v_total integer := 0;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;

  select p.xp,p.level,l.name,l.icon,l.required_xp
  into v_xp,v_level,v_level_name,v_level_icon,v_required
  from public.profiles p left join public.levels l on l.level=p.level
  where p.id=v_user_id;

  if v_xp is null then raise exception 'Profil utilisateur introuvable'; end if;

  select level,name,icon,required_xp
  into v_next_level,v_next_name,v_next_icon,v_next_required
  from public.levels
  where required_xp > v_xp
  order by required_xp asc limit 1;

  select coalesce(current_streak,0),coalesce(longest_streak,0)
  into v_current_streak,v_longest_streak
  from public.user_streaks where user_id=v_user_id;

  select count(*) into v_earned from public.user_badges where user_id=v_user_id;
  select count(*) into v_total from public.badges;

  return jsonb_build_object(
    'xp_total',v_xp,
    'level',jsonb_build_object(
      'number',v_level,'name',v_level_name,'icon',v_level_icon,'required_xp',coalesce(v_required,0),
      'next_level',v_next_level,'next_name',v_next_name,'next_icon',v_next_icon,'next_required_xp',v_next_required,
      'xp_to_next',case when v_next_required is null then 0 else greatest(0,v_next_required-v_xp) end,
      'progress_percent',case when v_next_required is null then 100 else least(100,greatest(0,round(100.0*(v_xp-coalesce(v_required,0))/greatest(1,v_next_required-coalesce(v_required,0)))::integer)) end
    ),
    'streak',jsonb_build_object('current',coalesce(v_current_streak,0),'longest',coalesce(v_longest_streak,0)),
    'badges',jsonb_build_object('earned',v_earned,'total',v_total)
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_user_dashboard_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_first_name text;
  v_avatar_url text;
  v_study_year integer;
  v_xp integer := 0;

  v_level integer := 1;
  v_level_name text := 'Débutant';
  v_level_icon text;
  v_level_required_xp integer := 0;
  v_next_level integer;
  v_next_level_name text;
  v_next_level_icon text;
  v_next_level_required_xp integer;
  v_level_progress integer := 100;
  v_xp_to_next integer := 0;

  v_current_streak integer := 0;
  v_longest_streak integer := 0;
  v_last_activity_date date;

  v_published_questions integer := 0;
  v_attempted_questions integer := 0;
  v_mastered_questions integer := 0;
  v_fragile_questions integer := 0;
  v_due_reviews integer := 0;
  v_avg_attempted_mastery numeric := 0;
  v_overall_mastery numeric := 0;
  v_coverage_percent numeric := 0;

  v_completed_sessions integer := 0;
  v_last_session_id uuid;
  v_last_session_mode text;
  v_last_session_correct integer := 0;
  v_last_session_questions integer := 0;
  v_last_session_xp integer := 0;
  v_last_session_completed_at timestamptz;

  v_badges_earned integer := 0;
  v_total_badges integer := 0;

  v_challenge_id uuid;
  v_challenge_title text;
  v_challenge_description text;
  v_challenge_reward integer;
  v_challenge_session_id uuid;
  v_challenge_answered integer := 0;
  v_challenge_total integer := 10;
  v_challenge_completed boolean := false;
  v_challenge_score integer;
  v_challenge_xp integer;
  v_challenge_status text := 'not_created';
begin
  if v_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  select
    p.first_name,
    p.avatar_url,
    p.study_year,
    coalesce(p.xp, 0)
  into
    v_first_name,
    v_avatar_url,
    v_study_year,
    v_xp
  from public.profiles p
  where p.id = v_user_id;

  if not found then
    raise exception 'Profil utilisateur introuvable';
  end if;

  select l.level, l.name, l.icon, l.required_xp
  into v_level, v_level_name, v_level_icon, v_level_required_xp
  from public.levels l
  where l.required_xp <= v_xp
  order by l.required_xp desc
  limit 1;

  if v_level is null then
    v_level := 1;
    v_level_name := 'Débutant';
    v_level_required_xp := 0;
  end if;

  select l.level, l.name, l.icon, l.required_xp
  into v_next_level, v_next_level_name, v_next_level_icon, v_next_level_required_xp
  from public.levels l
  where l.required_xp > v_xp
  order by l.required_xp asc
  limit 1;

  if v_next_level_required_xp is null then
    v_level_progress := 100;
    v_xp_to_next := 0;
  else
    v_xp_to_next := greatest(v_next_level_required_xp - v_xp, 0);
    v_level_progress := least(
      100,
      greatest(
        0,
        round(
          ((v_xp - v_level_required_xp)::numeric /
          greatest(v_next_level_required_xp - v_level_required_xp, 1)::numeric) * 100
        )::integer
      )
    );
  end if;

  select
    coalesce(us.current_streak, 0),
    coalesce(us.longest_streak, 0),
    us.last_activity_date
  into
    v_current_streak,
    v_longest_streak,
    v_last_activity_date
  from public.user_streaks us
  where us.user_id = v_user_id;

  select count(*)
  into v_published_questions
  from public.questions q
  where q.is_published = true;

  select
    count(*) filter (where uqm.attempt_count > 0),
    count(*) filter (where uqm.attempt_count > 0 and uqm.mastery_percent >= 80),
    count(*) filter (where uqm.attempt_count > 0 and uqm.mastery_percent < 60),
    count(*) filter (where uqm.next_review_at is not null and uqm.next_review_at <= now()),
    coalesce(avg(uqm.mastery_percent) filter (where uqm.attempt_count > 0), 0),
    coalesce(sum(uqm.mastery_percent), 0)
  into
    v_attempted_questions,
    v_mastered_questions,
    v_fragile_questions,
    v_due_reviews,
    v_avg_attempted_mastery,
    v_overall_mastery
  from public.user_question_mastery uqm
  join public.questions q on q.id = uqm.question_id
  where uqm.user_id = v_user_id
    and q.is_published = true;

  if v_published_questions > 0 then
    v_coverage_percent := round((v_attempted_questions::numeric / v_published_questions::numeric) * 100, 1);
    v_overall_mastery := round((v_overall_mastery / v_published_questions::numeric), 1);
  else
    v_coverage_percent := 0;
    v_overall_mastery := 0;
  end if;

  v_avg_attempted_mastery := round(v_avg_attempted_mastery, 1);

  select count(*)
  into v_completed_sessions
  from public.revision_sessions rs
  where rs.user_id = v_user_id
    and rs.completed_at is not null;

  select
    rs.id,
    rs.mode,
    rs.correct_count,
    rs.question_count,
    rs.xp_earned,
    rs.completed_at
  into
    v_last_session_id,
    v_last_session_mode,
    v_last_session_correct,
    v_last_session_questions,
    v_last_session_xp,
    v_last_session_completed_at
  from public.revision_sessions rs
  where rs.user_id = v_user_id
    and rs.completed_at is not null
  order by rs.completed_at desc
  limit 1;

  select count(*) into v_badges_earned
  from public.user_badges ub
  where ub.user_id = v_user_id;

  select count(*) into v_total_badges
  from public.badges;

  select
    dc.id,
    dc.title,
    dc.description,
    dc.xp_reward
  into
    v_challenge_id,
    v_challenge_title,
    v_challenge_description,
    v_challenge_reward
  from public.daily_challenges dc
  where dc.challenge_date = current_date
    and dc.is_active = true
  order by dc.created_at desc
  limit 1;

  if v_challenge_id is not null then
    v_challenge_status := 'ready';

    select
      rs.id,
      rs.question_count,
      (rs.completed_at is not null)
    into
      v_challenge_session_id,
      v_challenge_total,
      v_challenge_completed
    from public.revision_sessions rs
    where rs.user_id = v_user_id
      and rs.daily_challenge_id = v_challenge_id
    order by rs.started_at desc
    limit 1;

    if v_challenge_session_id is not null then
      select count(*)
      into v_challenge_answered
      from public.revision_session_questions rsq
      where rsq.session_id = v_challenge_session_id
        and rsq.answered_at is not null;

      if v_challenge_completed then
        v_challenge_status := 'completed';
      elsif v_challenge_answered > 0 then
        v_challenge_status := 'in_progress';
      else
        v_challenge_status := 'ready';
      end if;
    end if;

    select dca.score, dca.xp_earned
    into v_challenge_score, v_challenge_xp
    from public.daily_challenge_attempts dca
    where dca.user_id = v_user_id
      and dca.challenge_id = v_challenge_id
    limit 1;

    if found then
      v_challenge_status := 'completed';
      v_challenge_completed := true;
    end if;
  end if;

  return jsonb_build_object(
    'profile', jsonb_build_object(
      'id', v_user_id,
      'first_name', v_first_name,
      'avatar_url', v_avatar_url,
      'study_year', v_study_year
    ),
    'level', jsonb_build_object(
      'xp_total', v_xp,
      'current_level', v_level,
      'current_name', v_level_name,
      'current_icon', v_level_icon,
      'current_required_xp', v_level_required_xp,
      'next_level', v_next_level,
      'next_name', v_next_level_name,
      'next_icon', v_next_level_icon,
      'next_required_xp', v_next_level_required_xp,
      'xp_to_next', v_xp_to_next,
      'progress_percent', v_level_progress
    ),
    'streak', jsonb_build_object(
      'current', v_current_streak,
      'longest', v_longest_streak,
      'last_activity_date', v_last_activity_date
    ),
    'mastery', jsonb_build_object(
      'published_questions', v_published_questions,
      'attempted_questions', v_attempted_questions,
      'mastered_questions', v_mastered_questions,
      'fragile_questions', v_fragile_questions,
      'reviews_due', v_due_reviews,
      'coverage_percent', v_coverage_percent,
      'average_attempted_percent', v_avg_attempted_mastery,
      'overall_percent', v_overall_mastery
    ),
    'activity', jsonb_build_object(
      'completed_sessions', v_completed_sessions,
      'last_session', case
        when v_last_session_id is null then null
        else jsonb_build_object(
          'id', v_last_session_id,
          'mode', v_last_session_mode,
          'correct_count', v_last_session_correct,
          'question_count', v_last_session_questions,
          'xp_earned', v_last_session_xp,
          'completed_at', v_last_session_completed_at
        )
      end
    ),
    'badges', jsonb_build_object(
      'earned', v_badges_earned,
      'total', v_total_badges
    ),
    'daily_challenge', jsonb_build_object(
      'id', v_challenge_id,
      'title', v_challenge_title,
      'description', v_challenge_description,
      'xp_reward', v_challenge_reward,
      'status', v_challenge_status,
      'session_id', v_challenge_session_id,
      'answered_count', v_challenge_answered,
      'question_count', coalesce(v_challenge_total, 10),
      'score', v_challenge_score,
      'xp_earned', v_challenge_xp,
      'completed', v_challenge_completed
    ),
    'generated_at', now()
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_smart_revision_v2(p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_existing uuid;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  if p_question_count is null or p_question_count < 1 or p_question_count > 50 then
    raise exception 'Nombre de questions invalide';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_uid::text, 0));

  select rs.id
  into v_existing
  from public.revision_sessions rs
  where rs.user_id = v_uid
    and rs.mode = 'smart'
    and rs.completed_at is null
    and rs.abandoned_at is null
    and rs.daily_challenge_id is null
    and rs.challenge_id is null
    and rs.started_at >= now() - interval '12 hours'
    and exists (
      select 1
      from public.revision_session_questions rsq
      where rsq.session_id = rs.id
        and rsq.answered_at is null
    )
  order by rs.started_at desc
  limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  return public.start_smart_revision_v5_internal(v_uid, p_question_count);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_daily_challenge_v2(p_challenge_date date DEFAULT CURRENT_DATE)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_activity_date date:=current_date;
  v_challenge_id uuid;
  v_session_id uuid;
  v_question_count integer:=0;
  v_answered_count integer:=0;
  v_completed_at timestamptz;
  v_attempt_score integer;
  v_attempt_xp integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  v_challenge_id:=public.ensure_daily_challenge_v2(v_activity_date);

  select rs.id,rs.completed_at into v_session_id,v_completed_at
  from public.revision_sessions rs
  where rs.user_id=v_user_id and rs.daily_challenge_id=v_challenge_id
  limit 1;

  if v_session_id is null then
    insert into public.revision_sessions(user_id,mode,question_count,daily_challenge_id)
    values(v_user_id,'daily',10,v_challenge_id)
    returning id into v_session_id;
    insert into public.revision_session_questions(session_id,question_id,display_order)
    select v_session_id,dcq.question_id,dcq.display_order
    from public.daily_challenge_questions dcq
    where dcq.challenge_id=v_challenge_id
    order by dcq.display_order;
  end if;

  select count(*),count(*) filter(where rsq.answered_at is not null)
  into v_question_count,v_answered_count
  from public.revision_session_questions rsq
  where rsq.session_id=v_session_id;

  select dca.score,dca.xp_earned into v_attempt_score,v_attempt_xp
  from public.daily_challenge_attempts dca
  where dca.challenge_id=v_challenge_id and dca.user_id=v_user_id;

  return jsonb_build_object(
    'challenge_id',v_challenge_id,
    'challenge_date',v_activity_date,
    'session_id',v_session_id,
    'question_count',v_question_count,
    'answered_count',v_answered_count,
    'remaining_count',greatest(v_question_count-v_answered_count,0),
    'completed',v_completed_at is not null,
    'score',v_attempt_score,
    'xp_earned',v_attempt_xp,
    'status',case when v_completed_at is not null then 'completed' when v_answered_count>0 then 'in_progress' else 'ready' end
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_daily_challenge_v2(p_session_id uuid, p_activity_date date DEFAULT CURRENT_DATE)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_activity_date date:=current_date;
  v_challenge_id uuid;
  v_total integer:=0;
  v_answered integer:=0;
  v_correct integer:=0;
  v_question_xp integer:=0;
  v_bonus_xp integer:=0;
  v_total_xp integer:=0;
  v_score integer:=0;
  v_progress jsonb;
  v_badges jsonb;
  v_existing public.daily_challenge_attempts%rowtype;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  select rs.daily_challenge_id into v_challenge_id
  from public.revision_sessions rs
  where rs.id=p_session_id and rs.user_id=v_user_id and rs.mode='daily'
  for update;
  if v_challenge_id is null then raise exception 'Challenge inexistant ou accès non autorisé'; end if;

  select * into v_existing from public.daily_challenge_attempts dca
  where dca.challenge_id=v_challenge_id and dca.user_id=v_user_id;
  if v_existing.id is not null then
    select public.get_user_dashboard_v2() into v_progress;
    return jsonb_build_object('challenge_id',v_challenge_id,'session_id',p_session_id,'score',v_existing.score,'total_questions',v_existing.total_questions,'xp_earned',v_existing.xp_earned,'completed',true,'already_rewarded',true,'dashboard',v_progress);
  end if;

  select count(*),count(*) filter(where rsq.answered_at is not null)
  into v_total,v_answered from public.revision_session_questions rsq where rsq.session_id=p_session_id;
  if v_total<>10 then raise exception 'Le Challenge du jour doit contenir exactement 10 questions'; end if;
  if v_answered<>v_total then raise exception 'Challenge incomplet : % question(s) sur % répondue(s)',v_answered,v_total; end if;

  select count(*) filter(where qa.is_correct=true),coalesce(sum(qa.xp_earned),0)
  into v_correct,v_question_xp from public.question_attempts qa where qa.session_id=p_session_id and qa.user_id=v_user_id;
  v_score:=round((v_correct::numeric/v_total::numeric)*100)::integer;
  select coalesce(dc.xp_reward,0) into v_bonus_xp from public.daily_challenges dc where dc.id=v_challenge_id;
  v_total_xp:=v_question_xp+coalesce(v_bonus_xp,0);

  insert into public.daily_challenge_attempts(challenge_id,user_id,score,total_questions,xp_earned,completed_at)
  values(v_challenge_id,v_user_id,v_score,v_total,v_total_xp,now());
  update public.revision_sessions set correct_count=v_correct,xp_earned=v_total_xp,completed_at=coalesce(completed_at,now()) where id=p_session_id;
  v_progress:=public.update_user_progress_v2(v_user_id,v_total_xp,v_activity_date);
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object('challenge_id',v_challenge_id,'session_id',p_session_id,'score',v_score,'correct_count',v_correct,'incorrect_count',v_total-v_correct,'total_questions',v_total,'question_xp',v_question_xp,'bonus_xp',v_bonus_xp,'xp_earned',v_total_xp,'xp_total',v_progress->'xp_total','level',v_progress->'level','level_name',v_progress->'level_name','current_streak',v_progress->'current_streak','longest_streak',v_progress->'longest_streak','last_activity_date',v_progress->'last_activity_date','new_badges',v_badges->'new_badges','new_badges_count',v_badges->'new_badges_count','completed',true,'already_rewarded',false);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_user_stats_v2(p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_days integer;
  v_result jsonb;
begin
  if v_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  v_days := greatest(7, least(coalesce(p_days,30), 365));

  with
  attempts as (
    select qa.* from public.question_attempts qa where qa.user_id=v_user_id
  ),
  completed_sessions as (
    select rs.* from public.revision_sessions rs where rs.user_id=v_user_id and rs.completed_at is not null
  ),
  overall as (
    select count(*)::integer attempts_count,
           count(*) filter(where is_correct)::integer correct_count,
           coalesce(round(avg(response_time_ms))::integer,0) avg_response_ms
    from attempts
  ),
  session_totals as (
    select count(*)::integer completed_sessions_count from completed_sessions
  ),
  mastery as (
    select count(*) filter(where attempt_count>0)::integer attempted_questions,
           count(*) filter(where mastery_percent>=80)::integer mastered_questions,
           count(*) filter(where mastery_percent<60 and attempt_count>0)::integer fragile_questions,
           count(*) filter(where next_review_at is not null and next_review_at<=now())::integer reviews_due,
           coalesce(round(avg(mastery_percent))::integer,0) avg_mastery
    from public.user_question_mastery
    where user_id=v_user_id
  ),
  daily_series as (
    select generate_series(current_date-(v_days-1),current_date,interval '1 day')::date as activity_date
  ),
  daily_agg as (
    select date(created_at) as activity_date,
           count(*)::integer attempts_count,
           count(*) filter(where is_correct)::integer correct_count,
           coalesce(sum(xp_earned),0)::integer xp_sum
    from attempts
    where created_at>=current_date-(v_days-1)
    group by date(created_at)
  ),
  daily_json as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'date',ds.activity_date,
      'attempts',coalesce(da.attempts_count,0),
      'correct',coalesce(da.correct_count,0),
      'accuracy_percent',case when coalesce(da.attempts_count,0)=0 then 0 else round(100.0*da.correct_count/da.attempts_count)::integer end,
      'xp',coalesce(da.xp_sum,0)
    ) order by ds.activity_date),'[]'::jsonb) as data
    from daily_series ds
    left join daily_agg da on da.activity_date=ds.activity_date
  ),
  subject_question_base as (
    select s.id as subject_id,s.name,s.slug,s.icon,y.number as year_number,y.name as year_name,s.display_order,q.id as question_id
    from public.subjects s
    join public.years y on y.id=s.year_id
    left join public.chapters c on c.subject_id=s.id and c.is_active=true
    left join public.questions q on q.chapter_id=c.id and q.is_published=true
    where s.is_active=true and y.is_active=true
  ),
  subject_content as (
    select subject_id,max(name) as name,max(slug) as slug,max(icon) as icon,max(year_number) as year_number,max(year_name) as year_name,max(display_order) as display_order,
           count(question_id)::integer as published_questions
    from subject_question_base group by subject_id
  ),
  subject_mastery as (
    select sqb.subject_id,
           count(uqm.question_id) filter(where uqm.attempt_count>0)::integer as attempted_questions,
           coalesce(round(avg(uqm.mastery_percent))::integer,0) as mastery_percent,
           count(uqm.question_id) filter(where uqm.mastery_percent>=80)::integer as mastered_questions,
           count(uqm.question_id) filter(where uqm.mastery_percent<60 and uqm.attempt_count>0)::integer as fragile_questions
    from subject_question_base sqb
    left join public.user_question_mastery uqm on uqm.question_id=sqb.question_id and uqm.user_id=v_user_id
    group by sqb.subject_id
  ),
  subject_attempts as (
    select sqb.subject_id,
           count(a.id)::integer as attempts_count,
           count(a.id) filter(where a.is_correct)::integer as correct_attempts
    from subject_question_base sqb
    left join attempts a on a.question_id=sqb.question_id
    group by sqb.subject_id
  ),
  subject_rows as (
    select sc.*,coalesce(sm.attempted_questions,0) as attempted_questions,coalesce(sm.mastery_percent,0) as mastery_percent,
           coalesce(sm.mastered_questions,0) as mastered_questions,coalesce(sm.fragile_questions,0) as fragile_questions,
           coalesce(sa.attempts_count,0) as attempts_count,coalesce(sa.correct_attempts,0) as correct_attempts
    from subject_content sc
    left join subject_mastery sm on sm.subject_id=sc.subject_id
    left join subject_attempts sa on sa.subject_id=sc.subject_id
  ),
  subjects_json as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'id',subject_id,'name',name,'slug',slug,'icon',icon,'year_number',year_number,'year_name',year_name,
      'published_questions',published_questions,'attempted_questions',attempted_questions,
      'coverage_percent',case when published_questions=0 then 0 else round(100.0*attempted_questions/published_questions)::integer end,
      'attempts',attempts_count,'correct_attempts',correct_attempts,
      'accuracy_percent',case when attempts_count=0 then 0 else round(100.0*correct_attempts/attempts_count)::integer end,
      'mastery_percent',mastery_percent,'mastered_questions',mastered_questions,'fragile_questions',fragile_questions
    ) order by year_number,display_order,name),'[]'::jsonb) as data
    from subject_rows
  ),
  mode_rows as (
    select mode,count(*)::integer as sessions_count,coalesce(sum(question_count),0)::integer as questions_count,
           coalesce(sum(correct_count),0)::integer as correct_count,coalesce(sum(xp_earned),0)::integer as xp_sum
    from completed_sessions group by mode
  ),
  modes_json as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'mode',mode,'sessions',sessions_count,'questions',questions_count,'correct',correct_count,
      'accuracy_percent',case when questions_count=0 then 0 else round(100.0*correct_count/questions_count)::integer end,'xp',xp_sum
    ) order by sessions_count desc,mode),'[]'::jsonb) as data from mode_rows
  ),
  weak_rows as (
    select q.id as question_id,left(q.question_text,180) as question_text,q.type,q.difficulty,s.name as subject_name,
           uqm.attempt_count,uqm.correct_count,uqm.mastery_percent,uqm.lapse_count,uqm.next_review_at,
           case when uqm.attempt_count=0 then 0 else round(100.0*uqm.correct_count/uqm.attempt_count)::integer end as accuracy_percent
    from public.user_question_mastery uqm
    join public.questions q on q.id=uqm.question_id and q.is_published=true
    join public.chapters c on c.id=q.chapter_id
    join public.subjects s on s.id=c.subject_id
    where uqm.user_id=v_user_id and uqm.attempt_count>0 and uqm.mastery_percent<80
    order by uqm.mastery_percent asc,uqm.lapse_count desc,uqm.attempt_count desc,uqm.last_attempt_at desc
    limit 10
  ),
  weak_json as (
    select coalesce(jsonb_agg(jsonb_build_object(
      'question_id',question_id,'question_text',question_text,'type',type,'difficulty',difficulty,'subject_name',subject_name,
      'attempt_count',attempt_count,'correct_count',correct_count,'accuracy_percent',accuracy_percent,
      'mastery_percent',mastery_percent,'lapse_count',lapse_count,'next_review_at',next_review_at
    )),'[]'::jsonb) as data from weak_rows
  )
  select jsonb_build_object(
    'period_days',v_days,
    'generated_at',now(),
    'summary',jsonb_build_object(
      'attempts',o.attempts_count,
      'correct_answers',o.correct_count,
      'incorrect_answers',o.attempts_count-o.correct_count,
      'accuracy_percent',case when o.attempts_count=0 then 0 else round(100.0*o.correct_count/o.attempts_count)::integer end,
      'avg_response_ms',o.avg_response_ms,
      'completed_sessions',st.completed_sessions_count,
      'xp_total',coalesce(p.xp,0),
      'level',coalesce(p.level,1),
      'attempted_questions',m.attempted_questions,
      'mastered_questions',m.mastered_questions,
      'fragile_questions',m.fragile_questions,
      'reviews_due',m.reviews_due,
      'mastery_percent',m.avg_mastery),
    'daily_activity',dj.data,
    'subjects',sj.data,
    'modes',mj.data,
    'weak_questions',wj.data
  ) into v_result
  from overall o
  cross join session_totals st
  cross join mastery m
  cross join daily_json dj
  cross join subjects_json sj
  cross join modes_json mj
  cross join weak_json wj
  join public.profiles p on p.id=v_user_id;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.update_user_progress_v2(p_user_id uuid, p_xp_earned integer DEFAULT 0, p_activity_date date DEFAULT CURRENT_DATE)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_total_xp integer;
  v_level integer;
  v_level_name text;
  v_last_activity date;
  v_current_streak integer := 0;
  v_longest_streak integer := 0;
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;
  if auth.uid() <> p_user_id then
    raise exception 'Accès non autorisé';
  end if;
  if p_xp_earned < 0 then
    raise exception 'XP invalide';
  end if;
  if p_activity_date is null then
    raise exception 'Date d''activité invalide';
  end if;

  perform set_config('kineo.internal_update', 'on', true);

  update public.profiles
  set xp = coalesce(xp, 0) + p_xp_earned
  where id = p_user_id
  returning xp into v_total_xp;

  if not found then
    raise exception 'Profil utilisateur introuvable';
  end if;

  select l.level, l.name
    into v_level, v_level_name
  from public.levels l
  where l.required_xp <= v_total_xp
  order by l.required_xp desc
  limit 1;

  if v_level is null then
    v_level := 1;
    v_level_name := 'Débutant';
  end if;

  update public.profiles set level = v_level where id = p_user_id;

  insert into public.user_streaks (
    user_id, current_streak, longest_streak, last_activity_date, updated_at
  ) values (
    p_user_id, 1, 1, p_activity_date, now()
  )
  on conflict (user_id) do nothing;

  select us.last_activity_date, us.current_streak, us.longest_streak
    into v_last_activity, v_current_streak, v_longest_streak
  from public.user_streaks us
  where us.user_id = p_user_id
  for update;

  if v_last_activity is null then
    v_current_streak := 1;
    v_longest_streak := greatest(coalesce(v_longest_streak,0),1);
    v_last_activity := p_activity_date;
  elsif p_activity_date < v_last_activity then
    null;
  elsif p_activity_date = v_last_activity then
    null;
  elsif p_activity_date = v_last_activity + 1 then
    v_current_streak := coalesce(v_current_streak,0) + 1;
    v_longest_streak := greatest(coalesce(v_longest_streak,0), v_current_streak);
    v_last_activity := p_activity_date;
  else
    v_current_streak := 1;
    v_longest_streak := greatest(coalesce(v_longest_streak,0),1);
    v_last_activity := p_activity_date;
  end if;

  update public.user_streaks
  set current_streak = v_current_streak,
      longest_streak = v_longest_streak,
      last_activity_date = v_last_activity,
      updated_at = now()
  where user_id = p_user_id;

  return jsonb_build_object(
    'xp_total', v_total_xp,
    'level', v_level,
    'level_name', v_level_name,
    'current_streak', v_current_streak,
    'longest_streak', v_longest_streak,
    'last_activity_date', v_last_activity
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_content_review_status_v1(p_kind text, p_id uuid, p_status text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  v_current text;
  v_published boolean;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;
  IF p_kind NOT IN ('lesson','question') THEN
    RAISE EXCEPTION 'Invalid content kind';
  END IF;
  IF p_status NOT IN ('draft','review','validated','published') THEN
    RAISE EXCEPTION 'Invalid status';
  END IF;

  IF p_kind = 'lesson' THEN
    SELECT validation_status INTO v_current FROM public.lessons WHERE id = p_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Lesson not found'; END IF;
    IF p_status = 'published' AND v_current <> 'validated' THEN
      RAISE EXCEPTION 'Lesson must be validated before publication';
    END IF;

    UPDATE public.lessons
    SET validation_status = p_status,
        is_published = (p_status = 'published'),
        validated_at = CASE WHEN p_status IN ('validated','published') THEN COALESCE(validated_at, now()) ELSE NULL END,
        validated_by = CASE WHEN p_status IN ('validated','published') THEN COALESCE(validated_by, auth.uid()) ELSE NULL END,
        updated_at = now()
    WHERE id = p_id
    RETURNING is_published INTO v_published;
  ELSE
    SELECT validation_status INTO v_current FROM public.questions WHERE id = p_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Question not found'; END IF;
    IF p_status = 'published' AND v_current <> 'validated' THEN
      RAISE EXCEPTION 'Question must be validated before publication';
    END IF;

    UPDATE public.questions
    SET validation_status = p_status,
        is_published = (p_status = 'published'),
        validated_at = CASE WHEN p_status IN ('validated','published') THEN COALESCE(validated_at, now()) ELSE NULL END,
        validated_by = CASE WHEN p_status IN ('validated','published') THEN COALESCE(validated_by, auth.uid()) ELSE NULL END,
        updated_at = now()
    WHERE id = p_id
    RETURNING is_published INTO v_published;
  END IF;

  RETURN jsonb_build_object('kind', p_kind, 'id', p_id, 'status', p_status, 'published', v_published);
END;
$function$
;
CREATE OR REPLACE FUNCTION public.get_atlas_stats_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select coalesce(jsonb_agg(jsonb_build_object(
    'area', a.area,
    'attempts', a.attempts,
    'best_accuracy_percent', a.best_accuracy_percent,
    'best_duration_ms', a.best_duration_ms,
    'last_played_at', a.last_played_at
  ) order by a.area), '[]'::jsonb)
  from (
    select distinct on (area)
      area,
      count(*) over (partition by area)::integer as attempts,
      first_value(accuracy_percent) over (partition by area order by accuracy_percent desc, duration_ms asc, created_at asc) as best_accuracy_percent,
      first_value(duration_ms) over (partition by area order by accuracy_percent desc, duration_ms asc, created_at asc) as best_duration_ms,
      max(created_at) over (partition by area) as last_played_at
    from public.atlas_attempts
    where user_id = auth.uid()
    order by area, created_at desc
  ) a;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friendships_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (select auth.uid() as uid),
  accepted as (
    select f.id,
           case when f.requester_id = me.uid then f.addressee_id else f.requester_id end as friend_id,
           f.updated_at
    from public.friendships f cross join me
    where me.uid is not null
      and f.status = 'accepted'
      and (f.requester_id = me.uid or f.addressee_id = me.uid)
  ),
  incoming as (
    select f.id, f.requester_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.addressee_id = me.uid and f.status = 'pending'
  ),
  outgoing as (
    select f.id, f.addressee_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.requester_id = me.uid and f.status = 'pending'
  )
  select jsonb_build_object(
    'friends', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', a.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level) order by p.username) from accepted a join public.profiles p on p.id = a.friend_id), '[]'::jsonb),
    'incoming', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', i.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'created_at', i.created_at) order by i.created_at desc) from incoming i join public.profiles p on p.id = i.user_id), '[]'::jsonb),
    'outgoing', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', o.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'created_at', o.created_at) order by o.created_at desc) from outgoing o join public.profiles p on p.id = o.user_id), '[]'::jsonb)
  );
$function$
;
CREATE OR REPLACE FUNCTION public.get_quiz_questions_v4(p_session_id uuid)
 RETURNS TABLE(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(
    select 1
    from public.revision_sessions rs
    where rs.id=p_session_id
      and rs.user_id=auth.uid()
      and rs.abandoned_at is null
  ) then
    raise exception 'Session inexistante, abandonnée ou accès non autorisé';
  end if;

  return query
  select
    q.id,
    q.type,
    q.question_text,
    null::text,
    q.difficulty,
    q.image_url,
    case
      when q.type='matching' then jsonb_build_object(
        'left_items',coalesce((
          select jsonb_agg(e.value->'left' order by e.ord)
          from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality e(value,ord)
        ),'[]'::jsonb),
        'right_items',coalesce((
          select jsonb_agg(r.right_value order by random())
          from (
            select e.value->'right' right_value
            from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) e(value)
          ) r
        ),'[]'::jsonb)
      )
      else coalesce(q.metadata,'{}'::jsonb)-'answer'-'accepted_answers'-'correct_answer'-'is_correct'-'pairs'
    end,
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id',qo.id,
          'option_text',qo.option_text,
          'display_order',qo.display_order
        )
        order by qo.display_order
      )
      from public.question_options qo
      where qo.question_id=q.id
    ),'[]'::jsonb),
    row_number() over(order by q.difficulty asc, rsq.display_order asc)::int
  from public.revision_session_questions rsq
  join public.questions q on q.id=rsq.question_id
  join public.revision_sessions rs on rs.id=rsq.session_id
  where rsq.session_id=p_session_id
    and rs.abandoned_at is null
    and rsq.answered_at is null
    and q.is_published=true
    and q.validation_status='published'
  order by q.difficulty asc, rsq.display_order asc;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_course_document_v1(p_document_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare v_doc jsonb;
begin
 if auth.uid() is null or not exists(select 1 from public.profiles where id=auth.uid()) then
  raise exception 'Utilisateur non authentifié';
 end if;
 select jsonb_build_object('id',d.id,'title',d.title,'file_name',d.file_name,
  'storage_path',d.storage_path,'mime_type',d.mime_type,'file_size',d.file_size)
 into v_doc from public.course_documents d
 where d.id=p_document_id and d.validation_status='validated' and d.mime_type='application/pdf'
  and exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path);
 if v_doc is null then raise exception 'Support indisponible'; end if;
 return v_doc;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_my_library_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object(
    'favorites', coalesce((select jsonb_agg(jsonb_build_object('id',l.id,'title',l.title,'summary',l.summary,'subject',s.name,'year',y.number,'created_at',f.created_at) order by f.created_at desc) from public.favorites f join public.lessons l on l.id=f.content_id and f.content_type='lesson' join public.chapters c on c.id=l.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id where f.user_id=auth.uid()),'[]'::jsonb),
    'notes', coalesce((select jsonb_agg(jsonb_build_object('id',un.id,'lesson_id',l.id,'title',l.title,'content',un.content,'subject',s.name,'year',y.number,'updated_at',un.updated_at) order by un.updated_at desc) from public.user_notes un join public.lessons l on l.id=un.lesson_id join public.chapters c on c.id=l.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id where un.user_id=auth.uid() and un.lesson_id is not null),'[]'::jsonb)
  )
  where auth.uid() is not null;
$function$
;
CREATE OR REPLACE FUNCTION public.notify_level_up_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_result jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  with lesson_stats as (
    select l.id as lesson_id,
      count(q.id)::integer as published_questions,
      count(uqm.question_id) filter(where uqm.attempt_count>0)::integer as attempted_questions,
      coalesce(round(avg(uqm.mastery_percent))::integer,0) as mastery_percent,
      (select count(*)::integer from public.lesson_sources lsrc where lsrc.lesson_id=l.id) as source_document_count,
      exists(select 1 from public.lesson_sources lsrc join public.course_documents cd on cd.id=lsrc.document_id where lsrc.lesson_id=l.id and cd.validation_status='validated') as has_validated_source
    from public.lessons l
    left join public.questions q on q.lesson_id=l.id
      and q.is_published=true
      and q.validation_status='published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
    left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
    where l.is_published=true and l.validation_status='published'
    group by l.id
  ), lesson_rows as (
    select l.id,l.chapter_id,l.title,l.slug,l.summary,l.image_url,l.display_order,
      coalesce(ls.published_questions,0) as published_questions,coalesce(ls.attempted_questions,0) as attempted_questions,
      coalesce(ls.mastery_percent,0) as mastery_percent,coalesce(ls.source_document_count,0) as source_document_count,
      coalesce(ls.has_validated_source,false) as has_validated_source
    from public.lessons l left join lesson_stats ls on ls.lesson_id=l.id
    where l.is_published=true and l.validation_status='published'
  ), chapter_rows as (
    select c.id,c.subject_id,c.name,c.slug,c.description,c.display_order,
      coalesce((select jsonb_agg(jsonb_build_object(
        'id',lr.id,'title',lr.title,'slug',lr.slug,'summary',lr.summary,'image_url',lr.image_url,
        'published_questions',lr.published_questions,'attempted_questions',lr.attempted_questions,'mastery_percent',lr.mastery_percent,
        'coverage_percent',case when lr.published_questions=0 then 0 else round(100.0*lr.attempted_questions/lr.published_questions)::integer end,
        'source_document_count',lr.source_document_count,'has_validated_source',lr.has_validated_source
      ) order by lr.display_order,lr.title) from lesson_rows lr where lr.chapter_id=c.id),'[]'::jsonb) as lessons,
      (select count(*) from lesson_rows lr where lr.chapter_id=c.id)::integer as lesson_count,
      (select count(q.id) from public.questions q where q.chapter_id=c.id
        and q.is_published=true and q.validation_status='published'
        and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case'))::integer as published_questions
    from public.chapters c where c.is_active=true
  ), subject_rows as (
    select s.id,s.year_id,s.name,s.slug,s.description,s.icon,s.display_order,
      coalesce((select jsonb_agg(jsonb_build_object('id',cr.id,'name',cr.name,'slug',cr.slug,'description',cr.description,'lesson_count',cr.lesson_count,'published_questions',cr.published_questions,'lessons',cr.lessons) order by cr.display_order,cr.name) from chapter_rows cr where cr.subject_id=s.id and (cr.lesson_count>0 or cr.published_questions>0)),'[]'::jsonb) as chapters,
      (select count(*) from chapter_rows cr where cr.subject_id=s.id and (cr.lesson_count>0 or cr.published_questions>0))::integer as chapter_count
    from public.subjects s where s.is_active=true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',y.id,'number',y.number,'name',y.name,'description',y.description,
    'subjects',coalesce((select jsonb_agg(jsonb_build_object('id',sr.id,'name',sr.name,'slug',sr.slug,'description',sr.description,'icon',sr.icon,'chapter_count',sr.chapter_count,'chapters',sr.chapters) order by sr.display_order,sr.name) from subject_rows sr where sr.year_id=y.id and sr.chapter_count>0),'[]'::jsonb)
  ) order by y.number),'[]'::jsonb) into v_result
  from public.years y where y.is_active=true;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friendships_v3(p_program_id text)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (select auth.uid() as uid),
  my_program as (
    select pp.academic_level_id
    from public.profile_programs pp cross join me
    where pp.user_id = me.uid and pp.program_id = p_program_id
    order by pp.is_primary desc
    limit 1
  ),
  accepted as (
    select f.id,
           case when f.requester_id = me.uid then f.addressee_id else f.requester_id end as friend_id,
           f.updated_at
    from public.friendships f cross join me
    where me.uid is not null
      and f.status = 'accepted'
      and (f.requester_id = me.uid or f.addressee_id = me.uid)
  ),
  incoming as (
    select f.id, f.requester_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.addressee_id = me.uid and f.status = 'pending'
  ),
  outgoing as (
    select f.id, f.addressee_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.requester_id = me.uid and f.status = 'pending'
  ),
  friend_rows as (
    select a.id as friendship_id,p.id,p.username::text as username,p.first_name,p.study_year,p.level,p.avatar_url,a.updated_at,
           pp.program_id,al.code::text as level_code,
           (pp.academic_level_id is not null and pp.academic_level_id = (select academic_level_id from my_program)) as same_level
    from accepted a
    join public.profiles p on p.id = a.friend_id
    join public.profile_programs pp on pp.user_id = p.id and pp.program_id = p_program_id
    left join public.academic_levels al on al.id = pp.academic_level_id
  ),
  incoming_rows as (
    select i.id as friendship_id,p.id,p.username::text as username,p.first_name,p.study_year,p.level,p.avatar_url,i.created_at,
           pp.program_id,al.code::text as level_code,
           (pp.academic_level_id is not null and pp.academic_level_id = (select academic_level_id from my_program)) as same_level
    from incoming i
    join public.profiles p on p.id = i.user_id
    join public.profile_programs pp on pp.user_id = p.id and pp.program_id = p_program_id
    left join public.academic_levels al on al.id = pp.academic_level_id
  ),
  outgoing_rows as (
    select o.id as friendship_id,p.id,p.username::text as username,p.first_name,p.study_year,p.level,p.avatar_url,o.created_at,
           pp.program_id,al.code::text as level_code,
           (pp.academic_level_id is not null and pp.academic_level_id = (select academic_level_id from my_program)) as same_level
    from outgoing o
    join public.profiles p on p.id = o.user_id
    join public.profile_programs pp on pp.user_id = p.id and pp.program_id = p_program_id
    left join public.academic_levels al on al.id = pp.academic_level_id
  )
  select jsonb_build_object(
    'friends', coalesce((select jsonb_agg(to_jsonb(fr) order by fr.username) from friend_rows fr), '[]'::jsonb),
    'incoming', coalesce((select jsonb_agg(to_jsonb(ir) order by ir.created_at desc) from incoming_rows ir), '[]'::jsonb),
    'outgoing', coalesce((select jsonb_agg(to_jsonb(orr) order by orr.created_at desc) from outgoing_rows orr), '[]'::jsonb)
  );
$function$
;
CREATE OR REPLACE FUNCTION public.get_active_revision_session_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object(
    'id', rs.id,
    'mode', rs.mode,
    'question_count', rs.question_count,
    'answered_count', (select count(*) from public.revision_session_questions rsq where rsq.session_id=rs.id and rsq.answered_at is not null),
    'started_at', rs.started_at
  )
  from public.revision_sessions rs
  where rs.user_id=auth.uid()
    and rs.completed_at is null
    and rs.abandoned_at is null
    and rs.daily_challenge_id is null
    and rs.challenge_id is null
    and rs.started_at >= now()-interval '7 days'
  order by rs.started_at desc
  limit 1;
$function$
;
CREATE OR REPLACE FUNCTION public.start_lesson_quiz_v2(p_lesson_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  return public.start_lesson_quiz_v3_internal(auth.uid(), p_lesson_id, p_question_count);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_lesson_v2(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_result jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  select jsonb_build_object(
    'id',l.id,'title',l.title,'slug',l.slug,'summary',l.summary,'content',l.content,
    'key_points',coalesce(l.key_points,'[]'::jsonb),'sources',coalesce(l.sources,'[]'::jsonb),'image_url',l.image_url,
    'validation_status',l.validation_status,'source_document',l.source_document,
    'source_documents',coalesce((select jsonb_agg(jsonb_build_object('id',cd.id,'available',(cd.validation_status='validated' and exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=cd.storage_path)),'title',cd.title,'validation_status',cd.validation_status,'page_start',ls.page_start,'page_end',ls.page_end) order by cd.title,ls.page_start) from public.lesson_sources ls join public.course_documents cd on cd.id=ls.document_id where ls.lesson_id=l.id),'[]'::jsonb),
    'chapter',jsonb_build_object('id',c.id,'name',c.name,'slug',c.slug),
    'subject',jsonb_build_object('id',s.id,'name',s.name,'slug',s.slug,'icon',s.icon),
    'year',jsonb_build_object('number',y.number,'name',y.name),
    'question_count',(select count(*) from public.questions q where q.lesson_id=l.id and q.is_published=true and q.validation_status='published' and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image')),
    'attempted_questions',(select count(distinct qa.question_id) from public.questions q join public.question_attempts qa on qa.question_id=q.id and qa.user_id=v_user_id where q.lesson_id=l.id and q.is_published=true and q.validation_status='published' and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image')),
    'mastery_percent',coalesce((select round(avg(uqm.mastery_percent))::integer from public.questions q left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id where q.lesson_id=l.id and q.is_published=true and q.validation_status='published' and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image')),0)
  ) into v_result
  from public.lessons l join public.chapters c on c.id=l.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
  where l.id=p_lesson_id and l.is_published=true and l.validation_status='published' and c.is_active=true and s.is_active=true and y.is_active=true;
  if v_result is null then raise exception 'Leçon inexistante ou non publiée'; end if;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_course_documents_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 if auth.uid() is null or not exists(select 1 from public.profiles where id=auth.uid()) then
  raise exception 'Utilisateur non authentifié';
 end if;
 return coalesce((select jsonb_agg(jsonb_build_object('id',d.id,'title',d.title,
  'file_name',d.file_name,'file_size',d.file_size) order by d.title)
 from public.course_documents d where d.validation_status='validated' and d.mime_type='application/pdf'
  and exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path)),'[]'::jsonb);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_content_review_queue_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  SELECT jsonb_build_object(
    'lessons', COALESCE(jsonb_agg(item ORDER BY item->>'year_number', item->>'subject_name', item->>'title'), '[]'::jsonb),
    'counts', jsonb_build_object(
      'review', COUNT(*) FILTER (WHERE item->>'validation_status' = 'review'),
      'validated', COUNT(*) FILTER (WHERE item->>'validation_status' = 'validated'),
      'published', COUNT(*) FILTER (WHERE item->>'validation_status' = 'published')
    )
  )
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', l.id,
      'title', l.title,
      'summary', l.summary,
      'content', l.content,
      'key_points', l.key_points,
      'sources', l.sources,
      'validation_status', l.validation_status,
      'is_published', l.is_published,
      'validated_at', l.validated_at,
      'year_number', y.number,
      'subject_name', s.name,
      'chapter_name', c.name,
      'question_count', COUNT(q.id),
      'review_questions', COUNT(q.id) FILTER (WHERE q.validation_status = 'review'),
      'validated_questions', COUNT(q.id) FILTER (WHERE q.validation_status = 'validated'),
      'published_questions', COUNT(q.id) FILTER (WHERE q.is_published = true),
      'questions', COALESCE(jsonb_agg(
        jsonb_build_object(
          'id', q.id,
          'type', q.type,
          'question_text', q.question_text,
          'explanation', q.explanation,
          'difficulty', q.difficulty,
          'source', q.source,
          'source_document', q.source_document,
          'validation_status', q.validation_status,
          'is_published', q.is_published
        ) ORDER BY q.created_at
      ) FILTER (WHERE q.id IS NOT NULL), '[]'::jsonb)
    ) AS item
    FROM public.lessons l
    JOIN public.chapters c ON c.id = l.chapter_id
    JOIN public.subjects s ON s.id = c.subject_id
    JOIN public.years y ON y.id = s.year_id
    LEFT JOIN public.questions q ON q.lesson_id = l.id
    WHERE l.validation_status IN ('review','validated','published')
       OR EXISTS (
         SELECT 1 FROM public.questions q2
         WHERE q2.lesson_id = l.id AND q2.validation_status IN ('review','validated','published')
       )
    GROUP BY l.id, y.number, s.name, c.name
  ) review_items;

  RETURN COALESCE(v_result, jsonb_build_object('lessons','[]'::jsonb,'counts',jsonb_build_object('review',0,'validated',0,'published',0)));
END;
$function$
;
CREATE OR REPLACE FUNCTION public.publish_lesson_bundle_v1(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  v_lesson_status text;
  v_total integer;
  v_ready integer;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin access required';
  END IF;

  SELECT validation_status INTO v_lesson_status
  FROM public.lessons
  WHERE id = p_lesson_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Lesson not found';
  END IF;
  IF v_lesson_status <> 'validated' THEN
    RAISE EXCEPTION 'Lesson must be validated before publication';
  END IF;

  SELECT count(*), count(*) FILTER (WHERE validation_status = 'validated')
  INTO v_total, v_ready
  FROM public.questions
  WHERE lesson_id = p_lesson_id;

  IF v_total = 0 THEN
    RAISE EXCEPTION 'Lesson has no questions';
  END IF;
  IF v_ready <> v_total THEN
    RAISE EXCEPTION 'All lesson questions must be validated before publication';
  END IF;

  UPDATE public.lessons
  SET validation_status = 'published',
      is_published = true,
      validated_at = COALESCE(validated_at, now()),
      validated_by = COALESCE(validated_by, auth.uid()),
      updated_at = now()
  WHERE id = p_lesson_id;

  UPDATE public.questions
  SET validation_status = 'published',
      is_published = true,
      validated_at = COALESCE(validated_at, now()),
      validated_by = COALESCE(validated_by, auth.uid()),
      updated_at = now()
  WHERE lesson_id = p_lesson_id
    AND validation_status = 'validated';

  RETURN jsonb_build_object('lesson_id', p_lesson_id, 'published_questions', v_total, 'status', 'published');
END;
$function$
;
CREATE OR REPLACE FUNCTION public.start_smart_revision_v3_internal(p_user_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_session_id uuid;
  v_actual_count integer;
  v_study_year integer;
begin
  if p_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;
  if p_question_count is null or p_question_count < 1 or p_question_count > 50 then
    raise exception 'Nombre de questions invalide';
  end if;

  select p.study_year into v_study_year
  from public.profiles p
  where p.id = p_user_id;

  insert into public.revision_sessions(user_id, mode, question_count)
  values(p_user_id, 'smart', p_question_count)
  returning id into v_session_id;

  with candidates as (
    select
      q.id,
      coalesce(uqm.mastery_percent, 0) as mastery_percent,
      coalesce(uqm.attempt_count, 0) as attempt_count,
      coalesce(uqm.correct_count, 0) as correct_count,
      uqm.last_attempt_at,
      uqm.next_review_at,
      coalesce(uqm.lapse_count, 0) as lapse_count,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now() then 1
        when uqm.id is not null and coalesce(uqm.correct_count,0) < coalesce(uqm.attempt_count,0) then 2
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 60 then 3
        when uqm.id is null then 4
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 80 then 5
        else 6
      end as priority_group,
      case when exists (
        select 1 from public.question_attempts qa
        where qa.user_id = p_user_id
          and qa.question_id = q.id
          and qa.created_at >= now() - interval '12 hours'
      ) then 1 else 0 end as recent_penalty,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now()
          then extract(epoch from (now() - uqm.next_review_at)) / 86400.0
        else 0
      end as overdue_days
    from public.questions q
    join public.chapters c on c.id = q.chapter_id
    join public.subjects s on s.id = c.subject_id
    join public.years y on y.id = s.year_id
    left join public.user_question_mastery uqm
      on uqm.question_id = q.id and uqm.user_id = p_user_id
    where q.is_published = true
      and c.is_active = true
      and s.is_active = true
      and y.is_active = true
      and (v_study_year is null or y.number = v_study_year)
  ), ranked as (
    select c.*,
      row_number() over (
        order by
          c.priority_group asc,
          c.recent_penalty asc,
          c.overdue_days desc,
          c.lapse_count desc,
          c.mastery_percent asc,
          c.last_attempt_at asc nulls first,
          random()
      ) as rn
    from candidates c
  )
  insert into public.revision_session_questions(session_id, question_id, display_order)
  select v_session_id, r.id, r.rn::integer
  from ranked r
  where r.rn <= p_question_count
  order by r.rn;

  select count(*) into v_actual_count
  from public.revision_session_questions
  where session_id = v_session_id;

  if v_actual_count = 0 then
    delete from public.revision_sessions where id = v_session_id;
    raise exception 'Aucune question publiée disponible pour cette année';
  end if;

  update public.revision_sessions
  set question_count = v_actual_count
  where id = v_session_id;

  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_revision_session_review_v1(p_session_id uuid)
 RETURNS TABLE(display_order integer, question_id uuid, question_type text, question_text text, explanation text, image_url text, subject_name text, is_correct boolean, user_answer jsonb, correct_answer jsonb, response_time_ms integer)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select
    rsq.display_order,
    q.id,
    q.type,
    q.question_text,
    q.explanation,
    q.image_url,
    s.name,
    qa.is_correct,
    qa.answer,
    case
      when q.type in ('mcq','true_false') then coalesce((select jsonb_agg(jsonb_build_object('id',qo.id,'text',qo.option_text) order by qo.display_order) from public.question_options qo where qo.question_id=q.id and qo.is_correct=true),'[]'::jsonb)
      when q.type='fill_blank' then jsonb_build_object('text',q.metadata->>'answer')
      when q.type='matching' then jsonb_build_object('pairs',coalesce(q.metadata->'pairs',q.metadata->'correct_pairs','[]'::jsonb))
      when q.type='hotspot' then jsonb_build_object('hotspot',q.metadata->'hotspot')
      when q.type='image' then jsonb_build_object('label_targets',q.metadata->'label_targets')
      else '{}'::jsonb
    end,
    qa.response_time_ms
  from public.revision_sessions rs
  join public.revision_session_questions rsq on rsq.session_id=rs.id
  join public.questions q on q.id=rsq.question_id
  join public.chapters c on c.id=q.chapter_id
  join public.subjects s on s.id=c.subject_id
  left join lateral (
    select a.* from public.question_attempts a
    where a.session_id=rs.id and a.question_id=q.id and a.user_id=auth.uid()
    order by a.created_at desc
    limit 1
  ) qa on true
  where rs.id=p_session_id
    and rs.user_id=auth.uid()
    and rs.completed_at is not null
  order by rsq.display_order;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_quiz_answer_v3(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_result jsonb; v_type text; v_explanation text; v_display_explanation text; v_metadata jsonb; v_question_source text;
  v_correct_option_ids jsonb:='[]'::jsonb; v_correction jsonb:='{}'::jsonb; v_source jsonb:=null; v_source_label text; v_answer jsonb:=p_answer;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.revision_sessions rs join public.revision_session_questions rsq on rsq.session_id=rs.id where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is null and rs.abandoned_at is null and rsq.question_id=p_question_id) then raise exception 'Question ou session invalide, terminée ou abandonnée'; end if;
  select q.type,q.explanation,coalesce(q.metadata,'{}'::jsonb),nullif(btrim(q.source),'') into v_type,v_explanation,v_metadata,v_question_source from public.questions q where q.id=p_question_id;
  if v_type='matching' and jsonb_typeof(p_answer->'pairs')='array' then select jsonb_build_object('pairs',coalesce(jsonb_agg(jsonb_build_object('left',e.value->>'left','right',replace(e.value->>'right',chr(8203),'')) order by e.ord),'[]'::jsonb)) into v_answer from jsonb_array_elements(p_answer->'pairs') with ordinality e(value,ord); end if;
  v_result:=public.submit_quiz_answer_v2(p_session_id,p_question_id,v_answer,p_response_time_ms);
  select coalesce(jsonb_agg(qo.id order by qo.display_order) filter(where qo.is_correct),'[]'::jsonb) into v_correct_option_ids from public.question_options qo where qo.question_id=p_question_id;
  select jsonb_build_object('title',cd.title,'page_number',qs.page_number,'validation_status',cd.validation_status,'source_kind','course_document') into v_source from public.question_sources qs join public.course_documents cd on cd.id=qs.document_id where qs.question_id=p_question_id order by qs.created_at asc limit 1;
  if v_source is null and v_question_source is not null then v_source:=jsonb_build_object('title',v_question_source,'validation_status','external_reference','source_kind','external_reference'); end if;
  v_display_explanation:=nullif(btrim(coalesce(v_explanation,'')),'');
  if v_source is not null then if v_source->>'source_kind'='external_reference' then v_source_label:='🔎 Référence externe : '||coalesce(v_source->>'title','Référence externe'); else v_source_label:='📚 Source du cours : '||coalesce(v_source->>'title','Support IFMK'); end if; if nullif(v_source->>'page_number','') is not null then v_source_label:=v_source_label||' · page '||(v_source->>'page_number'); end if; v_display_explanation:=concat_ws(' — ',v_display_explanation,v_source_label); end if;
  v_correction:=jsonb_build_object('explanation',v_display_explanation,'correct_option_ids',v_correct_option_ids);
  if v_type in ('fill_blank','true_false','short_answer','translation','clinical_case') then v_correction:=v_correction||jsonb_build_object('correct_answer',v_metadata->'answer'); elsif v_type='matching' then v_correction:=v_correction||jsonb_build_object('correct_pairs',coalesce(v_metadata->'pairs','[]'::jsonb)); end if;
  if v_source is not null then v_correction:=v_correction||jsonb_build_object('source',v_source); end if;
  return v_result||jsonb_build_object('correction',v_correction);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_quiz_answer_v5(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_result jsonb;
  v_explanation text;
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  v_result := public.submit_quiz_answer_v4(p_session_id,p_question_id,p_answer,p_response_time_ms);

  v_explanation := v_result #>> '{correction,explanation}';
  if v_explanation is not null then
    v_explanation := split_part(v_explanation,' — 📚 Source du cours :',1);
    v_explanation := split_part(v_explanation,' — 🔎 Référence externe :',1);
    v_result := jsonb_set(v_result,'{correction,explanation}',to_jsonb(nullif(btrim(v_explanation),'')),false);
  end if;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_quiz_answer_v4(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid; v_type text; v_session_mode text; v_metadata jsonb:='{}'::jsonb; v_explanation text; v_question_source text; v_difficulty integer:=2;
  v_correct boolean:=false; v_xp integer:=0; v_attempts integer:=0; v_correct_count integer:=0; v_consecutive integer:=0; v_lapses integer:=0; v_interval integer:=1; v_ease numeric(4,2):=2.50; v_mastery_score integer:=0; v_mastery_percent integer:=0;
  v_source jsonb:=null; v_source_label text; v_display_explanation text; v_expected_count integer:=0; v_given_count integer:=0; v_result jsonb;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  select rs.user_id,q.type,rs.mode,coalesce(q.metadata,'{}'::jsonb),q.explanation,nullif(btrim(q.source),''),coalesce(q.difficulty,2)
  into v_user_id,v_type,v_session_mode,v_metadata,v_explanation,v_question_source,v_difficulty
  from public.revision_sessions rs
  join public.revision_session_questions rsq on rsq.session_id=rs.id
  join public.questions q on q.id=rsq.question_id
  where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is null and rs.abandoned_at is null and rsq.question_id=p_question_id and q.is_published=true;
  if v_user_id is null then raise exception 'Question ou session invalide'; end if;

  if v_type not in ('hotspot','image') then
    v_result:=public.submit_quiz_answer_v3(p_session_id,p_question_id,p_answer,p_response_time_ms);
    if v_session_mode='exam' then
      return jsonb_build_object('submitted',true,'exam_hidden',true,'question_type',v_type,'question_id',p_question_id,'session_id',p_session_id);
    end if;
    return v_result;
  end if;

  if exists(select 1 from public.question_attempts qa where qa.session_id=p_session_id and qa.question_id=p_question_id and qa.user_id=v_user_id) then raise exception 'Cette question a déjà reçu une réponse'; end if;
  if v_type='hotspot' then
    v_correct:=jsonb_typeof(v_metadata->'hotspot')='object' and nullif(p_answer->>'x','') is not null and nullif(p_answer->>'y','') is not null and sqrt(power((p_answer->>'x')::numeric-(v_metadata->'hotspot'->>'x')::numeric,2)+power((p_answer->>'y')::numeric-(v_metadata->'hotspot'->>'y')::numeric,2))<=coalesce((v_metadata->'hotspot'->>'radius')::numeric,10);
    if v_correct then v_xp:=16; end if;
  else
    if jsonb_typeof(v_metadata->'label_targets')='array' and jsonb_typeof(p_answer->'labels')='array' then
      v_expected_count:=jsonb_array_length(v_metadata->'label_targets'); v_given_count:=jsonb_array_length(p_answer->'labels');
      v_correct:=v_expected_count>0 and v_expected_count=v_given_count and not exists(
        select 1 from jsonb_array_elements(v_metadata->'label_targets') e where not exists(
          select 1 from jsonb_array_elements(p_answer->'labels') a where a->>'key'=e->>'key' and nullif(a->>'x','') is not null and nullif(a->>'y','') is not null and sqrt(power((a->>'x')::numeric-(e->>'x')::numeric,2)+power((a->>'y')::numeric-(e->>'y')::numeric,2))<=coalesce((e->>'radius')::numeric,10)
        )
      );
    end if;
    if v_correct then v_xp:=18; end if;
  end if;

  insert into public.question_attempts(user_id,question_id,session_id,answer,is_correct,response_time_ms,xp_earned)
  values(v_user_id,p_question_id,p_session_id,p_answer,v_correct,p_response_time_ms,v_xp);
  update public.revision_session_questions set answered_at=now() where session_id=p_session_id and question_id=p_question_id;

  select attempt_count,correct_count,interval_days,consecutive_correct,lapse_count,ease_factor
  into v_attempts,v_correct_count,v_interval,v_consecutive,v_lapses,v_ease
  from public.user_question_mastery where user_id=v_user_id and question_id=p_question_id;
  v_attempts:=coalesce(v_attempts,0)+1; v_correct_count:=coalesce(v_correct_count,0); v_interval:=coalesce(v_interval,1); v_consecutive:=coalesce(v_consecutive,0); v_lapses:=coalesce(v_lapses,0); v_ease:=coalesce(v_ease,2.50);
  if v_correct then
    v_correct_count:=v_correct_count+1; v_consecutive:=v_consecutive+1; v_ease:=least(3.00,v_ease+0.05);
    v_interval:=case when v_consecutive=1 then 1 when v_consecutive=2 then 3 when v_consecutive=3 then 7 when v_consecutive=4 then 14 when v_consecutive=5 then 30 else least(365,greatest(1,round(v_interval*v_ease)::integer)) end;
  else
    v_consecutive:=0; v_lapses:=v_lapses+1; v_ease:=greatest(1.30,v_ease-0.20); v_interval:=1;
  end if;
  v_mastery_score:=least(4,floor((v_correct_count::numeric/greatest(v_attempts,1))*4)::integer);
  v_mastery_percent:=least(100,greatest(0,round((v_correct_count::numeric/greatest(v_attempts,1))*65+least(v_consecutive,5)::numeric/5*20+least(v_interval,30)::numeric/30*10+greatest(0,5-v_difficulty)::numeric/4*5)::integer));
  insert into public.user_question_mastery(user_id,question_id,mastery_score,mastery_percent,attempt_count,correct_count,last_attempt_at,next_review_at,interval_days,consecutive_correct,lapse_count,ease_factor)
  values(v_user_id,p_question_id,v_mastery_score,v_mastery_percent,v_attempts,v_correct_count,now(),now()+make_interval(days=>v_interval),v_interval,v_consecutive,v_lapses,v_ease)
  on conflict(user_id,question_id) do update set mastery_score=excluded.mastery_score,mastery_percent=excluded.mastery_percent,attempt_count=excluded.attempt_count,correct_count=excluded.correct_count,last_attempt_at=excluded.last_attempt_at,next_review_at=excluded.next_review_at,interval_days=excluded.interval_days,consecutive_correct=excluded.consecutive_correct,lapse_count=excluded.lapse_count,ease_factor=excluded.ease_factor;

  if v_session_mode='exam' then
    return jsonb_build_object('submitted',true,'exam_hidden',true,'question_type',v_type,'question_id',p_question_id,'session_id',p_session_id);
  end if;

  select jsonb_build_object('title',cd.title,'page_number',qs.page_number,'validation_status',cd.validation_status,'source_kind','course_document') into v_source
  from public.question_sources qs join public.course_documents cd on cd.id=qs.document_id where qs.question_id=p_question_id order by qs.created_at asc limit 1;
  if v_source is null and v_question_source is not null then v_source:=jsonb_build_object('title',v_question_source,'validation_status','external_reference','source_kind','external_reference'); end if;
  v_display_explanation:=nullif(btrim(coalesce(v_explanation,'')),'');
  if v_source is not null then
    if v_source->>'source_kind'='external_reference' then v_source_label:='🔎 Référence externe : '||coalesce(v_source->>'title','Référence externe'); else v_source_label:='📚 Source du cours : '||coalesce(v_source->>'title','Support IFMK'); end if;
    if nullif(v_source->>'page_number','') is not null then v_source_label:=v_source_label||' · page '||(v_source->>'page_number'); end if;
    v_display_explanation:=concat_ws(' — ',v_display_explanation,v_source_label);
  end if;
  return jsonb_build_object('correct',v_correct,'xp_earned',v_xp,'mastery_score',v_mastery_score,'mastery_percent',v_mastery_percent,'interval_days',v_interval,'consecutive_correct',v_consecutive,'lapse_count',v_lapses,'ease_factor',v_ease,'next_review_at',now()+make_interval(days=>v_interval),'question_type',v_type,'question_id',p_question_id,'session_id',p_session_id,'correction',jsonb_strip_nulls(jsonb_build_object('explanation',v_display_explanation,'hotspot',case when v_type='hotspot' then v_metadata->'hotspot' else null end,'label_targets',case when v_type='image' then v_metadata->'label_targets' else null end,'source',v_source)));
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_smart_revision_v4_internal(p_user_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_session_id uuid;
  v_actual_count integer;
  v_study_year integer;
begin
  if p_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;
  if p_question_count is null or p_question_count < 1 or p_question_count > 50 then
    raise exception 'Nombre de questions invalide';
  end if;

  select p.study_year into v_study_year
  from public.profiles p
  where p.id = p_user_id;

  insert into public.revision_sessions(user_id, mode, question_count)
  values(p_user_id, 'smart', p_question_count)
  returning id into v_session_id;

  with candidates as (
    select
      q.id,
      q.chapter_id,
      q.lesson_id,
      case
        when coalesce((q.metadata ->> 'clinical_case')::boolean, false) then 'clinical'
        when q.type in ('hotspot','image') then 'visual'
        else q.type
      end as format_class,
      coalesce(uqm.mastery_percent, 0) as mastery_percent,
      coalesce(uqm.attempt_count, 0) as attempt_count,
      coalesce(uqm.correct_count, 0) as correct_count,
      uqm.last_attempt_at,
      uqm.next_review_at,
      coalesce(uqm.lapse_count, 0) as lapse_count,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now() then 1
        when uqm.id is not null and coalesce(uqm.correct_count,0) < coalesce(uqm.attempt_count,0) then 2
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 60 then 3
        when uqm.id is null then 4
        when uqm.id is not null and coalesce(uqm.mastery_percent,0) < 80 then 5
        else 6
      end as priority_group,
      case when exists (
        select 1 from public.question_attempts qa
        where qa.user_id = p_user_id
          and qa.question_id = q.id
          and qa.created_at >= now() - interval '12 hours'
      ) then 1 else 0 end as recent_penalty,
      case
        when uqm.next_review_at is not null and uqm.next_review_at <= now()
          then extract(epoch from (now() - uqm.next_review_at)) / 86400.0
        else 0
      end as overdue_days
    from public.questions q
    join public.chapters c on c.id = q.chapter_id
    join public.subjects s on s.id = c.subject_id
    join public.years y on y.id = s.year_id
    left join public.user_question_mastery uqm
      on uqm.question_id = q.id and uqm.user_id = p_user_id
    where q.is_published = true
      and c.is_active = true
      and s.is_active = true
      and y.is_active = true
      and (v_study_year is null or y.number = v_study_year)
  ), diversified as (
    select c.*,
      row_number() over (
        partition by c.priority_group, c.chapter_id
        order by c.recent_penalty asc, c.overdue_days desc, c.lapse_count desc,
                 c.mastery_percent asc, c.last_attempt_at asc nulls first, random()
      ) as chapter_occurrence,
      row_number() over (
        partition by c.priority_group, coalesce(c.lesson_id, c.id)
        order by c.recent_penalty asc, c.overdue_days desc, c.lapse_count desc,
                 c.mastery_percent asc, c.last_attempt_at asc nulls first, random()
      ) as lesson_occurrence,
      row_number() over (
        partition by c.priority_group, c.format_class
        order by c.recent_penalty asc, c.overdue_days desc, c.lapse_count desc,
                 c.mastery_percent asc, c.last_attempt_at asc nulls first, random()
      ) as format_occurrence
    from candidates c
  ), ranked as (
    select d.*,
      row_number() over (
        order by
          d.priority_group asc,
          d.recent_penalty asc,
          d.chapter_occurrence asc,
          d.lesson_occurrence asc,
          d.format_occurrence asc,
          d.overdue_days desc,
          d.lapse_count desc,
          d.mastery_percent asc,
          d.last_attempt_at asc nulls first,
          random()
      ) as rn
    from diversified d
  )
  insert into public.revision_session_questions(session_id, question_id, display_order)
  select v_session_id, r.id, r.rn::integer
  from ranked r
  where r.rn <= p_question_count
  order by r.rn;

  select count(*) into v_actual_count
  from public.revision_session_questions
  where session_id = v_session_id;

  if v_actual_count = 0 then
    delete from public.revision_sessions where id = v_session_id;
    raise exception 'Aucune question publiée disponible pour cette année';
  end if;

  update public.revision_sessions
  set question_count = v_actual_count
  where id = v_session_id;

  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_atlas_session_v1(p_session_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid;
  v_started timestamptz;
  v_area text;
  v_q integer;
  v_correct integer;
  v_accuracy integer;
  v_duration integer;
  v_best_accuracy integer;
  v_best_duration integer;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;

  select rs.user_id, rs.started_at
  into v_user, v_started
  from public.revision_sessions rs
  where rs.id = p_session_id and rs.user_id = auth.uid();
  if v_user is null then raise exception 'Session Atlas introuvable'; end if;

  select cd.title into v_area
  from public.revision_session_questions rsq
  join public.questions q on q.id = rsq.question_id
  left join public.question_sources qs on qs.question_id = q.id
  left join public.course_documents cd on cd.id = qs.document_id
  where rsq.session_id = p_session_id
  order by rsq.display_order
  limit 1;

  v_area := case
    when v_area ilike '%hanche%' then 'Hanche'
    when v_area ilike '%genou%' then 'Genou'
    when v_area ilike '%cheville%' then 'Cheville'
    when v_area ilike '%pied%' then 'Pied'
    else null
  end;
  if v_area is null then raise exception 'Zone Atlas indéterminée'; end if;

  select count(*), count(*) filter (where qa.is_correct)
  into v_q, v_correct
  from public.revision_session_questions rsq
  left join public.question_attempts qa on qa.session_id = rsq.session_id and qa.question_id = rsq.question_id and qa.user_id = v_user
  where rsq.session_id = p_session_id;

  v_accuracy := case when v_q > 0 then round(v_correct::numeric * 100 / v_q)::integer else 0 end;
  v_duration := greatest(0, (extract(epoch from (now() - v_started)) * 1000)::integer);

  insert into public.atlas_attempts(user_id, session_id, area, question_count, correct_count, accuracy_percent, duration_ms)
  values(v_user, p_session_id, v_area, v_q, v_correct, v_accuracy, v_duration)
  on conflict(session_id) do update set question_count=excluded.question_count, correct_count=excluded.correct_count, accuracy_percent=excluded.accuracy_percent, duration_ms=excluded.duration_ms;

  select aa.accuracy_percent, aa.duration_ms
  into v_best_accuracy, v_best_duration
  from public.atlas_attempts aa
  where aa.user_id = v_user and aa.area = v_area
  order by aa.accuracy_percent desc, aa.duration_ms asc, aa.created_at asc
  limit 1;

  return jsonb_build_object(
    'area', v_area,
    'question_count', v_q,
    'correct_count', v_correct,
    'accuracy_percent', v_accuracy,
    'duration_ms', v_duration,
    'best_accuracy_percent', coalesce(v_best_accuracy, v_accuracy),
    'best_duration_ms', coalesce(v_best_duration, v_duration)
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_smart_revision_v5_internal(p_user_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_session_id uuid;
  v_actual_count integer;
  v_study_year integer;
begin
  if p_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_question_count is null or p_question_count<1 or p_question_count>50 then raise exception 'Nombre de questions invalide'; end if;
  select p.study_year into v_study_year from public.profiles p where p.id=p_user_id;

  insert into public.revision_sessions(user_id,mode,question_count) values(p_user_id,'smart',p_question_count) returning id into v_session_id;

  with candidates as (
    select q.id,q.chapter_id,q.lesson_id,
      (q.type='clinical_case' or coalesce((q.metadata->>'clinical_case')::boolean,false)) as is_clinical,
      (q.type in ('hotspot','image') or coalesce((q.metadata->>'clinical_visual')::boolean,false)) as is_visual,
      case when q.type='clinical_case' or coalesce((q.metadata->>'clinical_case')::boolean,false) then 'clinical'
           when q.type in ('hotspot','image') then 'visual' else q.type end as format_class,
      coalesce(uqm.mastery_percent,0) as mastery_percent,
      coalesce(uqm.attempt_count,0) as attempt_count,
      coalesce(uqm.correct_count,0) as correct_count,
      uqm.last_attempt_at,uqm.next_review_at,coalesce(uqm.lapse_count,0) as lapse_count,
      case when uqm.next_review_at is not null and uqm.next_review_at<=now() then 1
           when uqm.id is not null and coalesce(uqm.correct_count,0)<coalesce(uqm.attempt_count,0) then 2
           when uqm.id is not null and coalesce(uqm.mastery_percent,0)<60 then 3
           when uqm.id is null then 4
           when uqm.id is not null and coalesce(uqm.mastery_percent,0)<80 then 5 else 6 end as priority_group,
      case when exists(select 1 from public.question_attempts qa where qa.user_id=p_user_id and qa.question_id=q.id and qa.created_at>=now()-interval '12 hours') then 1 else 0 end as recent_penalty,
      case when uqm.next_review_at is not null and uqm.next_review_at<=now() then extract(epoch from(now()-uqm.next_review_at))/86400.0 else 0 end as overdue_days
    from public.questions q
    join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
    left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=p_user_id
    where q.is_published=true and q.validation_status='published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
      and c.is_active=true and s.is_active=true and y.is_active=true and (v_study_year is null or y.number=v_study_year)
  ), diversified as (
    select c.*,
      row_number() over(partition by c.priority_group,c.chapter_id order by c.recent_penalty,c.overdue_days desc,c.lapse_count desc,c.mastery_percent,c.last_attempt_at nulls first,random()) as chapter_occurrence,
      row_number() over(partition by c.priority_group,coalesce(c.lesson_id,c.id) order by c.recent_penalty,c.overdue_days desc,c.lapse_count desc,c.mastery_percent,c.last_attempt_at nulls first,random()) as lesson_occurrence,
      row_number() over(partition by c.priority_group,c.format_class order by c.recent_penalty,c.overdue_days desc,c.lapse_count desc,c.mastery_percent,c.last_attempt_at nulls first,random()) as format_occurrence,
      row_number() over(partition by c.is_clinical order by c.priority_group,c.recent_penalty,c.overdue_days desc,c.mastery_percent,random()) as clinical_rank,
      row_number() over(partition by c.is_visual order by c.priority_group,c.recent_penalty,c.overdue_days desc,c.mastery_percent,random()) as visual_rank
    from candidates c
  ), preferred as (
    select d.id,1 as pref_order from diversified d where p_question_count>=6 and d.priority_group<=4 and d.is_clinical and d.clinical_rank=1
    union
    select d.id,2 as pref_order from diversified d where p_question_count>=6 and d.priority_group<=4 and d.is_visual and d.visual_rank=1
  ), general_ranked as (
    select d.id,row_number() over(order by d.priority_group,d.recent_penalty,d.chapter_occurrence,d.lesson_occurrence,d.format_occurrence,d.overdue_days desc,d.lapse_count desc,d.mastery_percent,d.last_attempt_at nulls first,random()) as rn
    from diversified d
  ), ordered as (
    select p.id,p.pref_order::bigint as ord from preferred p
    union all
    select g.id,(1000+g.rn)::bigint from general_ranked g where not exists(select 1 from preferred p where p.id=g.id)
  ), chosen as (
    select id,row_number() over(order by ord,id) as display_order from ordered order by ord,id limit p_question_count
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session_id,id,display_order::integer from chosen;

  select count(*) into v_actual_count from public.revision_session_questions where session_id=v_session_id;
  if v_actual_count=0 then delete from public.revision_sessions where id=v_session_id; raise exception 'Aucune question validée disponible pour cette année'; end if;
  update public.revision_sessions set question_count=v_actual_count where id=v_session_id;
  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_quiz_questions_v5(p_session_id uuid)
 RETURNS TABLE(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.revision_sessions rs where rs.id=p_session_id and rs.user_id=auth.uid()) then
    raise exception 'Session inexistante ou accès non autorisé';
  end if;

  return query
  select q.id,q.type,q.question_text,null::text,q.difficulty,q.image_url,
    case
      when q.type='matching' then jsonb_build_object(
        'left_items',coalesce((
          select jsonb_agg(e.value->'left' order by e.ord)
          from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality e(value,ord)
        ),'[]'::jsonb),
        'right_items',coalesce((
          select jsonb_agg(to_jsonb(x.display_value) order by random())
          from (
            select
              (e.value->>'right') || repeat(chr(8203),
                row_number() over(partition by e.value->>'right' order by e.ord)::int - 1
              ) as display_value
            from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality e(value,ord)
          ) x
        ),'[]'::jsonb),
        'clinical_case',coalesce(q.metadata->'clinical_case','false'::jsonb),
        'clinical_visual',coalesce(q.metadata->'clinical_visual','false'::jsonb),
        'scenario_id',q.metadata->'scenario_id',
        'scenario_step',q.metadata->'scenario_step',
        'scenario_total',q.metadata->'scenario_total',
        'scenario_title',q.metadata->'scenario_title',
        'source_page',q.metadata->'source_page',
        'source_document',q.metadata->'source_document'
      )
      when q.type='hotspot' then (coalesce(q.metadata,'{}'::jsonb)-'hotspot'-'answer'-'correct_answer'-'is_correct'-'pairs'-'label_targets')
      when q.type='image' then jsonb_build_object(
        'label_items',coalesce((select jsonb_agg(jsonb_build_object('key',e.value->>'key','label',e.value->>'label') order by e.ord) from jsonb_array_elements(coalesce(q.metadata->'label_targets','[]'::jsonb)) with ordinality e(value,ord)),'[]'::jsonb),
        'clinical_case',coalesce(q.metadata->'clinical_case','false'::jsonb),
        'clinical_visual',coalesce(q.metadata->'clinical_visual','false'::jsonb),
        'scenario_id',q.metadata->'scenario_id',
        'scenario_step',q.metadata->'scenario_step',
        'scenario_total',q.metadata->'scenario_total',
        'scenario_title',q.metadata->'scenario_title',
        'source_page',q.metadata->'source_page',
        'source_document',q.metadata->'source_document'
      )
      else coalesce(q.metadata,'{}'::jsonb)-'answer'-'correct_answer'-'is_correct'-'pairs'-'hotspot'-'label_targets'
    end,
    coalesce((select jsonb_agg(jsonb_build_object('id',qo.id,'option_text',qo.option_text,'display_order',qo.display_order) order by qo.display_order) from public.question_options qo where qo.question_id=q.id),'[]'::jsonb),
    rsq.display_order
  from public.revision_session_questions rsq
  join public.questions q on q.id=rsq.question_id
  where rsq.session_id=p_session_id and rsq.answered_at is null and q.is_published=true
  order by rsq.display_order;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.search_students_v1(p_query text)
 RETURNS TABLE(id uuid, username text, first_name text, study_year integer, level integer)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select p.id, p.username::text, p.first_name, p.study_year, p.level
  from public.profiles p
  where (select auth.uid()) is not null
    and p.id <> (select auth.uid())
    and length(trim(coalesce(p_query, ''))) >= 2
    and (
      coalesce(p.username::text, '') ilike '%' || trim(p_query) || '%'
      or coalesce(p.first_name, '') ilike '%' || trim(p_query) || '%'
    )
  order by
    case when p.username is not null and lower(p.username::text) = lower(trim(p_query)) then 0
         when lower(coalesce(p.first_name,'')) = lower(trim(p_query)) then 1
         else 2 end,
    coalesce(p.username::text,p.first_name,'')
  limit 12;
$function$
;
CREATE OR REPLACE FUNCTION public.send_friend_request_v1(p_addressee uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_id uuid;
  v_username text;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifie'; end if;
  if p_addressee is null or p_addressee = v_uid then raise exception 'Invitation invalide'; end if;
  if not exists (select 1 from public.profiles where id = p_addressee) then raise exception 'Utilisateur introuvable'; end if;
  if exists (
    select 1 from public.friendships
    where ((requester_id = v_uid and addressee_id = p_addressee) or (requester_id = p_addressee and addressee_id = v_uid))
      and status in ('pending','accepted','blocked')
  ) then raise exception 'Une relation existe deja avec cet utilisateur'; end if;

  insert into public.friendships(requester_id, addressee_id, status)
  values (v_uid, p_addressee, 'pending') returning id into v_id;

  select coalesce(username::text, first_name, 'Un etudiant') into v_username from public.profiles where id = v_uid;
  insert into public.notifications(user_id, type, title, body, data)
  values (p_addressee, 'friend_request', 'Nouvelle invitation', v_username || ' souhaite t’ajouter comme ami.', jsonb_build_object('friendship_id', v_id, 'requester_id', v_uid));

  return v_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.respond_friend_request_v1(p_friendship_id uuid, p_accept boolean)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_requester uuid;
  v_status text := case when p_accept then 'accepted' else 'rejected' end;
  v_username text;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifie'; end if;
  select requester_id into v_requester
  from public.friendships
  where id = p_friendship_id and addressee_id = v_uid and status = 'pending';
  if v_requester is null then raise exception 'Invitation introuvable'; end if;

  update public.friendships set status = v_status, updated_at = now() where id = p_friendship_id;
  if p_accept then
    select coalesce(username::text, first_name, 'Un etudiant') into v_username from public.profiles where id = v_uid;
    insert into public.notifications(user_id, type, title, body, data)
    values (v_requester, 'friend_accepted', 'Invitation acceptee', v_username || ' a accepte ton invitation.', jsonb_build_object('friendship_id', p_friendship_id));
  end if;
  return v_status;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.search_students_v2(p_query text)
 RETURNS TABLE(id uuid, username text, first_name text, study_year integer, level integer, avatar_url text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select p.id, p.username::text, p.first_name, p.study_year, p.level, p.avatar_url
  from public.profiles p
  where (select auth.uid()) is not null
    and p.id <> (select auth.uid())
    and p.username is not null
    and length(trim(coalesce(p_query, ''))) >= 2
    and (p.username ilike '%' || trim(p_query) || '%' or coalesce(p.first_name, '') ilike '%' || trim(p_query) || '%')
  order by case when lower(p.username::text) = lower(trim(p_query)) then 0 else 1 end, p.username
  limit 12;
$function$
;
CREATE OR REPLACE FUNCTION public.get_recent_revision_sessions_v1(p_limit integer DEFAULT 20)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with rows as (
    select rs.id, rs.mode, rs.question_count, rs.correct_count, rs.xp_earned, rs.started_at, rs.completed_at,
      greatest(0, floor(extract(epoch from (coalesce(rs.completed_at, now()) - rs.started_at)))::int) as duration_seconds,
      case when rs.question_count > 0 then round((rs.correct_count::numeric / rs.question_count::numeric) * 100, 0)::int else 0 end as score_percent
    from public.revision_sessions rs
    where rs.user_id = auth.uid()
      and rs.completed_at is not null
      and rs.abandoned_at is null
    order by rs.completed_at desc
    limit least(greatest(coalesce(p_limit,20),1),50)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', id,'mode', mode,'question_count', question_count,'correct_count', correct_count,'xp_earned', xp_earned,
    'score_percent', score_percent,'duration_seconds', duration_seconds,'started_at', started_at,'completed_at', completed_at
  ) order by completed_at desc), '[]'::jsonb)
  from rows;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friend_challenges_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (select auth.uid() uid),
  rows as (
    select c.*,
      case when c.challenger_id = me.uid then c.challenged_id else c.challenger_id end as opponent_id,
      case when c.challenger_id = me.uid then 'sent' else 'received' end as direction
    from public.challenges c cross join me
    where me.uid is not null and (c.challenger_id = me.uid or c.challenged_id = me.uid)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', r.id,
    'status', r.status,
    'direction', r.direction,
    'challenger_id', r.challenger_id,
    'challenged_id', r.challenged_id,
    'challenger_score', r.challenger_score,
    'challenged_score', r.challenged_score,
    'created_at', r.created_at,
    'completed_at', r.completed_at,
    'opponent', jsonb_build_object('id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'avatar_url', p.avatar_url)
  ) order by r.created_at desc), '[]'::jsonb)
  from rows r join public.profiles p on p.id = r.opponent_id;
$function$
;
CREATE OR REPLACE FUNCTION public.toggle_lesson_favorite_v1(p_lesson_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_exists boolean;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.lessons l where l.id=p_lesson_id and l.is_published=true) then raise exception 'Leçon indisponible'; end if;
  select exists(select 1 from public.favorites f where f.user_id=auth.uid() and f.content_type='lesson' and f.content_id=p_lesson_id) into v_exists;
  if v_exists then
    delete from public.favorites where user_id=auth.uid() and content_type='lesson' and content_id=p_lesson_id;
    return false;
  end if;
  insert into public.favorites(user_id,content_type,content_id) values(auth.uid(),'lesson',p_lesson_id);
  return true;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.respond_friend_challenge_v1(p_challenge_id uuid, p_accept boolean)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenger uuid;
  v_status text:=case when p_accept then 'accepted' else 'declined' end;
  v_username text;
  v_count integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select challenger_id into v_challenger
  from public.challenges
  where id=p_challenge_id and challenged_id=v_uid and status='pending';
  if v_challenger is null then raise exception 'Défi introuvable'; end if;

  if p_accept then
    select count(*) into v_count
    from public.challenge_questions cq
    join public.questions q on q.id=cq.question_id
    where cq.challenge_id=p_challenge_id
      and q.is_published=true and q.validation_status='published';
    if v_count<>10 then raise exception 'Ce défi ne contient pas 10 questions valides'; end if;
  end if;

  update public.challenges set status=v_status where id=p_challenge_id;

  select coalesce(username::text,first_name,'Ton ami') into v_username from public.profiles where id=v_uid;
  insert into public.notifications(user_id,type,title,body,data)
  values(
    v_challenger,
    case when p_accept then 'challenge_accepted' else 'challenge_declined' end,
    case when p_accept then 'Défi accepté' else 'Défi refusé' end,
    v_username||case when p_accept then ' a accepté ton défi.' else ' a refusé ton défi.' end,
    jsonb_build_object('challenge_id',p_challenge_id)
  );
  return v_status;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_friend_challenge_v1(p_challenge_id uuid, p_score integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenge public.challenges%rowtype;
  v_session uuid;
  v_total integer;
  v_answered integer;
  v_correct integer;
  v_score integer;
  v_done boolean;
  v_was_completed boolean;
  v_my_score integer;
  v_opponent_score integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_challenge from public.challenges where id=p_challenge_id for update;
  if v_challenge.id is null or (v_challenge.challenger_id<>v_uid and v_challenge.challenged_id<>v_uid) then raise exception 'Défi introuvable'; end if;
  if v_challenge.status not in ('in_progress','completed') then raise exception 'Ce défi ne peut pas être terminé'; end if;

  if (v_uid=v_challenge.challenger_id and v_challenge.challenger_score is not null)
     or (v_uid=v_challenge.challenged_id and v_challenge.challenged_score is not null) then
    v_my_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenger_score else v_challenge.challenged_score end;
    v_opponent_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenged_score else v_challenge.challenger_score end;
    return jsonb_build_object(
      'completed',v_challenge.status='completed',
      'my_score',v_my_score,
      'opponent_score',v_opponent_score,
      'challenger_score',v_challenge.challenger_score,
      'challenged_score',v_challenge.challenged_score
    );
  end if;

  select rs.id into v_session
  from public.revision_sessions rs
  where rs.challenge_id=p_challenge_id and rs.user_id=v_uid
  order by rs.started_at desc limit 1;
  if v_session is null then raise exception 'Session de défi introuvable'; end if;

  select count(*),count(*) filter(where rsq.answered_at is not null)
  into v_total,v_answered
  from public.revision_session_questions rsq
  where rsq.session_id=v_session;
  if v_total<>10 or v_answered<>10 then raise exception 'Le défi doit contenir 10 réponses validées'; end if;

  select count(*) filter(where qa.is_correct=true) into v_correct
  from public.question_attempts qa
  where qa.session_id=v_session and qa.user_id=v_uid;
  v_score:=round((coalesce(v_correct,0)::numeric/v_total::numeric)*100)::integer;

  if v_uid=v_challenge.challenger_id then
    update public.challenges set challenger_score=v_score where id=p_challenge_id;
  else
    update public.challenges set challenged_score=v_score where id=p_challenge_id;
  end if;

  select * into v_challenge from public.challenges where id=p_challenge_id;
  v_was_completed:=v_challenge.status='completed';
  v_done:=v_challenge.challenger_score is not null and v_challenge.challenged_score is not null;

  if v_done and not v_was_completed then
    update public.challenges set status='completed',completed_at=now() where id=p_challenge_id;
    insert into public.notifications(user_id,type,title,body,data)
    select u,'challenge_completed','Défi terminé 🏁','Les deux scores sont disponibles.',jsonb_build_object('challenge_id',p_challenge_id)
    from (values(v_challenge.challenger_id),(v_challenge.challenged_id)) x(u);
    select * into v_challenge from public.challenges where id=p_challenge_id;
  end if;

  v_my_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenger_score else v_challenge.challenged_score end;
  v_opponent_score:=case when v_uid=v_challenge.challenger_id then v_challenge.challenged_score else v_challenge.challenger_score end;

  return jsonb_build_object(
    'completed',v_challenge.status='completed',
    'my_score',v_my_score,
    'opponent_score',v_opponent_score,
    'challenger_score',v_challenge.challenger_score,
    'challenged_score',v_challenge.challenged_score
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_course_library_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_result jsonb;
begin
  if v_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  with linked_lessons as (
    select ls.document_id, ls.lesson_id
    from public.lesson_sources ls
    union
    select qs.document_id, qs.lesson_id
    from public.question_sources qs
    where qs.lesson_id is not null
  ), lesson_groups as (
    select
      ll.document_id,
      coalesce(
        jsonb_agg(
          distinct jsonb_build_object(
            'id', l.id,
            'title', l.title,
            'slug', l.slug
          )
        ) filter (where l.id is not null and l.is_published = true),
        '[]'::jsonb
      ) as lessons
    from linked_lessons ll
    join public.lessons l on l.id = ll.lesson_id
    group by ll.document_id
  ), question_counts as (
    select qs.document_id, count(distinct qs.question_id)::integer as question_count
    from public.question_sources qs
    join public.questions q on q.id = qs.question_id and q.is_published = true
    group by qs.document_id
  )
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', cd.id,
      'title', cd.title,
      'file_name', cd.file_name,
      'mime_type', cd.mime_type,
      'file_size', cd.file_size,
      'document_type', cd.document_type,
      'validation_status', cd.validation_status,
      'processing_status', cd.processing_status,
      'source_url', case
        when cd.storage_path like 'gdrive://%' then
          'https://drive.google.com/file/d/' || replace(cd.storage_path, 'gdrive://', '') || '/view'
        when cd.storage_path like 'https://%' then cd.storage_path
        else null
      end,
      'year', case when y.id is not null then jsonb_build_object('number', y.number, 'name', y.name) else null end,
      'subject', case when s.id is not null then jsonb_build_object('id', s.id, 'name', s.name, 'slug', s.slug, 'icon', s.icon) else null end,
      'chapter', case when c.id is not null then jsonb_build_object('id', c.id, 'name', c.name, 'slug', c.slug) else null end,
      'question_count', coalesce(qc.question_count, 0),
      'lessons', coalesce(lg.lessons, '[]'::jsonb),
      'created_at', cd.created_at,
      'updated_at', cd.updated_at
    ) order by coalesce(y.number, 99), coalesce(c.display_order, 999), cd.title
  ), '[]'::jsonb)
  into v_result
  from public.course_documents cd
  left join public.years y on y.id = cd.year_id
  left join public.subjects s on s.id = cd.subject_id
  left join public.chapters c on c.id = cd.chapter_id
  left join lesson_groups lg on lg.document_id = cd.id
  left join question_counts qc on qc.document_id = cd.id
  where cd.document_type = 'course'
    and cd.processing_status = 'processed'
    and cd.validation_status = 'validated';

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.save_lesson_note_v1(p_lesson_id uuid, p_content text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_content text:=btrim(coalesce(p_content,''));
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.lessons l where l.id=p_lesson_id and l.is_published=true) then raise exception 'Leçon indisponible'; end if;
  if length(v_content)>4000 then raise exception 'Note trop longue (4000 caractères maximum)'; end if;
  delete from public.user_notes where user_id=auth.uid() and lesson_id=p_lesson_id;
  if v_content<>'' then insert into public.user_notes(user_id,lesson_id,content) values(auth.uid(),p_lesson_id,v_content); end if;
  return v_content;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_friend_challenge_session_v1(p_challenge_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_challenge public.challenges%rowtype;
  v_session uuid;
  v_count integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_challenge from public.challenges where id=p_challenge_id;
  if v_challenge.id is null or (v_challenge.challenger_id<>v_uid and v_challenge.challenged_id<>v_uid) then raise exception 'Défi introuvable'; end if;
  if v_challenge.status not in ('accepted','in_progress') then raise exception 'Ce défi ne peut pas encore être joué'; end if;

  select count(*) into v_count from public.challenge_questions cq join public.questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id and q.is_published=true and q.validation_status='published';
  if v_count<>10 then raise exception 'Ce défi ne contient pas 10 questions valides'; end if;

  select id into v_session from public.revision_sessions where challenge_id=p_challenge_id and user_id=v_uid order by started_at desc limit 1;
  if v_session is not null then return v_session; end if;

  insert into public.revision_sessions(user_id,mode,question_count,challenge_id) values(v_uid,'mix',10,p_challenge_id) returning id into v_session;
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session,cq.question_id,cq.display_order from public.challenge_questions cq join public.questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id and q.is_published=true and q.validation_status='published' order by cq.display_order;
  update public.challenges set status='in_progress' where id=p_challenge_id and status='accepted';
  return v_session;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friendships_v2()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (select auth.uid() as uid),
  accepted as (
    select f.id,
           case when f.requester_id = me.uid then f.addressee_id else f.requester_id end as friend_id,
           f.updated_at
    from public.friendships f cross join me
    where me.uid is not null
      and f.status = 'accepted'
      and (f.requester_id = me.uid or f.addressee_id = me.uid)
  ),
  incoming as (
    select f.id, f.requester_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.addressee_id = me.uid and f.status = 'pending'
  ),
  outgoing as (
    select f.id, f.addressee_id as user_id, f.created_at
    from public.friendships f cross join me
    where me.uid is not null and f.requester_id = me.uid and f.status = 'pending'
  )
  select jsonb_build_object(
    'friends', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', a.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'avatar_url', p.avatar_url) order by p.username) from accepted a join public.profiles p on p.id = a.friend_id), '[]'::jsonb),
    'incoming', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', i.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'avatar_url', p.avatar_url, 'created_at', i.created_at) order by i.created_at desc) from incoming i join public.profiles p on p.id = i.user_id), '[]'::jsonb),
    'outgoing', coalesce((select jsonb_agg(jsonb_build_object('friendship_id', o.id, 'id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'avatar_url', p.avatar_url, 'created_at', o.created_at) order by o.created_at desc) from outgoing o join public.profiles p on p.id = o.user_id), '[]'::jsonb)
  );
$function$
;
CREATE OR REPLACE FUNCTION public.start_visual_revision_v1(p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_session_id uuid;
  v_actual_count integer;
  v_study_year integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_question_count is null or p_question_count < 1 or p_question_count > 30 then raise exception 'Nombre de questions invalide'; end if;
  select study_year into v_study_year from public.profiles where id = v_user_id;
  insert into public.revision_sessions(user_id, mode, question_count)
  values(v_user_id, 'visual', p_question_count)
  returning id into v_session_id;
  with candidates as (
    select q.id,
      coalesce(uqm.mastery_percent,0) mastery_percent,
      coalesce(uqm.attempt_count,0) attempt_count,
      uqm.next_review_at,
      case when uqm.next_review_at is not null and uqm.next_review_at<=now() then 1 when uqm.id is not null and coalesce(uqm.mastery_percent,0)<60 then 2 when uqm.id is null then 3 else 4 end priority_group,
      case when exists(select 1 from public.question_attempts qa where qa.user_id=v_user_id and qa.question_id=q.id and qa.created_at>=now()-interval '8 hours') then 1 else 0 end recent_penalty
    from public.questions q
    join public.chapters c on c.id=q.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
    where q.is_published=true
      and q.validation_status='published'
      and c.is_active=true and s.is_active=true and y.is_active=true
      and (v_study_year is null or y.number=v_study_year)
      and q.image_url is not null
      and q.type in ('mcq','matching','hotspot','image')
      and case when q.type in ('hotspot','image') then coalesce((q.metadata->>'visual_approved')::boolean,false)=true else true end
  ), chosen as (
    select id,row_number() over(order by priority_group,recent_penalty,mastery_percent,attempt_count,random()) display_order
    from candidates limit p_question_count
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session_id,id,display_order::integer from chosen;
  select count(*) into v_actual_count from public.revision_session_questions where session_id=v_session_id;
  if v_actual_count=0 then
    delete from public.revision_sessions where id=v_session_id;
    raise exception 'Aucune question visuelle validée disponible pour cette année';
  end if;
  update public.revision_sessions set question_count=v_actual_count where id=v_session_id;
  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_lesson_personal_state_v1(p_lesson_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object(
    'favorite', exists(select 1 from public.favorites f where f.user_id=auth.uid() and f.content_type='lesson' and f.content_id=p_lesson_id),
    'note', coalesce((select un.content from public.user_notes un where un.user_id=auth.uid() and un.lesson_id=p_lesson_id order by un.updated_at desc limit 1),'')
  )
  where auth.uid() is not null;
$function$
;
CREATE OR REPLACE FUNCTION public.get_revision_session_meta_v1(p_session_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_build_object(
    'id', rs.id,
    'mode', rs.mode,
    'question_count', rs.question_count,
    'answered_count', (select count(*) from public.revision_session_questions rsq where rsq.session_id=rs.id and rsq.answered_at is not null),
    'correct_count', rs.correct_count,
    'xp_earned', rs.xp_earned,
    'started_at', rs.started_at,
    'completed_at', rs.completed_at,
    'elapsed_seconds', greatest(0, floor(extract(epoch from (coalesce(rs.completed_at, now()) - rs.started_at)))::int)
  )
  from public.revision_sessions rs
  where rs.id = p_session_id
    and rs.user_id = auth.uid();
$function$
;
CREATE OR REPLACE FUNCTION public.get_revision_mode_availability_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
with me as(select p.study_year from public.profiles p where p.id=auth.uid()), counts as(
 select
  count(*) filter(where q.is_published=true and q.validation_status='published') as total_questions,
  count(*) filter(where q.is_published=true and q.validation_status='published' and q.image_url is not null and q.type in ('mcq','matching','hotspot','image')) as visual_questions,
  count(*) filter(where q.is_published=true and q.validation_status='published' and uqm.id is not null and (uqm.next_review_at<=now() or coalesce(uqm.mastery_percent,0)<60 or coalesce(uqm.correct_count,0)<coalesce(uqm.attempt_count,0))) as weak_questions
 from public.questions q
 join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id cross join me
 left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=auth.uid()
 where c.is_active=true and s.is_active=true and y.is_active=true and (me.study_year is null or y.number=me.study_year)
)
select jsonb_build_object('total_questions',total_questions,'visual_questions',visual_questions,'weak_questions',weak_questions,'can_visual',visual_questions>0,'can_weak',weak_questions>0,'can_exam',total_questions>=10) from counts;
$function$
;
CREATE OR REPLACE FUNCTION public.start_mistake_retry_v1(p_source_session_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_new_session uuid;
  v_count integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  perform 1 from public.revision_sessions rs
  where rs.id=p_source_session_id and rs.user_id=v_user_id and rs.completed_at is not null;
  if not found then raise exception 'Session terminée introuvable ou accès non autorisé'; end if;

  insert into public.revision_sessions(user_id,mode,question_count)
  values(v_user_id,'mix',0)
  returning id into v_new_session;

  with wrong as (
    select distinct on (rsq.question_id) rsq.question_id, rsq.display_order
    from public.revision_session_questions rsq
    join public.question_attempts qa on qa.session_id=rsq.session_id and qa.question_id=rsq.question_id and qa.user_id=v_user_id
    where rsq.session_id=p_source_session_id and qa.is_correct=false
    order by rsq.question_id, qa.created_at desc
  ), ordered as (
    select question_id,row_number() over(order by display_order)::integer as rn
    from wrong
    order by display_order
    limit 20
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_new_session,question_id,rn from ordered;

  select count(*) into v_count from public.revision_session_questions where session_id=v_new_session;
  if v_count=0 then
    delete from public.revision_sessions where id=v_new_session;
    raise exception 'Aucune erreur à retravailler dans cette session';
  end if;

  update public.revision_sessions set question_count=v_count where id=v_new_session;
  return v_new_session;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_profile_avatar_v1(p_avatar_url text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_url text:=nullif(trim(p_avatar_url),'');
  v_expected_prefix text;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  v_expected_prefix:='https://cyzdivbdgpvhwpmikeqh.supabase.co/storage/v1/object/public/avatars/'||v_user_id::text||'/';
  if v_url is not null and left(v_url,length(v_expected_prefix))<>v_expected_prefix then
    raise exception 'URL d’avatar non autorisée';
  end if;
  if v_url is not null and length(v_url)>1000 then raise exception 'URL d’avatar invalide'; end if;

  update public.profiles set avatar_url=v_url,updated_at=now() where id=v_user_id;
  if not found then raise exception 'Profil introuvable'; end if;
  return v_url;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.abandon_revision_session_v1(p_session_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  update public.revision_sessions
  set abandoned_at=now()
  where id=p_session_id
    and user_id=auth.uid()
    and completed_at is null
    and abandoned_at is null
    and daily_challenge_id is null
    and challenge_id is null;
  if not found then raise exception 'Session introuvable ou non abandonnable'; end if;
  return true;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_study_priorities_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
with me as (
  select auth.uid() as uid
), profile as (
  select p.study_year
  from public.profiles p, me
  where p.id=me.uid and me.uid is not null
), base as (
  select s.id as subject_id,s.name,s.icon,s.display_order,y.number as year_number,q.id as question_id
  from public.subjects s
  join public.years y on y.id=s.year_id
  join profile p on p.study_year=y.number
  left join public.chapters c on c.subject_id=s.id and c.is_active=true
  left join public.questions q on q.chapter_id=c.id and q.is_published=true and q.validation_status='published'
  where s.is_active=true and y.is_active=true
), agg as (
  select b.subject_id,max(b.name) as name,max(b.icon) as icon,max(b.display_order) as display_order,
         count(b.question_id)::int as published_questions,
         count(uqm.question_id) filter(where uqm.attempt_count>0)::int as attempted_questions,
         coalesce(round(avg(uqm.mastery_percent))::int,0) as mastery_percent,
         count(uqm.question_id) filter(where uqm.attempt_count>0 and uqm.mastery_percent<60)::int as fragile_questions,
         count(uqm.question_id) filter(where uqm.next_review_at is not null and uqm.next_review_at<=now())::int as due_questions
  from base b
  left join public.user_question_mastery uqm on uqm.question_id=b.question_id and uqm.user_id=(select uid from me)
  group by b.subject_id
), ranked as (
  select *,
    case when published_questions=0 then 0 else round(100.0*attempted_questions/published_questions)::int end as coverage_percent,
    (due_questions*6 + fragile_questions*4 + greatest(0,published_questions-attempted_questions)) as priority_score
  from agg
  where published_questions>0
), top3 as (
  select * from ranked
  order by priority_score desc, mastery_percent asc, display_order asc
  limit 3
)
select jsonb_build_object(
  'study_year',(select study_year from profile),
  'items',coalesce(jsonb_agg(jsonb_build_object(
    'subject_id',subject_id,
    'name',name,
    'icon',icon,
    'published_questions',published_questions,
    'attempted_questions',attempted_questions,
    'coverage_percent',coverage_percent,
    'mastery_percent',mastery_percent,
    'fragile_questions',fragile_questions,
    'due_questions',due_questions,
    'reason',case
      when due_questions>0 then due_questions||' révision'||case when due_questions>1 then 's' else '' end||' à échéance'
      when fragile_questions>0 then fragile_questions||' notion'||case when fragile_questions>1 then 's fragiles' else ' fragile' end
      when attempted_questions=0 then 'Matière pas encore commencée'
      when coverage_percent<50 then 'Couverture à compléter'
      else 'À consolider'
    end
  ) order by priority_score desc, mastery_percent asc),'[]'::jsonb)
) from top3;
$function$
;
CREATE OR REPLACE FUNCTION public.get_content_review_queue_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;

  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs
      join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id
      order by qs.created_at asc,qs.id asc
      limit 1
    ) src on true
    where q.validation_status in ('review','validated','published')
  )
  select jsonb_build_object(
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',count(*) filter(where validation_status='published'),
      'quarantined_visual',count(*) filter(where validation_status='review' and type in ('hotspot','image')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,
      'validation_status',validation_status,'is_published',is_published,
      'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,'lesson_title',lesson_title,
      'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue',
      'visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by year_number,subject_name,chapter_name,lesson_title,created_at) filter(where validation_status in ('review','validated')),'[]'::jsonb)
  ) into v_result
  from question_rows;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_subject_revision_v1(p_subject_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid(); v_count integer:=greatest(5,least(coalesce(p_question_count,10),30)); v_session uuid; v_actual integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(
    select 1
    from public.subjects s
    join public.years y on y.id=s.year_id
    join public.profiles p on p.id=v_user_id
    where s.id=p_subject_id
      and s.is_active=true
      and y.is_active=true
      and (y.number=p.study_year or p.role='admin')
  ) then raise exception 'Matière indisponible pour ton année'; end if;
  insert into public.revision_sessions(user_id,mode,question_count,correct_count,xp_earned) values(v_user_id,'smart',v_count,0,0) returning id into v_session;
  with candidates as (
    select q.id,row_number() over(order by case when uqm.next_review_at is not null and uqm.next_review_at<=now() then 0 when uqm.attempt_count>0 and uqm.mastery_percent<60 then 1 when uqm.question_id is null or uqm.attempt_count=0 then 2 else 3 end,coalesce(uqm.mastery_percent,0),coalesce(uqm.last_attempt_at,'1970-01-01'::timestamptz),random()) rn
    from public.questions q join public.chapters c on c.id=q.chapter_id left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
    where c.subject_id=p_subject_id and c.is_active=true and q.is_published=true and q.validation_status='published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
  ),picked as(select id,rn from candidates where rn<=v_count)
  insert into public.revision_session_questions(session_id,question_id,display_order) select v_session,id,rn::int from picked order by rn;
  select count(*) into v_actual from public.revision_session_questions where session_id=v_session;
  if v_actual=0 then delete from public.revision_sessions where id=v_session; raise exception 'Aucune question validée disponible dans cette matière'; end if;
  update public.revision_sessions set question_count=v_actual where id=v_session; return v_session;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.cancel_friend_challenge_v1(p_challenge_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_row public.challenges%rowtype;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_row from public.challenges where id=p_challenge_id for update;
  if v_row.id is null then raise exception 'Défi introuvable'; end if;
  if v_row.challenger_id<>v_uid then raise exception 'Seul l’auteur du défi peut l’annuler'; end if;
  if v_row.status<>'pending' then raise exception 'Seul un défi en attente peut être annulé'; end if;
  update public.challenges set status='cancelled' where id=p_challenge_id;
  return true;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.finish_quiz_session_v2(p_session_id uuid, p_activity_date date DEFAULT CURRENT_DATE)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_activity_date date:=current_date;
  v_total_questions integer:=0;
  v_answered_questions integer:=0;
  v_correct_count integer:=0;
  v_xp integer:=0;
  v_score numeric:=0;
  v_progress jsonb;
  v_badges jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  perform 1 from public.revision_sessions rs where rs.id=p_session_id and rs.user_id=v_user_id and rs.completed_at is null and rs.abandoned_at is null for update;
  if not found then raise exception 'Session inexistante, terminée, abandonnée ou accès non autorisé'; end if;
  select count(*),count(*) filter(where rsq.answered_at is not null) into v_total_questions,v_answered_questions from public.revision_session_questions rsq where rsq.session_id=p_session_id;
  if v_total_questions=0 then raise exception 'Cette session ne contient aucune question'; end if;
  if v_answered_questions<v_total_questions then raise exception 'Quiz incomplet : % question(s) sur % répondue(s)',v_answered_questions,v_total_questions; end if;
  select count(*) filter(where qa.is_correct=true),coalesce(sum(qa.xp_earned),0) into v_correct_count,v_xp from public.question_attempts qa where qa.session_id=p_session_id and qa.user_id=v_user_id;
  v_score:=round((v_correct_count::numeric/v_total_questions::numeric)*100,2);
  update public.revision_sessions set correct_count=v_correct_count,xp_earned=v_xp,completed_at=now() where id=p_session_id;
  v_progress:=public.update_user_progress_v2(v_user_id,v_xp,v_activity_date);
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object('session_id',p_session_id,'score',v_score,'correct_count',v_correct_count,'incorrect_count',v_total_questions-v_correct_count,'total_questions',v_total_questions,'xp_earned',v_xp,'xp_total',v_progress->'xp_total','level',v_progress->'level','level_name',v_progress->'level_name','current_streak',v_progress->'current_streak','longest_streak',v_progress->'longest_streak','last_activity_date',v_progress->'last_activity_date','new_badges',v_badges->'new_badges','new_badges_count',v_badges->'new_badges_count');
end;
$function$
;
CREATE OR REPLACE FUNCTION public.lock_student_curriculum_assignment()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_auth_uid uuid := auth.uid();
begin
  if new.academic_level_id is not null and not exists (
    select 1
    from public.academic_levels al
    where al.id = new.academic_level_id
      and al.program_id = new.program_id
  ) then
    raise exception 'academic level does not belong to assigned program';
  end if;

  if new.program_id = 'ifsi-fr' then
    if coalesce(new.curriculum_version,'2009') not in ('2009','2026') then
      raise exception 'invalid IFSI curriculum version';
    end if;
  elsif coalesce(new.curriculum_version,'default') <> 'default' then
    raise exception 'curriculum version must be default for this program';
  end if;

  if tg_op = 'INSERT' then
    if exists (select 1 from public.profile_programs existing where existing.user_id = new.user_id) then
      if v_auth_uid = new.user_id then
        raise exception 'student curriculum is already assigned';
      end if;
      new.is_primary := coalesce(new.is_primary,false);
      if new.is_primary then
        raise exception 'a secondary curriculum cannot replace the existing primary curriculum';
      end if;
      return new;
    end if;
    new.is_primary := true;
    return new;
  end if;

  if new.user_id is distinct from old.user_id or new.program_id is distinct from old.program_id then
    raise exception 'student curriculum cannot be changed';
  end if;

  if v_auth_uid = new.user_id and old.is_primary is not true then
    raise exception 'secondary curriculum assignment is managed by an administrator';
  end if;

  if old.is_primary then new.is_primary := true; else new.is_primary := false; end if;
  return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.create_curriculum_friend_challenge_v1(p_friend_id uuid, p_program_id text DEFAULT 'ifsi-fr'::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_id uuid;
  v_count integer;
  v_username text;
  v_program_name text;
  v_level_id uuid;
  v_friend_level_id uuid;
  v_version text;
  v_friend_version text;
  v_level_code text;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_friend_id is null or p_friend_id=v_uid then raise exception 'Ami invalide'; end if;

  if not exists(select 1 from public.friendships f where f.status='accepted' and ((f.requester_id=v_uid and f.addressee_id=p_friend_id) or (f.requester_id=p_friend_id and f.addressee_id=v_uid))) then
    raise exception 'Cet utilisateur ne fait pas partie de tes amis';
  end if;

  select pp.academic_level_id,coalesce(pp.curriculum_version,'default') into v_level_id,v_version
  from public.profile_programs pp where pp.user_id=v_uid and pp.program_id=p_program_id order by pp.is_primary desc limit 1;
  select pp.academic_level_id,coalesce(pp.curriculum_version,'default') into v_friend_level_id,v_friend_version
  from public.profile_programs pp where pp.user_id=p_friend_id and pp.program_id=p_program_id order by pp.is_primary desc limit 1;

  if v_level_id is null or v_friend_level_id is null then raise exception 'Les deux participants doivent avoir ce cursus attribué et un niveau sélectionné'; end if;
  if v_level_id<>v_friend_level_id then raise exception 'Les défis sont disponibles entre étudiants du même niveau'; end if;
  if v_version<>v_friend_version then raise exception 'Les défis sont disponibles entre étudiants du même référentiel'; end if;

  if exists(select 1 from public.curriculum_friend_challenges c where c.program_id=p_program_id and c.academic_level_id=v_level_id and c.status in ('pending','accepted','in_progress') and ((c.challenger_id=v_uid and c.challenged_id=p_friend_id) or (c.challenger_id=p_friend_id and c.challenged_id=v_uid))) then
    raise exception 'Un défi est déjà en cours avec cet ami';
  end if;

  select count(*) into v_count
  from public.curriculum_quiz_questions q
  join public.curriculum_topics t on t.id=q.topic_id
  join public.curriculum_units u on u.id=t.unit_id
  where u.program_id=p_program_id and u.academic_level_id=v_level_id and coalesce(u.curriculum_version,'default')=v_version
    and u.is_active=true and t.is_active=true and q.is_published=true and q.validation_status='source_validated'
    and q.question_type='mcq' and jsonb_array_length(q.options)>=2
    and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true);
  if v_count<10 then raise exception 'Pas assez de QCM validés pour créer un défi dans ce niveau'; end if;

  insert into public.curriculum_friend_challenges(program_id,academic_level_id,challenger_id,challenged_id)
  values(p_program_id,v_level_id,v_uid,p_friend_id) returning id into v_id;

  insert into public.curriculum_friend_challenge_questions(challenge_id,question_id,display_order)
  select v_id,id,row_number() over(order by random())::integer
  from (
    select q.id
    from public.curriculum_quiz_questions q
    join public.curriculum_topics t on t.id=q.topic_id
    join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id and u.academic_level_id=v_level_id and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq' and jsonb_array_length(q.options)>=2
      and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true)
    order by random() limit 10
  ) s;

  select coalesce(p.username::text,p.first_name,'Un ami') into v_username from public.profiles p where p.id=v_uid;
  select coalesce(p.short_name,p.name,p_program_id) into v_program_name from public.programs p where p.id=p_program_id;
  select al.code into v_level_code from public.academic_levels al where al.id=v_level_id;

  insert into public.notifications(user_id,type,title,body,data)
  values(p_friend_id,'challenge_received','Nouveau défi ⚔️',v_username||' te défie sur 10 questions '||coalesce(v_program_name,p_program_id)||' · '||coalesce(v_level_code,'niveau sélectionné')||'.',jsonb_build_object('curriculum_challenge_id',v_id,'program_id',p_program_id,'academic_level_id',v_level_id,'curriculum_version',v_version));
  return v_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_lesson_quiz_v3_internal(p_user_id uuid, p_lesson_id uuid, p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_session_id uuid; v_available integer; v_count integer;
begin
  if p_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_question_count is null or p_question_count<1 or p_question_count>50 then raise exception 'Nombre de questions invalide'; end if;
  if not exists(
    select 1
    from public.lessons l
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    join public.profiles p on p.id=p_user_id
    where l.id=p_lesson_id
      and l.is_published=true
      and l.validation_status='published'
      and c.is_active=true
      and s.is_active=true
      and y.is_active=true
      and (y.number=p.study_year or p.role='admin')
  ) then raise exception 'Leçon indisponible pour ton année active'; end if;
  select count(*) into v_available from public.questions q where q.lesson_id=p_lesson_id and q.is_published=true and q.validation_status='published' and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case');
  if v_available=0 then raise exception 'Aucune question validée disponible pour cette leçon'; end if;
  v_count:=least(p_question_count,v_available);
  insert into public.revision_sessions(user_id,mode,question_count) values(p_user_id,'mix',v_count) returning id into v_session_id;
  with candidates as (
    select q.id,coalesce(uqm.mastery_percent,0) mastery_percent,coalesce(uqm.attempt_count,0) attempt_count,coalesce(uqm.correct_count,0) correct_count,uqm.last_attempt_at,uqm.next_review_at,coalesce(uqm.lapse_count,0) lapse_count,
      case when uqm.next_review_at is not null and uqm.next_review_at<=now() then 1 when uqm.id is not null and coalesce(uqm.correct_count,0)<coalesce(uqm.attempt_count,0) then 2 when uqm.id is not null and coalesce(uqm.mastery_percent,0)<60 then 3 when uqm.id is null then 4 when uqm.id is not null and coalesce(uqm.mastery_percent,0)<80 then 5 else 6 end priority_group,
      case when exists(select 1 from public.question_attempts qa where qa.user_id=p_user_id and qa.question_id=q.id and qa.created_at>=now()-interval '12 hours') then 1 else 0 end recent_penalty,
      case when uqm.next_review_at is not null and uqm.next_review_at<=now() then extract(epoch from(now()-uqm.next_review_at))/86400.0 else 0 end overdue_days
    from public.questions q left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=p_user_id
    where q.lesson_id=p_lesson_id and q.is_published=true and q.validation_status='published' and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
  ),ranked as(select c.*,row_number() over(order by c.priority_group,c.recent_penalty,c.overdue_days desc,c.lapse_count desc,c.mastery_percent,c.last_attempt_at nulls first,random()) rn from candidates c)
  insert into public.revision_session_questions(session_id,question_id,display_order) select v_session_id,r.id,r.rn::integer from ranked r where r.rn<=v_count order by r.rn;
  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friend_leaderboard_v1()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
with me as (select auth.uid() uid),
people as (
  select uid as user_id,true as is_me from me where uid is not null
  union
  select case when f.requester_id=me.uid then f.addressee_id else f.requester_id end,false
  from public.friendships f cross join me
  where me.uid is not null and f.status='accepted' and (f.requester_id=me.uid or f.addressee_id=me.uid)
), activity as (
  select p.user_id,coalesce(sum(qa.xp_earned) filter(where qa.created_at>=date_trunc('week',now())),0)::int as weekly_xp,
         count(qa.id) filter(where qa.created_at>=date_trunc('week',now()))::int as weekly_answers
  from people p
  left join public.question_attempts qa on qa.user_id=p.user_id
  group by p.user_id
), rows as (
  select pr.id,pr.username::text,pr.first_name,pr.avatar_url,pr.level,pr.xp,
         a.weekly_xp,a.weekly_answers,p.is_me,
         row_number() over(order by a.weekly_xp desc,pr.xp desc,coalesce(pr.username::text,pr.first_name,'') asc)::int as rank
  from people p
  join public.profiles pr on pr.id=p.user_id
  join activity a on a.user_id=p.user_id
)
select coalesce(jsonb_agg(jsonb_build_object(
  'id',id,'username',username,'first_name',first_name,'avatar_url',avatar_url,'level',level,'xp_total',xp,
  'weekly_xp',weekly_xp,'weekly_answers',weekly_answers,'is_me',is_me,'rank',rank
) order by rank),'[]'::jsonb) from rows;
$function$
;
CREATE OR REPLACE FUNCTION public.search_students_v3(p_query text, p_program_id text)
 RETURNS TABLE(id uuid, username text, first_name text, study_year integer, level integer, avatar_url text, program_id text, level_code text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select
    p.id,
    p.username::text,
    p.first_name,
    p.study_year,
    p.level,
    p.avatar_url,
    pp.program_id,
    al.code::text as level_code
  from public.profiles p
  join public.profile_programs pp on pp.user_id = p.id and pp.program_id = p_program_id
  left join public.academic_levels al on al.id = pp.academic_level_id
  where (select auth.uid()) is not null
    and p.id <> (select auth.uid())
    and p.username is not null
    and length(trim(coalesce(p_query, ''))) >= 2
    and (p.username ilike '%' || trim(p_query) || '%' or coalesce(p.first_name, '') ilike '%' || trim(p_query) || '%')
    and exists(
      select 1 from public.profile_programs mine
      where mine.user_id = (select auth.uid()) and mine.program_id = p_program_id
    )
  order by case when lower(p.username::text) = lower(trim(p_query)) then 0 else 1 end, p.username
  limit 12;
$function$
;
CREATE OR REPLACE FUNCTION public.get_user_dashboard_v3()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_study_year integer;
  v_base jsonb;
  v_published integer:=0; v_attempted integer:=0; v_mastered integer:=0; v_fragile integer:=0; v_due integer:=0;
  v_mastery_sum numeric:=0; v_overall numeric:=0; v_coverage numeric:=0; v_avg numeric:=0;
  v_daily jsonb;
  v_challenge_id uuid; v_session_id uuid; v_answered integer:=0; v_total integer:=10; v_completed boolean:=false; v_score integer; v_xp integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  select p.study_year into v_study_year from public.profiles p where p.id=v_user_id;
  v_base:=public.get_user_dashboard_v2();

  select count(*) into v_published
  from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
  where q.is_published=true and q.validation_status='published' and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_study_year;

  select count(*) filter(where uqm.attempt_count>0),count(*) filter(where uqm.attempt_count>0 and uqm.mastery_percent>=80),
         count(*) filter(where uqm.attempt_count>0 and uqm.mastery_percent<60),count(*) filter(where uqm.next_review_at is not null and uqm.next_review_at<=now()),
         coalesce(avg(uqm.mastery_percent) filter(where uqm.attempt_count>0),0),coalesce(sum(uqm.mastery_percent),0)
  into v_attempted,v_mastered,v_fragile,v_due,v_avg,v_mastery_sum
  from public.user_question_mastery uqm
  join public.questions q on q.id=uqm.question_id
  join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
  where uqm.user_id=v_user_id and q.is_published=true and q.validation_status='published' and y.number=v_study_year;

  if v_published>0 then v_coverage:=round((v_attempted::numeric/v_published)*100,1); v_overall:=round(v_mastery_sum/v_published,1); end if;

  select dc.id into v_challenge_id from public.daily_challenges dc
  where dc.challenge_date=current_date and dc.study_year=v_study_year and dc.is_active=true
  order by dc.created_at desc limit 1;
  if v_challenge_id is not null then
    select rs.id,rs.question_count,(rs.completed_at is not null) into v_session_id,v_total,v_completed
    from public.revision_sessions rs where rs.user_id=v_user_id and rs.daily_challenge_id=v_challenge_id order by rs.started_at desc limit 1;
    if v_session_id is not null then select count(*) into v_answered from public.revision_session_questions where session_id=v_session_id and answered_at is not null; end if;
    select dca.score,dca.xp_earned into v_score,v_xp from public.daily_challenge_attempts dca where dca.user_id=v_user_id and dca.challenge_id=v_challenge_id limit 1;
    if found then v_completed:=true; end if;
  end if;
  v_daily:=jsonb_build_object('id',v_challenge_id,'ready',v_challenge_id is not null,'question_count',coalesce(v_total,10),'answered_count',v_answered,'completed',v_completed,'score',v_score,'xp_earned',v_xp,'status',case when v_completed then 'completed' when v_session_id is not null and v_answered>0 then 'in_progress' when v_challenge_id is not null then 'ready' else 'not_created' end);

  return v_base || jsonb_build_object(
    'mastery',jsonb_build_object('published_questions',v_published,'attempted_questions',v_attempted,'mastered',v_mastered,'mastered_questions',v_mastered,'fragile',v_fragile,'fragile_questions',v_fragile,'due',v_due,'reviews_due',v_due,'coverage_percent',v_coverage,'average_attempted_percent',round(v_avg,1),'overall_percent',v_overall),
    'daily',v_daily,'daily_challenge',v_daily
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_weak_revision_v1(p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_user_id uuid:=auth.uid(); v_session_id uuid; v_actual_count integer; v_study_year integer;
begin
 if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
 if p_question_count is null or p_question_count<1 or p_question_count>30 then raise exception 'Nombre de questions invalide'; end if;
 select study_year into v_study_year from public.profiles where id=v_user_id;
 insert into public.revision_sessions(user_id,mode,question_count) values(v_user_id,'weak',p_question_count) returning id into v_session_id;
 with candidates as(
  select q.id,coalesce(uqm.mastery_percent,0) mastery_percent,coalesce(uqm.attempt_count,0) attempt_count,coalesce(uqm.correct_count,0) correct_count,coalesce(uqm.lapse_count,0) lapse_count,uqm.next_review_at,
   case when uqm.next_review_at is not null and uqm.next_review_at<=now() then 1 when coalesce(uqm.attempt_count,0)>0 and coalesce(uqm.correct_count,0)<coalesce(uqm.attempt_count,0) then 2 when uqm.id is not null and coalesce(uqm.mastery_percent,0)<60 then 3 else 4 end priority_group,
   case when exists(select 1 from public.question_attempts qa where qa.user_id=v_user_id and qa.question_id=q.id and qa.created_at>=now()-interval '8 hours') then 1 else 0 end recent_penalty
  from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
  where q.is_published=true and q.validation_status='published' and c.is_active=true and s.is_active=true and y.is_active=true and (v_study_year is null or y.number=v_study_year)
   and (uqm.next_review_at<=now() or coalesce(uqm.mastery_percent,0)<60 or coalesce(uqm.correct_count,0)<coalesce(uqm.attempt_count,0))
 ),chosen as(select id,row_number() over(order by priority_group,recent_penalty,lapse_count desc,mastery_percent,attempt_count desc,random()) display_order from candidates limit p_question_count)
 insert into public.revision_session_questions(session_id,question_id,display_order) select v_session_id,id,display_order::integer from chosen;
 select count(*) into v_actual_count from public.revision_session_questions where session_id=v_session_id;
 if v_actual_count=0 then delete from public.revision_sessions where id=v_session_id; raise exception 'Aucune notion fragile validée à revoir pour le moment'; end if;
 update public.revision_sessions set question_count=v_actual_count where id=v_session_id; return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_user_stats_v3(p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_days integer;
  v_year integer;
  v_result jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  v_days:=greatest(7,least(coalesce(p_days,30),365));
  select study_year into v_year from public.profiles where id=v_user_id;

  with qbase as (
    select q.id,q.question_text,q.type,q.difficulty,s.id subject_id,s.name subject_name,s.slug,s.icon,s.display_order,y.number year_number
    from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
    where q.is_published=true and q.validation_status='published' and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_year
  ), attempts as (
    select qa.* from public.question_attempts qa join qbase q on q.id=qa.question_id
    where qa.user_id=v_user_id and qa.created_at>=current_date-(v_days-1)
  ), completed_sessions as (
    select distinct rs.* from public.revision_sessions rs
    join public.question_attempts qa on qa.session_id=rs.id
    join qbase q on q.id=qa.question_id
    where rs.user_id=v_user_id and rs.completed_at is not null and rs.completed_at>=current_date-(v_days-1)
  ), overall as (
    select count(*)::int attempts_count,count(*) filter(where is_correct)::int correct_count,coalesce(round(avg(response_time_ms))::int,0) avg_response_ms from attempts
  ), session_totals as (
    select count(*)::int completed_sessions_count from completed_sessions
  ), mastery as (
    select count(uqm.question_id) filter(where uqm.attempt_count>0)::int attempted_questions,
      count(uqm.question_id) filter(where uqm.mastery_percent>=80 and uqm.attempt_count>0)::int mastered_questions,
      count(uqm.question_id) filter(where uqm.mastery_percent<60 and uqm.attempt_count>0)::int fragile_questions,
      count(uqm.question_id) filter(where uqm.next_review_at is not null and uqm.next_review_at<=now())::int reviews_due,
      coalesce(round(avg(uqm.mastery_percent) filter(where uqm.attempt_count>0))::int,0) avg_mastery
    from qbase q left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
  ), daily_series as (
    select generate_series(current_date-(v_days-1),current_date,interval '1 day')::date activity_date
  ), daily_agg as (
    select date(created_at) activity_date,count(*)::int attempts_count,count(*) filter(where is_correct)::int correct_count,coalesce(sum(xp_earned),0)::int xp_sum
    from attempts group by date(created_at)
  ), daily_json as (
    select coalesce(jsonb_agg(jsonb_build_object('date',ds.activity_date,'attempts',coalesce(da.attempts_count,0),'correct',coalesce(da.correct_count,0),'accuracy_percent',case when coalesce(da.attempts_count,0)=0 then 0 else round(100.0*da.correct_count/da.attempts_count)::int end,'xp',coalesce(da.xp_sum,0)) order by ds.activity_date),'[]'::jsonb) data
    from daily_series ds left join daily_agg da on da.activity_date=ds.activity_date
  ), subject_content as (
    select subject_id,max(subject_name) name,max(slug) slug,max(icon) icon,max(year_number) year_number,max(display_order) display_order,count(*)::int published_questions
    from qbase group by subject_id
  ), subject_mastery as (
    select q.subject_id,count(uqm.question_id) filter(where uqm.attempt_count>0)::int attempted_questions,coalesce(round(avg(uqm.mastery_percent) filter(where uqm.attempt_count>0))::int,0) mastery_percent,
      count(uqm.question_id) filter(where uqm.mastery_percent>=80 and uqm.attempt_count>0)::int mastered_questions,count(uqm.question_id) filter(where uqm.mastery_percent<60 and uqm.attempt_count>0)::int fragile_questions
    from qbase q left join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id group by q.subject_id
  ), subject_attempts as (
    select q.subject_id,count(a.id)::int attempts_count,count(a.id) filter(where a.is_correct)::int correct_attempts
    from qbase q left join attempts a on a.question_id=q.id group by q.subject_id
  ), subjects_json as (
    select coalesce(jsonb_agg(jsonb_build_object('id',sc.subject_id,'name',sc.name,'slug',sc.slug,'icon',sc.icon,'year_number',sc.year_number,'published_questions',sc.published_questions,'attempted_questions',coalesce(sm.attempted_questions,0),'coverage_percent',case when sc.published_questions=0 then 0 else round(100.0*coalesce(sm.attempted_questions,0)/sc.published_questions)::int end,'attempts',coalesce(sa.attempts_count,0),'correct_attempts',coalesce(sa.correct_attempts,0),'accuracy_percent',case when coalesce(sa.attempts_count,0)=0 then 0 else round(100.0*sa.correct_attempts/sa.attempts_count)::int end,'mastery_percent',coalesce(sm.mastery_percent,0),'mastered_questions',coalesce(sm.mastered_questions,0),'fragile_questions',coalesce(sm.fragile_questions,0)) order by sc.display_order,sc.name),'[]'::jsonb) data
    from subject_content sc left join subject_mastery sm on sm.subject_id=sc.subject_id left join subject_attempts sa on sa.subject_id=sc.subject_id
  ), mode_rows as (
    select mode,count(*)::int sessions_count,coalesce(sum(question_count),0)::int questions_count,coalesce(sum(correct_count),0)::int correct_count,coalesce(sum(xp_earned),0)::int xp_sum from completed_sessions group by mode
  ), modes_json as (
    select coalesce(jsonb_agg(jsonb_build_object('mode',mode,'sessions',sessions_count,'questions',questions_count,'correct',correct_count,'accuracy_percent',case when questions_count=0 then 0 else round(100.0*correct_count/questions_count)::int end,'xp',xp_sum) order by sessions_count desc,mode),'[]'::jsonb) data from mode_rows
  ), weak_rows as (
    select q.id question_id,left(q.question_text,180) question_text,q.type,q.difficulty,q.subject_name,uqm.attempt_count,uqm.correct_count,uqm.mastery_percent,uqm.lapse_count,uqm.next_review_at,
      case when uqm.attempt_count=0 then 0 else round(100.0*uqm.correct_count/uqm.attempt_count)::int end accuracy_percent
    from qbase q join public.user_question_mastery uqm on uqm.question_id=q.id and uqm.user_id=v_user_id
    where uqm.attempt_count>0 and uqm.mastery_percent<80
    order by uqm.mastery_percent asc,uqm.lapse_count desc,uqm.attempt_count desc,uqm.last_attempt_at desc limit 10
  ), weak_json as (
    select coalesce(jsonb_agg(jsonb_build_object('question_id',question_id,'question_text',question_text,'type',type,'difficulty',difficulty,'subject_name',subject_name,'attempt_count',attempt_count,'correct_count',correct_count,'accuracy_percent',accuracy_percent,'mastery_percent',mastery_percent,'lapse_count',lapse_count,'next_review_at',next_review_at)),'[]'::jsonb) data from weak_rows
  )
  select jsonb_build_object('period_days',v_days,'study_year',v_year,'generated_at',now(),
    'summary',jsonb_build_object('attempts',o.attempts_count,'correct_answers',o.correct_count,'incorrect_answers',o.attempts_count-o.correct_count,'accuracy_percent',case when o.attempts_count=0 then 0 else round(100.0*o.correct_count/o.attempts_count)::int end,'avg_response_ms',o.avg_response_ms,'completed_sessions',st.completed_sessions_count,'xp_total',coalesce(p.xp,0),'level',coalesce(p.level,1),'attempted_questions',m.attempted_questions,'mastered_questions',m.mastered_questions,'fragile_questions',m.fragile_questions,'reviews_due',m.reviews_due,'mastery_percent',m.avg_mastery),
    'daily_activity',dj.data,'subjects',sj.data,'modes',mj.data,'weak_questions',wj.data)
  into v_result
  from overall o cross join session_totals st cross join mastery m cross join daily_json dj cross join subjects_json sj cross join modes_json mj cross join weak_json wj join public.profiles p on p.id=v_user_id;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_quiz_questions_v3(p_session_id uuid)
 RETURNS TABLE(id uuid, type text, question_text text, explanation text, difficulty integer, image_url text, metadata jsonb, question_options jsonb, display_order integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  if not exists (
    select 1
    from public.revision_sessions rs
    where rs.id = p_session_id
      and rs.user_id = auth.uid()
  ) then
    raise exception 'Session inexistante ou accès non autorisé';
  end if;

  return query
  select
    q.id,
    q.type,
    q.question_text,
    null::text as explanation,
    q.difficulty,
    q.image_url,
    case
      when q.type = 'matching' then
        jsonb_build_object(
          'left_items', coalesce((
            select jsonb_agg(e.value->'left' order by e.ord)
            from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality as e(value,ord)
          ), '[]'::jsonb),
          'right_items', coalesce((
            select jsonb_agg(r.right_value order by random())
            from (
              select e.value->'right' as right_value
              from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) as e(value)
            ) r
          ), '[]'::jsonb)
        )
      else
        coalesce(q.metadata,'{}'::jsonb)
          - 'answer'
          - 'correct_answer'
          - 'is_correct'
          - 'pairs'
    end as metadata,
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', qo.id,
          'option_text', qo.option_text,
          'display_order', qo.display_order
        ) order by qo.display_order
      )
      from public.question_options qo
      where qo.question_id = q.id
    ), '[]'::jsonb) as question_options,
    rsq.display_order
  from public.revision_session_questions rsq
  join public.questions q on q.id = rsq.question_id
  where rsq.session_id = p_session_id
    and q.is_published = true
  order by rsq.display_order;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_quiz_answer_v2(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_result jsonb;
  v_correct boolean;
  v_user_id uuid;
  v_difficulty integer := 2;
  v_interval integer := 1;
  v_consecutive integer := 0;
  v_lapses integer := 0;
  v_ease numeric(4,2) := 2.50;
  v_attempts integer := 0;
  v_correct_count integer := 0;
  v_mastery_percent integer := 0;
begin
  if auth.uid() is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  select rs.user_id
  into v_user_id
  from public.revision_sessions rs
  where rs.id = p_session_id
    and rs.user_id = auth.uid()
    and rs.completed_at is null;

  if v_user_id is null then
    raise exception 'Session inexistante, terminée ou accès non autorisé';
  end if;

  select coalesce(q.difficulty, 2)
  into v_difficulty
  from public.questions q
  where q.id = p_question_id;

  v_result := public.submit_quiz_answer(
    p_session_id,
    p_question_id,
    p_answer,
    p_response_time_ms
  );

  v_correct := coalesce((v_result->>'correct')::boolean, false);

  select
    uqm.interval_days,
    uqm.consecutive_correct,
    uqm.lapse_count,
    uqm.ease_factor,
    uqm.attempt_count,
    uqm.correct_count
  into
    v_interval,
    v_consecutive,
    v_lapses,
    v_ease,
    v_attempts,
    v_correct_count
  from public.user_question_mastery uqm
  where uqm.user_id = v_user_id
    and uqm.question_id = p_question_id
  for update;

  if v_correct then
    v_consecutive := coalesce(v_consecutive, 0) + 1;
    v_ease := least(3.00, coalesce(v_ease, 2.50) + 0.05);

    v_interval := case
      when v_consecutive = 1 then 1
      when v_consecutive = 2 then 3
      when v_consecutive = 3 then 7
      when v_consecutive = 4 then 14
      when v_consecutive = 5 then 30
      else least(365, greatest(1, round(coalesce(v_interval, 30) * v_ease)::integer))
    end;
  else
    v_consecutive := 0;
    v_lapses := coalesce(v_lapses, 0) + 1;
    v_ease := greatest(1.30, coalesce(v_ease, 2.50) - 0.20);
    v_interval := 1;
  end if;

  v_mastery_percent := least(
    100,
    greatest(
      0,
      round(
        (
          (coalesce(v_correct_count, 0)::numeric / greatest(coalesce(v_attempts, 1), 1)) * 65
          + least(v_consecutive, 5)::numeric / 5 * 20
          + least(v_interval, 30)::numeric / 30 * 10
          + greatest(0, 5 - v_difficulty)::numeric / 4 * 5
        )
      )::integer
    )
  );

  update public.user_question_mastery
  set mastery_percent = v_mastery_percent,
      interval_days = v_interval,
      consecutive_correct = v_consecutive,
      lapse_count = v_lapses,
      ease_factor = v_ease,
      next_review_at = now() + make_interval(days => v_interval)
  where user_id = v_user_id
    and question_id = p_question_id;

  return v_result || jsonb_build_object(
    'mastery_percent', v_mastery_percent,
    'interval_days', v_interval,
    'consecutive_correct', v_consecutive,
    'lapse_count', v_lapses,
    'ease_factor', v_ease,
    'next_review_at', now() + make_interval(days => v_interval)
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.start_smart_revision(p_question_count integer DEFAULT 10)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_session_id uuid;
  v_actual_count integer;
BEGIN

  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non authentifié';
  END IF;

  IF p_question_count < 1 OR p_question_count > 50 THEN
    RAISE EXCEPTION 'Nombre de questions invalide';
  END IF;

  /*
    Création de la session.
  */
  INSERT INTO public.revision_sessions (
    user_id,
    mode,
    question_count
  )
  VALUES (
    auth.uid(),
    'smart',
    p_question_count
  )
  RETURNING id INTO v_session_id;

  /*
    Sélection personnalisée des questions.

    Priorités :
    1. Révisions arrivées à échéance
    2. Faible maîtrise
    3. Questions avec erreurs précédentes
    4. Questions jamais travaillées
  */
  INSERT INTO public.revision_session_questions (
    session_id,
    question_id,
    display_order
  )
  SELECT
    v_session_id,
    ranked.id,
    ROW_NUMBER() OVER (
      ORDER BY ranked.priority_group,
               ranked.mastery_score,
               random()
    )::integer
  FROM (
    SELECT
      q.id,

      COALESCE(uqm.mastery_score, 0) AS mastery_score,

      CASE
        /* Révision arrivée à échéance */
        WHEN uqm.next_review_at IS NOT NULL
          AND uqm.next_review_at <= now()
          THEN 1

        /* Question déjà travaillée mais mal maîtrisée */
        WHEN uqm.id IS NOT NULL
          AND COALESCE(uqm.mastery_score, 0) < 3
          THEN 2

        /* Question avec au moins une erreur */
        WHEN uqm.id IS NOT NULL
          AND COALESCE(uqm.correct_count, 0)
              < COALESCE(uqm.attempt_count, 0)
          THEN 3

        /* Question jamais travaillée */
        WHEN uqm.id IS NULL
          THEN 4

        /* Question déjà bien maîtrisée */
        ELSE 5
      END AS priority_group

    FROM public.questions q

    LEFT JOIN public.user_question_mastery uqm
      ON uqm.question_id = q.id
      AND uqm.user_id = auth.uid()

    WHERE q.is_published = true

  ) ranked

  ORDER BY
    ranked.priority_group,
    ranked.mastery_score,
    random()

  LIMIT p_question_count;

  /*
    Nombre réel de questions sélectionnées.
  */
  SELECT COUNT(*)
  INTO v_actual_count
  FROM public.revision_session_questions
  WHERE session_id = v_session_id;

  IF v_actual_count = 0 THEN
    DELETE FROM public.revision_sessions
    WHERE id = v_session_id;

    RAISE EXCEPTION
      'Aucune question publiée disponible';
  END IF;

  UPDATE public.revision_sessions
  SET question_count = v_actual_count
  WHERE id = v_session_id;

  RETURN v_session_id;

END;
$function$
;
CREATE OR REPLACE FUNCTION public.remove_friendship_v1(p_friendship_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_row public.friendships%rowtype;
  v_other uuid;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_row from public.friendships where id=p_friendship_id for update;
  if v_row.id is null then raise exception 'Relation introuvable'; end if;
  if v_row.status='pending' then
    if v_row.requester_id<>v_uid then raise exception 'Seul l’expéditeur peut annuler cette invitation'; end if;
  elsif v_row.status='accepted' then
    if v_row.requester_id<>v_uid and v_row.addressee_id<>v_uid then raise exception 'Accès non autorisé'; end if;
  else
    raise exception 'Cette relation ne peut pas être supprimée ici';
  end if;
  v_other:=case when v_row.requester_id=v_uid then v_row.addressee_id else v_row.requester_id end;
  update public.challenges set status='cancelled'
  where status in ('pending','accepted','in_progress') and ((challenger_id=v_uid and challenged_id=v_other) or (challenger_id=v_other and challenged_id=v_uid));
  delete from public.friendships where id=p_friendship_id;
  return true;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.ensure_daily_challenge_v2(p_challenge_date date DEFAULT CURRENT_DATE)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_study_year integer;
  v_challenge_id uuid;
  v_available integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_challenge_date is null then raise exception 'Date de challenge invalide'; end if;
  select p.study_year into v_study_year from public.profiles p where p.id=v_user_id;
  if v_study_year is null then raise exception 'Année d’étude non renseignée'; end if;

  select dc.id into v_challenge_id
  from public.daily_challenges dc
  where dc.challenge_date=p_challenge_date and dc.study_year=v_study_year and dc.is_active=true
  order by dc.created_at desc limit 1;
  if v_challenge_id is not null then return v_challenge_id; end if;

  select count(*) into v_available
  from public.questions q
  join public.chapters c on c.id=q.chapter_id
  join public.subjects s on s.id=c.subject_id
  join public.years y on y.id=s.year_id
  where q.is_published=true and q.validation_status='published'
    and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
    and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_study_year;
  if v_available<10 then raise exception 'Impossible de créer le challenge K% : seulement % question(s) validée(s), 10 nécessaires',v_study_year,v_available; end if;

  insert into public.daily_challenges(challenge_date,title,description,xp_reward,is_active,study_year)
  values(p_challenge_date,'Challenge du jour K'||v_study_year,'10 questions variées adaptées à ton année pour entretenir ta série 🔥',100,true,v_study_year)
  on conflict (challenge_date,study_year) where study_year is not null do update set is_active=true
  returning id into v_challenge_id;

  if not exists(select 1 from public.daily_challenge_questions dcq where dcq.challenge_id=v_challenge_id) then
    with candidates as (
      select q.id,q.type,q.chapter_id,
             row_number() over(partition by q.type order by random()) as type_rank,
             row_number() over(partition by q.chapter_id order by random()) as chapter_rank
      from public.questions q
      join public.chapters c on c.id=q.chapter_id
      join public.subjects s on s.id=c.subject_id
      join public.years y on y.id=s.year_id
      where q.is_published=true and q.validation_status='published'
        and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
        and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_study_year
    ), ranked as (
      select c.id,
             row_number() over(
               order by case when c.type_rank=1 then 0 else 1 end,
                        c.chapter_rank,
                        c.type_rank,
                        random()
             )::integer as display_order
      from candidates c
    ), picked as (
      select id,display_order
      from ranked
      order by display_order
      limit 10
    )
    insert into public.daily_challenge_questions(challenge_id,question_id,display_order)
    select v_challenge_id,p.id,row_number() over(order by p.display_order)::integer
    from picked p;
  end if;
  return v_challenge_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_revision_session_review_v2(p_session_id uuid)
 RETURNS TABLE(display_order integer, question_id uuid, question_type text, question_text text, explanation text, image_url text, subject_name text, is_correct boolean, user_answer_display text, correct_answer_display text, response_time_ms integer, source_title text, source_page integer)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
select
  rsq.display_order,q.id,q.type,q.question_text,q.explanation,q.image_url,s.name,qa.is_correct,
  case
    when q.type in ('mcq','true_false') or (q.type='clinical_case' and qa.answer ? 'option_id') then coalesce((select qo.option_text from public.question_options qo where qo.id=(qa.answer->>'option_id')::uuid),'Réponse enregistrée')
    when q.type in ('fill_blank','short_answer','translation','clinical_case') then coalesce(qa.answer->>'text','Réponse enregistrée')
    when q.type='matching' then coalesce((select string_agg((e.value->>'left')||' → '||(e.value->>'right'),' · ' order by e.ord) from jsonb_array_elements(coalesce(qa.answer->'pairs','[]'::jsonb)) with ordinality e(value,ord)),'Associations enregistrées')
    when q.type='hotspot' then 'Zone sélectionnée sur le schéma'
    when q.type='image' then 'Étiquettes placées sur le schéma'
    else coalesce(qa.answer::text,'Réponse enregistrée')
  end,
  case
    when q.type in ('mcq','true_false') or (q.type='clinical_case' and exists(select 1 from public.question_options qo where qo.question_id=q.id)) then coalesce((select string_agg(qo.option_text,' · ' order by qo.display_order) from public.question_options qo where qo.question_id=q.id and qo.is_correct=true),'')
    when q.type in ('fill_blank','short_answer','translation','clinical_case') then coalesce(q.metadata->>'answer',(select string_agg(a.value,' / ') from jsonb_array_elements_text(case when jsonb_typeof(q.metadata->'accepted_answers')='array' then q.metadata->'accepted_answers' else '[]'::jsonb end) a(value)),'Voir l’explication')
    when q.type='matching' then coalesce((select string_agg((e.value->>'left')||' → '||(e.value->>'right'),' · ' order by e.ord) from jsonb_array_elements(coalesce(q.metadata->'pairs','[]'::jsonb)) with ordinality e(value,ord)),'Voir l’explication')
    when q.type='hotspot' then coalesce(q.metadata->'hotspot'->>'label','Zone indiquée sur le schéma')
    when q.type='image' then 'Voir les emplacements attendus sur le schéma'
    else 'Voir l’explication'
  end,
  qa.response_time_ms,
  coalesce(src.title,nullif(btrim(q.source),'')),
  src.page_number
from public.revision_sessions rs
join public.revision_session_questions rsq on rsq.session_id=rs.id
join public.questions q on q.id=rsq.question_id
join public.chapters c on c.id=q.chapter_id
join public.subjects s on s.id=c.subject_id
left join lateral (
  select a.* from public.question_attempts a where a.session_id=rs.id and a.question_id=q.id and a.user_id=auth.uid() order by a.created_at desc limit 1
) qa on true
left join lateral (
  select cd.title,qs.page_number from public.question_sources qs join public.course_documents cd on cd.id=qs.document_id where qs.question_id=q.id order by qs.created_at asc limit 1
) src on true
where rs.id=p_session_id and rs.user_id=auth.uid() and rs.completed_at is not null
order by rsq.display_order;
$function$
;
CREATE OR REPLACE FUNCTION public.start_atlas_session_v1(p_area text, p_question_count integer DEFAULT 8)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid := auth.uid();
  v_session uuid;
  v_count integer;
  v_limit integer := least(10, greatest(3, coalesce(p_question_count,8)));
begin
  if v_user is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_area not in ('Hanche','Genou','Cheville','Pied') then raise exception 'Zone Atlas invalide'; end if;

  with eligible as (
    select distinct q.id
    from public.questions q
    left join public.lessons l on l.id=q.lesson_id
    left join public.chapters c on c.id=l.chapter_id
    where q.is_published=true
      and q.type in ('hotspot','image')
      and (
        c.name=p_area
        or exists (
          select 1 from public.question_sources qs
          join public.course_documents cd on cd.id=qs.document_id
          where qs.question_id=q.id and cd.title ilike '%'||p_area||'%'
        )
      )
  ) select count(*) into v_count from eligible;

  if v_count=0 then raise exception 'Aucune question Atlas disponible pour cette zone'; end if;

  insert into public.revision_sessions(user_id,mode,question_count)
  values(v_user,'visual',least(v_limit,v_count))
  returning id into v_session;

  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session, e.id, row_number() over(order by random())
  from (
    select distinct q.id
    from public.questions q
    left join public.lessons l on l.id=q.lesson_id
    left join public.chapters c on c.id=l.chapter_id
    where q.is_published=true
      and q.type in ('hotspot','image')
      and (
        c.name=p_area
        or exists (
          select 1 from public.question_sources qs
          join public.course_documents cd on cd.id=qs.document_id
          where qs.question_id=q.id and cd.title ilike '%'||p_area||'%'
        )
      )
  ) e
  order by random()
  limit least(v_limit,v_count);

  return jsonb_build_object('session_id',v_session,'area',p_area,'question_count',least(v_limit,v_count));
end;
$function$
;
CREATE OR REPLACE FUNCTION public.enforce_question_publish_quality()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_option_count integer := 0;
  v_correct_count integer := 0;
  v_source_ok boolean := false;
  v_pairs jsonb;
begin
  if not (new.is_published = true and new.validation_status = 'published') then
    return new;
  end if;

  select exists(
    select 1
    from public.question_sources qs
    join public.course_documents cd on cd.id = qs.document_id
    join public.lessons l on l.id = new.lesson_id
    join public.chapters c on c.id = l.chapter_id
    join public.subjects s on s.id = c.subject_id
    where qs.question_id = new.id
      and qs.page_number is not null
      and nullif(btrim(qs.source_excerpt), '') is not null
      and cd.validation_status = 'validated'
      and cd.year_id = s.year_id
  ) into v_source_ok;

  if not v_source_ok then
    raise exception 'Publication impossible : source validée, page et extrait requis pour cette question';
  end if;

  if new.type in ('mcq','true_false') then
    select count(*), count(*) filter (where qo.is_correct)
      into v_option_count, v_correct_count
    from public.question_options qo
    where qo.question_id = new.id;

    if new.type = 'mcq' and (v_option_count < 2 or v_correct_count < 1) then
      raise exception 'Publication impossible : QCM sans options/réponse correcte complètes';
    end if;

    if new.type = 'true_false' and (v_option_count <> 2 or v_correct_count <> 1) then
      raise exception 'Publication impossible : un Vrai/Faux doit avoir 2 options et 1 seule réponse correcte';
    end if;
  elsif new.type = 'fill_blank' then
    if coalesce(nullif(btrim(new.metadata->>'answer'),''), nullif(btrim(new.metadata->>'correct_answer'),'')) is null then
      raise exception 'Publication impossible : réponse attendue manquante pour le texte à trou';
    end if;
  elsif new.type = 'matching' then
    v_pairs := new.metadata->'pairs';
    if jsonb_typeof(v_pairs) <> 'array' or jsonb_array_length(v_pairs) < 2 then
      raise exception 'Publication impossible : paires d’association incomplètes';
    end if;
    new.metadata := coalesce(new.metadata,'{}'::jsonb)
      || jsonb_build_object(
        'left_items', (select jsonb_agg(p->>'left') from jsonb_array_elements(v_pairs) p),
        'right_items', (select jsonb_agg(p->>'right') from jsonb_array_elements(v_pairs) p)
      );
  elsif new.type = 'hotspot' then
    if jsonb_typeof(new.metadata->'hotspot') <> 'object'
       or coalesce((new.metadata->>'visual_approved')::boolean,false) <> true then
      raise exception 'Publication impossible : hotspot non validé visuellement';
    end if;
  elsif new.type = 'image' then
    if jsonb_typeof(new.metadata->'label_targets') <> 'array'
       or jsonb_array_length(coalesce(new.metadata->'label_targets','[]'::jsonb)) < 1
       or coalesce((new.metadata->>'visual_approved')::boolean,false) <> true then
      raise exception 'Publication impossible : exercice image non validé visuellement';
    end if;
  elsif new.type in ('short_answer','translation') then
    if coalesce(nullif(btrim(new.metadata->>'answer'),''),
                case when jsonb_typeof(new.metadata->'accepted_answers')='array' and jsonb_array_length(new.metadata->'accepted_answers')>0 then 'ok' end) is null then
      raise exception 'Publication impossible : réponse attendue manquante';
    end if;
  elsif new.type = 'clinical_case' then
    select count(*), count(*) filter (where qo.is_correct)
      into v_option_count, v_correct_count
    from public.question_options qo
    where qo.question_id = new.id;
    if v_option_count = 0
       and coalesce(nullif(btrim(new.metadata->>'answer'),''),
                    case when jsonb_typeof(new.metadata->'accepted_answers')='array' and jsonb_array_length(new.metadata->'accepted_answers')>0 then 'ok' end) is null then
      raise exception 'Publication impossible : cas clinique sans réponse attendue';
    end if;
    if v_option_count > 0 and v_correct_count < 1 then
      raise exception 'Publication impossible : cas clinique à choix sans réponse correcte';
    end if;
  end if;

  return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_feedback_queue_v1(p_status text DEFAULT NULL::text, p_limit integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;
  if p_status is not null and p_status not in ('new','reviewed','resolved') then raise exception 'Statut invalide'; end if;
  if p_limit is null or p_limit<1 or p_limit>200 then p_limit:=100; end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',x.id,'kind',x.kind,'message',x.message,'page_path',x.page_path,'status',x.status,'created_at',x.created_at,
    'user',jsonb_build_object('first_name',x.first_name,'username',x.username,'avatar_url',x.avatar_url)
  ) order by x.created_at desc),'[]'::jsonb)
  into v_result
  from (
    select f.id,f.kind,f.message,f.page_path,f.status,f.created_at,p.first_name,p.username,p.avatar_url
    from public.feedback f
    left join public.profiles p on p.id=f.user_id
    where p_status is null or f.status=p_status
    order by f.created_at desc
    limit p_limit
  ) x;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_feedback_status_v1(p_feedback_id uuid, p_status text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;
  if p_status not in ('new','reviewed','resolved') then raise exception 'Statut invalide'; end if;
  update public.feedback set status=p_status where id=p_feedback_id;
  if not found then raise exception 'Retour introuvable'; end if;
  return true;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_content_quality_summary_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;
  with year_stats as (
    select y.number as study_year,
      count(distinct q.id) filter(where q.is_published and q.validation_status='published') as published_questions,
      count(distinct q.id) filter(where not q.is_published or q.validation_status<>'published') as unpublished_questions,
      count(distinct q.id) filter(where q.type in ('hotspot','image') and (not q.is_published or q.validation_status<>'published')) as visual_pending
    from public.years y
    left join public.subjects s on s.year_id=y.id
    left join public.chapters c on c.subject_id=s.id
    left join public.questions q on q.chapter_id=c.id
    group by y.number
  ), quality as (
    select
      count(distinct q.id) filter(where q.is_published and q.validation_status='published') as published_total,
      count(distinct q.id) filter(where q.is_published and q.validation_status='published' and qs.id is null) as published_without_source,
      count(distinct q.id) filter(where q.is_published and q.validation_status='published' and (qs.page_number is null or nullif(btrim(qs.source_excerpt),'') is null)) as published_incomplete_source,
      count(distinct q.id) filter(where not q.is_published and q.metadata->>'quality_issue' is not null) as quarantined_quality,
      count(distinct q.id) filter(where q.type in ('hotspot','image') and not q.is_published) as visual_quarantined
    from public.questions q
    left join public.question_sources qs on qs.question_id=q.id
  ), feedback_stats as (
    select count(*) filter(where status='new') new_feedback,
           count(*) filter(where status='reviewed') reviewed_feedback,
           count(*) filter(where status='resolved') resolved_feedback
    from public.feedback
  )
  select jsonb_build_object(
    'years',(select jsonb_agg(jsonb_build_object('study_year',study_year,'published_questions',published_questions,'unpublished_questions',unpublished_questions,'visual_pending',visual_pending) order by study_year) from year_stats),
    'quality',(select to_jsonb(quality) from quality),
    'feedback',(select to_jsonb(feedback_stats) from feedback_stats),
    'documents',jsonb_build_object(
      'total',(select count(*) from public.course_documents),
      'validated',(select count(*) from public.course_documents where validation_status='validated')
    )
  ) into v_result;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.protect_published_question_options()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_question_id uuid; v_locked boolean;
begin
  v_question_id:=coalesce(new.question_id,old.question_id);
  select (q.is_published=true and q.validation_status='published') into v_locked from public.questions q where q.id=v_question_id;
  if coalesce(v_locked,false) then
    raise exception 'Question publiée : repasse-la en revue avant de modifier ses options';
  end if;
  return coalesce(new,old);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.protect_published_question_sources()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_question_id uuid; v_locked boolean;
begin
  v_question_id:=coalesce(new.question_id,old.question_id);
  select (q.is_published=true and q.validation_status='published') into v_locked from public.questions q where q.id=v_question_id;
  if coalesce(v_locked,false) and tg_op in ('UPDATE','DELETE') then
    raise exception 'Question publiée : repasse-la en revue avant de modifier sa source';
  end if;
  return coalesce(new,old);
end;
$function$
;
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
$function$
;
CREATE OR REPLACE FUNCTION public.set_visual_approval_v1(p_question_id uuid, p_approved boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_type text;
  v_status text;
  v_image text;
begin
  if auth.uid() is null or not public.is_admin() then
    raise exception 'Accès administrateur requis';
  end if;

  select q.type,q.validation_status,q.image_url
    into v_type,v_status,v_image
  from public.questions q
  where q.id=p_question_id
  for update;

  if not found then raise exception 'Question introuvable'; end if;
  if v_type not in ('hotspot','image') then raise exception 'Cette question n’est pas un exercice visuel'; end if;
  if v_status='published' then raise exception 'Repasse la question en revue avant de modifier sa validation visuelle'; end if;
  if nullif(btrim(coalesce(v_image,'')),'') is null then raise exception 'Aucune image associée à cet exercice'; end if;

  update public.questions
  set metadata=jsonb_set(coalesce(metadata,'{}'::jsonb),'{visual_approved}',to_jsonb(coalesce(p_approved,false)),true),
      updated_at=now()
  where id=p_question_id;

  return jsonb_build_object('question_id',p_question_id,'visual_approved',coalesce(p_approved,false));
end;
$function$
;
CREATE OR REPLACE FUNCTION public.normalize_quiz_text_v1(p_text text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select btrim(
    pg_catalog.regexp_replace(
      pg_catalog.regexp_replace(
        pg_catalog.translate(
          pg_catalog.lower(
            pg_catalog.replace(
              pg_catalog.replace(coalesce(p_text,''),'œ','oe'),
              'æ','ae'
            )
          ),
          'àáâãäåçéèêëíìîïñóòôõöùúûüýÿ',
          'aaaaaaceeeeiiiinooooouuuuyy'
        ),
        '[^a-z0-9]+',
        ' ',
        'g'
      ),
      '[[:space:]]+',
      ' ',
      'g'
    )
  );
$function$
;
CREATE OR REPLACE FUNCTION public.start_mock_exam_v1(p_question_count integer DEFAULT 20)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid();
  v_session_id uuid;
  v_actual_count integer;
  v_study_year integer;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_question_count is null or p_question_count<10 or p_question_count>50 then raise exception 'Nombre de questions invalide'; end if;
  select study_year into v_study_year from public.profiles where id=v_user_id;

  insert into public.revision_sessions(user_id,mode,question_count)
  values(v_user_id,'exam',p_question_count)
  returning id into v_session_id;

  with candidates as(
    select q.id,q.chapter_id,q.difficulty,q.type,
           row_number() over(partition by q.chapter_id order by random()) as chapter_rank,
           row_number() over(partition by coalesce(q.difficulty,2) order by random()) as difficulty_rank,
           row_number() over(partition by q.type order by random()) as type_rank
    from public.questions q
    join public.chapters c on c.id=q.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    where q.is_published=true and q.validation_status='published'
      and q.type in ('mcq','true_false','fill_blank','matching','hotspot','image','short_answer','translation','clinical_case')
      and c.is_active=true and s.is_active=true and y.is_active=true
      and (v_study_year is null or y.number=v_study_year)
  ), ordered as(
    select id,
           row_number() over(
             order by case when type_rank=1 then 0 else 1 end,
                      chapter_rank,
                      difficulty_rank,
                      type_rank,
                      random()
           ) as display_order
    from candidates
  )
  insert into public.revision_session_questions(session_id,question_id,display_order)
  select v_session_id,id,display_order::integer
  from ordered
  order by display_order
  limit p_question_count;

  select count(*) into v_actual_count
  from public.revision_session_questions
  where session_id=v_session_id;
  if v_actual_count<10 then
    delete from public.revision_sessions where id=v_session_id;
    raise exception 'Pas assez de questions validées pour générer un examen blanc';
  end if;
  update public.revision_sessions set question_count=v_actual_count where id=v_session_id;
  return v_session_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_content_review_queue_v3()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then
    raise exception 'Accès administrateur requis';
  end if;

  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.image_url,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs
      join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id
      order by qs.created_at asc,qs.id asc
      limit 1
    ) src on true
    where q.validation_status in ('archived','review','validated','published')
  )
  select jsonb_build_object(
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',count(*) filter(where validation_status='published'),
      'quarantined_visual',count(*) filter(where validation_status='archived' and type in ('hotspot','image')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,
      'validation_status',validation_status,'is_published',is_published,
      'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,'lesson_title',lesson_title,
      'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue',
      'visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'visual_review',coalesce(metadata->'visual_review','{}'::jsonb),
      'visual_rebuild_batch',metadata->>'visual_rebuild_batch',
      'image_url',image_url,
      'hotspot',case when type='hotspot' then coalesce(metadata->'hotspot_v2',metadata->'hotspot') else null end,
      'label_targets',case when type='image' then coalesce(metadata->'label_targets','[]'::jsonb) else null end,
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by case validation_status when 'archived' then 0 when 'review' then 1 when 'validated' then 2 else 3 end,year_number,subject_name,chapter_name,lesson_title,created_at) filter(where (validation_status='archived' and type in ('hotspot','image')) or validation_status in ('review','validated')),'[]'::jsonb)
  ) into v_result
  from question_rows;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.create_friend_challenge_v1(p_friend_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_id uuid; v_username text; v_my_year integer; v_friend_year integer; v_count integer;
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 if p_friend_id is null or p_friend_id=v_uid then raise exception 'Ami invalide'; end if;
 if not exists(select 1 from public.friendships f where f.status='accepted' and ((f.requester_id=v_uid and f.addressee_id=p_friend_id) or (f.requester_id=p_friend_id and f.addressee_id=v_uid))) then raise exception 'Cet utilisateur ne fait pas partie de tes amis'; end if;
 if exists(select 1 from public.challenges c where c.status in ('pending','accepted','in_progress') and ((c.challenger_id=v_uid and c.challenged_id=p_friend_id) or (c.challenger_id=p_friend_id and c.challenged_id=v_uid))) then raise exception 'Un défi est déjà en cours avec cet ami'; end if;
 select study_year into v_my_year from public.profiles where id=v_uid;
 select study_year into v_friend_year from public.profiles where id=p_friend_id;
 if v_my_year is null or v_friend_year is null then raise exception 'Année d’étude manquante pour un participant'; end if;
 if v_my_year<>v_friend_year then raise exception 'Les défis sont disponibles entre étudiants de la même année'; end if;
 select count(*) into v_count from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id where q.is_published=true and q.validation_status='published' and q.type in ('mcq','matching') and coalesce(q.difficulty,1)>=2 and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_my_year;
 if v_count<10 then raise exception 'Pas assez de questions validées pour créer un défi K%',v_my_year; end if;
 insert into public.challenges(challenger_id,challenged_id,status) values(v_uid,p_friend_id,'pending') returning id into v_id;
 with candidates as (
  select q.id,q.type,q.chapter_id,coalesce(q.difficulty,1) difficulty,row_number() over(partition by q.type order by random()) type_rank,row_number() over(partition by q.chapter_id order by random()) chapter_rank
  from public.questions q join public.chapters c on c.id=q.chapter_id join public.subjects s on s.id=c.subject_id join public.years y on y.id=s.year_id
  where q.is_published=true and q.validation_status='published' and q.type in ('mcq','matching') and coalesce(q.difficulty,1)>=2 and c.is_active=true and s.is_active=true and y.is_active=true and y.number=v_my_year
 ), ranked as (
  select id,row_number() over(order by case when difficulty>=3 then 0 else 1 end,case when type_rank=1 then 0 else 1 end,chapter_rank,type_rank,random())::integer display_order from candidates
 )
 insert into public.challenge_questions(challenge_id,question_id,display_order) select v_id,id,display_order from ranked order by display_order limit 10;
 select count(*) into v_count from public.challenge_questions where challenge_id=v_id;
 if v_count<>10 then delete from public.challenges where id=v_id; raise exception 'Impossible de constituer les 10 questions du défi'; end if;
 select coalesce(username::text,first_name,'Un ami') into v_username from public.profiles where id=v_uid;
 insert into public.notifications(user_id,type,title,body,data) values(p_friend_id,'challenge_received','Nouveau défi ⚔️',v_username||' te défie sur 10 questions K'||v_my_year||'.',jsonb_build_object('challenge_id',v_id,'study_year',v_my_year));
 return v_id;
end;$function$
;
CREATE OR REPLACE FUNCTION public.update_study_profile_v1(p_first_name text, p_username text, p_study_year integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_old_year integer;
  v_program text;
  v_min integer := 2;
  v_max integer := 5;
  v_username text := nullif(btrim(coalesce(p_username, '')), '');
  v_first_name text := nullif(btrim(coalesce(p_first_name, '')), '');
  v_row public.profiles%rowtype;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select study_year into v_old_year from public.profiles where id = v_uid for update;
  if not found then raise exception 'Profil introuvable'; end if;
  select program_id into v_program from public.profile_programs where user_id = v_uid and is_primary;
  if v_program = 'ifsi-fr' then v_min := 1; v_max := 3;
  elsif v_program = 'kineo-es' then v_min := 1; v_max := 4;
  end if;
  if p_study_year is null or p_study_year not between v_min and v_max then
    raise exception 'Année d’étude invalide pour ton cursus';
  end if;
  if v_username is not null and (length(v_username) not between 3 and 24 or v_username !~ '^[A-Za-z0-9._-]+$') then
    raise exception 'Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore';
  end if;
  if length(v_first_name) > 100 then raise exception 'Le prénom est trop long'; end if;
  begin
    update public.profiles set first_name = v_first_name, username = v_username,
      study_year = p_study_year, updated_at = now() where id = v_uid returning * into v_row;
  exception when unique_violation then raise exception 'Ce pseudo est déjà utilisé';
  end;
  if v_old_year is distinct from p_study_year then
    update public.revision_sessions set abandoned_at = coalesce(abandoned_at, now())
    where user_id = v_uid and completed_at is null and abandoned_at is null and challenge_id is null;
  end if;
  return jsonb_build_object('id', v_row.id, 'first_name', v_row.first_name,
    'username', v_row.username::text, 'avatar_url', v_row.avatar_url, 'study_year', v_row.study_year);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.respond_curriculum_friend_challenge_v1(p_challenge_id uuid, p_accept boolean)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_row public.curriculum_friend_challenges%rowtype;
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 select * into v_row from public.curriculum_friend_challenges where id=p_challenge_id for update;
 if v_row.id is null or v_row.challenged_id<>v_uid or v_row.status<>'pending' then raise exception 'Défi indisponible'; end if;
 update public.curriculum_friend_challenges set status=case when p_accept then 'accepted' else 'declined' end where id=p_challenge_id;
 return case when p_accept then 'accepted' else 'declined' end;
end;$function$
;
CREATE OR REPLACE FUNCTION public.cancel_curriculum_friend_challenge_v1(p_challenge_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid();
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 update public.curriculum_friend_challenges set status='cancelled' where id=p_challenge_id and challenger_id=v_uid and status='pending';
 return found;
end;$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_friend_challenges_v1(p_program_id text DEFAULT 'ifsi-fr'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select coalesce(jsonb_agg(jsonb_build_object('id',c.id,'program_id',c.program_id,'academic_level_id',c.academic_level_id,'level_code',al.code,'status',c.status,'direction',case when c.challenger_id=v_uid then 'sent' else 'received' end,'challenger_id',c.challenger_id,'challenged_id',c.challenged_id,'challenger_score',c.challenger_score,'challenged_score',c.challenged_score,'created_at',c.created_at,'completed_at',c.completed_at,'has_played',case when c.challenger_id=v_uid then c.challenger_score is not null else c.challenged_score is not null end,'opponent_has_played',case when c.challenger_id=v_uid then c.challenged_score is not null else c.challenger_score is not null end,'my_session_id',null,'opponent',jsonb_build_object('id',p.id,'username',p.username,'first_name',p.first_name,'study_year',p.study_year,'level',p.level,'avatar_url',p.avatar_url)) order by c.created_at desc),'[]'::jsonb) into v_result
  from public.curriculum_friend_challenges c join public.profiles p on p.id=case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end left join public.academic_levels al on al.id=c.academic_level_id
  where c.program_id=p_program_id and (c.challenger_id=v_uid or c.challenged_id=v_uid);
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_curriculum_friend_challenge_answer_v1(p_challenge_id uuid, p_question_id uuid, p_answer_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_row public.curriculum_friend_challenges%rowtype; v_options jsonb; v_correct_text text; v_correct boolean; v_answered integer; v_correct_count integer; v_score integer; v_done boolean; v_progress jsonb; v_badges jsonb;
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 select * into v_row from public.curriculum_friend_challenges where id=p_challenge_id for update;
 if v_row.id is null or v_row.status not in ('accepted','in_progress') or (v_row.challenger_id<>v_uid and v_row.challenged_id<>v_uid) then raise exception 'Défi indisponible'; end if;
 if not exists(select 1 from public.curriculum_friend_challenge_questions where challenge_id=p_challenge_id and question_id=p_question_id) then raise exception 'Question hors défi'; end if;
 if exists(select 1 from public.curriculum_friend_challenge_answers where challenge_id=p_challenge_id and user_id=v_uid and question_id=p_question_id) then raise exception 'Question déjà répondue'; end if;
 select options into v_options from public.curriculum_quiz_questions where id=p_question_id and is_published=true;
 select x->>'text' into v_correct_text from jsonb_array_elements(v_options)x where coalesce((x->>'correct')::boolean,false)=true limit 1;
 v_correct:=p_answer_text=v_correct_text;
 insert into public.curriculum_friend_challenge_answers(challenge_id,user_id,question_id,answer_text,is_correct) values(p_challenge_id,v_uid,p_question_id,p_answer_text,v_correct);
 select count(*),count(*) filter(where is_correct) into v_answered,v_correct_count from public.curriculum_friend_challenge_answers where challenge_id=p_challenge_id and user_id=v_uid;
 if v_answered>=10 then
   v_score:=v_correct_count*10;
   if v_uid=v_row.challenger_id then update public.curriculum_friend_challenges set challenger_score=v_score,status='in_progress' where id=p_challenge_id; else update public.curriculum_friend_challenges set challenged_score=v_score,status='in_progress' where id=p_challenge_id; end if;
   v_progress:=public.update_user_progress_v2(v_uid,30,current_date);
   select * into v_row from public.curriculum_friend_challenges where id=p_challenge_id;
   v_done:=v_row.challenger_score is not null and v_row.challenged_score is not null;
   if v_done then update public.curriculum_friend_challenges set status='completed',completed_at=now() where id=p_challenge_id; end if;
   v_badges:=public.check_and_award_badges_v2();
 end if;
 return jsonb_build_object('correct',v_correct,'correct_answer',v_correct_text,'answered',v_answered,'completed_my_run',v_answered>=10,'score',case when v_answered>=10 then v_score else null end,'challenge_completed',coalesce(v_done,false),'new_badges',coalesce(v_badges->'new_badges','[]'::jsonb));
end;$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_friend_challenge_questions_v1(p_challenge_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_result jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if not exists(select 1 from public.curriculum_friend_challenges c where c.id=p_challenge_id and c.status in ('accepted','in_progress','completed') and (c.challenger_id=v_uid or c.challenged_id=v_uid)) then raise exception 'Défi indisponible'; end if;
  update public.curriculum_friend_challenges set status='in_progress' where id=p_challenge_id and status='accepted';
  select coalesce(jsonb_agg(jsonb_build_object('id',q.id,'question_text',q.question_text,'options',(select jsonb_agg(jsonb_build_object('text',o->>'text')) from jsonb_array_elements(q.options)o),'display_order',cq.display_order) order by cq.display_order),'[]'::jsonb) into v_result
  from public.curriculum_friend_challenge_questions cq join public.curriculum_quiz_questions q on q.id=cq.question_id
  where cq.challenge_id=p_challenge_id
    and q.is_published=true
    and q.validation_status='source_validated'
    and q.question_type='mcq'
    and not exists(select 1 from public.curriculum_friend_challenge_answers a where a.challenge_id=p_challenge_id and a.user_id=v_uid and a.question_id=q.id);
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.normalize_curriculum_answer_v1(p_value text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO ''
AS $function$
  select lower(regexp_replace(translate(trim(coalesce(p_value,'')),
    'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖòóôõöÙÚÛÜùúûüÝŸýÿŒœ',
    'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOoooooUUUUuuuuYYyyOo'),
    '\s+',' ','g'))
$function$
;
CREATE OR REPLACE FUNCTION public.submit_curriculum_topic_answer_v2(p_question_id uuid, p_answer jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_q public.curriculum_quiz_questions%rowtype;
  v_program_id text;
  v_curriculum_version text;
  v_level_id uuid;
  v_role text;
  v_correct boolean:=false;
  v_correct_text text;
  v_answer_text text:=coalesce(p_answer->>'text','');
  v_correct_hotspot text;
  v_expected_pairs jsonb:='[]'::jsonb;
  v_given_pairs jsonb:='[]'::jsonb;
  v_xp integer;
  v_total integer;
  v_answered integer;
  v_correct_total integer;
  v_completed boolean:=false;
  v_progress jsonb;
  v_badges jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;

  select q.* into v_q
  from public.curriculum_quiz_questions q
  where q.id=p_question_id and q.is_published=true and q.validation_status='source_validated';
  if v_q.id is null then raise exception 'Question indisponible'; end if;

  select u.program_id,coalesce(u.curriculum_version,'default'),u.academic_level_id
    into v_program_id,v_curriculum_version,v_level_id
  from public.curriculum_topics t
  join public.curriculum_units u on u.id=t.unit_id
  where t.id=v_q.topic_id and t.is_active=true and u.is_active=true;
  if v_program_id is null or v_level_id is null then raise exception 'Question hors cursus actif'; end if;

  select p.role into v_role from public.profiles p where p.id=v_uid;
  if coalesce(v_role,'')<>'admin' and not exists(
    select 1
    from public.profile_programs pp
    join public.academic_levels active_level on active_level.id=pp.academic_level_id
    join public.academic_levels target_level on target_level.id=v_level_id
    where pp.user_id=v_uid
      and pp.program_id=v_program_id
      and active_level.program_id=v_program_id
      and target_level.program_id=v_program_id
      and target_level.display_order<=active_level.display_order
      and coalesce(pp.curriculum_version,'default')=v_curriculum_version
  ) then raise exception 'Question hors niveau accessible ou référentiel actif'; end if;

  if v_q.question_type in ('mcq','clinical_case') and jsonb_array_length(coalesce(v_q.options,'[]'::jsonb))>0 then
    select x->>'text' into v_correct_text
    from jsonb_array_elements(v_q.options) x
    where coalesce((x->>'correct')::boolean,false)=true limit 1;
    v_correct:=public.normalize_curriculum_answer_v1(v_answer_text)=public.normalize_curriculum_answer_v1(v_correct_text);
  elsif v_q.question_type='fill_blank' then
    select a.value #>> '{}' into v_correct_text
    from jsonb_array_elements(coalesce(v_q.accepted_answers,'[]'::jsonb)) a(value)
    where public.normalize_curriculum_answer_v1(a.value #>> '{}')=public.normalize_curriculum_answer_v1(v_answer_text)
    limit 1;
    v_correct:=v_correct_text is not null;
    if not v_correct then
      select a.value #>> '{}' into v_correct_text
      from jsonb_array_elements(coalesce(v_q.accepted_answers,'[]'::jsonb)) a(value)
      limit 1;
    end if;
  elsif v_q.question_type='visual_hotspot' then
    v_answer_text:=coalesce(p_answer->>'hotspot_id',p_answer->>'text','');
    select h->>'id' into v_correct_hotspot
    from jsonb_array_elements(coalesce(v_q.metadata->'hotspots','[]'::jsonb)) h
    where coalesce((h->>'correct')::boolean,false)=true limit 1;
    v_correct:=v_answer_text=v_correct_hotspot and v_correct_hotspot is not null;
  elsif v_q.question_type='matching' then
    v_expected_pairs:=coalesce(v_q.metadata->'pairs','[]'::jsonb);
    v_given_pairs:=coalesce(p_answer->'pairs','[]'::jsonb);
    v_correct:=jsonb_array_length(v_expected_pairs)>0
      and jsonb_array_length(v_expected_pairs)=jsonb_array_length(v_given_pairs)
      and not exists(
        select 1 from jsonb_array_elements(v_expected_pairs) e
        where not exists(
          select 1 from jsonb_array_elements(v_given_pairs) g
          where public.normalize_curriculum_answer_v1(g->>'left')=public.normalize_curriculum_answer_v1(e->>'left')
            and public.normalize_curriculum_answer_v1(g->>'right')=public.normalize_curriculum_answer_v1(e->>'right')
        )
      );
    v_answer_text:=v_given_pairs::text;
  else
    raise exception 'Format de question non pris en charge: %',v_q.question_type;
  end if;

  -- Serialize submissions for this student/question to prevent concurrent XP farming.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_uid::text || ':' || v_q.id::text, 0));
  v_xp:=case
    when exists (
      select 1 from public.curriculum_question_attempts previous
      where previous.user_id=v_uid
        and previous.question_id=v_q.id
        and previous.created_at >= current_date
        and previous.created_at < current_date + interval '1 day'
    ) then 0
    when v_correct then 10
    else 2
  end;
  insert into public.curriculum_question_attempts(user_id,question_id,topic_id,answer_text,is_correct,xp_earned)
  values(v_uid,v_q.id,v_q.topic_id,coalesce(nullif(v_answer_text,''),p_answer::text),v_correct,v_xp);
  v_progress:=public.update_user_progress_v2(v_uid,v_xp,current_date);

  select count(*) into v_total
  from public.curriculum_quiz_questions q
  where q.topic_id=v_q.topic_id and q.is_published=true and q.validation_status='source_validated';

  select count(distinct a.question_id),count(distinct a.question_id) filter(where a.is_correct=true)
    into v_answered,v_correct_total
  from public.curriculum_question_attempts a
  join public.curriculum_quiz_questions q on q.id=a.question_id
  where a.user_id=v_uid
    and a.topic_id=v_q.topic_id
    and q.topic_id=v_q.topic_id
    and q.is_published=true
    and q.validation_status='source_validated';

  if v_total>0 and v_answered>=v_total then
    insert into public.curriculum_topic_completions(user_id,topic_id,score_percent,xp_earned)
    values(v_uid,v_q.topic_id,least(100,round(100.0*v_correct_total/greatest(v_total,1))::integer),20)
    on conflict(user_id,topic_id) do nothing;
    if found then v_progress:=public.update_user_progress_v2(v_uid,20,current_date); end if;
    v_completed:=true;
  end if;
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object(
    'correct',v_correct,
    'correct_answer',v_correct_text,
    'correct_hotspot_id',v_correct_hotspot,
    'correct_pairs',v_expected_pairs,
    'xp_earned',v_xp,
    'topic_completed',v_completed,
    'xp_total',v_progress->'xp_total',
    'current_streak',v_progress->'current_streak',
    'new_badges',v_badges->'new_badges'
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_content_review_queue_v4()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then
    raise exception 'Accès administrateur requis';
  end if;

  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.image_url,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs
      join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id
      order by qs.created_at asc,qs.id asc
      limit 1
    ) src on true
    where q.validation_status in ('review','validated','published','archived')
  )
  select jsonb_build_object(
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',count(*) filter(where validation_status='published'),
      'archived',count(*) filter(where validation_status='archived' and type in ('hotspot','image')),
      'quarantined_visual',count(*) filter(where validation_status in ('review','archived') and type in ('hotspot','image')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,
      'validation_status',validation_status,'is_published',is_published,
      'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,'lesson_title',lesson_title,
      'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue',
      'visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'visual_review',coalesce(metadata->'visual_review','{}'::jsonb),
      'visual_rebuild_batch',metadata->>'visual_rebuild_batch',
      'image_url',image_url,
      'hotspot',case when type='hotspot' then coalesce(metadata->'hotspot_v2',metadata->'hotspot') else null end,
      'label_targets',case when type='image' then coalesce(metadata->'label_targets','[]'::jsonb) else null end,
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by case when validation_status='archived' then 0 else 1 end,year_number,subject_name,chapter_name,lesson_title,created_at)
      filter(where validation_status in ('archived','review','validated')),'[]'::jsonb)
  ) into v_result
  from question_rows;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.touch_user_activity_v1()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_now timestamptz := now();
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  update public.profiles
  set last_seen_at = v_now
  where id = v_uid;

  return v_now;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_progress_v1(p_program_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_level_id uuid;
  v_version text;
  v_topics integer := 0;
  v_completed integer := 0;
  v_questions integer := 0;
  v_answered integer := 0;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  select pp.academic_level_id, coalesce(pp.curriculum_version, 'default')
    into v_level_id, v_version
  from public.profile_programs pp
  where pp.user_id = v_uid
    and pp.program_id = p_program_id
  order by pp.is_primary desc, pp.updated_at desc
  limit 1;

  if v_level_id is null then
    return jsonb_build_object(
      'topics_total', 0,
      'topics_completed', 0,
      'questions_total', 0,
      'questions_answered', 0,
      'coverage_percent', 0,
      'completion_percent', 0,
      'academic_level_id', null,
      'curriculum_version', v_version
    );
  end if;

  select count(distinct t.id), count(distinct q.id)
    into v_topics, v_questions
  from public.curriculum_units u
  join public.curriculum_topics t
    on t.unit_id = u.id
   and t.is_active = true
  left join public.curriculum_quiz_questions q
    on q.topic_id = t.id
   and q.is_published = true
   and q.validation_status = 'source_validated'
  where u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true;

  select count(distinct c.topic_id)
    into v_completed
  from public.curriculum_topic_completions c
  join public.curriculum_topics t on t.id = c.topic_id
  join public.curriculum_units u on u.id = t.unit_id
  where c.user_id = v_uid
    and u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true
    and t.is_active = true;

  select count(distinct a.question_id)
    into v_answered
  from public.curriculum_question_attempts a
  join public.curriculum_quiz_questions q on q.id = a.question_id
  join public.curriculum_topics t on t.id = q.topic_id
  join public.curriculum_units u on u.id = t.unit_id
  where a.user_id = v_uid
    and u.program_id = p_program_id
    and u.academic_level_id = v_level_id
    and u.curriculum_version = v_version
    and u.is_active = true
    and t.is_active = true
    and q.is_published = true
    and q.validation_status = 'source_validated';

  return jsonb_build_object(
    'topics_total', v_topics,
    'topics_completed', v_completed,
    'questions_total', v_questions,
    'questions_answered', v_answered,
    'coverage_percent', case when v_questions = 0 then 0 else round(100.0 * v_answered / v_questions)::integer end,
    'completion_percent', case when v_topics = 0 then 0 else round(100.0 * v_completed / v_topics)::integer end,
    'academic_level_id', v_level_id,
    'curriculum_version', v_version
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.notify_badge_earned_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION "public"."queue_inactivity_reminders_v1"() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $staging$ BEGIN RAISE EXCEPTION 'External delivery disabled in staging'; END; $staging$;;
CREATE OR REPLACE FUNCTION public.submit_curriculum_topic_answer_v1(p_question_id uuid, p_answer_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid(); v_topic uuid; v_options jsonb; v_correct_text text; v_correct boolean; v_xp integer; v_total integer; v_answered integer; v_correct_total integer; v_completed boolean:=false; v_progress jsonb; v_badges jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select q.topic_id,q.options into v_topic,v_options from public.curriculum_quiz_questions q where q.id=p_question_id and q.is_published=true;
  if v_topic is null then raise exception 'Question IFSI introuvable'; end if;
  select x->>'text' into v_correct_text from jsonb_array_elements(v_options) x where coalesce((x->>'correct')::boolean,false)=true limit 1;
  v_correct:=p_answer_text=v_correct_text; v_xp:=case when v_correct then 10 else 2 end;
  insert into public.curriculum_question_attempts(user_id,question_id,topic_id,answer_text,is_correct,xp_earned) values(v_uid,p_question_id,v_topic,p_answer_text,v_correct,v_xp);
  v_progress:=public.update_user_progress_v2(v_uid,v_xp,current_date);
  select count(*) into v_total from public.curriculum_quiz_questions where topic_id=v_topic and is_published=true;
  select count(distinct question_id),count(distinct question_id) filter(where is_correct=true) into v_answered,v_correct_total from public.curriculum_question_attempts where user_id=v_uid and topic_id=v_topic;
  if v_total>0 and v_answered>=v_total then
    insert into public.curriculum_topic_completions(user_id,topic_id,score_percent,xp_earned)
    values(v_uid,v_topic,round(100.0*v_correct_total/greatest(v_total,1))::integer,20)
    on conflict(user_id,topic_id) do nothing;
    if found then v_progress:=public.update_user_progress_v2(v_uid,20,current_date); end if;
    v_completed:=true;
  end if;
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object('correct',v_correct,'correct_answer',v_correct_text,'xp_earned',v_xp,'topic_completed',v_completed,'xp_total',v_progress->'xp_total','current_streak',v_progress->'current_streak','new_badges',v_badges->'new_badges');
end;$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_challenge_availability_v1(p_program_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_level_id uuid;
  v_level_code text;
  v_version text;
  v_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select pp.academic_level_id,al.code,coalesce(pp.curriculum_version,'default')
    into v_level_id,v_level_code,v_version
  from public.profile_programs pp
  left join public.academic_levels al on al.id=pp.academic_level_id
  where pp.user_id=v_uid and pp.program_id=p_program_id
  order by pp.is_primary desc
  limit 1;

  if v_level_id is not null then
    select count(*) into v_count
    from public.curriculum_quiz_questions q
    join public.curriculum_topics t on t.id=q.topic_id
    join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id
      and u.academic_level_id=v_level_id
      and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true
      and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq'
      and jsonb_array_length(q.options)>=2
      and exists(select 1 from jsonb_array_elements(q.options)o where coalesce((o->>'correct')::boolean,false)=true);
  end if;

  return jsonb_build_object('program_id',p_program_id,'academic_level_id',v_level_id,'level_code',v_level_code,'curriculum_version',v_version,'validated_mcq',v_count,'required_mcq',10,'can_challenge',v_level_id is not null and v_count>=10);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_client_error_logs_v1(p_limit integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb;
begin
  if auth.uid() is null or not public.is_admin() then raise exception 'Accès administrateur requis'; end if;
  p_limit:=least(200,greatest(1,coalesce(p_limit,100)));
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',x.id,'message',x.message,'component_stack',x.component_stack,
    'page_path',x.page_path,'app_version',x.app_version,'created_at',x.created_at,
    'user',jsonb_build_object('first_name',x.first_name,'username',x.username)
  ) order by x.created_at desc),'[]'::jsonb)
  into v_result
  from (
    select e.*,p.first_name,p.username
    from public.client_error_logs e
    left join public.profiles p on p.id=e.user_id
    order by e.created_at desc
    limit p_limit
  ) x;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_curriculum_daily_answer_v1(p_program_id text, p_question_id uuid, p_answer_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_row public.curriculum_daily_challenge_attempts%rowtype;
  v_options jsonb;
  v_correct_text text;
  v_correct boolean;
  v_xp integer;
  v_now_count integer;
  v_progress jsonb;
  v_badges jsonb;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  select * into v_row from public.curriculum_daily_challenge_attempts
  where user_id=v_uid and program_id=p_program_id and challenge_date=current_date for update;
  if v_row.id is null or not (p_question_id=any(v_row.question_ids)) then raise exception 'Question hors challenge'; end if;
  if p_question_id=any(v_row.answered_ids) then raise exception 'Question déjà répondue'; end if;
  select options into v_options from public.curriculum_quiz_questions
  where id=p_question_id and is_published=true and validation_status='source_validated' and question_type='mcq';
  if v_options is null then raise exception 'Question du challenge indisponible'; end if;
  select x->>'text' into v_correct_text from jsonb_array_elements(v_options) x
  where coalesce((x->>'correct')::boolean,false)=true limit 1;
  v_correct:=p_answer_text=v_correct_text;
  v_xp:=case when v_correct then 12 else 2 end;
  insert into public.curriculum_question_attempts(user_id,question_id,topic_id,answer_text,is_correct,xp_earned)
  select v_uid,q.id,q.topic_id,p_answer_text,v_correct,v_xp from public.curriculum_quiz_questions q where q.id=p_question_id;
  update public.curriculum_daily_challenge_attempts
  set answered_ids=array_append(answered_ids,p_question_id),
      correct_count=correct_count+case when v_correct then 1 else 0 end,
      xp_earned=xp_earned+v_xp
  where id=v_row.id returning cardinality(answered_ids) into v_now_count;
  v_progress:=public.update_user_progress_v2(v_uid,v_xp,current_date);
  if v_now_count>=v_row.total_questions then
    update public.curriculum_daily_challenge_attempts
    set completed_at=now(),xp_earned=xp_earned+25
    where id=v_row.id and completed_at is null;
    if found then
      v_progress:=public.update_user_progress_v2(v_uid,25,current_date);
    end if;
  end if;
  v_badges:=public.check_and_award_badges_v2();
  return jsonb_build_object('correct',v_correct,'correct_answer',v_correct_text,'xp_earned',v_xp,'completed',v_now_count>=v_row.total_questions,'xp_total',v_progress->'xp_total','current_streak',v_progress->'current_streak','new_badges',v_badges->'new_badges');
end
$function$
;
CREATE OR REPLACE FUNCTION public.report_client_error_v1(p_message text, p_component_stack text DEFAULT NULL::text, p_page_path text DEFAULT NULL::text, p_app_version text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_id uuid;
  v_recent integer;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if length(trim(coalesce(p_message,'')))=0 then raise exception 'Message d’erreur vide'; end if;
  select count(*) into v_recent
  from public.client_error_logs
  where user_id=v_uid and created_at>=now()-interval '1 hour';
  if v_recent>=20 then return null; end if;

  insert into public.client_error_logs(user_id,message,component_stack,page_path,app_version)
  values(
    v_uid,
    left(trim(p_message),1000),
    left(nullif(p_component_stack,''),5000),
    left(nullif(p_page_path,''),500),
    left(nullif(p_app_version,''),100)
  )
  returning id into v_id;
  return v_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.can_review_visuals_v1()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select auth.uid() is not null and (
    exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')
    or exists(select 1 from public.visual_reviewers vr where vr.user_id=auth.uid())
  );
$function$
;
CREATE OR REPLACE FUNCTION public.get_visual_review_queue_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb; v_can_publish boolean;
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then
    raise exception 'Accès relecteur visuel requis';
  end if;

  select exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin') into v_can_publish;

  with question_rows as (
    select q.id,q.type,q.question_text,q.difficulty,q.validation_status,q.is_published,q.metadata,q.image_url,q.created_at,
           y.number as year_number,s.name as subject_name,c.name as chapter_name,l.title as lesson_title,
           src.source_title,src.source_page,src.source_excerpt,
           (select count(*) from public.question_options qo where qo.question_id=q.id) as option_count,
           (select count(*) from public.question_options qo where qo.question_id=q.id and qo.is_correct) as correct_option_count
    from public.questions q
    join public.lessons l on l.id=q.lesson_id
    join public.chapters c on c.id=l.chapter_id
    join public.subjects s on s.id=c.subject_id
    join public.years y on y.id=s.year_id
    left join lateral (
      select cd.title as source_title,qs.page_number as source_page,qs.source_excerpt
      from public.question_sources qs
      join public.course_documents cd on cd.id=qs.document_id
      where qs.question_id=q.id
      order by qs.created_at asc,qs.id asc
      limit 1
    ) src on true
    where q.type in ('hotspot','image')
      and q.validation_status in ('archived','review','validated')
  )
  select jsonb_build_object(
    'can_publish',v_can_publish,
    'counts',jsonb_build_object(
      'review',count(*) filter(where validation_status='review'),
      'validated',count(*) filter(where validation_status='validated'),
      'published',0,
      'archived',count(*) filter(where validation_status='archived'),
      'quarantined_visual',count(*) filter(where validation_status in ('review','archived')),
      'quality_issues',count(*) filter(where metadata->>'quality_issue' is not null)
    ),
    'questions',coalesce(jsonb_agg(jsonb_build_object(
      'id',id,'type',type,'question_text',question_text,'difficulty',difficulty,
      'validation_status',validation_status,'is_published',is_published,
      'year_number',year_number,'subject_name',subject_name,'chapter_name',chapter_name,'lesson_title',lesson_title,
      'source_title',source_title,'source_page',source_page,'source_excerpt',source_excerpt,
      'quality_issue',metadata->>'quality_issue',
      'visual_approved',coalesce((metadata->>'visual_approved')::boolean,false),
      'visual_review',coalesce(metadata->'visual_review','{}'::jsonb),
      'visual_rebuild_batch',metadata->>'visual_rebuild_batch',
      'image_url',image_url,
      'hotspot',case when type='hotspot' then coalesce(metadata->'hotspot_v2',metadata->'hotspot') else null end,
      'label_targets',case when type='image' then coalesce(metadata->'label_targets','[]'::jsonb) else null end,
      'option_count',option_count,'correct_option_count',correct_option_count
    ) order by year_number,subject_name,chapter_name,lesson_title,created_at),'[]'::jsonb)
  ) into v_result
  from question_rows;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_visual_review_v2(p_question_id uuid, p_anatomy_ok boolean, p_mobile_ok boolean, p_target_ok boolean, p_source_ok boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_type text; v_status text; v_image text;
  v_approved boolean := coalesce(p_anatomy_ok,false) and coalesce(p_mobile_ok,false) and coalesce(p_target_ok,false) and coalesce(p_source_ok,false);
  v_review jsonb;
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then raise exception 'Accès relecteur visuel requis'; end if;
  select q.type,q.validation_status,q.image_url into v_type,v_status,v_image from public.questions q where q.id=p_question_id for update;
  if not found then raise exception 'Question introuvable'; end if;
  if v_type not in ('hotspot','image') then raise exception 'Cette question n’est pas un exercice visuel'; end if;
  if v_status='published' then raise exception 'Repasse la question en revue avant de modifier sa validation visuelle'; end if;
  if nullif(btrim(coalesce(v_image,'')),'') is null then raise exception 'Aucune image associée à cet exercice'; end if;
  v_review:=jsonb_build_object('anatomy_ok',coalesce(p_anatomy_ok,false),'mobile_ok',coalesce(p_mobile_ok,false),'target_ok',coalesce(p_target_ok,false),'source_ok',coalesce(p_source_ok,false),'reviewed_at',now(),'reviewed_by',auth.uid());
  update public.questions set metadata=jsonb_set(jsonb_set(coalesce(metadata,'{}'::jsonb),'{visual_review}',v_review,true),'{visual_approved}',to_jsonb(v_approved),true),updated_at=now() where id=p_question_id;
  return jsonb_build_object('question_id',p_question_id,'visual_approved',v_approved,'visual_review',v_review);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.set_visual_target_v1(p_question_id uuid, p_x numeric, p_y numeric, p_target_index integer DEFAULT NULL::integer, p_radius numeric DEFAULT NULL::numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_type text; v_status text; v_metadata jsonb; v_len integer; v_radius numeric; v_path text[];
begin
  if auth.uid() is null or not public.can_review_visuals_v1() then raise exception 'Accès relecteur visuel requis'; end if;
  if p_x < 0 or p_x > 100 or p_y < 0 or p_y > 100 then raise exception 'Coordonnées hors cadre'; end if;
  select q.type,q.validation_status,coalesce(q.metadata,'{}'::jsonb) into v_type,v_status,v_metadata from public.questions q where q.id=p_question_id for update;
  if not found then raise exception 'Question introuvable'; end if;
  if v_type not in ('hotspot','image') then raise exception 'Cette question n’est pas un exercice visuel'; end if;
  if v_status='published' then raise exception 'Repasse la question en revue avant de calibrer sa cible'; end if;
  if v_type='hotspot' then
    if v_metadata->'hotspot' is null then raise exception 'Hotspot absent'; end if;
    v_radius:=coalesce(p_radius,(v_metadata->'hotspot'->>'radius')::numeric,12);
    if v_radius < 6 or v_radius > 30 then raise exception 'Rayon hors limites'; end if;
    v_metadata:=jsonb_set(v_metadata,'{hotspot,x}',to_jsonb(round(p_x,2)),true);
    v_metadata:=jsonb_set(v_metadata,'{hotspot,y}',to_jsonb(round(p_y,2)),true);
    v_metadata:=jsonb_set(v_metadata,'{hotspot,radius}',to_jsonb(round(v_radius,2)),true);
  else
    v_len:=jsonb_array_length(coalesce(v_metadata->'label_targets','[]'::jsonb));
    if p_target_index is null or p_target_index < 0 or p_target_index >= v_len then raise exception 'Étiquette cible invalide'; end if;
    v_radius:=coalesce(p_radius,(v_metadata->'label_targets'->p_target_index->>'radius')::numeric,12);
    if v_radius < 6 or v_radius > 30 then raise exception 'Rayon hors limites'; end if;
    v_path:=array['label_targets',p_target_index::text,'x']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(p_x,2)),true);
    v_path:=array['label_targets',p_target_index::text,'y']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(p_y,2)),true);
    v_path:=array['label_targets',p_target_index::text,'radius']; v_metadata:=jsonb_set(v_metadata,v_path,to_jsonb(round(v_radius,2)),true);
  end if;
  v_metadata:=jsonb_set(v_metadata,'{visual_approved}','false'::jsonb,true);
  v_metadata:=jsonb_set(v_metadata,'{visual_review,target_ok}','false'::jsonb,true);
  v_metadata:=jsonb_set(v_metadata,'{visual_target_calibrated_at}',to_jsonb(now()),true);
  v_metadata:=jsonb_set(v_metadata,'{visual_target_calibrated_by}',to_jsonb(auth.uid()),true);
  update public.questions set metadata=v_metadata,updated_at=now() where id=p_question_id;
  return jsonb_build_object('question_id',p_question_id,'hotspot',v_metadata->'hotspot','label_targets',v_metadata->'label_targets','visual_approved',false);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.notify_streak_milestone_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;
CREATE OR REPLACE FUNCTION public.submit_feedback_v1(p_kind text, p_message text, p_page_path text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_id uuid;
  v_message text:=trim(coalesce(p_message,''));
  v_path text:=left(nullif(trim(coalesce(p_page_path,'')),''),500);
  v_recent_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if p_kind not in ('bug','content','suggestion') then raise exception 'Type de retour invalide'; end if;
  if length(v_message)<10 then raise exception 'Décris ton retour en au moins 10 caractères'; end if;
  if length(v_message)>2000 then raise exception 'Le message doit faire moins de 2000 caractères'; end if;
  select count(*) into v_recent_count from public.feedback where user_id=v_uid and created_at>=now()-interval '1 hour';
  if v_recent_count>=30 then raise exception 'Limite de 30 retours par heure atteinte. Réessaie un peu plus tard.'; end if;
  insert into public.feedback(user_id,kind,message,page_path) values(v_uid,p_kind,v_message,v_path) returning id into v_id;
  return v_id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_inactivity_email_candidates_v1()
 RETURNS TABLE(user_id uuid, email text, first_name text, inactivity_anchor timestamp with time zone, program_id text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  select
    p.id as user_id,
    u.email::text,
    p.first_name,
    greatest(
      coalesce(p.last_seen_at, '-infinity'::timestamptz),
      coalesce(p.last_app_open_at, '-infinity'::timestamptz),
      coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
      u.created_at
    ) as inactivity_anchor,
    pp.program_id
  from public.profiles p
  join auth.users u on u.id = p.id
  left join lateral (
    select x.program_id
    from public.profile_programs x
    where x.user_id = p.id
    order by x.is_primary desc, x.created_at asc
    limit 1
  ) pp on true
  where p.role = 'student'
    and u.email is not null
    and u.email_confirmed_at is not null
    and u.deleted_at is null
    and greatest(
      coalesce(p.last_seen_at, '-infinity'::timestamptz),
      coalesce(p.last_app_open_at, '-infinity'::timestamptz),
      coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
      u.created_at
    ) <= now() - interval '48 hours'
    and not exists (
      select 1
      from public.inactivity_email_log l
      where l.user_id = p.id
        and l.inactivity_anchor = greatest(
          coalesce(p.last_seen_at, '-infinity'::timestamptz),
          coalesce(p.last_app_open_at, '-infinity'::timestamptz),
          coalesce(u.last_sign_in_at, '-infinity'::timestamptz),
          u.created_at
        )
        and l.status in ('queued','sent')
    );
$function$
;
CREATE OR REPLACE FUNCTION public.get_friend_leaderboard_v2(p_program_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid := auth.uid();
  v_level_id uuid;
  v_curriculum_version text;
  v_result jsonb;
begin
  if v_user_id is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  select pp.academic_level_id, coalesce(pp.curriculum_version,'default')
  into v_level_id, v_curriculum_version
  from public.profile_programs pp
  where pp.user_id=v_user_id and pp.program_id=p_program_id
  limit 1;

  if v_level_id is null then
    raise exception 'Cursus ou niveau introuvable';
  end if;

  with people as (
    select v_user_id as user_id, true as is_me
    union
    select case when f.requester_id=v_user_id then f.addressee_id else f.requester_id end, false
    from public.friendships f
    where f.status='accepted'
      and (f.requester_id=v_user_id or f.addressee_id=v_user_id)
  ),
  eligible as (
    select p.user_id,p.is_me
    from people p
    join public.profile_programs pp
      on pp.user_id=p.user_id
     and pp.program_id=p_program_id
     and pp.academic_level_id=v_level_id
     and (
       p_program_id<>'ifsi-fr'
       or coalesce(pp.curriculum_version,'2009')=coalesce(v_curriculum_version,'2009')
     )
  ),
  legacy_activity as (
    select e.user_id,
      coalesce(sum(qa.xp_earned) filter(where qa.created_at>=date_trunc('week',now())),0)::int as weekly_xp,
      count(qa.id) filter(where qa.created_at>=date_trunc('week',now()))::int as weekly_answers
    from eligible e
    left join public.question_attempts qa on qa.user_id=e.user_id
    where p_program_id='kineo-fr'
    group by e.user_id
  ),
  curriculum_activity as (
    select e.user_id,
      coalesce(sum(cqa.xp_earned) filter(where cqa.created_at>=date_trunc('week',now())),0)::int as weekly_xp,
      count(cqa.id) filter(where cqa.created_at>=date_trunc('week',now()))::int as weekly_answers
    from eligible e
    left join public.curriculum_question_attempts cqa on cqa.user_id=e.user_id
    left join public.curriculum_topics ct on ct.id=cqa.topic_id
    left join public.curriculum_units cu on cu.id=ct.unit_id and cu.program_id=p_program_id
    where p_program_id<>'kineo-fr'
      and (cqa.id is null or cu.id is not null)
    group by e.user_id
  ),
  activity as (
    select * from legacy_activity
    union all
    select * from curriculum_activity
  ),
  ranked as (
    select pr.id,pr.username::text,pr.first_name,pr.avatar_url,pr.level,pr.xp,
      coalesce(a.weekly_xp,0) as weekly_xp,
      coalesce(a.weekly_answers,0) as weekly_answers,
      e.is_me,
      row_number() over(
        order by coalesce(a.weekly_xp,0) desc,
                 coalesce(a.weekly_answers,0) desc,
                 coalesce(pr.username::text,pr.first_name,'') asc
      )::int as rank
    from eligible e
    join public.profiles pr on pr.id=e.user_id
    left join activity a on a.user_id=e.user_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',id,'username',username,'first_name',first_name,'avatar_url',avatar_url,
    'level',level,'xp_total',xp,'weekly_xp',weekly_xp,'weekly_answers',weekly_answers,
    'is_me',is_me,'rank',rank
  ) order by rank),'[]'::jsonb)
  into v_result
  from ranked;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.refresh_release_health_status_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_payload jsonb;
begin
  with
  curriculum_questions as (
    select q.*, t.unit_id, u.program_id
    from public.curriculum_quiz_questions q
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.is_published=true
  ),
  curriculum_lessons as (
    select l.*, t.unit_id, u.program_id
    from public.curriculum_lessons l
    left join public.curriculum_topics t on t.id=l.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where l.is_published=true
  ),
  legacy_questions as (
    select q.* from public.questions q where q.is_published=true
  ),
  checks as (
    select
      (select count(*) from curriculum_questions where topic_id is null or unit_id is null or program_id is null)::int as orphan_curriculum_questions,
      (select count(*) from curriculum_questions where coalesce(validation_status,'')<>'source_validated')::int as unvalidated_curriculum_questions,
      (select count(*) from curriculum_questions where length(trim(coalesce(question_text,'')))=0)::int as empty_curriculum_questions,
      (select count(*) from curriculum_questions where length(trim(coalesce(source_label,'')))=0)::int as missing_curriculum_question_sources,
      (select count(*) from curriculum_questions where question_type='mcq' and (
        jsonb_typeof(options)<>'array'
        or jsonb_array_length(options)<2
        or (select count(*) from jsonb_array_elements(options) item where coalesce((item->>'correct')::boolean,false))<>1
      ))::int as invalid_curriculum_mcq,
      (select count(*) from curriculum_questions where question_type='fill_blank' and (
        jsonb_typeof(accepted_answers)<>'array' or jsonb_array_length(accepted_answers)=0
      ))::int as invalid_fill_blank,
      (select count(*) from curriculum_questions where question_type='visual_hotspot' and (
        length(trim(coalesce(image_url,'')))=0
        or jsonb_typeof(metadata->'hotspots')<>'array'
        or jsonb_array_length(coalesce(metadata->'hotspots','[]'::jsonb))=0
        or (select count(*) from jsonb_array_elements(coalesce(metadata->'hotspots','[]'::jsonb)) item where coalesce((item->>'correct')::boolean,false))<>1
      ))::int as invalid_visual_hotspot,
      (select count(*) from curriculum_lessons where topic_id is null or unit_id is null or program_id is null)::int as orphan_curriculum_lessons,
      (select count(*) from curriculum_lessons where coalesce(validation_status,'')<>'source_validated')::int as unvalidated_curriculum_lessons,
      (select count(*) from curriculum_lessons where length(trim(coalesce(title,'')))=0 or length(trim(coalesce(content,'')))=0)::int as empty_curriculum_lessons,
      (select count(*) from curriculum_lessons where source_files is null or source_files='[]'::jsonb or source_files='{}'::jsonb)::int as missing_curriculum_lesson_sources,
      (select count(*) from legacy_questions where length(trim(coalesce(question_text,'')))=0)::int as empty_legacy_questions,
      (select count(*) from legacy_questions q where q.type='mcq' and (
        select count(*) from public.question_options o where o.question_id=q.id and o.is_correct=true
      )<>1)::int as invalid_legacy_mcq,
      (select count(*) from curriculum_questions where length(trim(coalesce(explanation,'')))=0)::int as missing_curriculum_explanations,
      (select count(*) from legacy_questions where length(trim(coalesce(explanation,'')))=0)::int as missing_legacy_explanations,
      (select count(*) from curriculum_questions)::int as published_curriculum_questions,
      (select count(*) from curriculum_lessons)::int as published_curriculum_lessons,
      (select count(*) from legacy_questions)::int as published_legacy_questions
  )
  select jsonb_build_object(
    'ok',(
      orphan_curriculum_questions+unvalidated_curriculum_questions+empty_curriculum_questions+
      missing_curriculum_question_sources+invalid_curriculum_mcq+invalid_fill_blank+invalid_visual_hotspot+
      orphan_curriculum_lessons+unvalidated_curriculum_lessons+empty_curriculum_lessons+
      missing_curriculum_lesson_sources+empty_legacy_questions+invalid_legacy_mcq
    )=0,
    'critical_count',(
      orphan_curriculum_questions+unvalidated_curriculum_questions+empty_curriculum_questions+
      missing_curriculum_question_sources+invalid_curriculum_mcq+invalid_fill_blank+invalid_visual_hotspot+
      orphan_curriculum_lessons+unvalidated_curriculum_lessons+empty_curriculum_lessons+
      missing_curriculum_lesson_sources+empty_legacy_questions+invalid_legacy_mcq
    ),
    'warning_count',missing_curriculum_explanations+missing_legacy_explanations,
    'checks',jsonb_build_object(
      'orphan_curriculum_questions',orphan_curriculum_questions,
      'unvalidated_curriculum_questions',unvalidated_curriculum_questions,
      'empty_curriculum_questions',empty_curriculum_questions,
      'missing_curriculum_question_sources',missing_curriculum_question_sources,
      'invalid_curriculum_mcq',invalid_curriculum_mcq,
      'invalid_fill_blank',invalid_fill_blank,
      'invalid_visual_hotspot',invalid_visual_hotspot,
      'orphan_curriculum_lessons',orphan_curriculum_lessons,
      'unvalidated_curriculum_lessons',unvalidated_curriculum_lessons,
      'empty_curriculum_lessons',empty_curriculum_lessons,
      'missing_curriculum_lesson_sources',missing_curriculum_lesson_sources,
      'empty_legacy_questions',empty_legacy_questions,
      'invalid_legacy_mcq',invalid_legacy_mcq,
      'missing_curriculum_explanations',missing_curriculum_explanations,
      'missing_legacy_explanations',missing_legacy_explanations
    ),
    'published',jsonb_build_object(
      'curriculum_questions',published_curriculum_questions,
      'curriculum_lessons',published_curriculum_lessons,
      'legacy_questions',published_legacy_questions
    ),
    'generated_at',now()
  ) into v_payload
  from checks;

  insert into public.release_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.refresh_business_health_status_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_payload jsonb;
begin
  with duplicate_programs as (
    select user_id,program_id,count(*) c
    from public.profile_programs
    group by user_id,program_id
    having count(*)>1
  ),
  multiple_primary as (
    select user_id,count(*) c
    from public.profile_programs
    where is_primary
    group by user_id
    having count(*)>1
  ),
  bad_challenges as (
    select c.id
    from public.curriculum_friend_challenges c
    left join public.profile_programs a
      on a.user_id=c.challenger_id and a.program_id=c.program_id
    left join public.profile_programs b
      on b.user_id=c.challenged_id and b.program_id=c.program_id
    where a.user_id is null or b.user_id is null
       or a.academic_level_id<>c.academic_level_id
       or b.academic_level_id<>c.academic_level_id
       or (
         c.program_id='ifsi-fr'
         and coalesce(a.curriculum_version,'2009')<>coalesce(b.curriculum_version,'2009')
       )
  ),
  bad_challenge_questions as (
    select cq.challenge_id,cq.question_id
    from public.curriculum_friend_challenge_questions cq
    join public.curriculum_friend_challenges c on c.id=cq.challenge_id
    left join public.curriculum_quiz_questions q on q.id=cq.question_id
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.id is null or u.id is null
       or u.program_id<>c.program_id
       or u.academic_level_id<>c.academic_level_id
       or q.is_published<>true
       or q.validation_status<>'source_validated'
  ),
  bad_daily_questions as (
    select d.id,qid
    from public.curriculum_daily_challenge_attempts d
    join public.profile_programs pp
      on pp.user_id=d.user_id and pp.program_id=d.program_id
    cross join lateral unnest(d.question_ids) qid
    left join public.curriculum_quiz_questions q on q.id=qid
    left join public.curriculum_topics t on t.id=q.topic_id
    left join public.curriculum_units u on u.id=t.unit_id
    where q.id is null or u.id is null
       or u.program_id<>d.program_id
       or u.academic_level_id<>pp.academic_level_id
       or q.is_published<>true
       or q.validation_status<>'source_validated'
  ),
  checks as (
    select
      (select count(*) from duplicate_programs)::int as duplicate_profile_programs,
      (select count(*) from multiple_primary)::int as multiple_primary_programs,
      (select count(*) from bad_challenges)::int as invalid_friend_challenges,
      (select count(*) from bad_challenge_questions)::int as invalid_friend_challenge_questions,
      (select count(*) from bad_daily_questions)::int as invalid_daily_challenge_questions
  )
  select jsonb_build_object(
    'ok',(
      duplicate_profile_programs
      + multiple_primary_programs
      + invalid_friend_challenges
      + invalid_friend_challenge_questions
      + invalid_daily_challenge_questions
    )=0,
    'critical_count',(
      duplicate_profile_programs
      + multiple_primary_programs
      + invalid_friend_challenges
      + invalid_friend_challenge_questions
      + invalid_daily_challenge_questions
    ),
    'checks',jsonb_build_object(
      'duplicate_profile_programs',duplicate_profile_programs,
      'multiple_primary_programs',multiple_primary_programs,
      'invalid_friend_challenges',invalid_friend_challenges,
      'invalid_friend_challenge_questions',invalid_friend_challenge_questions,
      'invalid_daily_challenge_questions',invalid_daily_challenge_questions
    ),
    'generated_at',now()
  )
  into v_payload
  from checks;

  insert into public.business_health_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friend_challenges_v2()
 RETURNS jsonb
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  with me as (select auth.uid() uid),
  rows as (
    select c.*,
      case when c.challenger_id = me.uid then c.challenged_id else c.challenger_id end as opponent_id,
      case when c.challenger_id = me.uid then 'sent' else 'received' end as direction,
      me.uid as me_id
    from public.challenges c cross join me
    where me.uid is not null and (c.challenger_id = me.uid or c.challenged_id = me.uid)
  ),
  enriched as (
    select r.*,
      myrs.id as my_session_id,
      myrs.completed_at as my_completed_at,
      opprs.completed_at as opponent_completed_at
    from rows r
    left join lateral (
      select rs.id, rs.completed_at
      from public.revision_sessions rs
      where rs.user_id = r.me_id
        and rs.challenge_id = r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) myrs on true
    left join lateral (
      select rs.completed_at
      from public.revision_sessions rs
      where rs.user_id = r.opponent_id
        and rs.challenge_id = r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) opprs on true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', e.id,
    'status', e.status,
    'direction', e.direction,
    'challenger_id', e.challenger_id,
    'challenged_id', e.challenged_id,
    'challenger_score', e.challenger_score,
    'challenged_score', e.challenged_score,
    'created_at', e.created_at,
    'completed_at', e.completed_at,
    'my_session_id', e.my_session_id,
    'has_played', e.my_completed_at is not null,
    'opponent_has_played', e.opponent_completed_at is not null,
    'opponent', jsonb_build_object('id', p.id, 'username', p.username::text, 'first_name', p.first_name, 'study_year', p.study_year, 'level', p.level, 'avatar_url', p.avatar_url)
  ) order by e.created_at desc), '[]'::jsonb)
  from enriched e join public.profiles p on p.id = e.opponent_id;
$function$
;
CREATE OR REPLACE FUNCTION public.mark_app_open_v1()
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_now timestamptz := now();
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  update public.profiles
  set last_app_open_at = v_now
  where id = v_uid;

  return v_now;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.refresh_authenticated_contract_status_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_payload jsonb;
begin
  with assignments as (
    select
      pp.user_id,
      pp.program_id,
      pp.academic_level_id,
      coalesce(pp.curriculum_version,'default') as curriculum_version,
      al.display_order as active_order
    from public.profile_programs pp
    left join public.academic_levels al on al.id=pp.academic_level_id
  ),
  assigned as (
    select * from assignments where academic_level_id is not null and active_order is not null
  ),
  expected_access as (
    select
      a.user_id,
      a.program_id,
      a.curriculum_version,
      a.active_order,
      count(u.id)::int as expected_units,
      count(u.id) filter(where al.display_order>a.active_order)::int as future_units_in_expected_set
    from assigned a
    join public.curriculum_units u
      on u.program_id=a.program_id
     and u.is_active=true
     and (
       a.program_id<>'ifsi-fr'
       or coalesce(u.curriculum_version,'2009')=coalesce(a.curriculum_version,'2009')
     )
    join public.academic_levels al on al.id=u.academic_level_id
    where al.display_order<=a.active_order
    group by a.user_id,a.program_id,a.curriculum_version,a.active_order
  ),
  missing_current_or_previous as (
    select a.user_id,a.program_id
    from assigned a
    where a.program_id<>'kineo-fr'
      and not exists (
        select 1
        from public.curriculum_units u
        join public.academic_levels al on al.id=u.academic_level_id
        where u.program_id=a.program_id
          and u.is_active=true
          and al.display_order<=a.active_order
          and (
            a.program_id<>'ifsi-fr'
            or coalesce(u.curriculum_version,'2009')=coalesce(a.curriculum_version,'2009')
          )
      )
  ),
  invalid_primary as (
    select user_id
    from public.profile_programs
    group by user_id
    having count(*) filter(where is_primary)<>1
  ),
  invalid_level_binding as (
    select pp.user_id,pp.program_id
    from public.profile_programs pp
    join public.academic_levels al on al.id=pp.academic_level_id
    where pp.academic_level_id is not null
      and al.program_id<>pp.program_id
  ),
  unassigned_levels as (
    select user_id,program_id
    from public.profile_programs
    where academic_level_id is null
  ),
  invalid_curriculum_version as (
    select pp.user_id,pp.program_id
    from public.profile_programs pp
    where pp.program_id='ifsi-fr'
      and coalesce(pp.curriculum_version,'') not in ('2009','2026')
  ),
  checks as (
    select
      (select count(*) from assignments)::int as assignment_count,
      (select count(*) from assigned)::int as assigned_level_count,
      (select count(*) from expected_access)::int as assignments_with_curriculum,
      (select count(*) from missing_current_or_previous)::int as missing_current_or_previous_content,
      (select count(*) from invalid_primary)::int as invalid_primary_program_count,
      (select count(*) from invalid_level_binding)::int as invalid_level_binding_count,
      (select count(*) from unassigned_levels)::int as unassigned_level_count,
      (select count(*) from invalid_curriculum_version)::int as invalid_ifsi_curriculum_version_count,
      (select coalesce(sum(future_units_in_expected_set),0) from expected_access)::int as future_units_leaking_into_expected_set
  )
  select jsonb_build_object(
    'ok',(
      missing_current_or_previous_content
      + invalid_primary_program_count
      + invalid_level_binding_count
      + invalid_ifsi_curriculum_version_count
      + future_units_leaking_into_expected_set
    )=0,
    'critical_count',(
      missing_current_or_previous_content
      + invalid_primary_program_count
      + invalid_level_binding_count
      + invalid_ifsi_curriculum_version_count
      + future_units_leaking_into_expected_set
    ),
    'warning_count',unassigned_level_count,
    'checks',jsonb_build_object(
      'assignment_count',assignment_count,
      'assigned_level_count',assigned_level_count,
      'assignments_with_curriculum',assignments_with_curriculum,
      'missing_current_or_previous_content',missing_current_or_previous_content,
      'invalid_primary_program_count',invalid_primary_program_count,
      'invalid_level_binding_count',invalid_level_binding_count,
      'unassigned_level_count',unassigned_level_count,
      'invalid_ifsi_curriculum_version_count',invalid_ifsi_curriculum_version_count,
      'future_units_leaking_into_expected_set',future_units_leaking_into_expected_set
    ),
    'generated_at',now()
  )
  into v_payload
  from checks;

  insert into public.authenticated_contract_status(id,payload,checked_at)
  values(1,v_payload,now())
  on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;

  return v_payload;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_friend_challenges_v3()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_result jsonb;
begin
  if v_uid is null then
    raise exception 'Utilisateur non authentifié';
  end if;

  with rows as (
    select c.*,
      case when c.challenger_id=v_uid then c.challenged_id else c.challenger_id end as opponent_id,
      case when c.challenger_id=v_uid then 'sent' else 'received' end as direction
    from public.challenges c
    where c.challenger_id=v_uid or c.challenged_id=v_uid
  ),
  enriched as (
    select r.*,
      myrs.id as my_session_id,
      myrs.completed_at as my_completed_at,
      opprs.completed_at as opponent_completed_at
    from rows r
    left join lateral (
      select rs.id,rs.completed_at
      from public.revision_sessions rs
      where rs.user_id=v_uid
        and rs.challenge_id=r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) myrs on true
    left join lateral (
      select rs.completed_at
      from public.revision_sessions rs
      where rs.user_id=r.opponent_id
        and rs.challenge_id=r.id
        and rs.abandoned_at is null
      order by rs.started_at desc
      limit 1
    ) opprs on true
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id',e.id,
    'status',e.status,
    'direction',e.direction,
    'challenger_id',e.challenger_id,
    'challenged_id',e.challenged_id,
    'challenger_score',e.challenger_score,
    'challenged_score',e.challenged_score,
    'created_at',e.created_at,
    'completed_at',e.completed_at,
    'my_session_id',e.my_session_id,
    'has_played',e.my_completed_at is not null,
    'opponent_has_played',e.opponent_completed_at is not null,
    'opponent',jsonb_build_object(
      'id',p.id,'username',p.username::text,'first_name',p.first_name,
      'study_year',p.study_year,'level',p.level,'avatar_url',p.avatar_url
    )
  ) order by e.created_at desc),'[]'::jsonb)
  into v_result
  from enriched e
  join public.profiles p on p.id=e.opponent_id;

  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_stats_v1(p_program_id text, p_days integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_level uuid; v_version text; v_days int:=greatest(7,least(coalesce(p_days,30),90)); v_result jsonb;
begin
 if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
 select academic_level_id,coalesce(curriculum_version,'default') into v_level,v_version from public.profile_programs where user_id=v_uid and program_id=p_program_id order by is_primary desc limit 1;
 with qbase as (
  select q.id,t.id topic_id,t.name topic_name,u.id unit_id,u.name unit_name,u.display_order
  from public.curriculum_units u join public.curriculum_topics t on t.unit_id=u.id and t.is_active=true join public.curriculum_quiz_questions q on q.topic_id=t.id and q.is_published=true and q.validation_status='source_validated'
  where u.program_id=p_program_id and u.academic_level_id=v_level and u.curriculum_version=v_version and u.is_active=true
 ), a as (
  select x.* from public.curriculum_question_attempts x join qbase q on q.id=x.question_id where x.user_id=v_uid and x.created_at>=current_date-(v_days-1)
 ), totals as (select count(*)::int attempts,count(*) filter(where is_correct)::int correct,coalesce(sum(xp_earned),0)::int xp from a),
 days as (select generate_series(current_date-(v_days-1),current_date,interval '1 day')::date d),
 daily as (select date(created_at) d,count(*)::int attempts,count(*) filter(where is_correct)::int correct,coalesce(sum(xp_earned),0)::int xp from a group by 1),
 daily_json as (select jsonb_agg(jsonb_build_object('date',d.d,'attempts',coalesce(x.attempts,0),'correct',coalesce(x.correct,0),'accuracy_percent',case when coalesce(x.attempts,0)=0 then 0 else round(100.0*x.correct/x.attempts)::int end,'xp',coalesce(x.xp,0)) order by d.d) data from days d left join daily x using(d)),
 units as (
  select q.unit_id,max(q.unit_name) name,max(q.display_order) display_order,count(distinct q.id)::int questions_total,count(distinct a.question_id)::int questions_answered,count(a.id)::int attempts,count(a.id) filter(where a.is_correct)::int correct
  from qbase q left join a on a.question_id=q.id group by q.unit_id
 ), units_json as (select coalesce(jsonb_agg(jsonb_build_object('id',unit_id,'name',name,'questions_total',questions_total,'questions_answered',questions_answered,'coverage_percent',case when questions_total=0 then 0 else round(100.0*questions_answered/questions_total)::int end,'attempts',attempts,'correct',correct,'accuracy_percent',case when attempts=0 then 0 else round(100.0*correct/attempts)::int end) order by display_order,name),'[]'::jsonb) data from units),
 alltime as (select count(distinct x.question_id)::int answered from public.curriculum_question_attempts x join qbase q on q.id=x.question_id where x.user_id=v_uid),
 qcount as (select count(*)::int total from qbase),
 streak as (select coalesce(current_streak,0)::int current,coalesce(longest_streak,0)::int longest from public.user_streaks where user_id=v_uid),
 profile as (select coalesce(xp,0)::int xp,coalesce(level,1)::int level from public.profiles where id=v_uid)
 select jsonb_build_object('period_days',v_days,'summary',jsonb_build_object('attempts',t.attempts,'correct_answers',t.correct,'accuracy_percent',case when t.attempts=0 then 0 else round(100.0*t.correct/t.attempts)::int end,'xp_period',t.xp,'xp_total',p.xp,'level',p.level,'streak_current',coalesce(s.current,0),'streak_longest',coalesce(s.longest,0),'questions_total',qc.total,'questions_answered',at.answered,'coverage_percent',case when qc.total=0 then 0 else round(100.0*at.answered/qc.total)::int end),'daily_activity',dj.data,'units',uj.data) into v_result
 from totals t cross join daily_json dj cross join units_json uj cross join alltime at cross join qcount qc cross join profile p left join streak s on true;
 return v_result;
end $function$
;
CREATE OR REPLACE FUNCTION public.get_inactivity_reminder_preference_v1()
 RETURNS TABLE(opted_in boolean, updated_at timestamp with time zone)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select p.opted_in,p.updated_at from public.inactivity_email_preferences p where p.user_id=(select auth.uid())
$function$
;
CREATE OR REPLACE FUNCTION public.set_inactivity_reminder_preference_v1(p_opted_in boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 insert into public.inactivity_email_preferences(user_id,opted_in,opted_in_at,opted_out_at,updated_at)
 values(auth.uid(),p_opted_in,case when p_opted_in then now() else null end,case when p_opted_in then null else now() end,now())
 on conflict(user_id) do update set opted_in=excluded.opted_in,opted_in_at=excluded.opted_in_at,opted_out_at=excluded.opted_out_at,updated_at=now();
 return p_opted_in;
end $function$
;
CREATE OR REPLACE FUNCTION public.get_badges_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid(); v_quiz_count integer:=0; v_correct_count integer:=0; v_streak integer:=0; v_daily_count integer:=0; v_daily_perfect boolean:=false; v_high_score integer:=0; v_perfect integer:=0; v_friend_completed integer:=0; v_friend_won integer:=0; v_friends integer:=0; v_badges jsonb:='[]'::jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null)+(select count(*) from public.curriculum_topic_completions where user_id=v_user_id) into v_quiz_count;
  select (select count(*) from public.question_attempts where user_id=v_user_id and is_correct=true)+(select count(distinct question_id) from public.curriculum_question_attempts where user_id=v_user_id and is_correct=true) into v_correct_count;
  select coalesce(current_streak,0) into v_streak from public.user_streaks where user_id=v_user_id; v_streak:=coalesce(v_streak,0);
  select (select count(*) from public.daily_challenge_attempts where user_id=v_user_id)+(select count(*) from public.curriculum_daily_challenge_attempts where user_id=v_user_id and completed_at is not null) into v_daily_count;
  select exists(select 1 from public.daily_challenge_attempts where user_id=v_user_id and score>=100) or exists(select 1 from public.curriculum_daily_challenge_attempts where user_id=v_user_id and completed_at is not null and correct_count=total_questions) into v_daily_perfect;

  select (select count(*) from public.challenges where status='completed' and (challenger_id=v_user_id or challenged_id=v_user_id)) + (select count(*) from public.curriculum_friend_challenges where status='completed' and (challenger_id=v_user_id or challenged_id=v_user_id)) into v_friend_completed;
  select (select count(*) from public.challenges where status='completed' and ((challenger_id=v_user_id and challenger_score>challenged_score) or (challenged_id=v_user_id and challenged_score>challenger_score))) + (select count(*) from public.curriculum_friend_challenges where status='completed' and ((challenger_id=v_user_id and challenger_score>challenged_score) or (challenged_id=v_user_id and challenged_score>challenger_score))) into v_friend_won;
  select count(*) into v_friends from public.friendships where status='accepted' and (requester_id=v_user_id or addressee_id=v_user_id);

  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null and question_count>0 and correct_count*100>=question_count*80) + (select count(*) from public.curriculum_topic_completions where user_id=v_user_id and score_percent>=80) into v_high_score;
  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null and question_count>0 and correct_count>=question_count) + (select count(*) from public.curriculum_topic_completions where user_id=v_user_id and score_percent>=100) into v_perfect;
  select coalesce(jsonb_agg(jsonb_build_object('id',b.id,'name',b.name,'description',b.description,'icon',b.icon,'condition_type',b.condition_type,'earned',ub.badge_id is not null,'earned_at',ub.earned_at,'current_value',case b.condition_type when 'quiz_completed' then v_quiz_count when 'streak' then v_streak when 'correct_answers' then v_correct_count when 'daily_completed' then v_daily_count when 'daily_perfect' then case when v_daily_perfect then 1 else 0 end when 'friend_challenges_completed' then v_friend_completed when 'friend_challenges_won' then v_friend_won when 'friends_added' then v_friends when 'high_score_quizzes' then v_high_score when 'perfect_quizzes' then v_perfect else 0 end,'target_value',case b.condition_type when 'quiz_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'streak' then coalesce((b.condition_value->>'days')::integer,1) when 'correct_answers' then coalesce((b.condition_value->>'count')::integer,1) when 'daily_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'daily_perfect' then 1 when 'friend_challenges_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'friend_challenges_won' then coalesce((b.condition_value->>'count')::integer,1) when 'friends_added' then coalesce((b.condition_value->>'count')::integer,1) when 'high_score_quizzes' then coalesce((b.condition_value->>'count')::integer,1) when 'perfect_quizzes' then coalesce((b.condition_value->>'count')::integer,1) else 1 end,'progress_percent',least(100,round(100.0*(case b.condition_type when 'quiz_completed' then v_quiz_count when 'streak' then v_streak when 'correct_answers' then v_correct_count when 'daily_completed' then v_daily_count when 'daily_perfect' then case when v_daily_perfect then 1 else 0 end when 'friend_challenges_completed' then v_friend_completed when 'friend_challenges_won' then v_friend_won when 'friends_added' then v_friends when 'high_score_quizzes' then v_high_score when 'perfect_quizzes' then v_perfect else 0 end)/greatest(1,(case b.condition_type when 'quiz_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'streak' then coalesce((b.condition_value->>'days')::integer,1) when 'correct_answers' then coalesce((b.condition_value->>'count')::integer,1) when 'daily_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'daily_perfect' then 1 when 'friend_challenges_completed' then coalesce((b.condition_value->>'count')::integer,1) when 'friend_challenges_won' then coalesce((b.condition_value->>'count')::integer,1) when 'friends_added' then coalesce((b.condition_value->>'count')::integer,1) when 'high_score_quizzes' then coalesce((b.condition_value->>'count')::integer,1) when 'perfect_quizzes' then coalesce((b.condition_value->>'count')::integer,1) else 1 end)))::integer)) order by (ub.badge_id is not null) desc,b.name),'[]'::jsonb) into v_badges from public.badges b left join public.user_badges ub on ub.badge_id=b.id and ub.user_id=v_user_id;
  return jsonb_build_object('badges',v_badges,'stats',jsonb_build_object('completed_quizzes',v_quiz_count,'correct_answers',v_correct_count,'current_streak',v_streak,'daily_challenges',v_daily_count,'daily_perfect',v_daily_perfect));
end;$function$
;
CREATE OR REPLACE FUNCTION public.check_and_award_badges_v2()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user_id uuid:=auth.uid(); v_quiz_count integer:=0; v_correct_count integer:=0; v_streak integer:=0; v_daily_count integer:=0; v_daily_perfect boolean:=false; v_high_score integer:=0; v_perfect integer:=0; v_friend_completed integer:=0; v_friend_won integer:=0; v_friends integer:=0; v_new_badges jsonb:='[]'::jsonb; v_all jsonb;
begin
  if v_user_id is null then raise exception 'Utilisateur non authentifié'; end if;
  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null)+(select count(*) from public.curriculum_topic_completions where user_id=v_user_id) into v_quiz_count;
  select (select count(*) from public.question_attempts where user_id=v_user_id and is_correct=true)+(select count(distinct question_id) from public.curriculum_question_attempts where user_id=v_user_id and is_correct=true) into v_correct_count;
  select coalesce(current_streak,0) into v_streak from public.user_streaks where user_id=v_user_id; v_streak:=coalesce(v_streak,0);
  select (select count(*) from public.daily_challenge_attempts where user_id=v_user_id)+(select count(*) from public.curriculum_daily_challenge_attempts where user_id=v_user_id and completed_at is not null) into v_daily_count;
  select exists(select 1 from public.daily_challenge_attempts where user_id=v_user_id and score>=100) or exists(select 1 from public.curriculum_daily_challenge_attempts where user_id=v_user_id and completed_at is not null and correct_count=total_questions) into v_daily_perfect;

  select (select count(*) from public.challenges where status='completed' and (challenger_id=v_user_id or challenged_id=v_user_id)) + (select count(*) from public.curriculum_friend_challenges where status='completed' and (challenger_id=v_user_id or challenged_id=v_user_id)) into v_friend_completed;
  select (select count(*) from public.challenges where status='completed' and ((challenger_id=v_user_id and challenger_score>challenged_score) or (challenged_id=v_user_id and challenged_score>challenger_score))) + (select count(*) from public.curriculum_friend_challenges where status='completed' and ((challenger_id=v_user_id and challenger_score>challenged_score) or (challenged_id=v_user_id and challenged_score>challenger_score))) into v_friend_won;
  select count(*) into v_friends from public.friendships where status='accepted' and (requester_id=v_user_id or addressee_id=v_user_id);

  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null and question_count>0 and correct_count*100>=question_count*80) + (select count(*) from public.curriculum_topic_completions where user_id=v_user_id and score_percent>=80) into v_high_score;
  select (select count(*) from public.revision_sessions where user_id=v_user_id and completed_at is not null and question_count>0 and correct_count>=question_count) + (select count(*) from public.curriculum_topic_completions where user_id=v_user_id and score_percent>=100) into v_perfect;
  with eligible as (select b.id from public.badges b where (b.condition_type='quiz_completed' and v_quiz_count>=coalesce((b.condition_value->>'count')::integer,0)) or (b.condition_type='streak' and v_streak>=coalesce((b.condition_value->>'days')::integer,0)) or (b.condition_type='correct_answers' and v_correct_count>=coalesce((b.condition_value->>'count')::integer,0)) or (b.condition_type='daily_completed' and v_daily_count>=coalesce((b.condition_value->>'count')::integer,0)) or (b.condition_type='daily_perfect' and v_daily_perfect) or (b.condition_type='high_score_quizzes' and v_high_score>=coalesce((b.condition_value->>'count')::integer,1)) or (b.condition_type='perfect_quizzes' and v_perfect>=coalesce((b.condition_value->>'count')::integer,1)) or (b.condition_type='friend_challenges_completed' and v_friend_completed>=coalesce((b.condition_value->>'count')::integer,1)) or (b.condition_type='friend_challenges_won' and v_friend_won>=coalesce((b.condition_value->>'count')::integer,1)) or (b.condition_type='friends_added' and v_friends>=coalesce((b.condition_value->>'count')::integer,1))), inserted as (insert into public.user_badges(user_id,badge_id) select v_user_id,id from eligible on conflict(user_id,badge_id) do nothing returning badge_id) select coalesce(jsonb_agg(jsonb_build_object('id',b.id,'name',b.name,'description',b.description,'icon',b.icon) order by b.name),'[]'::jsonb) into v_new_badges from inserted i join public.badges b on b.id=i.badge_id;
  v_all:=public.get_badges_v2();
  return jsonb_build_object('new_badges',v_new_badges,'new_badges_count',jsonb_array_length(v_new_badges),'badges',v_all->'badges','stats',v_all->'stats');
end;$function$
;
CREATE OR REPLACE FUNCTION public.start_revision_session_replay_v1(p_source_session_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$ declare v_source public.revision_sessions%rowtype; v_new uuid; begin if auth.uid() is null then raise exception 'Authentication required'; end if; select * into v_source from public.revision_sessions where id=p_source_session_id and user_id=auth.uid() and completed_at is not null; if not found then raise exception 'Completed session not found'; end if; insert into public.revision_sessions(user_id,mode,question_count,correct_count,xp_earned) values(auth.uid(),'replay',v_source.question_count,0,0) returning id into v_new; insert into public.revision_session_questions(session_id,question_id,display_order) select v_new,rsq.question_id,rsq.display_order from public.revision_session_questions rsq join public.questions q on q.id=rsq.question_id where rsq.session_id=p_source_session_id and q.is_published order by rsq.display_order; if (select count(*) from public.revision_session_questions where session_id=v_new) <> v_source.question_count then raise exception 'Some questions are no longer available'; end if; return v_new; end $function$
;
CREATE OR REPLACE FUNCTION private.queue_weekly_friend_rankings(p_week date)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare n integer;
begin
 if extract(isodow from p_week) <> 1 then raise exception 'week must start on Monday'; end if;
 with members as (
   select pp.program_id,pp.user_id,coalesce(p.username::text,p.first_name,'Étudiant') pseudo
   from public.profile_programs pp join public.profiles p on p.id=pp.user_id
 ),
 scores as (
   select m.program_id,m.user_id,m.pseudo,coalesce(sum(greatest(0,a.xp_earned)),0)::bigint xp
   from members m left join public.kineo_attempt_audit_all_v1 a
   on a.user_id=m.user_id and a.program_id=m.program_id
   and a.created_at >= (p_week::timestamp at time zone 'Europe/Paris')
   and a.created_at < ((p_week+7)::timestamp at time zone 'Europe/Paris')
   group by m.program_id,m.user_id,m.pseudo
 ),
 circles as (
   select s.program_id,s.user_id,s.pseudo,s.xp, f.requester_id as viewer from scores s
   join public.friendships f on f.addressee_id=s.user_id and f.status='accepted'
   union all
   select s.program_id,s.user_id,s.pseudo,s.xp,f.addressee_id from scores s
   join public.friendships f on f.requester_id=s.user_id and f.status='accepted'
   union all
   select program_id,user_id,pseudo,xp,user_id from scores
 ),
 ranked as (
   select c.*,row_number() over(partition by viewer,program_id order by xp desc,user_id) rank,
   count(*) over(partition by viewer,program_id) participants
   from circles c where exists(select 1 from members m where m.user_id=c.viewer and m.program_id=c.program_id)
 ),
 summaries as (
   select viewer,program_id,
   jsonb_agg(jsonb_build_object('pseudo',pseudo,'xp',xp,'rank',rank) order by rank) filter(where rank<=3) podium,
   max(rank) filter(where user_id=viewer) my_rank,
   max(xp) filter(where user_id=viewer) my_xp,
   max(participants) participants
   from ranked group by viewer,program_id
 )
 insert into private.weekly_friend_email_queue(user_id,program_id,week_start,payload)
 select s.viewer,s.program_id,p_week,jsonb_build_object('podium',s.podium,'my_rank',s.my_rank,'my_xp',s.my_xp,'participants',s.participants)
 from summaries s join public.weekly_friend_email_preferences pref on pref.user_id=s.viewer and pref.opted_in=true
 where s.participants>=2
 on conflict(user_id,program_id,week_start) do nothing;
 get diagnostics n=row_count;
 return n;
end $function$
;
CREATE OR REPLACE FUNCTION private.weekly_friend_rankings_tick()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare local_now timestamp;
begin
 local_now := now() at time zone 'Europe/Paris';
 if extract(isodow from local_now)=1 and extract(hour from local_now)=9 then
   perform private.queue_weekly_friend_rankings((local_now::date-7));
 end if;
end $function$
;
CREATE OR REPLACE FUNCTION public.setup_student_profile_v1(p_program_id text, p_level_code text, p_first_name text, p_username text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_profile public.profiles%rowtype;
  v_level public.academic_levels%rowtype;
  v_existing public.profile_programs%rowtype;
  v_year integer;
  v_username text := nullif(btrim(coalesce(p_username, '')), '');
  v_first_name text := nullif(btrim(coalesce(p_first_name, '')), '');
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if v_username is not null and (length(v_username) not between 3 and 24 or v_username !~ '^[A-Za-z0-9._-]+$') then
    raise exception 'Le pseudo doit contenir 3 à 24 caractères : lettres, chiffres, point, tiret ou underscore';
  end if;
  if length(v_first_name) > 100 then raise exception 'Le prénom est trop long'; end if;

  -- Serialize two setup requests for the same user, including first assignment.
  select * into v_profile from public.profiles where id = v_uid for update;
  if not found then raise exception 'Profil introuvable'; end if;
  select al.* into v_level
  from public.academic_levels al join public.programs pr on pr.id = al.program_id
  where al.program_id = p_program_id and al.code = p_level_code
    and al.is_active and pr.is_active;
  if not found then raise exception 'Choisis un niveau d’étude valide pour ton cursus'; end if;
  if p_program_id not in ('kineo-fr', 'kineo-es', 'ifsi-fr') then
    raise exception 'Cursus indisponible';
  end if;

  select * into v_existing from public.profile_programs
  where user_id = v_uid and is_primary for update;
  if found and (v_existing.program_id <> p_program_id or
    (v_existing.academic_level_id is not null and v_existing.academic_level_id <> v_level.id)) then
    raise exception 'Ton cursus est déjà défini. Modifie ton niveau depuis ton profil';
  end if;
  v_year := case when p_program_id = 'ifsi-fr' then (v_level.level_number + 1) / 2 else v_level.level_number end;

  begin
    update public.profiles set first_name = v_first_name, username = v_username,
      study_year = v_year, updated_at = now()
    where id = v_uid returning * into v_profile;
  exception when unique_violation then raise exception 'Ce pseudo est déjà utilisé';
  end;

  if v_existing.user_id is null then
    insert into public.profile_programs(user_id, program_id, academic_level_id, is_primary, curriculum_version)
    values(v_uid, p_program_id, v_level.id, true, case when p_program_id = 'ifsi-fr' then '2009' else 'default' end);
  elsif v_existing.academic_level_id is null then
    update public.profile_programs set academic_level_id = v_level.id, updated_at = now()
    where user_id = v_uid and program_id = p_program_id;
  end if;

  return jsonb_build_object('id', v_profile.id, 'first_name', v_profile.first_name,
    'username', v_profile.username::text, 'avatar_url', v_profile.avatar_url,
    'study_year', v_profile.study_year, 'role', v_profile.role);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_quiz_questions_v1(p_topic_ids uuid[])
 RETURNS TABLE(id uuid, topic_id uuid, question_text text, explanation text, options jsonb, difficulty smallint, source_label text, display_order integer, question_type text, image_url text, metadata jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := auth.uid();
  v_admin boolean;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;
  if coalesce(cardinality(p_topic_ids), 0) > 200 then raise exception 'Trop de chapitres demandés'; end if;
  select role = 'admin' into v_admin from public.profiles where profiles.id = v_uid;
  return query
  select q.id, q.topic_id, q.question_text, null::text,
    coalesce((select jsonb_agg(jsonb_build_object('text', o.value->>'text') order by random())
      from jsonb_array_elements(q.options) o(value)), '[]'::jsonb),
    q.difficulty, q.source_label, q.display_order, q.question_type, q.image_url,
    case q.question_type
      when 'visual_hotspot' then jsonb_build_object('hotspots', coalesce((
        select jsonb_agg(jsonb_build_object('id', h.value->'id', 'label', h.value->'label',
          'x', h.value->'x', 'y', h.value->'y') order by h.ord)
        from jsonb_array_elements(coalesce(q.metadata->'hotspots', '[]'::jsonb)) with ordinality h(value,ord)
      ), '[]'::jsonb))
      when 'matching' then jsonb_build_object(
        'left_items', coalesce((select jsonb_agg(p.value->'left' order by p.ord)
          from jsonb_array_elements(coalesce(q.metadata->'pairs', '[]'::jsonb)) with ordinality p(value,ord)), '[]'::jsonb),
        'right_items', coalesce((select jsonb_agg(p.value->'right' order by random())
          from jsonb_array_elements(coalesce(q.metadata->'pairs', '[]'::jsonb)) p(value)), '[]'::jsonb))
      else '{}'::jsonb
    end
  from public.curriculum_quiz_questions q
  join public.curriculum_topics t on t.id = q.topic_id and t.is_active
  join public.curriculum_units u on u.id = t.unit_id and u.is_active
  join public.academic_levels target on target.id = u.academic_level_id and target.program_id = u.program_id and target.is_active
  where q.topic_id = any(p_topic_ids) and q.is_published and q.validation_status = 'source_validated'
    and (coalesce(v_admin, false) or exists(
      select 1 from public.profile_programs pp
      join public.academic_levels assigned on assigned.id = pp.academic_level_id and assigned.program_id = pp.program_id
      where pp.user_id = v_uid and pp.program_id = u.program_id
        and target.display_order <= assigned.display_order
        and coalesce(pp.curriculum_version, 'default') = coalesce(u.curriculum_version, 'default')
    ))
  order by q.difficulty, q.display_order, q.id;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.submit_curriculum_topic_answer_v3(p_question_id uuid, p_answer jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_result jsonb; v_explanation text;
begin
  if auth.uid() is null then raise exception 'Utilisateur non authentifié'; end if;
  v_result := public.submit_curriculum_topic_answer_v2(p_question_id, p_answer);
  select explanation into v_explanation from public.curriculum_quiz_questions where id = p_question_id;
  return v_result || jsonb_build_object('explanation', v_explanation);
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.activity(p_user uuid)
 RETURNS timestamp with time zone
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select greatest(u.created_at,u.last_sign_in_at,p.last_seen_at,
   (select max(greatest(s.created_at,s.refreshed_at)) from auth.sessions s where s.user_id=u.id))
 from auth.users u left join public.profiles p on p.id=u.id where u.id=p_user;
$function$
;
CREATE OR REPLACE FUNCTION retention.check_lease(p_lease uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if not exists(select 1 from retention.worker where lease=p_lease and lease_until>now()) then
  raise exception 'Retention worker lease expired';
 end if;
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.cancel_on_activity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if (tg_table_schema='public' and (new.last_seen_at is distinct from old.last_seen_at or new.role is distinct from old.role)) then
  if exists(select 1 from retention.notices where user_id=new.id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.id;
 end if;
 return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.cancel_on_auth_activity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if new.last_sign_in_at is distinct from old.last_sign_in_at or new.email is distinct from old.email then
  if exists(select 1 from retention.notices where user_id=new.id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.id;
 end if;
 return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.cancel_on_session_activity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if tg_op='INSERT' or new.refreshed_at is distinct from old.refreshed_at then
  perform 1 from auth.users where id=new.user_id for key share;
  if exists(select 1 from retention.notices where user_id=new.user_id and state='deleting') then
   raise exception 'Account deletion in progress';
  end if;
  delete from retention.notices where user_id=new.user_id;
 end if;
 return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.guard_storage()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 perform 1 from auth.users u where new.owner=u.id or new.owner_id=u.id::text or
  (new.bucket_id='avatars' and split_part(new.name,'/',1)=u.id::text) for key share;
 if exists(select 1 from retention.notices n where n.state='deleting' and
  (new.owner_id=n.user_id::text or new.owner=n.user_id or
   (new.bucket_id='avatars' and split_part(new.name,'/',1)=n.user_id::text))) then
  raise exception 'Account deletion in progress';
 end if;
 return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.retention_worker_finish_v1(p_lease uuid, p_result jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 update retention.worker set lease=null,lease_until=null,last_result=p_result where lease=p_lease;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.retention_jobs_v1(p_lease uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 perform retention.check_lease(p_lease);
 delete from retention.notices n where n.state<>'deleting' and
  (retention.activity(n.user_id)>n.anchor or not exists
   (select 1 from public.profiles p join auth.users u on u.id=p.id where p.id=n.user_id
    and p.role='student' and u.email=n.recipient and u.email_confirmed_at is not null and u.deleted_at is null));
 insert into retention.notices(user_id,anchor,recipient)
 select u.id,retention.activity(u.id),u.email from auth.users u join public.profiles p on p.id=u.id
 where p.role='student' and u.email_confirmed_at is not null and u.deleted_at is null
  and coalesce(u.is_anonymous,false)=false and coalesce(u.is_sso_user,false)=false
  and coalesce(u.raw_app_meta_data->>'retention_exempt','false')<>'true'
  and retention.activity(u.id)<=now()-interval '24 months'
  and not exists(select 1 from retention.notices n where n.user_id=u.id)
 order by retention.activity(u.id) limit 5 on conflict(user_id) do nothing;
 return coalesce((select jsonb_agg(to_jsonb(n)) from
  (select * from retention.notices where hold_reason is null and state<>'blocked'
   order by updated_at limit 10) n),'[]'::jsonb);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.retention_notice_result_v1(p_lease uuid, p_id uuid, p_event text, p_provider_id text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare n retention.notices;
begin
 perform retention.check_lease(p_lease);
 select * into n from retention.notices where id=p_id for update;
 if not found then return null; end if;
 if n.state='deleting' or n.hold_reason is not null then return null; end if;
 if retention.activity(n.user_id)>n.anchor then delete from retention.notices where id=p_id; return null; end if;
 if p_event='sending' and n.state in ('pending','sending') then
  if n.started_at is not null and n.started_at<now()-interval '20 hours' then
   update retention.notices set state='blocked',hold_reason='send_confirmation_missing',updated_at=now() where id=p_id;
   return null;
  end if;
  update retention.notices set state='sending',started_at=coalesce(started_at,now()),updated_at=now() where id=p_id;
 elsif p_event='sent' and n.state='sending' and coalesce(p_provider_id,'')<>'' then
  update retention.notices set state='sent',provider_id=p_provider_id,updated_at=now() where id=p_id;
 elsif p_event='delivered' and n.state in ('sent','delivered') then
  update retention.notices set state='delivered',delivered_at=coalesce(delivered_at,now()),
   delete_after=coalesce(delete_after,now()+interval '30 days'),updated_at=now() where id=p_id;
 elsif p_event='blocked' then
  update retention.notices set state='blocked',hold_reason='email_delivery_failed',updated_at=now() where id=p_id;
 else raise exception 'Invalid retention transition'; end if;
 return (select to_jsonb(q) from retention.notices q where id=p_id);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.retention_claim_delete_v1(p_lease uuid, p_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare n retention.notices; v_user uuid;
begin
 perform retention.check_lease(p_lease);
 select user_id into v_user from retention.notices where id=p_id;
 if v_user is null then return null; end if;
 perform 1 from auth.users where id=v_user for update;
 perform 1 from public.profiles where id=v_user for update;
 select * into n from retention.notices where id=p_id for update;
 if not found or n.hold_reason is not null then return null; end if;
 if not exists(select 1 from auth.users u join public.profiles p on p.id=u.id
  where u.id=v_user and p.role='student' and u.email=n.recipient and u.email_confirmed_at is not null
  and u.deleted_at is null and coalesce(u.raw_app_meta_data->>'retention_exempt','false')<>'true') then return null; end if;
 if n.state<>'deleting' then
  if n.state<>'delivered' or n.delivered_at is null or n.delete_after is null or n.delete_after>now()
    or retention.activity(v_user)>n.anchor or retention.activity(v_user)>now()-interval '24 months' then return null; end if;
 end if;
 if exists(select 1 from storage.objects o where (o.owner=v_user or o.owner_id=v_user::text)
   and (o.bucket_id<>'avatars' or split_part(o.name,'/',1)<>v_user::text)) then
  update retention.notices set hold_reason='shared_or_unexpected_storage',updated_at=now() where id=p_id;
  return null;
 end if;
 update retention.notices set state='deleting',updated_at=now() where id=p_id;
 -- Refresh tokens cannot be used after this point; the Auth API removes the identity.
 delete from auth.sessions where user_id=v_user;
 return jsonb_build_object('user_id',v_user,'avatars',coalesce((select jsonb_agg(name) from
  (select name from storage.objects where bucket_id='avatars' and split_part(name,'/',1)=v_user::text limit 100) o),'[]'::jsonb));
end;
$function$
;
CREATE OR REPLACE FUNCTION retention.cleanup_social_references()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 delete from public.notifications n where n.data->>'requester_id'=old.id::text
  or n.data->>'friendship_id' in
   (select f.id::text from public.friendships f where f.requester_id=old.id or f.addressee_id=old.id)
  or n.data->>'challenge_id' in
   (select c.id::text from public.challenges c where c.challenger_id=old.id or c.challenged_id=old.id)
  or n.data->>'curriculum_challenge_id' in
   (select c.id::text from public.curriculum_friend_challenges c where c.challenger_id=old.id or c.challenged_id=old.id);
 return old;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.retention_worker_start_v1(p_token text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_key text; v_from text; v_lease uuid:=gen_random_uuid();
begin
 if p_token is null or length(p_token)<>72 then return null; end if;
 delete from retention.invocations where token_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex') and expires_at>now();
 if not found then return null; end if;
 update retention.worker set lease=v_lease,lease_until=now()+interval '10 minutes',last_run_at=now()
 where id and (lease_until is null or lease_until<now());
 if not found then return jsonb_build_object('busy',true); end if;
 select decrypted_secret into v_key from vault.decrypted_secrets
 where name in ('leryko_retention_resend_api_key','resend_api_key')
 order by (name='leryko_retention_resend_api_key') desc limit 1;
 select decrypted_secret into v_from from vault.decrypted_secrets
 where name in ('leryko_retention_from','kineo_inactivity_from')
 order by (name='leryko_retention_from') desc limit 1;
 return jsonb_build_object('lease',v_lease,'resend_key',v_key,'sender',v_from,
  'configured',coalesce(v_key,'')<>'' and coalesce(v_from,'')<>'');
end;
$function$
;
CREATE OR REPLACE FUNCTION "retention"."invoke_worker"() RETURNS bigint LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $staging$ BEGIN RAISE EXCEPTION 'External delivery disabled in staging'; END; $staging$;;
CREATE OR REPLACE FUNCTION public.refresh_security_health_status_v1()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_payload jsonb; v_checks jsonb; v_count integer;
begin
 select jsonb_build_object(
  'anon_security_definer_executable',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and has_function_privilege('anon',p.oid,'execute')),
  'unpinned_security_definer_search_path',(select count(*) from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.prosecdef and not exists(select 1 from unnest(p.proconfig) x where x like 'search_path=%')),
  'client_truncate_grants',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in ('r','p') and (has_table_privilege('anon',c.oid,'truncate') or has_table_privilege('authenticated',c.oid,'truncate'))),
  'public_tables_without_rls',(select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind in ('r','p') and not c.relrowsecurity),
  'public_course_bucket',(select count(*) from storage.buckets where id='documents' and public)
 ) into v_checks;
 select sum(value::integer) into v_count from jsonb_each_text(v_checks);
 v_payload:=jsonb_build_object('ok',v_count=0,'critical_count',v_count,'checks',v_checks,'generated_at',now());
 insert into public.security_health_status(id,payload,checked_at) values(1,v_payload,now())
 on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;
 return v_payload;
end; $function$
;
CREATE OR REPLACE FUNCTION app_security.limit_client_writes()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_window timestamptz; v_count integer;
 v_seconds integer:=tg_argv[0]::integer; v_limit integer:=tg_argv[1]::integer;
begin
 if v_uid is null then return new; end if;
 if not exists(select 1 from public.profiles where id=v_uid) then
  raise exception 'Compte indisponible' using errcode='42501';
 end if;
 v_window:=to_timestamp(floor(extract(epoch from statement_timestamp())/v_seconds)*v_seconds);
 insert into app_security.request_windows as w(user_id,action,window_start,requests)
 values(v_uid,tg_table_name,v_window,1)
 on conflict(user_id,action,window_start) do update set requests=w.requests+1
 returning requests into v_count;
 if v_count>v_limit then raise exception 'Trop de demandes. Réessaie dans quelques instants.' using errcode='P0001'; end if;
 return new;
end; $function$
;
CREATE OR REPLACE FUNCTION app_security.refresh_operations_health()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_checks jsonb; v_count integer; v_payload jsonb;
begin
 select jsonb_build_object(
 'retention_worker_stale',case when exists(select 1 from retention.worker where last_run_at>now()-interval '30 hours') then 0 else 1 end,
 'retention_worker_errors',coalesce((select (last_result->>'errors')::integer from retention.worker),0),
 'recent_cron_failures',(select count(*) from cron.job_run_details where start_time>now()-interval '1 hour' and status='failed'),
 'missing_course_objects',(select count(*) from public.course_documents d where d.storage_path like 'courses/local-courses-2026-10/%' and not exists(select 1 from storage.objects o where o.bucket_id='documents' and o.name=d.storage_path))
 ) into v_checks;
 select sum(value::integer) into v_count from jsonb_each_text(v_checks);
 v_payload:=jsonb_build_object('ok',v_count=0,'critical_count',v_count,'checks',v_checks,
  'retention_email_configured',coalesce((select (last_result->>'configured')::boolean from retention.worker),false),'generated_at',now());
 insert into app_security.operations_health_status(id,payload,checked_at) values(1,v_payload,now())
 on conflict(id) do update set payload=excluded.payload,checked_at=excluded.checked_at;
 return v_payload;
end; $function$
;
CREATE OR REPLACE FUNCTION public.check_operations_health_v1()
 RETURNS boolean
 LANGUAGE sql
 SET search_path TO ''
AS $function$
 select coalesce((select (payload->>'ok')::boolean and checked_at>now()-interval '90 minutes'
 from app_security.operations_health_status where id=1),false)
$function$
;
CREATE OR REPLACE FUNCTION public.get_curriculum_daily_challenge_v1(p_program_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid();
  v_row public.curriculum_daily_challenge_attempts%rowtype;
  v_ids uuid[];
  v_questions jsonb;
  v_level_id uuid;
  v_version text;
  v_scope_count integer:=0;
begin
  if v_uid is null then raise exception 'Utilisateur non authentifié'; end if;

  select pp.academic_level_id,coalesce(pp.curriculum_version,'default')
    into v_level_id,v_version
  from public.profile_programs pp
  where pp.user_id=v_uid and pp.program_id=p_program_id
  order by pp.is_primary desc
  limit 1;

  if v_level_id is null then
    raise exception 'Niveau de cursus non configuré';
  end if;

  select * into v_row
  from public.curriculum_daily_challenge_attempts
  where user_id=v_uid and program_id=p_program_id and challenge_date=current_date;

  if v_row.id is not null and v_row.completed_at is null then
    select count(*) into v_scope_count
    from unnest(v_row.question_ids) x(question_id)
    join public.curriculum_quiz_questions q on q.id=x.question_id
    join public.curriculum_topics t on t.id=q.topic_id
    join public.curriculum_units u on u.id=t.unit_id
    where u.program_id=p_program_id
      and u.academic_level_id=v_level_id
      and coalesce(u.curriculum_version,'default')=v_version
      and u.is_active=true and t.is_active=true
      and q.is_published=true and q.validation_status='source_validated'
      and q.question_type='mcq';

    if v_scope_count<>coalesce(array_length(v_row.question_ids,1),0) then
      delete from public.curriculum_daily_challenge_attempts where id=v_row.id;
      v_row:=null;
    end if;
  end if;

  if v_row.id is null then
    select array_agg(id) into v_ids from (
      select q.id
      from public.curriculum_quiz_questions q
      join public.curriculum_topics t on t.id=q.topic_id
      join public.curriculum_units u on u.id=t.unit_id
      where u.program_id=p_program_id
        and u.academic_level_id=v_level_id
        and coalesce(u.curriculum_version,'default')=v_version
        and u.is_active=true and t.is_active=true
        and q.is_published=true and q.validation_status='source_validated'
        and q.question_type='mcq'
        and exists(select 1 from jsonb_array_elements(coalesce(q.options,'[]'::jsonb)) o where coalesce((o->>'correct')::boolean,false)=true)
      order by random()
      limit 5
    ) s;
    if coalesce(array_length(v_ids,1),0)<5 then raise exception 'Pas assez de QCM validés pour le challenge du jour dans ce niveau'; end if;
    insert into public.curriculum_daily_challenge_attempts(user_id,program_id,question_ids,total_questions)
    values(v_uid,p_program_id,v_ids,5)
    returning * into v_row;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id',q.id,
    'question_text',q.question_text,
    'options',(select jsonb_agg(jsonb_build_object('text',o->>'text')) from jsonb_array_elements(q.options) o),
    'explanation',case when v_row.completed_at is not null then q.explanation else null end,
    'display_order',s.ord
  ) order by s.ord),'[]'::jsonb)
  into v_questions
  from unnest(v_row.question_ids) with ordinality s(id,ord)
  join public.curriculum_quiz_questions q on q.id=s.id;

  return jsonb_build_object(
    'id',v_row.id,
    'completed',v_row.completed_at is not null,
    'correct_count',v_row.correct_count,
    'total_questions',v_row.total_questions,
    'questions',v_questions,
    'academic_level_id',v_level_id,
    'curriculum_version',v_version
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION public.require_current_profile_v1()
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
 if current_user='authenticated' and not exists(select 1 from public.profiles p where p.id=(select auth.uid())) then
  raise exception 'Compte indisponible' using errcode='42501';
 end if;
end; $function$
;
CREATE VIEW "public"."curriculum_quiz_readiness_v1" WITH (security_invoker=true) AS  SELECT p.id AS program_id,
    a.code AS level_code,
    t.id AS topic_id,
    t.name AS topic_name,
    count(q.id) FILTER (WHERE q.is_published AND q.validation_status = 'source_validated'::text)::integer AS question_count,
    GREATEST(10 - count(q.id) FILTER (WHERE q.is_published AND q.validation_status = 'source_validated'::text), 0::bigint)::integer AS missing_to_ready,
    count(q.id) FILTER (WHERE q.is_published AND q.validation_status = 'source_validated'::text) >= 10 AS is_ready
   FROM curriculum_topics t
     JOIN curriculum_units u ON u.id = t.unit_id
     JOIN academic_levels a ON a.id = u.academic_level_id
     JOIN programs p ON p.id = u.program_id
     LEFT JOIN curriculum_quiz_questions q ON q.topic_id = t.id
  WHERE t.is_active AND u.is_active
  GROUP BY p.id, a.code, a.display_order, t.id, t.name;
CREATE VIEW "public"."legacy_subject_quiz_readiness_v1" WITH (security_invoker=true) AS  SELECT y.name AS level_label,
    s.id AS subject_id,
    s.name AS subject_name,
    count(q.id) FILTER (WHERE q.is_published)::integer AS question_count,
    GREATEST(10 - count(q.id) FILTER (WHERE q.is_published), 0::bigint)::integer AS missing_to_ready,
    count(q.id) FILTER (WHERE q.is_published) >= 10 AS is_ready
   FROM subjects s
     JOIN years y ON y.id = s.year_id
     LEFT JOIN chapters c ON c.subject_id = s.id
     LEFT JOIN questions q ON q.chapter_id = c.id
  WHERE y.number >= 2 AND y.number <= 4
  GROUP BY y.number, y.name, s.id, s.name;
CREATE VIEW "kineo_internal"."inactivity_reminder_candidates" AS  SELECT u.id AS user_id,
    u.email,
    p.username,
    GREATEST(COALESCE(p.last_seen_at, '1970-01-01 00:00:00+00'::timestamp with time zone), COALESCE(p.last_app_open_at, '1970-01-01 00:00:00+00'::timestamp with time zone), COALESCE(u.last_sign_in_at, '1970-01-01 00:00:00+00'::timestamp with time zone)) AS last_activity,
    COALESCE(( SELECT max(l.queued_at) AS max
           FROM inactivity_email_log l
          WHERE l.user_id = u.id AND (l.status = ANY (ARRAY['queued'::text, 'sent'::text, 'delivered'::text]))), '1970-01-01 00:00:00+00'::timestamp with time zone) AS last_reminder
   FROM auth.users u
     JOIN profiles p ON p.id = u.id
     JOIN inactivity_email_preferences pref ON pref.user_id = u.id
  WHERE pref.opted_in = true AND pref.opted_out_at IS NULL AND u.email IS NOT NULL AND u.email::text !~~* 'kineo-e2e%'::text AND GREATEST(COALESCE(p.last_seen_at, '1970-01-01 00:00:00+00'::timestamp with time zone), COALESCE(p.last_app_open_at, '1970-01-01 00:00:00+00'::timestamp with time zone), COALESCE(u.last_sign_in_at, '1970-01-01 00:00:00+00'::timestamp with time zone)) < (now() - '48:00:00'::interval) AND NOT (EXISTS ( SELECT 1
           FROM inactivity_email_log l
          WHERE l.user_id = u.id AND l.queued_at > (now() - '7 days'::interval) AND (l.status = ANY (ARRAY['queued'::text, 'sent'::text, 'delivered'::text]))));
CREATE VIEW "public"."kineo_attempt_audit_all_v1" WITH (security_invoker=true) AS  SELECT 'kineo-fr'::text AS program_id,
    a.id AS attempt_id,
    a.user_id,
    a.question_id,
    q.chapter_id AS scope_id,
    a.session_id,
    a.is_correct,
    a.xp_earned,
    a.created_at,
    a.response_time_ms,
    'question_attempts'::text AS source_table
   FROM question_attempts a
     LEFT JOIN questions q ON q.id = a.question_id
UNION ALL
 SELECT u.program_id,
    a.id AS attempt_id,
    a.user_id,
    a.question_id,
    a.topic_id AS scope_id,
    NULL::uuid AS session_id,
    a.is_correct,
    a.xp_earned,
    a.created_at,
    NULL::integer AS response_time_ms,
    'curriculum_question_attempts'::text AS source_table
   FROM curriculum_question_attempts a
     JOIN curriculum_topics t ON t.id = a.topic_id
     JOIN curriculum_units u ON u.id = t.unit_id;
CREATE VIEW "public"."kineo_question_audit_all_v1" WITH (security_invoker=true) AS  SELECT 'kineo-fr'::text AS program_id,
    q.id AS question_id,
    q.lesson_id,
    q.chapter_id AS scope_id,
    q.type AS question_type,
    q.question_text,
    q.explanation,
    q.is_published,
    q.validation_status,
    q.image_url,
    q.created_at,
    q.updated_at,
    'questions'::text AS source_table
   FROM questions q
UNION ALL
 SELECT u.program_id,
    q.id AS question_id,
    NULL::uuid AS lesson_id,
    q.topic_id AS scope_id,
    q.question_type,
    q.question_text,
    q.explanation,
    q.is_published,
    q.validation_status,
    q.image_url,
    q.created_at,
    q.updated_at,
    'curriculum_quiz_questions'::text AS source_table
   FROM curriculum_quiz_questions q
     JOIN curriculum_topics t ON t.id = q.topic_id
     JOIN curriculum_units u ON u.id = t.unit_id;
CREATE VIEW "public"."kineo_program_audit_summary_v1" WITH (security_invoker=true) AS  SELECT program_id,
    count(*) AS total_questions,
    count(*) FILTER (WHERE is_published) AS published_questions,
    count(*) FILTER (WHERE is_published AND (explanation IS NULL OR length(TRIM(BOTH FROM explanation)) < 20)) AS weak_explanations,
    ( SELECT count(*) AS count
           FROM kineo_attempt_audit_all_v1 a
          WHERE a.program_id = q.program_id) AS attempts,
    ( SELECT count(*) AS count
           FROM kineo_attempt_audit_all_v1 a
          WHERE a.program_id = q.program_id AND a.is_correct) AS correct_attempts
   FROM kineo_question_audit_all_v1 q
  GROUP BY program_id;
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER lessons_updated_at BEFORE UPDATE ON lessons FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER questions_updated_at BEFORE UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER notes_updated_at BEFORE UPDATE ON user_notes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER friendships_updated_at BEFORE UPDATE ON friendships FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER streak_updated_at BEFORE UPDATE ON user_streaks FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
CREATE TRIGGER protect_profile_data BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION protect_profile_data();
CREATE TRIGGER update_course_documents_updated_at BEFORE UPDATE ON course_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER enforce_question_publish_quality_trigger BEFORE INSERT OR UPDATE ON questions FOR EACH ROW EXECUTE FUNCTION enforce_question_publish_quality();
CREATE TRIGGER protect_published_question_options_trigger BEFORE INSERT OR DELETE OR UPDATE ON question_options FOR EACH ROW EXECUTE FUNCTION protect_published_question_options();
CREATE TRIGGER protect_published_question_sources_trigger BEFORE DELETE OR UPDATE ON question_sources FOR EACH ROW EXECUTE FUNCTION protect_published_question_sources();
CREATE TRIGGER trg_notify_badge_earned_v1 AFTER INSERT ON user_badges FOR EACH ROW EXECUTE FUNCTION notify_badge_earned_v1();
CREATE TRIGGER trg_notify_streak_milestone_v1 AFTER INSERT OR UPDATE OF current_streak ON user_streaks FOR EACH ROW EXECUTE FUNCTION notify_streak_milestone_v1();
CREATE TRIGGER trg_notify_level_up_v1 AFTER UPDATE OF level ON profiles FOR EACH ROW EXECUTE FUNCTION notify_level_up_v1();
CREATE TRIGGER trg_lock_student_curriculum_assignment BEFORE INSERT OR UPDATE ON profile_programs FOR EACH ROW EXECUTE FUNCTION lock_student_curriculum_assignment();
CREATE TRIGGER retention_profile_activity BEFORE UPDATE OF last_seen_at, role ON profiles FOR EACH ROW EXECUTE FUNCTION retention.cancel_on_activity();
CREATE TRIGGER retention_auth_activity BEFORE UPDATE OF last_sign_in_at, email ON auth.users FOR EACH ROW EXECUTE FUNCTION retention.cancel_on_auth_activity();
CREATE TRIGGER retention_social_cleanup BEFORE DELETE ON profiles FOR EACH ROW EXECUTE FUNCTION retention.cleanup_social_references();
CREATE TRIGGER limit_revision_sessions BEFORE INSERT ON revision_sessions FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('60', '20');
CREATE TRIGGER limit_friend_requests BEFORE INSERT ON friendships FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('3600', '30');
CREATE TRIGGER limit_feedback BEFORE INSERT ON feedback FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('3600', '30');
CREATE TRIGGER limit_client_errors BEFORE INSERT ON client_error_logs FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('3600', '20');
CREATE TRIGGER limit_notes BEFORE INSERT OR UPDATE ON user_notes FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('60', '60');
CREATE TRIGGER limit_curriculum_answers BEFORE INSERT ON curriculum_question_attempts FOR EACH ROW EXECUTE FUNCTION app_security.limit_client_writes('60', '240');
CREATE TRIGGER retention_storage_guard BEFORE INSERT OR UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION retention.guard_storage();
CREATE TRIGGER retention_session_activity BEFORE INSERT OR UPDATE OF refreshed_at ON auth.sessions FOR EACH ROW EXECUTE FUNCTION retention.cancel_on_session_activity();
CREATE POLICY "years_read" ON "public"."years" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "subjects_read" ON "public"."subjects" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "chapters_read" ON "public"."chapters" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "lessons_read" ON "public"."lessons" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_published = true));
CREATE POLICY "questions_read" ON "public"."questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_published = true));
CREATE POLICY "question_options_read" ON "public"."question_options" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM questions q
  WHERE ((q.id = question_options.question_id) AND (q.is_published = true)))));
CREATE POLICY "exams_read" ON "public"."exams" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_published = true));
CREATE POLICY "exam_questions_read" ON "public"."exam_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM exams e
  WHERE ((e.id = exam_questions.exam_id) AND (e.is_published = true)))));
CREATE POLICY "daily_challenges_read" ON "public"."daily_challenges" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "daily_challenge_questions_read" ON "public"."daily_challenge_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM daily_challenges d
  WHERE ((d.id = daily_challenge_questions.challenge_id) AND (d.is_active = true)))));
CREATE POLICY "levels_read" ON "public"."levels" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "badges_read" ON "public"."badges" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "Authenticated users can view validated documents" ON "public"."course_documents" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((validation_status = 'validated'::text));
CREATE POLICY "Authenticated users can view published lesson sources" ON "public"."lesson_sources" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM lessons l
  WHERE ((l.id = lesson_sources.lesson_id) AND (l.is_published = true)))));
CREATE POLICY "Authenticated users can view published question sources" ON "public"."question_sources" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM questions q
  WHERE ((q.id = question_sources.question_id) AND (q.is_published = true)))));
CREATE POLICY "Authenticated users can read validated documents" ON "storage"."objects" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((bucket_id = 'documents'::text) AND (EXISTS ( SELECT 1
   FROM course_documents cd
  WHERE ((cd.storage_path = objects.name) AND (cd.validation_status = 'validated'::text))))));
CREATE POLICY "Authenticated users can read course images" ON "storage"."objects" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((bucket_id = ANY (ARRAY['course-images'::text, 'anatomy-images'::text])));
CREATE POLICY "Users can upload own avatar" ON "storage"."objects" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));
CREATE POLICY "Users can update own avatar" ON "storage"."objects" AS PERMISSIVE FOR UPDATE TO "authenticated" USING (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text))) WITH CHECK (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));
CREATE POLICY "Users can delete own avatar" ON "storage"."objects" AS PERMISSIVE FOR DELETE TO "authenticated" USING (((bucket_id = 'avatars'::text) AND ((storage.foldername(name))[1] = (auth.uid())::text)));
CREATE POLICY "favorites_select_own" ON "public"."favorites" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "favorites_insert_own" ON "public"."favorites" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "favorites_update_own" ON "public"."favorites" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "favorites_delete_own" ON "public"."favorites" AS PERMISSIVE FOR DELETE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "user_notes_select_own" ON "public"."user_notes" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "user_notes_insert_own" ON "public"."user_notes" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "user_notes_update_own" ON "public"."user_notes" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "user_notes_delete_own" ON "public"."user_notes" AS PERMISSIVE FOR DELETE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "notifications_select_own" ON "public"."notifications" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "notifications_update_own" ON "public"."notifications" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "friendships_select_participant" ON "public"."friendships" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((( SELECT auth.uid() AS uid) = requester_id) OR (( SELECT auth.uid() AS uid) = addressee_id)));
CREATE POLICY "friendships_insert_requester" ON "public"."friendships" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK (((( SELECT auth.uid() AS uid) = requester_id) AND (requester_id <> addressee_id) AND (status = 'pending'::text)));
CREATE POLICY "challenges_select_participant" ON "public"."challenges" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((( SELECT auth.uid() AS uid) = challenger_id) OR (( SELECT auth.uid() AS uid) = challenged_id)));
CREATE POLICY "challenges_insert_challenger" ON "public"."challenges" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK (((( SELECT auth.uid() AS uid) = challenger_id) AND (challenger_id <> challenged_id) AND (status = 'pending'::text) AND (challenger_score IS NULL) AND (challenged_score IS NULL)));
CREATE POLICY "challenge_questions_select_participant" ON "public"."challenge_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM challenges c
  WHERE ((c.id = challenge_questions.challenge_id) AND ((( SELECT auth.uid() AS uid) = c.challenger_id) OR (( SELECT auth.uid() AS uid) = c.challenged_id))))));
CREATE POLICY "daily_challenge_attempts_own" ON "public"."daily_challenge_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "exam_attempts_own" ON "public"."exam_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "profile_select_own" ON "public"."profiles" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = id));
CREATE POLICY "profile_update_own" ON "public"."profiles" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = id)) WITH CHECK ((( SELECT auth.uid() AS uid) = id));
CREATE POLICY "question_attempts_own" ON "public"."question_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "revision_sessions_own" ON "public"."revision_sessions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "mastery_own" ON "public"."user_question_mastery" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "user_badges_own" ON "public"."user_badges" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "streak_own" ON "public"."user_streaks" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "Users can view own session questions" ON "public"."revision_session_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM revision_sessions rs
  WHERE ((rs.id = revision_session_questions.session_id) AND (rs.user_id = ( SELECT auth.uid() AS uid))))));
CREATE POLICY "atlas_attempts_select_own" ON "public"."atlas_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY "programs_authenticated_read" ON "public"."programs" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "academic_levels_authenticated_read" ON "public"."academic_levels" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((is_active = true));
CREATE POLICY "profile_programs_read_own" ON "public"."profile_programs" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "profile_programs_insert_own" ON "public"."profile_programs" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "profile_programs_update_own" ON "public"."profile_programs" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "anatomy_visual_assets_authenticated_read" ON "public"."anatomy_visual_assets" AS PERMISSIVE FOR SELECT TO "authenticated" USING (true);
CREATE POLICY "authenticated_read_visual_asset_bundle" ON "public"."visual_asset_bundle_chunks" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((bundle_id = 'ifmk_lower_limb_v1'::text));
CREATE POLICY "curriculum_topics_active_assignment_read" ON "public"."curriculum_topics" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((is_active = true) AND (EXISTS ( SELECT 1
   FROM curriculum_units u
  WHERE (u.id = curriculum_topics.unit_id)))));
CREATE POLICY "curriculum_lessons_active_assignment_read" ON "public"."curriculum_lessons" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((is_published = true) AND (EXISTS ( SELECT 1
   FROM curriculum_topics t
  WHERE (t.id = curriculum_lessons.topic_id)))));
CREATE POLICY "curriculum_quiz_active_assignment_read" ON "public"."curriculum_quiz_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((is_published = true) AND (validation_status = 'source_validated'::text) AND (EXISTS ( SELECT 1
   FROM curriculum_topics t
  WHERE (t.id = curriculum_quiz_questions.topic_id)))));
CREATE POLICY "curriculum_daily_own_read" ON "public"."curriculum_daily_challenge_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY "curriculum_friend_answers_own_read" ON "public"."curriculum_friend_challenge_answers" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY "curriculum_friend_questions_participant_read" ON "public"."curriculum_friend_challenge_questions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM curriculum_friend_challenges c
  WHERE ((c.id = curriculum_friend_challenge_questions.challenge_id) AND ((c.challenger_id = ( SELECT auth.uid() AS uid)) OR (c.challenged_id = ( SELECT auth.uid() AS uid)))))));
CREATE POLICY "curriculum_friend_participant_read" ON "public"."curriculum_friend_challenges" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((challenger_id = ( SELECT auth.uid() AS uid)) OR (challenged_id = ( SELECT auth.uid() AS uid))));
CREATE POLICY "curriculum_attempts_own_read" ON "public"."curriculum_question_attempts" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY "curriculum_completions_own_read" ON "public"."curriculum_topic_completions" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((user_id = ( SELECT auth.uid() AS uid)));
CREATE POLICY "release_health_public_read" ON "public"."release_health_status" AS PERMISSIVE FOR SELECT TO "anon", "authenticated" USING ((id = 1));
CREATE POLICY "security_health_public_read" ON "public"."security_health_status" AS PERMISSIVE FOR SELECT TO "anon", "authenticated" USING ((id = 1));
CREATE POLICY "curriculum_units_active_assignment_read" ON "public"."curriculum_units" AS PERMISSIVE FOR SELECT TO "authenticated" USING (((is_active = true) AND ((EXISTS ( SELECT 1
   FROM profiles p
  WHERE ((p.id = ( SELECT auth.uid() AS uid)) AND (p.role = 'admin'::text)))) OR (EXISTS ( SELECT 1
   FROM ((profile_programs pp
     JOIN academic_levels assigned_level ON ((assigned_level.id = pp.academic_level_id)))
     JOIN academic_levels target_level ON ((target_level.id = curriculum_units.academic_level_id)))
  WHERE ((pp.user_id = ( SELECT auth.uid() AS uid)) AND (pp.program_id = curriculum_units.program_id) AND (assigned_level.program_id = curriculum_units.program_id) AND (target_level.program_id = curriculum_units.program_id) AND (target_level.display_order <= assigned_level.display_order) AND ((curriculum_units.program_id <> 'ifsi-fr'::text) OR (COALESCE(pp.curriculum_version, '2009'::text) = COALESCE(curriculum_units.curriculum_version, '2009'::text)))))))));
CREATE POLICY "business_health_public_read" ON "public"."business_health_status" AS PERMISSIVE FOR SELECT TO "anon", "authenticated" USING ((id = 1));
CREATE POLICY "authenticated_contract_public_read" ON "public"."authenticated_contract_status" AS PERMISSIVE FOR SELECT TO "anon", "authenticated" USING ((id = 1));
CREATE POLICY "weekly_friend_preferences_read" ON "public"."weekly_friend_email_preferences" AS PERMISSIVE FOR SELECT TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "weekly_friend_preferences_insert" ON "public"."weekly_friend_email_preferences" AS PERMISSIVE FOR INSERT TO "authenticated" WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "weekly_friend_preferences_update" ON "public"."weekly_friend_email_preferences" AS PERMISSIVE FOR UPDATE TO "authenticated" USING ((( SELECT auth.uid() AS uid) = user_id)) WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));
CREATE POLICY "storage_requires_current_profile" ON "storage"."objects" AS RESTRICTIVE FOR ALL TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM profiles p
  WHERE (p.id = ( SELECT auth.uid() AS uid))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM profiles p
  WHERE (p.id = ( SELECT auth.uid() AS uid)))));
REVOKE ALL ON ALL TABLES IN SCHEMA "public" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA "public" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL TABLES IN SCHEMA "private" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA "private" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL TABLES IN SCHEMA "app_security" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA "app_security" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL TABLES IN SCHEMA "kineo_internal" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA "kineo_internal" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL TABLES IN SCHEMA "retention" FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA "retention" FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA "public" TO PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT USAGE ON SCHEMA "app_security" TO "service_role";
GRANT INSERT ON TABLE "public"."feedback" TO "service_role";
GRANT SELECT ON TABLE "public"."feedback" TO "service_role";
GRANT UPDATE ON TABLE "public"."feedback" TO "service_role";
GRANT DELETE ON TABLE "public"."feedback" TO "service_role";
GRANT INSERT ON TABLE "public"."curriculum_quiz_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_quiz_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_quiz_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_quiz_questions" TO "service_role";
GRANT INSERT ON TABLE "public"."user_notes" TO "authenticated";
GRANT SELECT ON TABLE "public"."user_notes" TO "authenticated";
GRANT UPDATE ON TABLE "public"."user_notes" TO "authenticated";
GRANT DELETE ON TABLE "public"."user_notes" TO "authenticated";
GRANT INSERT ON TABLE "public"."user_notes" TO "service_role";
GRANT SELECT ON TABLE "public"."user_notes" TO "service_role";
GRANT UPDATE ON TABLE "public"."user_notes" TO "service_role";
GRANT DELETE ON TABLE "public"."user_notes" TO "service_role";
GRANT INSERT ON TABLE "public"."friendships" TO "authenticated";
GRANT SELECT ON TABLE "public"."friendships" TO "authenticated";
GRANT INSERT ON TABLE "public"."friendships" TO "service_role";
GRANT SELECT ON TABLE "public"."friendships" TO "service_role";
GRANT UPDATE ON TABLE "public"."friendships" TO "service_role";
GRANT DELETE ON TABLE "public"."friendships" TO "service_role";
GRANT INSERT ON TABLE "public"."challenges" TO "authenticated";
GRANT SELECT ON TABLE "public"."challenges" TO "authenticated";
GRANT INSERT ON TABLE "public"."challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."challenges" TO "service_role";
GRANT UPDATE ON TABLE "public"."challenges" TO "service_role";
GRANT DELETE ON TABLE "public"."challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."programs" TO "authenticated";
GRANT INSERT ON TABLE "public"."programs" TO "service_role";
GRANT SELECT ON TABLE "public"."programs" TO "service_role";
GRANT UPDATE ON TABLE "public"."programs" TO "service_role";
GRANT DELETE ON TABLE "public"."programs" TO "service_role";
GRANT SELECT ON TABLE "public"."academic_levels" TO "authenticated";
GRANT INSERT ON TABLE "public"."academic_levels" TO "service_role";
GRANT SELECT ON TABLE "public"."academic_levels" TO "service_role";
GRANT UPDATE ON TABLE "public"."academic_levels" TO "service_role";
GRANT DELETE ON TABLE "public"."academic_levels" TO "service_role";
GRANT SELECT ON TABLE "public"."challenge_questions" TO "authenticated";
GRANT INSERT ON TABLE "public"."challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."challenge_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."challenge_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."notifications" TO "authenticated";
GRANT UPDATE ON TABLE "public"."notifications" TO "authenticated";
GRANT INSERT ON TABLE "public"."notifications" TO "service_role";
GRANT SELECT ON TABLE "public"."notifications" TO "service_role";
GRANT UPDATE ON TABLE "public"."notifications" TO "service_role";
GRANT DELETE ON TABLE "public"."notifications" TO "service_role";
GRANT SELECT ON TABLE "public"."course_documents" TO "authenticated";
GRANT INSERT ON TABLE "public"."course_documents" TO "service_role";
GRANT SELECT ON TABLE "public"."course_documents" TO "service_role";
GRANT UPDATE ON TABLE "public"."course_documents" TO "service_role";
GRANT DELETE ON TABLE "public"."course_documents" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_topics" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_topics" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_topics" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_topics" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_topics" TO "service_role";
GRANT INSERT ON TABLE "public"."profile_programs" TO "authenticated";
GRANT SELECT ON TABLE "public"."profile_programs" TO "authenticated";
GRANT UPDATE ON TABLE "public"."profile_programs" TO "authenticated";
GRANT INSERT ON TABLE "public"."profile_programs" TO "service_role";
GRANT SELECT ON TABLE "public"."profile_programs" TO "service_role";
GRANT UPDATE ON TABLE "public"."profile_programs" TO "service_role";
GRANT DELETE ON TABLE "public"."profile_programs" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_units" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_units" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_units" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_units" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_units" TO "service_role";
GRANT INSERT ON TABLE "public"."inactivity_email_log" TO "service_role";
GRANT SELECT ON TABLE "public"."inactivity_email_log" TO "service_role";
GRANT UPDATE ON TABLE "public"."inactivity_email_log" TO "service_role";
GRANT DELETE ON TABLE "public"."inactivity_email_log" TO "service_role";
GRANT INSERT ON TABLE "public"."client_error_logs" TO "service_role";
GRANT SELECT ON TABLE "public"."client_error_logs" TO "service_role";
GRANT UPDATE ON TABLE "public"."client_error_logs" TO "service_role";
GRANT DELETE ON TABLE "public"."client_error_logs" TO "service_role";
GRANT INSERT ON TABLE "public"."visual_reviewers" TO "service_role";
GRANT SELECT ON TABLE "public"."visual_reviewers" TO "service_role";
GRANT UPDATE ON TABLE "public"."visual_reviewers" TO "service_role";
GRANT DELETE ON TABLE "public"."visual_reviewers" TO "service_role";
GRANT SELECT ON TABLE "public"."anatomy_visual_assets" TO "authenticated";
GRANT INSERT ON TABLE "public"."anatomy_visual_assets" TO "service_role";
GRANT SELECT ON TABLE "public"."anatomy_visual_assets" TO "service_role";
GRANT UPDATE ON TABLE "public"."anatomy_visual_assets" TO "service_role";
GRANT DELETE ON TABLE "public"."anatomy_visual_assets" TO "service_role";
GRANT SELECT ON TABLE "public"."subjects" TO "authenticated";
GRANT INSERT ON TABLE "public"."subjects" TO "service_role";
GRANT SELECT ON TABLE "public"."subjects" TO "service_role";
GRANT UPDATE ON TABLE "public"."subjects" TO "service_role";
GRANT DELETE ON TABLE "public"."subjects" TO "service_role";
GRANT SELECT ON TABLE "public"."years" TO "authenticated";
GRANT INSERT ON TABLE "public"."years" TO "service_role";
GRANT SELECT ON TABLE "public"."years" TO "service_role";
GRANT UPDATE ON TABLE "public"."years" TO "service_role";
GRANT DELETE ON TABLE "public"."years" TO "service_role";
GRANT SELECT ON TABLE "public"."visual_asset_bundle_chunks" TO "authenticated";
GRANT INSERT ON TABLE "public"."visual_asset_bundle_chunks" TO "service_role";
GRANT SELECT ON TABLE "public"."visual_asset_bundle_chunks" TO "service_role";
GRANT UPDATE ON TABLE "public"."visual_asset_bundle_chunks" TO "service_role";
GRANT DELETE ON TABLE "public"."visual_asset_bundle_chunks" TO "service_role";
GRANT SELECT ON TABLE "public"."chapters" TO "authenticated";
GRANT INSERT ON TABLE "public"."chapters" TO "service_role";
GRANT SELECT ON TABLE "public"."chapters" TO "service_role";
GRANT UPDATE ON TABLE "public"."chapters" TO "service_role";
GRANT DELETE ON TABLE "public"."chapters" TO "service_role";
GRANT SELECT ON TABLE "public"."lessons" TO "authenticated";
GRANT INSERT ON TABLE "public"."lessons" TO "service_role";
GRANT SELECT ON TABLE "public"."lessons" TO "service_role";
GRANT UPDATE ON TABLE "public"."lessons" TO "service_role";
GRANT DELETE ON TABLE "public"."lessons" TO "service_role";
GRANT INSERT ON TABLE "public"."questions" TO "service_role";
GRANT SELECT ON TABLE "public"."questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."questions" TO "service_role";
GRANT DELETE ON TABLE "public"."questions" TO "service_role";
GRANT INSERT ON TABLE "public"."question_options" TO "service_role";
GRANT SELECT ON TABLE "public"."question_options" TO "service_role";
GRANT UPDATE ON TABLE "public"."question_options" TO "service_role";
GRANT DELETE ON TABLE "public"."question_options" TO "service_role";
GRANT SELECT ON TABLE "public"."question_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."question_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."question_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."question_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."question_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."revision_sessions" TO "authenticated";
GRANT INSERT ON TABLE "public"."revision_sessions" TO "service_role";
GRANT SELECT ON TABLE "public"."revision_sessions" TO "service_role";
GRANT UPDATE ON TABLE "public"."revision_sessions" TO "service_role";
GRANT DELETE ON TABLE "public"."revision_sessions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_lessons" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_lessons" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_lessons" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_lessons" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_lessons" TO "service_role";
GRANT SELECT ON TABLE "public"."user_question_mastery" TO "authenticated";
GRANT INSERT ON TABLE "public"."user_question_mastery" TO "service_role";
GRANT SELECT ON TABLE "public"."user_question_mastery" TO "service_role";
GRANT UPDATE ON TABLE "public"."user_question_mastery" TO "service_role";
GRANT DELETE ON TABLE "public"."user_question_mastery" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenges" TO "authenticated";
GRANT INSERT ON TABLE "public"."daily_challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenges" TO "service_role";
GRANT UPDATE ON TABLE "public"."daily_challenges" TO "service_role";
GRANT DELETE ON TABLE "public"."daily_challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."exams" TO "authenticated";
GRANT INSERT ON TABLE "public"."exams" TO "service_role";
GRANT SELECT ON TABLE "public"."exams" TO "service_role";
GRANT UPDATE ON TABLE "public"."exams" TO "service_role";
GRANT DELETE ON TABLE "public"."exams" TO "service_role";
GRANT SELECT ON TABLE "public"."exam_questions" TO "authenticated";
GRANT INSERT ON TABLE "public"."exam_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."exam_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."exam_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."exam_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."exam_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."exam_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."exam_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."exam_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."exam_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."user_streaks" TO "authenticated";
GRANT INSERT ON TABLE "public"."user_streaks" TO "service_role";
GRANT SELECT ON TABLE "public"."user_streaks" TO "service_role";
GRANT UPDATE ON TABLE "public"."user_streaks" TO "service_role";
GRANT DELETE ON TABLE "public"."user_streaks" TO "service_role";
GRANT SELECT ON TABLE "public"."levels" TO "authenticated";
GRANT INSERT ON TABLE "public"."levels" TO "service_role";
GRANT SELECT ON TABLE "public"."levels" TO "service_role";
GRANT UPDATE ON TABLE "public"."levels" TO "service_role";
GRANT DELETE ON TABLE "public"."levels" TO "service_role";
GRANT SELECT ON TABLE "public"."badges" TO "authenticated";
GRANT INSERT ON TABLE "public"."badges" TO "service_role";
GRANT SELECT ON TABLE "public"."badges" TO "service_role";
GRANT UPDATE ON TABLE "public"."badges" TO "service_role";
GRANT DELETE ON TABLE "public"."badges" TO "service_role";
GRANT SELECT ON TABLE "public"."user_badges" TO "authenticated";
GRANT INSERT ON TABLE "public"."user_badges" TO "service_role";
GRANT SELECT ON TABLE "public"."user_badges" TO "service_role";
GRANT UPDATE ON TABLE "public"."user_badges" TO "service_role";
GRANT DELETE ON TABLE "public"."user_badges" TO "service_role";
GRANT SELECT ON TABLE "public"."lesson_sources" TO "authenticated";
GRANT INSERT ON TABLE "public"."lesson_sources" TO "service_role";
GRANT SELECT ON TABLE "public"."lesson_sources" TO "service_role";
GRANT UPDATE ON TABLE "public"."lesson_sources" TO "service_role";
GRANT DELETE ON TABLE "public"."lesson_sources" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenge_questions" TO "authenticated";
GRANT INSERT ON TABLE "public"."daily_challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenge_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."daily_challenge_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."daily_challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenge_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."daily_challenge_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."daily_challenge_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."daily_challenge_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."daily_challenge_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."revision_session_questions" TO "authenticated";
GRANT INSERT ON TABLE "public"."revision_session_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."revision_session_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."revision_session_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."revision_session_questions" TO "service_role";
GRANT INSERT ON TABLE "public"."favorites" TO "authenticated";
GRANT SELECT ON TABLE "public"."favorites" TO "authenticated";
GRANT UPDATE ON TABLE "public"."favorites" TO "authenticated";
GRANT DELETE ON TABLE "public"."favorites" TO "authenticated";
GRANT INSERT ON TABLE "public"."favorites" TO "service_role";
GRANT SELECT ON TABLE "public"."favorites" TO "service_role";
GRANT UPDATE ON TABLE "public"."favorites" TO "service_role";
GRANT DELETE ON TABLE "public"."favorites" TO "service_role";
GRANT SELECT ON TABLE "public"."question_sources" TO "authenticated";
GRANT INSERT ON TABLE "public"."question_sources" TO "service_role";
GRANT SELECT ON TABLE "public"."question_sources" TO "service_role";
GRANT UPDATE ON TABLE "public"."question_sources" TO "service_role";
GRANT DELETE ON TABLE "public"."question_sources" TO "service_role";
GRANT SELECT ON TABLE "public"."atlas_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."atlas_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."atlas_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."atlas_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."atlas_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_question_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_question_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_question_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_question_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_question_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_topic_completions" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_topic_completions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_topic_completions" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_topic_completions" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_topic_completions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_daily_challenge_attempts" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_daily_challenge_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_daily_challenge_attempts" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_daily_challenge_attempts" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_daily_challenge_attempts" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenge_questions" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_friend_challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenge_questions" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_friend_challenge_questions" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_friend_challenge_questions" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenge_answers" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_friend_challenge_answers" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenge_answers" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_friend_challenge_answers" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_friend_challenge_answers" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenges" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_friend_challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_friend_challenges" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_friend_challenges" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_friend_challenges" TO "service_role";
GRANT SELECT ON TABLE "public"."profiles" TO "authenticated";
GRANT INSERT ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."profiles" TO "service_role";
GRANT UPDATE ON TABLE "public"."profiles" TO "service_role";
GRANT DELETE ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."authenticated_contract_status" TO "authenticated";
GRANT INSERT ON TABLE "public"."authenticated_contract_status" TO "service_role";
GRANT SELECT ON TABLE "public"."authenticated_contract_status" TO "service_role";
GRANT UPDATE ON TABLE "public"."authenticated_contract_status" TO "service_role";
GRANT DELETE ON TABLE "public"."authenticated_contract_status" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_quiz_readiness_v1" TO "authenticated";
GRANT INSERT ON TABLE "public"."curriculum_quiz_readiness_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."curriculum_quiz_readiness_v1" TO "service_role";
GRANT UPDATE ON TABLE "public"."curriculum_quiz_readiness_v1" TO "service_role";
GRANT DELETE ON TABLE "public"."curriculum_quiz_readiness_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."legacy_subject_quiz_readiness_v1" TO "authenticated";
GRANT INSERT ON TABLE "public"."legacy_subject_quiz_readiness_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."legacy_subject_quiz_readiness_v1" TO "service_role";
GRANT UPDATE ON TABLE "public"."legacy_subject_quiz_readiness_v1" TO "service_role";
GRANT DELETE ON TABLE "public"."legacy_subject_quiz_readiness_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."release_health_status" TO "authenticated";
GRANT INSERT ON TABLE "public"."release_health_status" TO "service_role";
GRANT SELECT ON TABLE "public"."release_health_status" TO "service_role";
GRANT UPDATE ON TABLE "public"."release_health_status" TO "service_role";
GRANT DELETE ON TABLE "public"."release_health_status" TO "service_role";
GRANT SELECT ON TABLE "public"."security_health_status" TO "authenticated";
GRANT INSERT ON TABLE "public"."security_health_status" TO "service_role";
GRANT SELECT ON TABLE "public"."security_health_status" TO "service_role";
GRANT UPDATE ON TABLE "public"."security_health_status" TO "service_role";
GRANT DELETE ON TABLE "public"."security_health_status" TO "service_role";
GRANT SELECT ON TABLE "public"."business_health_status" TO "authenticated";
GRANT INSERT ON TABLE "public"."business_health_status" TO "service_role";
GRANT SELECT ON TABLE "public"."business_health_status" TO "service_role";
GRANT UPDATE ON TABLE "public"."business_health_status" TO "service_role";
GRANT DELETE ON TABLE "public"."business_health_status" TO "service_role";
GRANT INSERT ON TABLE "public"."kineo_program_audit_summary_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."kineo_program_audit_summary_v1" TO "service_role";
GRANT UPDATE ON TABLE "public"."kineo_program_audit_summary_v1" TO "service_role";
GRANT DELETE ON TABLE "public"."kineo_program_audit_summary_v1" TO "service_role";
GRANT INSERT ON TABLE "public"."inactivity_email_preferences" TO "service_role";
GRANT SELECT ON TABLE "public"."inactivity_email_preferences" TO "service_role";
GRANT UPDATE ON TABLE "public"."inactivity_email_preferences" TO "service_role";
GRANT DELETE ON TABLE "public"."inactivity_email_preferences" TO "service_role";
GRANT INSERT ON TABLE "public"."kineo_attempt_audit_all_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."kineo_attempt_audit_all_v1" TO "service_role";
GRANT UPDATE ON TABLE "public"."kineo_attempt_audit_all_v1" TO "service_role";
GRANT DELETE ON TABLE "public"."kineo_attempt_audit_all_v1" TO "service_role";
GRANT INSERT ON TABLE "public"."kineo_question_audit_all_v1" TO "service_role";
GRANT SELECT ON TABLE "public"."kineo_question_audit_all_v1" TO "service_role";
GRANT UPDATE ON TABLE "public"."kineo_question_audit_all_v1" TO "service_role";
GRANT DELETE ON TABLE "public"."kineo_question_audit_all_v1" TO "service_role";
GRANT INSERT ON TABLE "public"."weekly_friend_email_preferences" TO "authenticated";
GRANT SELECT ON TABLE "public"."weekly_friend_email_preferences" TO "authenticated";
GRANT UPDATE ON TABLE "public"."weekly_friend_email_preferences" TO "authenticated";
GRANT INSERT ON TABLE "public"."weekly_friend_email_preferences" TO "service_role";
GRANT SELECT ON TABLE "public"."weekly_friend_email_preferences" TO "service_role";
GRANT UPDATE ON TABLE "public"."weekly_friend_email_preferences" TO "service_role";
GRANT DELETE ON TABLE "public"."weekly_friend_email_preferences" TO "service_role";
GRANT SELECT ON TABLE "app_security"."operations_health_status" TO "service_role";
GRANT UPDATE ("avatar_url") ON TABLE "public"."profiles" TO "authenticated";
GRANT UPDATE ("first_name") ON TABLE "public"."profiles" TO "authenticated";
GRANT UPDATE ("study_year") ON TABLE "public"."profiles" TO "authenticated";
GRANT UPDATE ("username") ON TABLE "public"."profiles" TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."update_updated_at"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."update_updated_at"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."is_admin"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."handle_new_user"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."update_user_progress"(p_user_id uuid, p_xp_earned integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."protect_profile_data"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_quiz_session"(p_user_id uuid, p_mode text, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."check_and_award_badges"(p_user_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_daily_challenge"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_daily_challenge"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."ensure_daily_challenge"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_lesson_progress"(p_lesson_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions_v2"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_lesson_quiz"(p_lesson_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_quiz_session"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_gamification_summary_v2"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_gamification_summary_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_user_dashboard_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision_v2"(p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision_v2"(p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_daily_challenge_v2"(p_challenge_date date) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_daily_challenge_v2"(p_challenge_date date) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_daily_challenge_v2"(p_session_id uuid, p_activity_date date) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."finish_daily_challenge_v2"(p_session_id uuid, p_activity_date date) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_user_stats_v2"(p_days integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."update_user_progress_v2"(p_user_id uuid, p_xp_earned integer, p_activity_date date) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_content_review_status_v1"(p_kind text, p_id uuid, p_status text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_content_review_status_v1"(p_kind text, p_id uuid, p_status text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_atlas_stats_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friendships_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions_v4"(p_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions_v4"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_course_document_v1"(p_document_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_course_document_v1"(p_document_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_my_library_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_my_library_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."notify_level_up_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_v2"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friendships_v3"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_friendships_v3"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_active_revision_session_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_active_revision_session_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_lesson_quiz_v2"(p_lesson_id uuid, p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_lesson_quiz_v2"(p_lesson_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_lesson_v2"(p_lesson_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_lesson_v2"(p_lesson_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_course_documents_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_course_documents_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."publish_lesson_bundle_v1"(p_lesson_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."publish_lesson_bundle_v1"(p_lesson_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision_v3_internal"(p_user_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_revision_session_review_v1"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer_v3"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer_v5"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer_v5"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer_v4"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision_v4_internal"(p_user_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_atlas_session_v1"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision_v5_internal"(p_user_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions_v5"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."search_students_v1"(p_query text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."send_friend_request_v1"(p_addressee uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."send_friend_request_v1"(p_addressee uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."respond_friend_request_v1"(p_friendship_id uuid, p_accept boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."respond_friend_request_v1"(p_friendship_id uuid, p_accept boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."search_students_v2"(p_query text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."search_students_v2"(p_query text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_recent_revision_sessions_v1"(p_limit integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_recent_revision_sessions_v1"(p_limit integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friend_challenges_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."toggle_lesson_favorite_v1"(p_lesson_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."toggle_lesson_favorite_v1"(p_lesson_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."respond_friend_challenge_v1"(p_challenge_id uuid, p_accept boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."respond_friend_challenge_v1"(p_challenge_id uuid, p_accept boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_friend_challenge_v1"(p_challenge_id uuid, p_score integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."finish_friend_challenge_v1"(p_challenge_id uuid, p_score integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_course_library_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_course_library_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."save_lesson_note_v1"(p_lesson_id uuid, p_content text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."save_lesson_note_v1"(p_lesson_id uuid, p_content text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_friend_challenge_session_v1"(p_challenge_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_friend_challenge_session_v1"(p_challenge_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friendships_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_visual_revision_v1"(p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_visual_revision_v1"(p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_lesson_personal_state_v1"(p_lesson_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_lesson_personal_state_v1"(p_lesson_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_revision_session_meta_v1"(p_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_revision_session_meta_v1"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_revision_mode_availability_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_revision_mode_availability_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_mistake_retry_v1"(p_source_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_mistake_retry_v1"(p_source_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_profile_avatar_v1"(p_avatar_url text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_profile_avatar_v1"(p_avatar_url text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."abandon_revision_session_v1"(p_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."abandon_revision_session_v1"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_study_priorities_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_study_priorities_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_subject_revision_v1"(p_subject_id uuid, p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_subject_revision_v1"(p_subject_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."cancel_friend_challenge_v1"(p_challenge_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."cancel_friend_challenge_v1"(p_challenge_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."finish_quiz_session_v2"(p_session_id uuid, p_activity_date date) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."finish_quiz_session_v2"(p_session_id uuid, p_activity_date date) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."lock_student_curriculum_assignment"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."lock_student_curriculum_assignment"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."create_curriculum_friend_challenge_v1"(p_friend_id uuid, p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."create_curriculum_friend_challenge_v1"(p_friend_id uuid, p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_lesson_quiz_v3_internal"(p_user_id uuid, p_lesson_id uuid, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friend_leaderboard_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."search_students_v3"(p_query text, p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."search_students_v3"(p_query text, p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_user_dashboard_v3"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_user_dashboard_v3"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_weak_revision_v1"(p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_weak_revision_v1"(p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_user_stats_v3"(p_days integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_user_stats_v3"(p_days integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_quiz_questions_v3"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_quiz_answer_v2"(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_smart_revision"(p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."remove_friendship_v1"(p_friendship_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."remove_friendship_v1"(p_friendship_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."ensure_daily_challenge_v2"(p_challenge_date date) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_revision_session_review_v2"(p_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_revision_session_review_v2"(p_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_atlas_session_v1"(p_area text, p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."enforce_question_publish_quality"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_feedback_queue_v1"(p_status text, p_limit integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_feedback_queue_v1"(p_status text, p_limit integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_feedback_status_v1"(p_feedback_id uuid, p_status text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_feedback_status_v1"(p_feedback_id uuid, p_status text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_content_quality_summary_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_content_quality_summary_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."protect_published_question_options"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."protect_published_question_sources"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."quiz_text_equivalent_v1"(p_given text, p_expected text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."quiz_text_equivalent_v1"(p_given text, p_expected text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_visual_approval_v1"(p_question_id uuid, p_approved boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_visual_approval_v1"(p_question_id uuid, p_approved boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."normalize_quiz_text_v1"(p_text text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_mock_exam_v1"(p_question_count integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_mock_exam_v1"(p_question_count integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v3"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v3"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."create_friend_challenge_v1"(p_friend_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."create_friend_challenge_v1"(p_friend_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."update_study_profile_v1"(p_first_name text, p_username text, p_study_year integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."update_study_profile_v1"(p_first_name text, p_username text, p_study_year integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."respond_curriculum_friend_challenge_v1"(p_challenge_id uuid, p_accept boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."respond_curriculum_friend_challenge_v1"(p_challenge_id uuid, p_accept boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."cancel_curriculum_friend_challenge_v1"(p_challenge_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."cancel_curriculum_friend_challenge_v1"(p_challenge_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_friend_challenges_v1"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_friend_challenges_v1"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_friend_challenge_answer_v1"(p_challenge_id uuid, p_question_id uuid, p_answer_text text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_friend_challenge_answer_v1"(p_challenge_id uuid, p_question_id uuid, p_answer_text text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_friend_challenge_questions_v1"(p_challenge_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_friend_challenge_questions_v1"(p_challenge_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."normalize_curriculum_answer_v1"(p_value text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."normalize_curriculum_answer_v1"(p_value text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_topic_answer_v2"(p_question_id uuid, p_answer jsonb) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_topic_answer_v2"(p_question_id uuid, p_answer jsonb) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v4"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_content_review_queue_v4"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."touch_user_activity_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."touch_user_activity_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_progress_v1"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_progress_v1"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."notify_badge_earned_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."queue_inactivity_reminders_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_topic_answer_v1"(p_question_id uuid, p_answer_text text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_challenge_availability_v1"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_challenge_availability_v1"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_client_error_logs_v1"(p_limit integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_client_error_logs_v1"(p_limit integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_daily_answer_v1"(p_program_id text, p_question_id uuid, p_answer_text text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_daily_answer_v1"(p_program_id text, p_question_id uuid, p_answer_text text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."report_client_error_v1"(p_message text, p_component_stack text, p_page_path text, p_app_version text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."report_client_error_v1"(p_message text, p_component_stack text, p_page_path text, p_app_version text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."can_review_visuals_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."can_review_visuals_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_visual_review_queue_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_visual_review_queue_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_visual_review_v2"(p_question_id uuid, p_anatomy_ok boolean, p_mobile_ok boolean, p_target_ok boolean, p_source_ok boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_visual_review_v2"(p_question_id uuid, p_anatomy_ok boolean, p_mobile_ok boolean, p_target_ok boolean, p_source_ok boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_visual_target_v1"(p_question_id uuid, p_x numeric, p_y numeric, p_target_index integer, p_radius numeric) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_visual_target_v1"(p_question_id uuid, p_x numeric, p_y numeric, p_target_index integer, p_radius numeric) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."notify_streak_milestone_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_feedback_v1"(p_kind text, p_message text, p_page_path text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_feedback_v1"(p_kind text, p_message text, p_page_path text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_inactivity_email_candidates_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friend_leaderboard_v2"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_friend_leaderboard_v2"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."refresh_release_health_status_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."refresh_business_health_status_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friend_challenges_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."mark_app_open_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."mark_app_open_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."refresh_authenticated_contract_status_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_friend_challenges_v3"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_friend_challenges_v3"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_stats_v1"(p_program_id text, p_days integer) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_stats_v1"(p_program_id text, p_days integer) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_inactivity_reminder_preference_v1"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_inactivity_reminder_preference_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."set_inactivity_reminder_preference_v1"(p_opted_in boolean) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."set_inactivity_reminder_preference_v1"(p_opted_in boolean) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_badges_v2"() TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_badges_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."check_and_award_badges_v2"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."start_revision_session_replay_v1"(p_source_session_id uuid) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."start_revision_session_replay_v1"(p_source_session_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."setup_student_profile_v1"(p_program_id text, p_level_code text, p_first_name text, p_username text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."setup_student_profile_v1"(p_program_id text, p_level_code text, p_first_name text, p_username text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_quiz_questions_v1"(p_topic_ids uuid[]) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_quiz_questions_v1"(p_topic_ids uuid[]) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_topic_answer_v3"(p_question_id uuid, p_answer jsonb) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."submit_curriculum_topic_answer_v3"(p_question_id uuid, p_answer jsonb) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."retention_worker_finish_v1"(p_lease uuid, p_result jsonb) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."retention_jobs_v1"(p_lease uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."retention_notice_result_v1"(p_lease uuid, p_id uuid, p_event text, p_provider_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."retention_claim_delete_v1"(p_lease uuid, p_id uuid) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."retention_worker_start_v1"(p_token text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."refresh_security_health_status_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."check_operations_health_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_daily_challenge_v1"(p_program_id text) TO "authenticated";
GRANT EXECUTE ON FUNCTION "public"."get_curriculum_daily_challenge_v1"(p_program_id text) TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."require_current_profile_v1"() TO "service_role";
GRANT EXECUTE ON FUNCTION "public"."require_current_profile_v1"() TO "authenticated";
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES ('documents','documents',false,52428800,ARRAY['application/pdf']::text[]);
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES ('course-images','course-images',false,10485760,ARRAY['image/jpeg','image/png','image/webp']::text[]);
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES ('anatomy-images','anatomy-images',false,10485760,ARRAY['image/jpeg','image/png','image/webp']::text[]);
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types) VALUES ('avatars','avatars',true,5242880,ARRAY['image/jpeg','image/png','image/webp','image/heic','image/heif']::text[]);
