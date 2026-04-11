# UniOne Rails - Implementation Plan

## Project Overview

A comprehensive academic management system built with **Ruby on Rails 7+** with feature parity to the original Laravel backend and Node.js clone.

---

## DATABASE MODELS & RELATIONSHIPS

### 1. **User Core Models**

- **User** (Base authentication model)
  - Fields: national_id, first_name, last_name, email, password, phone, gender, date_of_birth, avatar_path, is_active, must_change_password
  - Relations: has_many :role_users, has_many :roles, through: :role_users
  - has_one :student, has_one :professor, has_one :employee (polymorphic profiles)
  - Timestamps: created_at, updated_at
  - Soft deletes: acts_as_paranoid or custom deleted_at

- **Role** (Admin, Faculty Admin, Department Admin, Professor, Student, Employee)
  - Fields: name, slug, permissions (JSONB)
  - Join Table: role_users (user_id, role_id, scope, scope_id)

- **University**
  - Fields: name, code, country, city, established_year, logo_path, contact_* (phone, email, website, address)
  - Relations: has_many :faculties, has_many :departments, has_many :users (through roles)

### 2. **Organizational Structure**

- **Faculty**
  - Fields: name, name_ar, code, university_id, logo_path
  - Relations: has_many :departments, belongs_to :university

- **Department**
  - Fields: name, name_ar, code, faculty_id, scope, is_mandatory, required_credit_hours, logo_path
  - Relations: belongs_to :faculty, has_many :students, has_many :professors

- **Employee**
  - Fields: user_id, staff_number, department_id, position, hired_at
  - Relations: belongs_to :user, belongs_to :department

- **UniversityVicePresident**
  - Fields: user_id, university_id, department, appointed_at
  - Relations: belongs_to :user, belongs_to :university

### 3. **Academic Models**

- **Course**
  - Fields: code, name, name_ar, description, credit_hours, lecture_hours, lab_hours, level, is_elective, is_active
  - Relations: has_and_belongs_to_many :departments, has_and_belongs_to_many :prerequisites (self-referential)

- **Section**
  - Fields: course_id, professor_id, academic_term_id, semester, capacity, schedule (JSONB)
  - Relations: belongs_to :course, belongs_to :professor, belongs_to :academic_term, has_many :enrollments

- **AcademicTerm**
  - Fields: name, start_date, end_date, registration_start, registration_end, is_active
  - Relations: has_many :sections, has_many :enrollments

- **Enrollment**
  - Fields: student_id, section_id, academic_term_id, status, registered_at, dropped_at
  - Relations: belongs_to :student, belongs_to :section, belongs_to :academic_term, has_one :grade

- **EnrollmentWaitlist**
  - Fields: student_id, section_id, academic_term_id, position, priority_score, requested_at
  - Relations: belongs_to :student, belongs_to :section

- **Student**
  - Fields: user_id, student_number, faculty_id, department_id, academic_year, semester, enrollment_status, gpa, academic_standing, enrolled_at, graduated_at
  - Relations: belongs_to :user, belongs_to :faculty, belongs_to :department, has_many :enrollments

- **StudentTermGpa**
  - Fields: student_id, academic_term_id, gpa, credit_hours_completed
  - Relations: belongs_to :student, belongs_to :academic_term

- **StudentDepartmentHistory**
  - Fields: student_id, department_id, academic_year, semester, reason
  - Relations: belongs_to :student, belongs_to :department

### 4. **Grading & Performance**

- **Grade**
  - Fields: enrollment_id, points, letter_grade, status (complete/incomplete)
  - Relations: belongs_to :enrollment

- **CourseRating**
  - Fields: enrollment_id, rating (1-5), feedback, submitted_at
  - Relations: belongs_to :enrollment

### 5. **Attendance**

- **AttendanceSession**
  - Fields: section_id, date, session_number, status
  - Relations: belongs_to :section, has_many :attendance_records

