# UniOne Rails Quick Reference Card

> **Print this** or bookmark for fast lookups during development

---

## 🚀 Essential Commands

### Rails Setup

```bash
rails new unione_rails --api --database=postgresql  # Create project
cd unione_rails
bundle install                                      # Install gems
rails db:create                                     # Create database
rails db:migrate                                    # Run migrations
rails db:seed                                       # Seed database
rails server                                        # Start server (port 3000)
```

### Development

```bash
rails server -p 3001          # Start on different port
rails console                 # Rails console
rails db:migrate:status       # Check migration status
rails routes                  # Show all routes
rails generate model User     # Generate model
rails generate controller Api::Auth  # Generate controller
rails generate migration AddFieldToTable field:type  # Generate migration
bundle exec rspec             # Run tests
```

---

## 📊 System at a Glance

| Aspect | Details |
| -------- | --------- |
| **User Roles** | Admin, Faculty Admin, Department Admin, Professor, Student, Employee |
| **Database Tables** | 34 total (27 core models + 7 system) |
| **API Endpoints** | 52+ REST endpoints |
| **Timeline** | 7-8 weeks (Rails implementation) |
| **Tech Stack** | Rails 7+ + PostgreSQL + Devise + JWT + Pundit |
| **Testing** | RSpec + FactoryBot + SimpleCov |

---

## 📁 Database Tables (Quick Reference)

### Core (27 Models)

**Users & Auth**: User, Role, RoleUser
**Organization**: University, Faculty, Department, UniversityVicePresident
**Academic**: Course, Section, AcademicTerm, CoursePrerequisite, DepartmentCourse
**People**: Student, Professor, Employee
**Enrollment**: Enrollment, EnrollmentWaitlist
**Grading**: Grade, CourseRating, StudentTermGpa
**Attendance**: AttendanceSession, AttendanceRecord
**History**: StudentDepartmentHistory

### Communication (3 Tables)

Announcement, AnnouncementRead, SectionAnnouncement

### System (6 Tables)

Notification, AuditLog, Webhook, WebhookDelivery, PasswordResetToken, PersonalAccessToken

---

## 🔌 API Endpoint Categories

### Authentication (10 endpoints)

`POST /api/auth/login` • `POST /api/auth/logout` • `GET /api/auth/me`
`POST /api/auth/change-password` • `PATCH /api/auth/profile`
`POST /api/auth/forgot-password` • `POST /api/auth/reset-password`
`GET /api/auth/tokens` • `DELETE /api/auth/tokens` • `DELETE /api/auth/tokens/:id`

### Student Portal (15 endpoints)

`GET /api/student/profile` • `GET/POST /api/student/enrollments` • `DELETE /api/student/enrollments/:id`
`GET /api/student/grades` • `GET /api/student/transcript` • `GET /api/student/transcript/pdf`
`GET /api/student/schedule` • `GET /api/student/schedule/ics`
`GET /api/student/attendance` • `GET/POST /api/student/ratings`
`GET /api/student/academic-history` • `GET /api/student/waitlist` • `DELETE /api/student/waitlist/:id`

### Professor Portal (13 endpoints)

`GET /api/professor/profile` • `GET /api/professor/sections` • `GET /api/professor/schedule`
`GET /api/professor/sections/:id/students` • `GET/POST /api/professor/sections/:id/grades`
`GET/POST /api/professor/sections/:id/attendance` • `GET/PUT /api/professor/sections/:id/attendance/:sessionId`
`GET/POST /api/professor/sections/:id/announcements` • `DELETE /api/professor/sections/:id/announcements/:id`

### Shared (8 endpoints)

`GET /api/announcements` • `POST /api/announcements/:id/read`
`GET /api/notifications` • `POST /api/notifications/read-all`
`POST /api/notifications/:id/read` • `DELETE /api/notifications/:id`

### Admin (5+ endpoints)

`GET/POST/PATCH/DELETE /api/admin/webhooks` • `GET /api/admin/webhooks/:id/deliveries`

---

## 🔐 Security Checklist

