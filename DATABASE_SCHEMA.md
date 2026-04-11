# UniOne Rails - Database Schema Reference

---

## Table Structure Reference

### 1. universities

```sql
id (PK)
name (VARCHAR)
code (VARCHAR, UNIQUE)
country (VARCHAR)
city (VARCHAR)
established_year (INTEGER)
logo_path (VARCHAR, NULL)
president_id (FK→users, NULL)
phone (VARCHAR, NULL)
email (VARCHAR, NULL)
website (VARCHAR, NULL)
address (TEXT, NULL)
created_at, updated_at
```

### 2. roles

```sql
id (PK)
name (VARCHAR, UNIQUE)
slug (VARCHAR, UNIQUE)
permissions (JSONB)
created_at, updated_at
```

### 3. users

```sql
id (PK)
national_id (VARCHAR, UNIQUE)
first_name (VARCHAR)
last_name (VARCHAR)
email (VARCHAR, UNIQUE)
password_digest (VARCHAR)
phone (VARCHAR, NULL)
gender (VARCHAR, NULL)
date_of_birth (DATE, NULL)
avatar_path (VARCHAR, NULL)
is_active (BOOLEAN, default: true)
must_change_password (BOOLEAN, default: false)
email_verified_at (TIMESTAMP, NULL)
deleted_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 4. role_users (Join Table)

```sql
id (PK)
user_id (FK→users)
role_id (FK→roles)
scope (VARCHAR, NULL) - university_id, faculty_id, department_id, or NULL
scope_id (INTEGER, NULL) - the actual ID of the scope
created_at, updated_at
```

### 5. faculties

```sql
id (PK)
university_id (FK→universities)
name (VARCHAR)
name_ar (VARCHAR, NULL)
code (VARCHAR)
logo_path (VARCHAR, NULL)
created_at, updated_at
```

### 6. departments

```sql
id (PK)
faculty_id (FK→faculties)
name (VARCHAR)
name_ar (VARCHAR, NULL)
code (VARCHAR)
scope (VARCHAR, NULL) - "university", "faculty", or "department"
is_mandatory (BOOLEAN, default: false)
required_credit_hours (INTEGER, NULL)
logo_path (VARCHAR, NULL)
created_at, updated_at
```

### 7. professors

```sql
id (PK)
user_id (FK→users, UNIQUE)
staff_number (VARCHAR, UNIQUE)
department_id (FK→departments)
specialization (VARCHAR, NULL)
academic_rank (VARCHAR) - "Assistant Professor", "Associate Professor", "Professor"
office_location (VARCHAR, NULL)
hired_at (DATE)
created_at, updated_at
```

### 8. employees

```sql
id (PK)
user_id (FK→users, UNIQUE)
staff_number (VARCHAR, UNIQUE)
department_id (FK→departments)
position (VARCHAR)
hired_at (DATE)
created_at, updated_at
```

### 9. students

```sql
id (PK)
user_id (FK→users, UNIQUE)
student_number (VARCHAR, UNIQUE)
faculty_id (FK→faculties)
department_id (FK→departments)
academic_year (INTEGER)
semester (INTEGER) - 1 or 2
enrollment_status (VARCHAR) - "active", "graduated", "suspended"
gpa (DECIMAL(3,2)) - 0.00 to 4.00
academic_standing (VARCHAR) - "good", "probation", "suspension"
enrolled_at (DATE)
graduated_at (DATE, NULL)
created_at, updated_at
```

### 10. student_department_histories

```sql
id (PK)
student_id (FK→students)
department_id (FK→departments)
academic_year (INTEGER)
semester (INTEGER)
reason (VARCHAR, NULL)
created_at, updated_at
```

### 11. courses

```sql
id (PK)
code (VARCHAR, UNIQUE)
name (VARCHAR)
name_ar (VARCHAR, NULL)
description (TEXT, NULL)
credit_hours (INTEGER)
lecture_hours (INTEGER)
lab_hours (INTEGER)
level (INTEGER) - 100-400 level
is_elective (BOOLEAN, default: false)
is_active (BOOLEAN, default: true)
created_at, updated_at
```

### 12. department_courses (Join Table)

```sql
id (PK)
department_id (FK→departments)
course_id (FK→courses)
is_owner (BOOLEAN) - primary department teaching course
created_at, updated_at
```

### 13. course_prerequisites (Self-Referential Join)

```sql
id (PK)
course_id (FK→courses)
prerequisite_id (FK→courses)
created_at, updated_at
```

### 14. academic_terms

```sql
id (PK)
name (VARCHAR) - "Spring 2025", "Fall 2024"
start_date (DATE)
end_date (DATE)
registration_start (DATE)
registration_end (DATE)
is_active (BOOLEAN, default: false)
created_at, updated_at
```

### 15. sections

```sql
id (PK)
course_id (FK→courses)
professor_id (FK→professors)
academic_term_id (FK→academic_terms)
semester (INTEGER) - 1 or 2
capacity (INTEGER)
schedule (JSONB) - { days: [1,3,5], start_time: "09:00", end_time: "10:30", location: "Room 101" }
created_at, updated_at
```

### 16. enrollments

```sql
id (PK)
student_id (FK→students)
section_id (FK→sections)
academic_term_id (FK→academic_terms)
status (VARCHAR) - "active", "completed", "dropped"
registered_at (TIMESTAMP)
dropped_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 17. enrollment_waitlists

