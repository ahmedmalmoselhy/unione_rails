# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_12_000036) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_terms", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.date "registration_start", null: false
    t.date "registration_end", null: false
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "announcement_reads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "announcement_id", null: false
    t.datetime "read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["announcement_id"], name: "index_announcement_reads_on_announcement_id"
    t.index ["user_id", "announcement_id"], name: "index_announcement_reads_on_user_id_and_announcement_id", unique: true
    t.index ["user_id"], name: "index_announcement_reads_on_user_id"
  end

  create_table "announcements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "published_at"
    t.boolean "is_published", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_announcements_on_user_id"
  end

  create_table "attendance_records", force: :cascade do |t|
    t.bigint "attendance_session_id", null: false
    t.bigint "student_id", null: false
    t.integer "status", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_session_id", "student_id"], name: "idx_on_attendance_session_id_student_id_91c990da51", unique: true
    t.index ["attendance_session_id"], name: "index_attendance_records_on_attendance_session_id"
    t.index ["student_id"], name: "index_attendance_records_on_student_id"
  end

  create_table "attendance_sessions", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.date "date", null: false
    t.integer "session_number", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_attendance_sessions_on_section_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.text "description", null: false
    t.jsonb "old_values"
    t.jsonb "new_values"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "cache", force: :cascade do |t|
    t.string "key", null: false
    t.binary "value"
    t.integer "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_cache_on_key", unique: true
  end

  create_table "course_prerequisites", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "prerequisite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "prerequisite_id"], name: "index_course_prerequisites_on_course_id_and_prerequisite_id", unique: true
    t.index ["course_id"], name: "index_course_prerequisites_on_course_id"
    t.index ["prerequisite_id"], name: "index_course_prerequisites_on_prerequisite_id"
  end

  create_table "course_ratings", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.integer "rating", null: false
    t.text "feedback"
    t.datetime "submitted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_course_ratings_on_enrollment_id", unique: true
  end

  create_table "courses", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "name_ar"
    t.text "description"
    t.integer "credit_hours", null: false
    t.integer "lecture_hours", default: 0, null: false
    t.integer "lab_hours", default: 0, null: false
    t.integer "level", null: false
    t.boolean "is_elective", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_courses_on_code", unique: true
  end

  create_table "department_courses", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.bigint "course_id", null: false
    t.boolean "is_owner", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_department_courses_on_course_id"
    t.index ["department_id", "course_id"], name: "index_department_courses_on_department_id_and_course_id", unique: true
    t.index ["department_id"], name: "index_department_courses_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.bigint "faculty_id", null: false
    t.string "name", null: false
    t.string "name_ar"
    t.string "code", null: false
    t.string "scope"
    t.boolean "is_mandatory", default: false
    t.integer "required_credit_hours"
    t.string "logo_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_departments_on_faculty_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "staff_number", null: false
    t.bigint "department_id", null: false
    t.string "position", null: false
    t.date "hired_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["staff_number"], name: "index_employees_on_staff_number", unique: true
    t.index ["user_id"], name: "index_employees_on_user_id", unique: true
  end

  create_table "enrollment_waitlists", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "section_id", null: false
    t.bigint "academic_term_id", null: false
    t.integer "position", null: false
    t.decimal "priority_score", precision: 4, scale: 2
    t.datetime "requested_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_term_id"], name: "index_enrollment_waitlists_on_academic_term_id"
    t.index ["section_id"], name: "index_enrollment_waitlists_on_section_id"
    t.index ["student_id"], name: "index_enrollment_waitlists_on_student_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "section_id", null: false
    t.bigint "academic_term_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "registered_at", null: false
    t.datetime "dropped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_term_id"], name: "index_enrollments_on_academic_term_id"
    t.index ["section_id"], name: "index_enrollments_on_section_id"
    t.index ["student_id", "status"], name: "index_enrollments_on_student_id_and_status"
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.bigint "university_id", null: false
    t.string "name", null: false
    t.string "name_ar"
    t.string "code", null: false
    t.string "logo_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_faculties_on_university_id"
  end

  create_table "grades", force: :cascade do |t|
    t.bigint "enrollment_id", null: false
    t.integer "points"
    t.string "letter_grade"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id"], name: "index_grades_on_enrollment_id", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.string "queue", null: false
    t.jsonb "payload", null: false
    t.integer "priority", null: false
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["concurrency_key"], name: "index_jobs_on_concurrency_key"
    t.index ["queue", "priority", "scheduled_at"], name: "index_jobs_for_fetching"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "type", null: false
    t.jsonb "data", default: {}
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.boolean "used", default: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_password_reset_tokens_on_expires_at"
    t.index ["token"], name: "index_password_reset_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "personal_access_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.datetime "revoked_at"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revoked_at"], name: "index_personal_access_tokens_on_revoked_at"
    t.index ["token"], name: "index_personal_access_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_personal_access_tokens_on_user_id"
  end

  create_table "professors", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "staff_number", null: false
    t.bigint "department_id", null: false
    t.string "specialization"
    t.string "academic_rank", null: false
    t.string "office_location"
    t.date "hired_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_professors_on_department_id"
    t.index ["staff_number"], name: "index_professors_on_staff_number", unique: true
    t.index ["user_id"], name: "index_professors_on_user_id", unique: true
  end

  create_table "role_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.string "scope_entity_type"
    t.bigint "scope_entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_users_on_role_id"
    t.index ["scope_entity_type", "scope_entity_id"], name: "index_role_users_on_scope_entity"
    t.index ["user_id", "role_id"], name: "index_role_users_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_role_users_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["slug"], name: "index_roles_on_slug", unique: true
  end

  create_table "section_announcements", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_section_announcements_on_section_id"
    t.index ["user_id"], name: "index_section_announcements_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "professor_id", null: false
    t.bigint "academic_term_id", null: false
    t.integer "semester", null: false
    t.integer "capacity", null: false
    t.jsonb "schedule", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_term_id"], name: "index_sections_on_academic_term_id"
    t.index ["course_id"], name: "index_sections_on_course_id"
    t.index ["professor_id"], name: "index_sections_on_professor_id"
  end

  create_table "student_department_histories", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "department_id", null: false
    t.integer "academic_year", null: false
    t.integer "semester", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_student_department_histories_on_department_id"
    t.index ["student_id"], name: "index_student_department_histories_on_student_id"
  end

  create_table "student_term_gpas", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "academic_term_id", null: false
    t.decimal "gpa", precision: 3, scale: 2
    t.integer "credit_hours_completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_term_id"], name: "index_student_term_gpas_on_academic_term_id"
    t.index ["student_id", "academic_term_id"], name: "index_student_term_gpas_on_student_id_and_academic_term_id", unique: true
    t.index ["student_id"], name: "index_student_term_gpas_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "student_number", null: false
    t.bigint "faculty_id", null: false
    t.bigint "department_id", null: false
    t.integer "academic_year", null: false
    t.integer "semester", null: false
    t.integer "enrollment_status", default: 0, null: false
    t.decimal "gpa", precision: 3, scale: 2, default: "0.0"
    t.integer "academic_standing", default: 0, null: false
    t.date "enrolled_at", null: false
    t.date "graduated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_students_on_department_id"
    t.index ["faculty_id"], name: "index_students_on_faculty_id"
    t.index ["student_number"], name: "index_students_on_student_number", unique: true
    t.index ["user_id"], name: "index_students_on_user_id", unique: true
  end

  create_table "universities", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "country"
    t.string "city"
    t.integer "established_year"
    t.string "logo_path"
    t.bigint "president_id"
    t.string "phone"
    t.string "email"
    t.string "website"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_universities_on_code", unique: true
    t.index ["president_id"], name: "index_universities_on_president_id"
  end

  create_table "university_vice_presidents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "university_id", null: false
    t.string "department", null: false
    t.date "appointed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_university_vice_presidents_on_university_id"
    t.index ["user_id"], name: "index_university_vice_presidents_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "last_login_at"
    t.datetime "email_verified_at"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "national_id"
    t.string "gender"
    t.date "date_of_birth"
    t.boolean "must_change_password", default: false
    t.datetime "deleted_at"
    t.string "avatar_path"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_active"], name: "index_users_on_is_active"
    t.index ["national_id"], name: "index_users_on_national_id", unique: true
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.bigint "webhook_id", null: false
    t.string "event", null: false
    t.jsonb "payload", default: {}
    t.integer "status", default: 0, null: false
    t.text "response"
    t.integer "attempt_count", default: 0
    t.datetime "next_retry_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "url", null: false
    t.string "secret", null: false
    t.jsonb "events", default: []
    t.boolean "is_active", default: true
    t.integer "failure_count", default: 0
    t.datetime "last_triggered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_webhooks_on_user_id"
  end

  add_foreign_key "announcement_reads", "announcements"
  add_foreign_key "announcement_reads", "users"
  add_foreign_key "announcements", "users"
  add_foreign_key "attendance_records", "attendance_sessions"
  add_foreign_key "attendance_records", "students"
  add_foreign_key "attendance_sessions", "sections"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "course_prerequisites", "courses"
  add_foreign_key "course_prerequisites", "courses", column: "prerequisite_id"
  add_foreign_key "course_ratings", "enrollments"
  add_foreign_key "department_courses", "courses"
  add_foreign_key "department_courses", "departments"
  add_foreign_key "departments", "faculties"
  add_foreign_key "employees", "departments"
  add_foreign_key "employees", "users"
  add_foreign_key "enrollment_waitlists", "academic_terms"
  add_foreign_key "enrollment_waitlists", "sections"
  add_foreign_key "enrollment_waitlists", "students"
  add_foreign_key "enrollments", "academic_terms"
  add_foreign_key "enrollments", "sections"
  add_foreign_key "enrollments", "students"
  add_foreign_key "faculties", "universities"
  add_foreign_key "grades", "enrollments"
  add_foreign_key "notifications", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "personal_access_tokens", "users"
  add_foreign_key "professors", "departments"
  add_foreign_key "professors", "users"
  add_foreign_key "role_users", "roles"
  add_foreign_key "role_users", "users"
  add_foreign_key "section_announcements", "sections"
  add_foreign_key "section_announcements", "users"
  add_foreign_key "sections", "academic_terms"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "professors"
  add_foreign_key "student_department_histories", "departments"
  add_foreign_key "student_department_histories", "students"
  add_foreign_key "student_term_gpas", "academic_terms"
  add_foreign_key "student_term_gpas", "students"
  add_foreign_key "students", "departments"
  add_foreign_key "students", "faculties"
  add_foreign_key "students", "users"
  add_foreign_key "universities", "users", column: "president_id"
  add_foreign_key "university_vice_presidents", "universities"
  add_foreign_key "university_vice_presidents", "users"
  add_foreign_key "webhook_deliveries", "webhooks"
  add_foreign_key "webhooks", "users"
end