+ ✅ Devise authentication
+ ✅ JWT tokens for API
+ ✅ Pundit authorization policies
+ ✅ Password hashing (bcrypt)
+ ✅ Rate limiting (Rack::Attack)
+ ✅ CORS configured
+ ✅ Strong parameters
+ ✅ SQL injection prevention (ActiveRecord)

---

## 📝 File Organization

```bash
unione_rails/
├── app/
│   ├── controllers/api/     # API controllers (namespaced)
│   ├── models/              # ActiveRecord models
│   ├── services/            # Business logic (service objects)
│   ├── policies/            # Pundit authorization policies
│   ├── mailers/             # Email notifications
│   ├── jobs/                # Background jobs (Sidekiq)
│   └── channels/            # ActionCable (real-time)
├── db/
│   ├── migrate/             # Database migrations (34 total)
│   ├── seeds/               # Seed data
│   └── schema.rb            # Current schema
├── config/
│   ├── routes.rb            # API routes
│   ├── database.yml         # Database configuration
│   └── credentials.yml.enc  # Encrypted secrets
├── spec/                    # RSpec tests
│   ├── models/
│   ├── requests/
│   └── services/
└── Gemfile                  # Dependencies
```

---

## 🧪 Testing Quick Start

### RSpec Commands

```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/models        # Model tests only
bundle exec rspec spec/requests      # Request tests only
bundle exec rspec --format doc       # Verbose output
```

### Generate Test Files

```bash
rails generate rspec:model User      # Model spec
rails generate rspec:controller Api::Auth  # Controller spec
```

### Test Structure

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should have_many(:roles).through(:role_users) }
end

# spec/requests/api/auth_spec.rb
RSpec.describe 'Api::Auth', type: :request do
  describe 'POST /api/auth/login' do
    it 'returns token' do
      post '/api/auth/login', params: { email: user.email, password: 'password' }
      expect(response).to have_http_status(:ok)
    end
  end
end
```

---

## 🔗 Database Connection

```bash
Host:     localhost
Port:     5432
Database: unione_db_development
Username: unione
Password: 241996
Pool:     5 threads (configurable)
```

### Connection String

```bash
DATABASE_URL=postgresql://unione:241996@localhost:5432/unione_db_development
```

### Test Connection

```bash
psql -U unione -d unione_db_development -c "SELECT 1"
```

---

## 📚 Key User Roles

| Role | Slug | Permissions |
| ------ | ------ | ------------- |
| **Admin** | admin | All system access |
| **Faculty Admin** | faculty_admin | Faculty-level management |
| **Department Admin** | department_admin | Department-level management |
| **Professor** | professor | Course management, grading |
| **Student** | student | Course enrollment, grades |
| **Employee** | employee | Administrative tasks |

---

## 🎯 Development Workflow

### 1. Feature Development Flow

```bash
# Create branch
git checkout -b feature/feature-name

# Generate migration (if needed)
rails generate migration CreateTableName

# Edit migration
# Run migration
rails db:migrate

# Generate model/controller
rails generate model ModelName
rails generate controller Api::ControllerName

# Implement feature
# Write tests
# Run tests
bundle exec rspec

# Commit and push
git add .
git commit -m "feat: description"
git push origin feature/feature-name
```

### 2. Database Workflow

```bash
# Create migration
rails generate migration AddFieldToTable field:type

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database (drop + create + migrate + seed)
rails db:reset