- **AttendanceRecord**
  - Fields: attendance_session_id, student_id, status (present/absent/late), note
  - Relations: belongs_to :attendance_session, belongs_to :student

### 6. **Communication**

- **Announcement** (university-wide)
  - Fields: user_id, title, content, published_at, is_published
  - Relations: has_many :announcement_reads, belongs_to :user

- **AnnouncementRead**
  - Fields: user_id, announcement_id, read_at
  - Track announcement engagement

- **SectionAnnouncement** (course-specific)
  - Fields: section_id, user_id (professor), title, content, published_at
  - Relations: belongs_to :section, belongs_to :user

### 7. **Notifications**

- **Notification** (polymorphic)
  - Fields: user_id, type, data (JSONB), read_at
  - System notifications for enrollments, grades, announcements, etc.

### 8. **System Features**

- **AuditLog**
  - Fields: user_id, action, auditable_type, auditable_id, description, old_values (JSONB), new_values (JSONB), ip_address
  - Complete audit trail of all system changes

- **Webhook**
  - Fields: user_id, url, secret, events (JSONB array), is_active, failure_count, last_triggered_at
  - Relations: has_many :webhook_deliveries

- **WebhookDelivery**
  - Fields: webhook_id, event, payload (JSONB), status, response, attempt_count, next_retry_at
  - Relations: belongs_to :webhook

---

## API ENDPOINTS STRUCTURE

### Authentication Routes (Public + Rate Limited)

```bash
POST   /api/auth/login                    - Login with email/password
POST   /api/auth/forgot-password          - Request password reset
POST   /api/auth/reset-password           - Reset password with token
```

### Authentication Routes (Protected)

```bash
POST   /api/auth/logout                   - Logout user
GET    /api/auth/me                       - Get current user profile
POST   /api/auth/change-password          - Change password
PATCH  /api/auth/profile                  - Update profile (phone, dob, avatar)
GET    /api/auth/tokens                   - List active tokens
DELETE /api/auth/tokens                   - Revoke all tokens
DELETE /api/auth/tokens/{tokenId}         - Revoke specific token
```

### Announcements Routes (Protected)

```bash
GET    /api/announcements                 - Get all announcements
POST   /api/announcements/{id}/read       - Mark announcement as read
```

### Notifications Routes (Protected)

```bash
GET    /api/notifications                 - Get user notifications
POST   /api/notifications/read-all        - Mark all as read
POST   /api/notifications/{id}/read       - Mark single as read
DELETE /api/notifications/{id}            - Delete notification
```

### Student Portal Routes (Protected - Student Role)

```bash
GET    /api/student/profile               - Get student profile
GET    /api/student/enrollments           - List enrolled courses
POST   /api/student/enrollments           - Enroll in course
DELETE /api/student/enrollments/{id}      - Drop course
GET    /api/student/grades                - Get all grades
GET    /api/student/transcript            - Get academic transcript
GET    /api/student/transcript/pdf        - Download transcript as PDF
GET    /api/student/academic-history      - Get academic history
GET    /api/student/schedule              - Get class schedule
GET    /api/student/schedule/ics          - Download schedule as iCal
GET    /api/student/attendance            - Get attendance records
GET    /api/student/ratings               - Get course ratings submitted
POST   /api/student/ratings               - Submit course rating
GET    /api/student/waitlist              - Get waitlist entries
DELETE /api/student/waitlist/{sectionId}  - Remove from waitlist
```

### Professor Portal Routes (Protected - Professor Role)

```bash
GET    /api/professor/profile             - Get professor profile
GET    /api/professor/sections            - List taught sections
GET    /api/professor/schedule            - Get teaching schedule
GET    /api/professor/sections/{id}/students         - Get section students
GET    /api/professor/sections/{id}/grades           - Get all grades
POST   /api/professor/sections/{id}/grades           - Submit grades
GET    /api/professor/sections/{id}/attendance       - Get attendance sessions
POST   /api/professor/sections/{id}/attendance       - Create attendance session
GET    /api/professor/sections/{id}/attendance/{sessionId}    - Get session details
PUT    /api/professor/sections/{id}/attendance/{sessionId}    - Update attendance records
GET    /api/professor/sections/{id}/announcements    - Get section announcements
POST   /api/professor/sections/{id}/announcements    - Create announcement
DELETE /api/professor/sections/{id}/announcements/{id} - Delete announcement
```