```sql
id (PK)
student_id (FK→students)
section_id (FK→sections)
academic_term_id (FK→academic_terms)
position (INTEGER)
priority_score (DECIMAL(4,2)) - for priority calculation
requested_at (TIMESTAMP)
created_at, updated_at
```

### 18. grades

```sql
id (PK)
enrollment_id (FK→enrollments, UNIQUE)
points (INTEGER) - 0-100
letter_grade (VARCHAR) - A, B, C, D, F
status (VARCHAR) - "complete", "incomplete"
created_at, updated_at
```

### 19. student_term_gpas

```sql
id (PK)
student_id (FK→students)
academic_term_id (FK→academic_terms)
gpa (DECIMAL(3,2))
credit_hours_completed (INTEGER)
created_at, updated_at
UNIQUE (student_id, academic_term_id)
```

### 20. announcements (University-wide)

```sql
id (PK)
user_id (FK→users)
title (VARCHAR)
content (TEXT)
published_at (TIMESTAMP)
is_published (BOOLEAN, default: true)
created_at, updated_at
```

### 21. announcement_reads (Join Table)

```sql
id (PK)
user_id (FK→users)
announcement_id (FK→announcements)
read_at (TIMESTAMP)
UNIQUE (user_id, announcement_id)
```

### 22. section_announcements (Course-specific)

```sql
id (PK)
section_id (FK→sections)
user_id (FK→users) - professor
title (VARCHAR)
content (TEXT)
published_at (TIMESTAMP)
created_at, updated_at
```

### 23. attendance_sessions

```sql
id (PK)
section_id (FK→sections)
date (DATE)
session_number (INTEGER)
status (VARCHAR) - "open", "closed", "archived"
created_at, updated_at
```

### 24. attendance_records

```sql
id (PK)
attendance_session_id (FK→attendance_sessions)
student_id (FK→students)
status (VARCHAR) - "present", "absent", "late"
note (TEXT, NULL)
created_at, updated_at
```

### 25. course_ratings

```sql
id (PK)
enrollment_id (FK→enrollments, UNIQUE)
rating (SMALLINT) - 1-5
feedback (TEXT, NULL)
submitted_at (TIMESTAMP)
created_at, updated_at
```

### 26. audit_logs

```sql
id (PK)
user_id (FK→users, NULL)
action (VARCHAR) - "create", "update", "delete"
auditable_type (VARCHAR) - Model class name
auditable_id (INTEGER)
description (TEXT)
old_values (JSONB, NULL)
new_values (JSONB, NULL)
ip_address (VARCHAR, NULL)
created_at (TIMESTAMP)
```

