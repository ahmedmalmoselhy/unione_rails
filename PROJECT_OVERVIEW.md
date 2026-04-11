# UniOne Complete Project Overview - Rails Edition

**Last Updated**: April 11, 2026
**Status**: Full Implementation Plan Complete (Rails Backend + Optional Frontend)
**Total Effort**: 7-8 weeks

---

## 🎯 Project Summary

UniOne is a comprehensive academic management system supporting:

- **Universities** with multiple faculties and departments
- **6 User Roles** with hierarchical scoping
- **Student Lifecycle** from enrollment to graduation
- **Academic Management** including grading, GPA calculations, transcripts
- **Communication** via announcements and notifications
- **Integration** through webhooks and audit logging

### Multi-Platform Architecture

```bash
Rails API Backend      ←→  Database (PostgreSQL)
      ↓
Hotwire (Turbo/Stimulus)  OR  React/Vue SPA
```

---

## 📊 Project Statistics

| Metric | Count |
| -------- | ------- |
| **Rails Models** | 27 core + 7 system = 34 total |
| **API Endpoints** | 52+ |
| **Database Tables** | 34 |
| **User Roles** | 6 |
| **Feature Categories** | 10 |
| **Implementation Phases** | 8 |
| **Total Effort** | 7-8 weeks |

---

## 🏗️ Architecture Components

### Backend Stack (Ruby on Rails)

```bash
HTTP Layer:     Rails 7+ (API mode or full-stack)
Database:       PostgreSQL + ActiveRecord
Authentication: Devise + JWT (for API)
Authorization:  Pundit or CanCanCan
Validation:     ActiveModel Validations (built-in)
File Handling:  Active Storage
Email:          ActionMailer
Background Jobs: Active Job + Sidekiq/GoodJob
Security:       Rack::Attack (rate limiting), Strong Parameters
Testing:        RSpec + FactoryBot + Faker
Deployment:     Docker + Capistrano
```

### Frontend Options

**Option 1: Hotwire (Recommended for Rails monolith)**
```bash
Framework:      Turbo Drive + Turbo Frames + Stimulus
Styling:        Tailwind CSS
Routing:        Rails routes
Real-time:      ActionCable + Turbo Streams
PDF:            Wicked PDF or Prawnto
Calendar:       FullCalendar.js (via importmap)
```

**Option 2: Separate SPA (API-only Rails)**
```bash
Build:          Vite (via vite_rails gem)
Framework:      React 18+ or Vue 3 + TypeScript
Styling:        Tailwind CSS + Headless UI
State:          React Query or Pinia/Redux
HTTP:           Axios
Forms:          React Hook Form + Zod
Router:         React Router v6 or Vue Router
```

---

## 📋 Feature Breakdown

### 1️⃣ Authentication & Security (5 features)

- Email/password login with rate limiting
- JWT token management and refresh
- Role-Based Access Control (RBAC)
- Password reset & change flows
- Audit logging of all actions

### 2️⃣ Student Features (8 major areas)

```bash
Profile            → View academic info
Enrollments        → Browse catalog, enroll/drop, waitlist
Grades             → View all grades and transcripts
Transcript         → Academic history, downloadable PDF
Schedule           → Calendar view + iCal export
Attendance         → Track attendance records
Academic History   → Department transfers, GPA trends
Ratings            → Rate courses post-completion
```

### 3️⃣ Professor Features (5 major areas)

```bash
Profile            → View assignment details
Sections           → Manage taught sections
Students           → View section enrollment
Grading            → Submit grades in bulk
Attendance         → Create sessions, record attendance
Announcements      → Create section announcements
Schedule           → View class schedule
```

### 4️⃣ Academic Management

- GPA calculations (term-based)
- Academic standing tracking
- Course prerequisites validation
- Student department transfer history
- Multi-semester progression

### 5️⃣ Communication

- University-wide announcements
- Section-specific announcements
- Real-time notifications
- Notification center with badge

### 6️⃣ Advanced Features

- PDF transcript generation
- iCal schedule export
- Webhook system for integrations
- Audit logging
- Multi-language support (EN/AR)
- Soft deletes for data recovery

---

## 📁 Repository Structure

