# UniOne Platform - Ruby on Rails

**Academic Management System** | Rails 7.1 + PostgreSQL

A comprehensive university management platform with student, professor, and admin portals. This is a Ruby on Rails reimplementation maintaining feature parity with existing Laravel and Node.js versions.

## Project Type

**Backend**: Ruby on Rails 7.1 (API-first)  
**Database**: PostgreSQL 15  
**Auth**: Devise + JWT + Pundit  
**Background Jobs**: Sidekiq + Redis  
**Testing**: RSpec + FactoryBot + Shoulda Matchers  
**Containerization**: Docker + Docker Compose

## Architecture

- **6 User Roles**: Admin, Faculty Admin, Department Admin, Professor, Student, Employee
- **34 Database Tables**: 27 core models + 7 system tables
- **52+ API Endpoints**: RESTful API under `/api/*`
- **Multi-tier Org**: Universities → Faculties → Departments

### Key Feature Areas

| Portal | Endpoints | Features |
| -------- | ----------- | ---------- |
| **Auth** | 10 | Login, logout, password reset, token management |
| **Student** | 15 | Enrollments, grades, transcripts (PDF), schedule (iCal), attendance, ratings |
| **Professor** | 13 | Sections, grade submission, attendance tracking, announcements |
| **Shared** | 8 | Announcements, notifications |
| **Admin** | 5+ | Webhooks, audit logs |

## Building and Running

### Prerequisites

- Ruby >= 3.1.0
- PostgreSQL 12+
- Redis 7+ (for Sidekiq)
- Bundler

### Local Development

```bash
# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start server
rails server          # localhost:3000
```

### Docker Development (Recommended)

```bash
# Start all services (Rails, PostgreSQL, Redis, Sidekiq, Mailcatcher)
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

Docker Compose services:

- **web**: Rails app on `localhost:3000`
- **db**: PostgreSQL 15
- **redis**: Redis 7
- **sidekiq**: Background job processor
- **mailcatcher**: Email testing on `localhost:1080`

### Key Rails Commands

```bash
rails console                  # Interactive console
rails db:migrate:status        # Migration status
rails routes                   # All routes
rails generate model Name      # Generate model
rails generate migration ...   # Generate migration
rails db:rollback              # Rollback last migration
rails db:reset                 # Drop + create + migrate + seed
bundle exec rspec              # Run all tests
bundle exec rspec spec/models  # Model tests only
```

## Project Structure

```bash
unione_rails/
├── app/
│   ├── controllers/api/       # Namespaced API controllers
│   ├── models/                # ActiveRecord models (27+)
│   ├── services/              # Business logic (GPA, Enrollment, Auth)
│   ├── policies/              # Pundit authorization policies
│   ├── mailers/               # Email notifications
│   ├── jobs/                  # Sidekiq background jobs
│   └── channels/              # ActionCable (real-time)
├── db/
│   ├── migrate/               # Database migrations (34 tables)
│   └── seeds/                 # Seed data
├── config/
│   ├── routes.rb              # API routes
│   ├── database.yml           # DB config
│   └── sidekiq.yml            # Sidekiq config
├── spec/                      # RSpec tests
│   ├── models/
│   ├── requests/
│   └── services/
├── Gemfile                    # Dependencies
├── docker-compose.yml         # Docker orchestration
└── Dockerfile.dev             # Dev container
```

## Development Conventions

### Code Patterns

- **Thin controllers, fat models/services** - Business logic in service objects
- **Pundit policies** - Authorization logic isolated in policy classes
- **Strong parameters** - All user input permitted explicitly
- **Consistent JSON responses** - Use `jbuilder` for API responses
- **Eager loading** - Use `includes` to prevent N+1 queries

### Service Object Pattern

```ruby
class EnrollmentService
  def initialize(student, section)
    @student = student
    @section = section
  end

  def call
    raise "Section full" if @section.enrollments.count >= @section.capacity
    Enrollment.create!(student: @student, section: @section, academic_term: @section.academic_term)
  end
end
```

### Testing

- RSpec for all tests (`bundle exec rspec`)
- FactoryBot for test data
- Shoulda Matchers for common Rails assertions
- Target: 80%+ coverage
- Write tests alongside features

### Git Workflow

```bash
git checkout -b feature/feature-name
# implement + test
git add .
git commit -m "feat: description"
git push origin feature/feature-name
```

## Database

**Connection** (local):

```bash
Host:     localhost
Port:     5432
Database: unione_db_development
Username: unione
Password: 241996
```

**Core Tables**: users, roles, role_user, universities, faculties, departments, courses, sections, enrollments, academic_terms, grades, students, professors, employees, attendance_sessions, attendance_records, announcements, notifications, audit_logs, webhooks

## API Authentication

```bash
# Login
POST /api/auth/login
{ "email": "user@example.com", "password": "password" }

# Use token in subsequent requests
Authorization: Bearer <token>
```

## Troubleshooting

| Issue | Solution |
| ------- | ---------- |
| Port 3000 in use | `rails server -p 3001` or kill process |
| Database connection failed | Check PostgreSQL running, verify `database.yml` |
| Gem installation fails | Check Ruby version, run `bundle update` |
| Migration pending | `rails db:migrate` |
| 401 Unauthorized | Token expired, re-authenticate |

## Documentation

| File | Purpose |
| ------ | --------- |
| `README.md` | Project overview and quick start |
| `QUICK_REFERENCE.md` | ⚡ Common commands, database info, API endpoints |
| `PROJECT_OVERVIEW.md` | Full project summary and architecture |
| `IMPLEMENTATION_PLAN.md` | Technical roadmap and phase details |
| `API_ENDPOINTS.md` | All 52+ endpoint specifications |
| `DATABASE_SCHEMA.md` | All 34 table schemas and relationships |
| `DEPENDENCIES_SETUP.md` | Gem specifications and setup guide |
| `FEATURES_REFERENCE.md` | Feature matrix and requirements |
| `DOCKER_SETUP.md` | Docker configuration details |

## Status

- Documentation and planning: **Complete**
- Database schema designed: **Complete**
- API endpoints specified: **Complete**
- Implementation: **Ready to start**
- Estimated timeline: 7-8 weeks