### Admin Routes (Protected - Admin/Faculty Admin/Department Admin Roles)

```bash
GET    /api/admin/webhooks                - List webhooks
POST   /api/admin/webhooks                - Create webhook
PATCH  /api/admin/webhooks/{id}           - Update webhook
DELETE /api/admin/webhooks/{id}           - Delete webhook
GET    /api/admin/webhooks/{id}/deliveries - Get webhook delivery history
```

---

## RAILS IMPLEMENTATION PATTERNS

### 1. Controllers (API Mode)

```ruby
# app/controllers/api/auth_controller.rb
module Api
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: [:login, :forgot_password, :reset_password]
    before_action :set_rate_limit, only: [:login]

    def login
      user = User.find_by(email: params[:email])
      
      unless user&.authenticate(params[:password])
        return render json: { error: 'Invalid credentials' }, status: :unauthorized
      end

      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: user.as_json }, status: :ok
    end

    def me
      render json: current_user.as_json(include: [:roles])
    end

    private

    def set_rate_limit
      # Implement rate limiting with Rack::Attack
    end
  end
end
```

### 2. Models (ActiveRecord)

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

### 3. Service Objects

```ruby
# app/services/gpa_calculator.rb
class GpaCalculator
  GRADE_POINTS = {
    'A' => 4.0, 'A-' => 3.7, 'B+' => 3.3, 'B' => 3.0,
    'B-' => 2.7, 'C+' => 2.3, 'C' => 2.0, 'D' => 1.0, 'F' => 0.0
  }.freeze

  def initialize(student)
    @student = student
  end

  def calculate_term_gpa(term_id)
    grades = Grade.joins(enrollment: :academic_term)
                  .where(enrollments: { student_id: @student.id, academic_term_id: term_id })
    
    return 0.0 if grades.empty?
    
    total_points = grades.sum { |g| GRADE_POINTS[g.letter_grade] * g.enrollment.section.course.credit_hours }
    total_credits = grades.sum { |g| g.enrollment.section.course.credit_hours }
    
    (total_points / total_credits).round(2)
  end
end
```

### 4. Policies (Pundit)

```ruby
# app/policies/student_policy.rb
class StudentPolicy < ApplicationPolicy
  def show?
    user.admin? || user == record.user
  end
  
  def enroll?
    user.student? && user.student == record
  end
  
  def drop?
    user.student? && user.student == record && enrollment_within_deadline?
  end
  
  private
  
  def enrollment_within_deadline?
    # Check if within drop deadline
    term = AcademicTerm.current
    Time.current <= term.registration_end
  end
end
```

### 5. Background Jobs

```ruby
# app/jobs/send_email_job.rb
class SendEmailJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  def perform(mailer_class, method_name, *args)
    mailer_class.constantize.send(method_name, *args).deliver_later
  end
end
```

### 6. Mailers

```ruby
# app/mailers/announcement_mailer.rb
class AnnouncementMailer < ApplicationMailer
  def new_announcement(user, announcement)
    @user = user
    @announcement = announcement
    
    mail(
      to: @user.email,
      subject: "New Announcement: #{@announcement.title}"
    )
  end
end
```

---

## IMPLEMENTATION PHASES

### Phase 1: Foundation (Week 1)

- [ ] Rails project setup (rails new unione_rails --api)
- [ ] Database configuration and connection
- [ ] Create all migrations (34 tables)
- [ ] User & authentication models (Devise + JWT)
- [ ] Auth controller & token management
- [ ] Role & authorization setup (Pundit)
- [ ] Basic models (University, Faculty, Department)
- [ ] Seed data for roles