### Rails Backend Directory

```bash
unione_rails/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   ├── auth_controller.rb
│   │   │   ├── student/
│   │   │   │   ├── profile_controller.rb
│   │   │   │   ├── enrollments_controller.rb
│   │   │   │   └── grades_controller.rb
│   │   │   ├── professor/
│   │   │   │   ├── profile_controller.rb
│   │   │   │   ├── sections_controller.rb
│   │   │   │   └── grades_controller.rb
│   │   │   └── admin/
│   │   │       ├── webhooks_controller.rb
│   │   │       └── analytics_controller.rb
│   │   └── application_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── student.rb
│   │   ├── professor.rb
│   │   ├── course.rb
│   │   ├── section.rb
│   │   ├── enrollment.rb
│   │   └── ... (27 core models)
│   ├── services/
│   │   ├── gpa_calculator.rb
│   │   ├── enrollment_service.rb
│   │   ├── authentication_service.rb
│   │   └── webhook_service.rb
│   ├── policies/
│   │   ├── user_policy.rb
│   │   ├── student_policy.rb
│   │   └── ... (Pundit policies)
│   ├── mailers/
│   │   ├── announcement_mailer.rb
│   │   ├── enrollment_mailer.rb
│   │   └── password_mailer.rb
│   ├── jobs/
│   │   ├── send_email_job.rb
│   │   ├── webhook_delivery_job.rb
│   │   └── generate_transcript_job.rb
│   └── channels/
│       ├── notification_channel.rb
│       └── application_cable/
├── db/
│   ├── migrate/
│   │   ├── 001_create_users.rb
│   │   ├── 002_create_roles.rb
│   │   └── ... (34 migrations)
│   ├── seeds/
│   │   ├── roles.rb
│   │   └── sample_data.rb
│   └── schema.rb
├── config/
│   ├── routes.rb
│   ├── database.yml
│   ├── application.rb
│   └── credentials.yml.enc
├── spec/
│   ├── models/
│   ├── requests/
│   ├── services/
│   └── support/
├── Gemfile
├── .env
└── Documentation files
```

---

## 🔄 Development Phases

### Week 1: Foundation

**Backend (Rails)**

- [ ] Rails project setup and configuration
- [ ] Database connection & migrations setup
- [ ] Core models (User, Role, University, Faculty, Department)
- [ ] Authentication system (Devise + JWT)
- [ ] Authorization setup (Pundit)

### Week 2-3: Core Features

**Backend Features**

- [ ] Student model & relationships
- [ ] Course & Section models
- [ ] Enrollment system
- [ ] Grade management
- [ ] API endpoints for student portal

**Frontend (if applicable)**

- [ ] Student dashboard
- [ ] Course enrollment system
- [ ] Grades view
- [ ] Academic records display

### Week 4: Professor Portal & Advanced Features

**Backend**

- [ ] Professor model & relationships
- [ ] Attendance system
- [ ] Section announcements
- [ ] Professor API endpoints

**Frontend**

- [ ] Professor portal
- [ ] Grade submission
- [ ] Attendance tracking
- [ ] Announcements UI

### Week 5: Communication & System Features

**Backend**

- [ ] Announcements system
- [ ] Notifications
- [ ] Webhooks & audit logging
- [ ] Advanced features

**Frontend**

- [ ] Announcements display
- [ ] Notifications center
- [ ] Admin panel
- [ ] Real-time updates

### Week 6-7: Integration & Polish

**Backend + Frontend**

- [ ] End-to-end testing
- [ ] API-UI integration
- [ ] Performance optimization
- [ ] Error handling
- [ ] Documentation

### Week 8: Deployment

**Backend + Frontend**

- [ ] Docker containerization
- [ ] CI/CD setup
- [ ] Production deployment
- [ ] Monitoring setup

---

## 🎯 API Layer

### Authentication (3 public + 10 protected)

```bash
POST   /api/auth/login
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
POST   /api/auth/logout
GET    /api/auth/me
POST   /api/auth/change-password
PATCH  /api/auth/profile
GET    /api/auth/tokens
DELETE /api/auth/tokens
DELETE /api/auth/tokens/{id}
```