### 27. webhooks

```sql
id (PK)
user_id (FK→users)
url (VARCHAR)
secret (VARCHAR) - for HMAC verification
events (JSONB) - array of event names
is_active (BOOLEAN, default: true)
failure_count (INTEGER, default: 0)
last_triggered_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 28. webhook_deliveries

```sql
id (PK)
webhook_id (FK→webhooks)
event (VARCHAR)
payload (JSONB)
status (VARCHAR) - "pending", "delivered", "failed"
response (TEXT, NULL)
attempt_count (INTEGER, default: 0)
next_retry_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 29. university_vice_presidents

```sql
id (PK)
user_id (FK→users)
university_id (FK→universities)
department (VARCHAR) - "Academic Affairs", "Student Services", etc.
appointed_at (DATE)
created_at, updated_at
```

### 30. notifications

```sql
id (PK)
user_id (FK→users)
notifiable_type (VARCHAR) - "User", "Student", etc.
notifiable_id (BIGINT)
type (VARCHAR) - "EnrollmentNotification", "GradeNotification", etc.
data (JSONB)
read_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 31. password_reset_tokens

```sql
email (VARCHAR, PRIMARY KEY)
token (VARCHAR)
created_at (TIMESTAMP)
```

### 32. personal_access_tokens

```sql
id (PK)
tokenable_type (VARCHAR) - "User"
tokenable_id (BIGINT)
name (VARCHAR)
token (VARCHAR, UNIQUE) - hashed
abilities (JSONB, NULL)
last_used_at (TIMESTAMP, NULL)
expires_at (TIMESTAMP, NULL)
created_at, updated_at
```

### 33. ar_internal_metadata

```sql
key (VARCHAR, PRIMARY KEY)
value (VARCHAR)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### 34. schema_migrations

```sql
version (VARCHAR, PRIMARY KEY)
```

---

## Migration Order (Sequential)

```bash
rails generate migration CreateUniversities
rails generate migration CreateRoles
rails generate migration CreateUsers
rails generate migration CreateRoleUsers
rails generate migration CreateFaculties
rails generate migration CreateDepartments
rails generate migration CreateProfessors
rails generate migration CreateEmployees
rails generate migration CreateStudents
rails generate migration CreateStudentDepartmentHistories
rails generate migration CreateCourses
rails generate migration CreateDepartmentCourses
rails generate migration CreateCoursePrerequisites
rails generate migration CreateAcademicTerms
rails generate migration CreateSections
rails generate migration CreateEnrollments
rails generate migration CreateEnrollmentWaitlists
rails generate migration CreateGrades
rails generate migration CreateStudentTermGpas
rails generate migration CreateAnnouncements
rails generate migration CreateAnnouncementReads
rails generate migration CreateSectionAnnouncements
rails generate migration CreateAttendanceSessions
rails generate migration CreateAttendanceRecords
rails generate migration CreateCourseRatings
rails generate migration CreateAuditLogs
rails generate migration CreateWebhooks
rails generate migration CreateWebhookDeliveries
rails generate migration CreateUniversityVicePresidents
rails generate migration CreateNotifications
rails generate migration CreatePasswordResetTokens
rails generate migration CreatePersonalAccessTokens
rails generate migration CreateCache
rails generate migration CreateJobs
```

---

## Rails Migration Examples

### Basic Table

```ruby
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :national_id, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :phone
      t.string :gender
      t.date :date_of_birth
      t.string :avatar_path
      t.boolean :is_active, default: true
      t.boolean :must_change_password, default: false
      t.datetime :email_verified_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :national_id, unique: true
    add_index :users, :email, unique: true
    add_index :users, :deleted_at
  end
end
```

### Join Table

```ruby
class CreateRoleUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :role_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.string :scope
      t.integer :scope_id

      t.timestamps
    end

    add_index :role_users, [:user_id, :role_id], unique: true
  end
end
```

### Self-Referential Join