### Phase 2: Student Portal (Week 2)

- [ ] Student model & relationships
- [ ] Course & Section models
- [ ] Enrollment system (service object)
- [ ] Grade management
- [ ] Student controller & routes
- [ ] Enrollment validations (prerequisites, capacity)

### Phase 3: Professor Portal (Week 3)

- [ ] Professor model & relationships
- [ ] Grade submission (bulk operations)
- [ ] Attendance management
- [ ] Section announcements
- [ ] Professor controller & routes

### Phase 4: Academic Features (Week 4)

- [ ] Academic terms management
- [ ] GPA calculation service
- [ ] Academic standing logic
- [ ] Transcript generation (PDF with Wicked PDF)
- [ ] Schedule/iCal export

### Phase 5: Communication & Notifications (Week 5)

- [ ] Announcements system
- [ ] Real-time notifications (ActionCable)
- [ ] Email notifications (ActionMailer)
- [ ] Notification controller & routes

### Phase 6: Advanced Features (Week 6)

- [ ] Audit logging (model callbacks or observers)
- [ ] Webhook system (background jobs)
- [ ] Waitlist management
- [ ] Course ratings
- [ ] Admin webhooks management

### Phase 7: Admin & Management (Week 7)

- [ ] Admin dashboard (if full-stack)
- [ ] User management
- [ ] Role scoping
- [ ] Organization structure management
- [ ] Admin controller & routes

### Phase 8: Testing & Optimization (Week 8)

- [ ] RSpec tests for all models
- [ ] Request specs for endpoints
- [ ] Performance optimization (N+1 queries)
- [ ] API documentation (RDoc or Swagger)
- [ ] Deployment preparation

---

## KEY CONSIDERATIONS FOR RAILS MIGRATION

### Database Layer

- Use ActiveRecord migrations (built-in)
- PostgreSQL connection pooling configured in database.yml
- Use same database (unione_db) for seamless transition

### Authentication

- Replace JWT tokens with Devise + JWT gem
- Implement token refresh mechanism
- Use bcrypt (built-in with has_secure_password)
- Implement rate limiting (rack-attack gem)

### Middleware Stack

- Rack middleware for auth, validation, error handling
- Custom middleware for role-based access
- Error handling centralization
- Request logging (built-in)

### Validation

- ActiveModel validations (built-in)
- Custom validation methods
- Consistent error response format

### File Handling

- Active Storage for avatar uploads
- PDF generation (wicked_pdf or prawn gem)
- iCal generation (icalendar gem)
- File storage in local filesystem or cloud (S3)

### Notifications

- ActionMailer for email service
- Active Job for async jobs (Sidekiq or GoodJob)
- ActionCable for real-time notifications

### Performance

- Database connection pooling (configured)
- Eager loading with includes/preload
- Caching layer (Redis)
- Pagination with kaminari or will_paginate

---

## REPOSITORY STRUCTURE FOR RAILS

