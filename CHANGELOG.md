# Changelog

All notable changes to the UniOne Rails project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - April 12, 2026

#### Phase 8 - Enhancements
- Admin CRUD controllers for Students, Professors, Employees, Sections
- Student Section Announcements controller
- Student Import Service (CSV/Array)
- Grade Import Service (CSV/Array)
- Grade Submission Service with bulk operations
- Authentication Service (login, register, password reset)
- Exam Schedule Service with conflict detection
- ApplicationMailer base class (critical fix)
- ApplicationJob base class (critical fix)
- FactoryBot support file (critical fix)
- Missing policies: Webhook, AcademicTerm, Employee, Role
- Missing mailers: PasswordMailer, ExamScheduleMailer
- Missing jobs: SendEmail, SendAnnouncementEmail, SendGradeNotification
- Comprehensive factories for all 31+ models
- API Documentation (API_DOCUMENTATION.md)
- Project Audit Summary (AUDIT_SUMMARY.md)

#### Phase 7 - Admin & Management
- Admin users management controller with role assignment
- Admin analytics dashboard with comprehensive statistics
- User statistics endpoint
- User activation/deactivation endpoints

#### Phase 6 - Advanced Features
- Audit logging system with middleware
- Webhook delivery system with background jobs
- Webhook trigger service
- Audit logs admin endpoint with filtering and statistics
- EagerLoadable concern for N+1 query prevention
- ApiFormatter concern for consistent responses

#### Phase 5 - Communication & Notifications
- ActionCable real-time notifications
- NotificationChannel for WebSocket streaming
- Email mailers: Notification, Enrollment, Grade, Announcement
- Notification broadcast service
- Email integration with enrollment, grade, and announcement events

#### Phase 4 - Academic Features
- PDF transcript generation with Prawn
- Academic standing service with auto-update logic
- Prerequisite validation service
- Waitlist auto-enrollment background job
- Enhanced academic terms management with activate/deactivate

#### Phase 3 - Professor Portal
- Professor profile controller
- Sections controller with student lists
- Grades controller with bulk submission
- Attendance controller with sessions and statistics
- Section announcements controller

#### Phase 2 - Student Portal
- Student profile controller
- Enrollments controller with validation
- Grades controller with GPA calculation
- Transcript controller with academic history
- Schedule controller with iCal export
- Attendance controller with statistics
- Ratings controller for course feedback
- Waitlist controller with priority scoring

#### Phase 1 - Foundation
- Rails 7.1 API setup with PostgreSQL
- 35 database migrations (all applied)
- 33 ActiveRecord models with associations and validations
- JWT authentication with Devise
- Pundit authorization policies (21 policies)
- Rack::Attack rate limiting
- CORS configuration
- Comprehensive seed data

### Changed
- Updated User model to include additional associations
- Enhanced enrollment validation with prerequisite checking
- Improved GPA calculation accuracy
- Added namespace resolution (::) in admin controllers

### Fixed
- ApplicationMailer base class missing (caused NameError)
- ApplicationJob base class missing (caused NameError)
- Middleware remote_ip access error
- Namespace conflicts in admin controllers
- Student academic standing enum updated to include 'excellent'

## Statistics

| Metric | Count |
|--------|-------|
| Database Tables | 35 |
| Models | 33 |
| Controllers | 36 |
| API Endpoints | 90+ |
| Service Objects | 16 |
| Mailers | 6 |
| Background Jobs | 5 |
| Policies | 21 |
| Factories | 31+ |
| Test Files | 10+ |
| Lines of Code | ~18,000+ |

---

[Unreleased]: https://github.com/unione/unione_rails/compare/v0.1.0...HEAD