```ruby
class CreateCoursePrerequisites < ActiveRecord::Migration[7.1]
  def change
    create_table :course_prerequisites do |t|
      t.references :course, null: false, foreign_key: true
      t.references :prerequisite, null: false, foreign_key: { to_table: :courses }

      t.timestamps
    end

    add_index :course_prerequisites, [:course_id, :prerequisite_id], unique: true
  end
end
```

### JSONB Column

```ruby
class CreateSections < ActiveRecord::Migration[7.1]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: true
      t.references :professor, null: false, foreign_key: true
      t.references :academic_term, null: false, foreign_key: true
      t.integer :semester
      t.integer :capacity
      t.jsonb :schedule, default: {}

      t.timestamps
    end
  end
end
```

---

## Key Considerations

### Foreign Keys

- All ForeignKey constraints should be enabled
- ON DELETE CASCADE for dependent records
- ON UPDATE CASCADE for parent updates
- Use `foreign_key: true` in Rails migrations

### Indexes

- Primary keys on all tables (automatic)
- UNIQUE on: national_id, email, course code, student number, staff number
- Foreign keys should auto-index in Rails
- Composite indexes for common queries:
  - (user_id, role_id) on role_users
  - (student_id, status) on enrollments
  - (section_id, student_id) on attendance_records

### Soft Deletes

- Only on users table
- Use `deleted_at` field
- Query filters must exclude soft-deleted records
- Consider using `acts_as_paranoid` gem

### Timestamps

- All tables use `t.timestamps` in Rails
- Some tables have business timestamps (published_at, hired_at, etc.)
- created_at and updated_at managed automatically by Rails

### JSONB Fields

- schedule on sections: `{ days: [1,3,5], start_time, end_time, location }`
- events on webhooks: `["enrollment.created", "grade.submitted", ...]`
- permissions on roles: `{ "create_users", "edit_grades", ... }`
- data on notifications: payload for notification
- old_values / new_values on audit_logs: before/after state
- payload on webhook_deliveries: event data sent

### Type Mappings

- Student status enum: active, graduated, suspended
- Enrollment status enum: active, completed, dropped
- Attendance status enum: present, absent, late
- Grade status enum: complete, incomplete
- Academic standing enum: good, probation, suspension
- Role scopes: university_id, faculty_id, department_id, NULL (global)

### Rails Enums

```ruby
# app/models/student.rb
class Student < ApplicationRecord
  enum enrollment_status: { active: 0, graduated: 1, suspended: 2 }
  enum academic_standing: { good: 0, probation: 1, suspension: 2 }
end

# app/models/enrollment.rb
class Enrollment < ApplicationRecord
  enum status: { active: 0, completed: 1, dropped: 2 }
end
```

---

## Relationships Overview (Rails Associations)

```ruby
User (1) ─→ (N) RoleUser
User (1) ─→ (1) Student
User (1) ─→ (1) Professor
User (1) ─→ (1) Employee

Role (1) ─→ (N) RoleUser
University (1) ─→ (N) Faculty
University (1) ─→ (N) UniversityVicePresident
Faculty (1) ─→ (N) Department
Department (1) ─→ (N) Professor
Department (1) ─→ (N) Employee
Department (1) ─→ (N) Student

Course (1) ─→ (N) Section
Course (N) ─→ (N) Department (via DepartmentCourse)
Course (N) ─→ (N) Course (self-join for prerequisites)

AcademicTerm (1) ─→ (N) Section
AcademicTerm (1) ─→ (N) Enrollment
Section (1) ─→ (N) Enrollment
Section (1) ─→ (N) AttendanceSession
Section (1) ─→ (N) SectionAnnouncement

Student (1) ─→ (N) Enrollment
Student (1) ─→ (N) AttendanceRecord
Student (1) ─→ (N) StudentDepartmentHistory
Student (1) ─→ (N) StudentTermGpa
Student (1) ─→ (N) EnrollmentWaitlist
Enrollment (1) ─→ (1) Grade
Enrollment (1) ─→ (1) CourseRating

Professor (1) ─→ (N) Section
AttendanceSession (1) ─→ (N) AttendanceRecord

Webhook (1) ─→ (N) WebhookDelivery
Announcement (1) ─→ (N) AnnouncementRead

AuditLog ─→ User, Model (polymorphic)
Notification ─→ User (polymorphic via notifiable)
```