### Student Portal (15 endpoints)

```bash
GET    /api/student/profile
GET    /api/student/enrollments
POST   /api/student/enrollments
DELETE /api/student/enrollments/{id}
GET    /api/student/grades
GET    /api/student/transcript
GET    /api/student/transcript/pdf
GET    /api/student/academic-history
GET    /api/student/schedule
GET    /api/student/schedule/ics
GET    /api/student/attendance
GET    /api/student/ratings
POST   /api/student/ratings
GET    /api/student/waitlist
DELETE /api/student/waitlist/{sectionId}
```

### Professor Portal (13 endpoints)

```bash
GET    /api/professor/profile
GET    /api/professor/sections
GET    /api/professor/schedule
GET    /api/professor/sections/{id}/students
GET    /api/professor/sections/{id}/grades
POST   /api/professor/sections/{id}/grades
GET    /api/professor/sections/{id}/attendance
POST   /api/professor/sections/{id}/attendance
GET    /api/professor/sections/{id}/attendance/{sessionId}
PUT    /api/professor/sections/{id}/attendance/{sessionId}
GET    /api/professor/sections/{id}/announcements
POST   /api/professor/sections/{id}/announcements
DELETE /api/professor/sections/{id}/announcements/{id}
```

### Shared & Admin (9 endpoints)

```bash
GET    /api/announcements
POST   /api/announcements/{id}/read
GET    /api/notifications
POST   /api/notifications/read-all
POST   /api/notifications/{id}/read
DELETE /api/notifications/{id}
GET    /api/admin/webhooks
POST   /api/admin/webhooks
PATCH  /api/admin/webhooks/{id}
```

---

## 💾 Database Schema (34 Tables)

### User & Organization (6 tables)

- users, roles, role_user
- universities, faculties, departments

### Academic (8 tables)

- courses, sections, enrollments
- academic_terms, student_term_gpas
- professors, employees

### Grading & Performance (3 tables)

- grades, course_ratings
- student_department_histories

### Communication (3 tables)

- announcements, announcement_reads
- section_announcements

### Attendance (2 tables)

- attendance_sessions, attendance_records

### System (6 tables)

- audit_logs, webhooks, webhook_deliveries
- notifications, password_reset_tokens
- personal_access_tokens

Plus: cache, jobs tables

---

## 🧪 Testing Strategy

### Backend Testing (RSpec)

```bash
Model Tests:         Model validations, associations, scopes
Request Specs:       API endpoints, authentication, responses
Service Tests:       Business logic (GPA, enrollment, etc.)
Mailer Tests:        Email delivery and templates
Job Tests:           Background job execution
Coverage Target:     80%+
Framework:           RSpec + FactoryBot + Faker + SimpleCov
```

### Frontend Testing

**For Hotwire:**
```bash
System Tests:        Rails system tests (Capybara + Selenium)
Integration:         Full user workflows
Coverage Target:     80%+
Framework:           Minitest::Spec or RSpec + Capybara
```

**For SPA:**
```bash
Unit Tests:          Components, hooks, utilities
Integration:         Page navigation, data flow
E2E Tests:           Complete user workflows
Coverage Target:     80%+
Frameworks:          Jest + React Testing Library + Cypress
```

### Test Scenarios

```bash
Student Workflow:   Login → Enroll → View Grades → Rate Course
Professor Flow:     Login → View Sections → Submit Grades
Admin Tasks:        Login → Manage Webhooks → View Audit Logs
```

---

## 🚀 Deployment Strategy

### Containerization

```dockerfile
# Dockerfile
FROM ruby:3.2-slim
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN bundle exec rails assets:precompile
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
```

### Deployment Options

**Option 1: Traditional (Capistrano)**
- **Web Server**: Puma
- **Reverse Proxy**: Nginx
- **Database**: PostgreSQL
- **Cache**: Redis
- **Queue**: Sidekiq
- **CI/CD**: GitHub Actions

**Option 2: Platform as a Service**
- **Heroku**: Easy deployment with addons
- **Render**: Modern PaaS with PostgreSQL
- **Fly.io**: Global edge deployment
- **DigitalOcean App Platform**: Simple scaling

