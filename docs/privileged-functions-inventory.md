# Inventaire des fonctions privilégiées — 15 octobre 2026

Inventaire de la base réelle : 80 fonctions SECURITY DEFINER exécutables par authenticated. Aucun droit d'exécution anonyme détecté, tous les chemins de recherche sont fixés. Ce classement est un outil de revue statique, pas une preuve exhaustive de l'absence de faille. Les fonctions de calcul XP et les helpers internes ne sont pas exécutables directement par les étudiants.

Les tests account_isolation.sql couvrent deux comptes, notes, profils, notifications, sessions, transfert de propriétaire, publication administrateur, attribution directe de XP et quota de signalements. Les tests audit_regressions.sql couvrent les réponses masquées et le périmètre de cursus. Une revue indépendante de chaque corps et des accès transitifs reste recommandée avant une ouverture large.

| Fonction | Repère pour la revue |
|---|---|
| `abandon_revision_session_v1(p_session_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `can_review_visuals_v1()` | Contrôle administrateur/relecteur |
| `cancel_curriculum_friend_challenge_v1(p_challenge_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `cancel_friend_challenge_v1(p_challenge_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `create_curriculum_friend_challenge_v1(p_friend_id uuid, p_program_id text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `create_friend_challenge_v1(p_friend_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `finish_daily_challenge_v2(p_session_id uuid, p_activity_date date)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `finish_friend_challenge_v1(p_challenge_id uuid, p_score integer)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `finish_quiz_session_v2(p_session_id uuid, p_activity_date date)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_active_revision_session_v1()` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_badges_v2()` | Identité courante : usage applicatif |
| `get_client_error_logs_v1(p_limit integer)` | Contrôle administrateur/relecteur |
| `get_content_quality_summary_v1()` | Contrôle administrateur/relecteur |
| `get_content_review_queue_v3()` | Contrôle administrateur/relecteur |
| `get_content_review_queue_v4()` | Contrôle administrateur/relecteur |
| `get_course_library_v1()` | Identité courante : usage applicatif |
| `get_curriculum_challenge_availability_v1(p_program_id text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_curriculum_daily_challenge_v1(p_program_id text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_curriculum_friend_challenge_questions_v1(p_challenge_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_curriculum_friend_challenges_v1(p_program_id text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_curriculum_progress_v1(p_program_id text)` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `get_curriculum_quiz_questions_v1(p_topic_ids uuid[])` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `get_curriculum_stats_v1(p_program_id text, p_days integer)` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `get_curriculum_v2()` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `get_feedback_queue_v1(p_status text, p_limit integer)` | Contrôle administrateur/relecteur |
| `get_friend_challenges_v3()` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_friend_leaderboard_v2(p_program_id text)` | Identité courante : usage applicatif |
| `get_friendships_v3(p_program_id text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_gamification_summary_v2()` | Identité courante : usage applicatif |
| `get_inactivity_reminder_preference_v1()` | Identité courante : usage applicatif |
| `get_lesson_personal_state_v1(p_lesson_id uuid)` | Identité courante : usage applicatif |
| `get_lesson_v2(p_lesson_id uuid)` | Identité courante : usage applicatif |
| `get_my_library_v1()` | Identité courante : usage applicatif |
| `get_quiz_questions_v4(p_session_id uuid)` | Identité courante : usage applicatif |
| `get_recent_revision_sessions_v1(p_limit integer)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_revision_mode_availability_v1()` | Identité courante : usage applicatif |
| `get_revision_session_meta_v1(p_session_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_revision_session_review_v2(p_session_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `get_study_priorities_v1()` | Identité courante : usage applicatif |
| `get_user_dashboard_v3()` | Identité courante : usage applicatif |
| `get_user_stats_v3(p_days integer)` | Identité courante : usage applicatif |
| `get_visual_review_queue_v1()` | Contrôle administrateur/relecteur |
| `mark_app_open_v1()` | Identité courante : usage applicatif |
| `publish_lesson_bundle_v1(p_lesson_id uuid)` | Contrôle administrateur/relecteur |
| `remove_friendship_v1(p_friendship_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `report_client_error_v1(p_message text, p_component_stack text, p_page_path text, p_app_version text)` | Identité courante : usage applicatif |
| `respond_curriculum_friend_challenge_v1(p_challenge_id uuid, p_accept boolean)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `respond_friend_challenge_v1(p_challenge_id uuid, p_accept boolean)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `respond_friend_request_v1(p_friendship_id uuid, p_accept boolean)` | Identité courante : usage applicatif |
| `save_lesson_note_v1(p_lesson_id uuid, p_content text)` | Identité courante : usage applicatif |
| `search_students_v2(p_query text)` | Identité courante : usage applicatif |
| `search_students_v3(p_query text, p_program_id text)` | Identité courante : usage applicatif |
| `send_friend_request_v1(p_addressee uuid)` | Identité courante : usage applicatif |
| `set_content_review_status_v1(p_kind text, p_id uuid, p_status text)` | Contrôle administrateur/relecteur |
| `set_feedback_status_v1(p_feedback_id uuid, p_status text)` | Contrôle administrateur/relecteur |
| `set_inactivity_reminder_preference_v1(p_opted_in boolean)` | Identité courante : usage applicatif |
| `set_profile_avatar_v1(p_avatar_url text)` | Identité courante : usage applicatif |
| `set_visual_approval_v1(p_question_id uuid, p_approved boolean)` | Contrôle administrateur/relecteur |
| `set_visual_review_v2(p_question_id uuid, p_anatomy_ok boolean, p_mobile_ok boolean, p_target_ok boolean, p_source_ok boolean)` | Contrôle administrateur/relecteur |
| `set_visual_target_v1(p_question_id uuid, p_x numeric, p_y numeric, p_target_index integer, p_radius numeric)` | Contrôle administrateur/relecteur |
| `setup_student_profile_v1(p_program_id text, p_level_code text, p_first_name text, p_username text)` | Identité courante : usage applicatif |
| `start_daily_challenge_v2(p_challenge_date date)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `start_friend_challenge_session_v1(p_challenge_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `start_lesson_quiz_v2(p_lesson_id uuid, p_question_count integer)` | Identité courante : usage applicatif |
| `start_mistake_retry_v1(p_source_session_id uuid)` | Identité courante : usage applicatif |
| `start_mock_exam_v1(p_question_count integer)` | Identité courante : usage applicatif |
| `start_revision_session_replay_v1(p_source_session_id uuid)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `start_smart_revision_v2(p_question_count integer)` | Identité courante : usage applicatif |
| `start_subject_revision_v1(p_subject_id uuid, p_question_count integer)` | Identité courante : usage applicatif |
| `start_visual_revision_v1(p_question_count integer)` | Identité courante : usage applicatif |
| `start_weak_revision_v1(p_question_count integer)` | Identité courante : usage applicatif |
| `submit_curriculum_daily_answer_v1(p_program_id text, p_question_id uuid, p_answer_text text)` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `submit_curriculum_friend_challenge_answer_v1(p_challenge_id uuid, p_question_id uuid, p_answer_text text)` | Session ou relation : contrôle d’identité/propriété à maintenir |
| `submit_curriculum_topic_answer_v2(p_question_id uuid, p_answer jsonb)` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `submit_curriculum_topic_answer_v3(p_question_id uuid, p_answer jsonb)` | Cursus et identité : accès à vérifier dans les tests de périmètre |
| `submit_feedback_v1(p_kind text, p_message text, p_page_path text)` | Identité courante : usage applicatif |
| `submit_quiz_answer_v5(p_session_id uuid, p_question_id uuid, p_answer jsonb, p_response_time_ms integer)` | Identité courante : usage applicatif |
| `toggle_lesson_favorite_v1(p_lesson_id uuid)` | Identité courante : usage applicatif |
| `touch_user_activity_v1()` | Identité courante : usage applicatif |
| `update_study_profile_v1(p_first_name text, p_username text, p_study_year integer)` | Identité courante : usage applicatif |