---

## Rails Model Examples

### User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  
  has_one :student, dependent: :destroy
  has_one :professor, dependent: :destroy
  has_one :employee, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :national_id, presence: true, uniqueness: true
  
  scope :active, -> { where(is_active: true) }
  scope :with_role, ->(role) { joins(:roles).where(roles: { slug: role }) }
  
  def admin?
    roles.exists?(slug: 'admin')
  end
  
  def student?
    roles.exists?(slug: 'student')
  end
  
  def professor?
    roles.exists?(slug: 'professor')
  end
end
```

### Student Model

```ruby
# app/models/student.rb
class Student < ApplicationRecord
  belongs_to :user
  belongs_to :faculty
  belongs_to :department
  
  has_many :enrollments, dependent: :destroy
  has_many :sections, through: :enrollments
  has_many :attendance_records, dependent: :destroy
  has_many :department_histories, dependent: :destroy
  has_many :term_gpas, class_name: 'StudentTermGpa', dependent: :destroy
  
  enum enrollment_status: { active: 0, graduated: 1, suspended: 2 }
  enum academic_standing: { good: 0, probation: 1, suspension: 2 }
  
  validates :student_number, presence: true, uniqueness: true
  
  def calculate_gpa
    # GPA calculation logic
  end
end
```

### Section Model with JSONB

```ruby
# app/models/section.rb
class Section < ApplicationRecord
  belongs_to :course
  belongs_to :professor
  belongs_to :academic_term
  
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
  has_many :attendance_sessions, dependent: :destroy
  has_many :announcements, class_name: 'SectionAnnouncement', dependent: :destroy
  
  validates :capacity, numericality: { greater_than: 0 }
  
  # JSONB query helpers
  def self.by_location(location)
    where("schedule ->> 'location' = ?", location)
  end
  
  def self.by_day(day)
    where("schedule -> 'days' @> ?", [day].to_json)
  end
  
  def schedule_days
    schedule['days'] || []
  end
  
  def start_time
    schedule['start_time']
  end
  
  def end_time
    schedule['end_time']
  end
end
```

---

## Data Volume Estimation

For a typical medium-sized university:

- Users: 10,000-50,000
- Students: 5,000-20,000
- Faculty/Professors: 200-500
- Departments: 20-50
- Courses: 500-2,000
- Sections/Offerings: 2,000-5,000
- Enrollments: 50,000-200,000
- Grades: 50,000-200,000
- Audit Logs: 500,000+ (grows continuously)

---

## Backup & Recovery Strategy

1. Daily automated backups using `rails db:backup` or pg_dump
2. Point-in-time recovery capability (14-30 days)
3. Audit log archival for compliance
4. Transaction-level consistency
5. Replicated read-only copies for reporting

---

## Database Commands

```bash
rails db:create                  # Create databases
rails db:migrate                 # Run migrations
rails db:rollback                # Rollback last migration
rails db:rollback STEP=3         # Rollback 3 migrations
rails db:seed                    # Seed database
rails db:reset                   # Drop, create, migrate, seed
rails db:drop                    # Drop databases
rails db:version                 # Current schema version
rails db:migrate:status          # Show migration status

# Generate migration
rails generate migration CreateNewTable
rails generate migration AddColumnToTable column:type
rails generate migration RemoveColumnFromTable column:type
rails generate migration RenameOldToNew old_column:new_column

# Schema
rails db:schema:dump             # Update schema.rb
rails db:schema:load             # Load schema.rb (dangerous!)
```

---

**Last Updated**: April 11, 2026
**Maintainers**: Development Team
**Status**: 🟢 Ready for Implementation