```bash
unione_rails/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   ├── auth_controller.rb
│   │   │   ├── student/
│   │   │   │   ├── profile_controller.rb
│   │   │   │   ├── enrollments_controller.rb
│   │   │   │   ├── grades_controller.rb
│   │   │   │   ├── transcript_controller.rb
│   │   │   │   ├── schedule_controller.rb
│   │   │   │   ├── attendance_controller.rb
│   │   │   │   └── ratings_controller.rb
│   │   │   ├── professor/
│   │   │   │   ├── profile_controller.rb
│   │   │   │   ├── sections_controller.rb
│   │   │   │   ├── grades_controller.rb
│   │   │   │   ├── attendance_controller.rb
│   │   │   │   └── announcements_controller.rb
│   │   │   ├── admin/
│   │   │   │   ├── webhooks_controller.rb
│   │   │   │   ├── analytics_controller.rb
│   │   │   │   └── users_controller.rb
│   │   │   ├── announcements_controller.rb
│   │   │   └── notifications_controller.rb
│   │   └── application_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── role.rb
│   │   ├── role_user.rb
│   │   ├── university.rb
│   │   ├── faculty.rb
│   │   ├── department.rb
│   │   ├── student.rb
│   │   ├── professor.rb
│   │   ├── employee.rb
│   │   ├── course.rb
│   │   ├── section.rb
│   │   ├── enrollment.rb
│   │   ├── enrollment_waitlist.rb
│   │   ├── grade.rb
│   │   ├── academic_term.rb
│   │   ├── student_term_gpa.rb
│   │   ├── student_department_history.rb
│   │   ├── course_rating.rb
│   │   ├── attendance_session.rb
│   │   ├── attendance_record.rb
│   │   ├── announcement.rb
│   │   ├── announcement_read.rb
│   │   ├── section_announcement.rb
│   │   ├── notification.rb
│   │   ├── audit_log.rb
│   │   ├── webhook.rb
│   │   ├── webhook_delivery.rb
│   │   └── university_vice_president.rb
│   ├── services/
│   │   ├── gpa_calculator.rb
│   │   ├── enrollment_service.rb
│   │   ├── authentication_service.rb
│   │   ├── attendance_service.rb
│   │   ├── webhook_service.rb
│   │   └── transcript_generator.rb
│   ├── policies/
│   │   ├── application_policy.rb
│   │   ├── user_policy.rb
│   │   ├── student_policy.rb
│   │   ├── professor_policy.rb
│   │   └── admin_policy.rb
│   ├── mailers/
│   │   ├── announcement_mailer.rb
│   │   ├── enrollment_mailer.rb
│   │   ├── grade_mailer.rb
│   │   └── password_mailer.rb
│   ├── jobs/
│   │   ├── send_email_job.rb
│   │   ├── webhook_delivery_job.rb
│   │   ├── generate_transcript_job.rb
│   │   └── application_job.rb
│   ├── channels/
│   │   ├── notification_channel.rb
│   │   └── application_cable/
│   └── views/
│       ├── layouts/
│       └── mailers/
├── db/
│   ├── migrate/
│   │   ├── 001_create_users.rb
│   │   ├── 002_create_roles.rb
│   │   ├── 003_create_role_users.rb
│   │   └── ... (34 migrations total)
│   ├── seeds/
│   │   ├── roles.rb
│   │   └── sample_data.rb
│   └── schema.rb
├── config/
│   ├── routes.rb
│   ├── database.yml
│   ├── application.rb
│   ├── credentials.yml.enc
│   └── initializers/
│       ├── devise.rb
│       ├── jwt.rb
│       ├── pundit.rb
│       ├── rack_attack.rb
│       └── cors.rb
├── spec/
│   ├── models/
│   ├── requests/
│   ├── services/
│   ├── mailers/
│   └── support/
│       ├── factory_bot.rb
│       └── helpers.rb
├── Gemfile
├── .env
├── .gitignore
├── Dockerfile
└── README.md
```

---

## DATABASE MIGRATION COUNT

### **Total Migrations: 34**

1. Create users
2. Create roles
3. Create role_users (join table)
4. Create universities
5. Create faculties
6. Create departments
7. Create professors
8. Create employees
9. Create students
10. Create student_department_histories
11. Create courses
12. Create department_courses (join table)
13. Create course_prerequisites (self-join)
14. Create academic_terms
15. Create sections
16. Create enrollments
17. Create enrollment_waitlists
18. Create grades
19. Create student_term_gpas
20. Create announcements
21. Create announcement_reads
22. Create section_announcements
23. Create attendance_sessions
24. Create attendance_records
25. Create course_ratings
26. Create audit_logs
27. Create webhooks
28. Create webhook_deliveries
29. Create university_vice_presidents
30. Create notifications
31. Create password_reset_tokens
32. Create personal_access_tokens
33. Create cache
34. Create jobs