# Check migration status
rails db:migrate:status
```

---

## 🚨 Common Issues & Solutions

### Issue: "Gem::LoadError: pg is not part of the bundle"

**Solution**: Run `bundle install`

### Issue: "Database connection refused"

**Solution**: Check PostgreSQL is running, verify database.yml credentials

### Issue: "Port 3000 already in use"

**Solution**: Kill process: `lsof -ti:3000 | xargs kill -9` or use `rails server -p 3001`

### Issue: "JWT token invalid"

**Solution**: Ensure token is passed in header: `Authorization: Bearer <token>`

### Issue: "CORS errors"

**Solution**: Check `config/initializers/cors.rb`, verify origin is allowed

### Issue: "Migration pending"

**Solution**: Run `rails db:migrate`

### Issue: "Pundit NotAuthorizedError"

**Solution**: Check policy methods, ensure current_user has permission

---

## 📊 Current Status

```bash
✅ Backend Core              → Auth, RBAC, organization, student/professor/admin APIs
✅ Data Layer                → Migrations, schema, and seed data in place
✅ Advanced Features         → Webhooks, imports, uploads, locale/privacy endpoints
✅ GraphQL Endpoint          → Schema, queries, and mutations scaffolded
✅ Operational Baseline      → CI, health endpoint, structured logging
⏳ Coverage Expansion        → Additional test scenarios for new endpoints
⏳ Hardening                 → Production environment validation and observability tuning
```

---

## 🔗 Documentation Links

| Document | Purpose | Best For |
| ---------- | --------- | ---------- |
| [README.md](README.md) | Quick start | Setup |
| [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | Project summary | Overview |
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | Technical roadmap | Planning |
| [API_ENDPOINTS.md](API_ENDPOINTS.md) | API reference | API integration |
| [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) | DB reference | Database work |
| [FEATURES_REFERENCE.md](FEATURES_REFERENCE.md) | Feature matrix | Requirements |
| [DEPENDENCIES_SETUP.md](DEPENDENCIES_SETUP.md) | Installation info | Setup help |
| [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) | Doc navigation | Finding info |

---

## 💡 Pro Tips

1. **Use Rails generators** - Save time with `rails generate`
2. **Keep API responses consistent** - Use consistent JSON structure
3. **Always use migrations** - Never alter database manually
4. **Test as you code** - Write specs alongside features
5. **Document decisions** - Update docs when architecture changes
6. **Use Pundit policies** - Keep authorization logic in one place
7. **Service objects for complex logic** - Keep controllers thin
8. **Use `includes` to avoid N+1 queries** - Eager load associations
9. **Commit frequently** - Small commits are easier to review
10. **Follow Rails conventions** - Convention over configuration

---

## 🔍 Rails-Specific Patterns

### Controller Pattern

```ruby
module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_user, only: [:update, :destroy]

    def index
      @users = User.all
      render json: @users
    end

    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name)
    end
  end
end
```

### Service Object Pattern

```ruby
class EnrollmentService
  def initialize(student, section)
    @student = student
    @section = section
  end

  def call
    raise "Section full" if @section.enrollments.count >= @section.capacity
    
    Enrollment.create!(
      student: @student,
      section: @section,
      academic_term: @section.academic_term
    )
  end
end
```

### Policy Pattern

```ruby
class StudentPolicy < ApplicationPolicy
  def show?
    user.admin? || user.student == record
  end

  def enroll?
    user.student?
  end
end
```

---

## 📞 Quick Help

### "How do I...?"

**...start a feature?**
→ Read IMPLEMENTATION_PLAN.md → See DATABASE_SCHEMA.md → Create migration

**...connect to database?**
→ Check database.yml → Run `rails db:migrate`

**...make an API call?**
→ See API_ENDPOINTS.md for endpoints and formats

**...add database columns?**
→ Create migration: `rails generate migration AddFieldToTable field:type`

**...test my code?**
→ Run: `bundle exec rspec`

**...deploy to production?**
→ See PROJECT_OVERVIEW.md Deployment section

---

## 🎖️ Remember

> Your work builds on solid foundations:
>
> + ✅ Core backend architecture implemented
> + ✅ Database and API layers running in production shape
> + ✅ Imports, uploads, privacy, and GraphQL delivered
> + ✅ CI and observability scaffolding in place
> + ✅ Documentation synchronized to current capabilities
>
> **Focus on test depth, operational hardening, and endpoint reliability.**

---

**Last Updated**: April 15, 2026
**Version**: 2.0 Backend Enhancement Wave Delivered
**Ready to Code**: YES ✅

Print this card. Bookmark these docs. **Let's build something great!** 🚀