**Option 3: Kubernetes**
- **Container Runtime**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitHub Actions or GitLab CI
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack

### Environment Setup

```bash
Development:    localhost:3000
Staging:        staging.example.com
Production:     api.example.com or app.example.com
Database:       PostgreSQL (unione_db)
Cache:          Redis
Queue:          Sidekiq or GoodJob
```

---

## 📚 Documentation Files

1. **IMPLEMENTATION_PLAN.md** ⭐
   - Complete 8-phase Rails implementation
   - Rails-specific patterns and conventions
   - Controller, model, and service examples

2. **API_ENDPOINTS.md**
   - Complete endpoint documentation
   - Request/response examples
   - Rate limiting rules

3. **DATABASE_SCHEMA.md**
   - All 34 tables documented
   - Relationships and constraints
   - Migration order

4. **FEATURES_REFERENCE.md**
   - Feature matrix
   - User roles and capabilities
   - Technology stack details

5. **DEPENDENCIES_SETUP.md**
   - Rails gems installation
   - Development environment setup
   - Testing configuration

---

## ✅ Success Criteria

### Backend (Rails)

✅ All 34 tables created and migrated
✅ All 52+ API endpoints functional
✅ Role-based access working
✅ GPA calculations accurate
✅ Notification system active
✅ Audit logging comprehensive
✅ 80%+ test coverage
✅ API response times < 500ms

### Frontend (if applicable)

✅ All portals (Student, Professor, Admin) functional
✅ Responsive design (mobile/tablet/desktop)
✅ Real-time notifications working
✅ PDF and iCal export working
✅ Role-based UI rendering
✅ 80%+ test coverage
✅ Accessibility compliant (WCAG 2.1 AA)

### Overall

✅ End-to-end user workflows
✅ Full parity with Laravel backend
✅ Production-ready deployment
✅ Comprehensive documentation

---

## 🎓 Learning Resources

### Rails Backend

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- [Action Controller Overview](https://guides.rubyonrails.org/action_controller_overview.html)
- [Devise Authentication](https://github.com/heartcombo/devise)
- [Pundit Authorization](https://github.com/varvet/pundit)

### Testing

- [RSpec Documentation](https://rspec.info/)
- [FactoryBot Guide](https://github.com/thoughtbot/factory_bot_rails)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)

### Database

- [PostgreSQL Docs](https://www.postgresql.org/docs)
- [Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html)

---

## 📞 Support & Resources

### Common Issues

| Issue | Solution |
| ------- | ---------- |
| Database connection failed | Check credentials, ensure PostgreSQL running |
| API 401 Unauthorized | Token expired → refresh or re-login |
| CORS Error | Backend CORS config needs frontend URL |
| Gem installation fails | Check Ruby version, run `bundle update` |

### Getting Help

1. Check relevant documentation file
2. Review error messages in logs
3. Check Rails guides and Stack Overflow
4. Compare with Laravel/Node implementations

---

## 🎯 Next Steps

### Immediate (Today)

1. ✅ Documentation complete
2. Create Rails project structure
3. Install gems and dependencies

### This Week

1. Create database migrations
2. Implement authentication system
3. Connect to database

### By End of Week 2

1. ✅ Rails Phase 1 complete
2. Student basic features working
3. End-to-end enrollment flow

---

## 📊 Project Timeline

```bash
Week 1  |████| Foundation (Rails setup + Auth)
Week 2  |████| Student Portal Core
Week 3  |████| Academic Records + Professor Start
Week 4  |████| Professor Portal Complete
Week 5  |████| Communication & System Features
Week 6  |████| Admin & Advanced Features
Week 7  |████| Integration & Polish
Week 8  |████| Testing, Deployment, Finalization

Total: 7-8 weeks for complete Rails implementation
```

---

## 📝 Version History

| Date | Status | Notes |
| ------ | -------- | ------- |
| Apr 11, 2026 | Planning Complete | Full Rails implementation plan |
| Apr 11, 2026 | Documentation Ready | All docs created |
| Upcoming | Phase 1 Start | Rails setup and authentication |

---

**Last Updated**: April 11, 2026
**Maintainers**: Development Team
**Status**: 🟢 Ready for Implementation