---

## ESTIMATED EFFORT

- Rails Setup & Configuration: 1-2 days
- Database Migrations: 2-3 days
- API Implementation: 2-3 weeks
- Testing & Refinement: 1 week
- Documentation & Deployment: 3-5 days
- **Total: 4-5 weeks**

---

## Success Criteria

✅ All 34 tables created and migrated
✅ All 52+ API endpoints functional
✅ Role-based access working correctly
✅ Student/Professor portals fully operational
✅ GPA calculations accurate
✅ Notification system active
✅ Audit logging comprehensive
✅ 80%+ code coverage in tests
✅ API response times < 500ms
✅ Full parity with Laravel backend

---

## RAILS-SPECIFIC FEATURES

### 1. Strong Parameters

```ruby
def user_params
  params.require(:user).permit(:email, :password, :first_name, :last_name, :phone)
end
```

### 2. Scopes & Queries

```ruby
# app/models/user.rb
scope :active, -> { where(is_active: true) }
scope :students, -> { joins(:roles).where(roles: { slug: 'student' }) }
scope :professors, -> { joins(:roles).where(roles: { slug: 'professor' }) }

# app/models/enrollment.rb
scope :active, -> { where(status: 'active') }
scope :for_term, ->(term_id) { where(academic_term_id: term_id) }
```

### 3. Callbacks for Audit Logging

```ruby
class AuditLoggable
  def self.included(base)
    base.after_create :log_creation
    base.after_update :log_update
    base.after_destroy :log_destruction
  end
  
  private
  
  def log_creation
    AuditLog.create!(
      user: Current.user,
      action: 'create',
      auditable: self,
      new_values: attributes
    )
  end
end
```

### 4. JSONB Queries

```ruby
# Query JSONB fields
Section.where("schedule ->> 'location' = ?", 'Room 101')
Webhook.where("events @> ?", ['enrollment.created'].to_json)
```

---

## GEMFILE ESSENTIALS

```ruby
# Core
gem 'rails', '~> 7.1'
gem 'pg', '~> 1.5'
gem 'puma', '>= 5.0'

# Authentication & Authorization
gem 'devise'
gem 'jwt'
gem 'pundit'

# Security & Rate Limiting
gem 'rack-attack'
gem 'rack-cors'

# File Handling & PDF
gem 'active_storage_validations'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'icalendar'

# Background Jobs
gem 'sidekiq' # or 'good_job'

# Email
gem 'redis' # for ActionCable/ Sidekiq

# Pagination
gem 'kaminari'

# Testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'simplecov', require: false
end

# Development
group :development do
  gem 'bullet' # N+1 query detection
  gem 'annotate' # Auto-annotate models
end
```

---

## TESTING STRATEGY

### RSpec Structure

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:role_users) }
  it { should have_many(:roles).through(:role_users) }
  
  describe '#admin?' do
    it 'returns true if user has admin role' do
      user = create(:user, :admin)
      expect(user.admin?).to be true
    end
  end
end

# spec/requests/api/auth_spec.rb
RSpec.describe 'Api::Auth', type: :request do
  describe 'POST /api/auth/login' do
    context 'with valid credentials' do
      let(:user) { create(:user, password: 'password') }
      
      it 'returns authentication token' do
        post '/api/auth/login', params: { 
          email: user.email, 
          password: 'password' 
        }
        
        expect(response).to have_http_status(:ok)
        expect(json['token']).to be_present
      end
    end
  end
end
```

---

## DEPLOYMENT CHECKLIST

- [ ] Database backup strategy
- [ ] Environment variables configured
- [ ] SSL certificates
- [ ] CDN for assets
- [ ] Monitoring setup (New Relic, Skylight)
- [ ] Log aggregation
- [ ] Backup testing procedures
- [ ] Rollback plan

---

**Last Updated**: April 11, 2026
**Maintainers**: Development Team
**Status**: 🟢 Ready for Implementation
