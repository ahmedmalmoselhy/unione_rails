# UniOne Platform - Ruby on Rails Clone

A complete academic management system built with **Ruby on Rails** and **PostgreSQL**, maintaining feature parity with the original Laravel and Node.js implementations.

## 🎯 Project Overview

UniOne is a comprehensive university management platform featuring:

- **Student Portal**: Course enrollment, grades, transcripts, attendance tracking
- **Professor Portal**: Grade submission, attendance management, announcements
- **Admin Portal**: System management, webhooks, audit logs
- **Multi-tier Organization**: Universities → Faculties → Departments
- **6 User Roles**: Admin, Faculty Admin, Department Admin, Professor, Student, Employee
- **Advanced Features**: PDF transcripts, iCal schedules, real-time notifications, webhooks

### Technology Stack

**Backend**: Ruby on Rails 7+ + PostgreSQL
**Frontend**: Hotwire (Turbo + Stimulus) or API-only mode for SPA
**Database**: PostgreSQL (same schema as Laravel/Node implementations)
**Authentication**: Devise + JWT (for API mode)
**Authorization**: Pundit or CanCanCan

## 📚 Documentation

**New to the project?** Start here:

1. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** ⚡ - **PRINT THIS!** Common commands, database info, API endpoints, quick answers
2. **[DOCUMENTATION_INDEX.md](./DOCUMENTATION_INDEX.md)** 📑 - **READ THIS NEXT** - Complete guide to all documentation by role

For detailed information:

| Document | Purpose |
| ---------- | --------- |
| [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md) | 📊 Complete project summary, architecture, timeline |
| [IMPLEMENTATION_PLAN.md](./IMPLEMENTATION_PLAN.md) | 🎯 Detailed 8-phase implementation + UI specification |
| [API_ENDPOINTS.md](./API_ENDPOINTS.md) | 🔌 All 52+ endpoints documented |
| [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) | 🗄️ All 34 tables with relationships |
| [FEATURES_REFERENCE.md](./FEATURES_REFERENCE.md) | ✨ Feature matrix, roles, capabilities |
| [DEPENDENCIES_SETUP.md](./DEPENDENCIES_SETUP.md) | 📦 Rails gems and dependencies |

**3,000+ lines of documentation** covering entire project specification.

## ⚡ Quick Start

### Prerequisites

- **Ruby** 3.1.x or higher
- **Rails** 7.0.x or higher
- **PostgreSQL** 12.x or higher
- **Bundler** gem manager

### Initial Setup

```bash
# 1. Install Ruby gems
bundle install

# 2. Configure environment
cp .env.example .env
# or
rails credentials:edit

# 3. Create and setup database
rails db:create
rails db:migrate
rails db:seed

# 4. Start development server
rails server
```

Server will be available at `http://localhost:3000`

## 🏗️ Project Structure

### Standard Rails Structure

```bash
unione_rails/
├── app/
│   ├── controllers/     # API controllers (52+ endpoints)
│   ├── models/          # 27 database models
│   ├── services/        # Business logic (GPA, Auth, Enrollment)
│   ├── policies/        # Authorization policies (Pundit)
│   ├── mailers/         # Email notifications
│   ├── jobs/            # Background jobs (webhooks, emails)
│   └── channels/        # ActionCable for real-time features
├── db/
│   ├── migrate/         # Database migrations (34 tables)
│   └── seeds/           # Database seed data
├── config/
│   ├── routes.rb        # API routes
│   ├── database.yml     # Database configuration
│   └── application.rb   # App configuration
├── spec/                # RSpec tests
│   ├── models/
│   ├── requests/
│   └── support/
└── lib/                 # Custom libraries and tasks
```

### API-Only Mode (Optional)

If building separate frontend:

```bash
# Create as API-only app
rails new unione_rails --api

# Structure:
app/
├── controllers/api/     # API namespace
├── models/              # ActiveRecord models
├── services/            # Business logic
└── mailers/             # Email services
```

## 🚀 Available Scripts

### Rails Commands

```bash
rails server              # Start development server
rails console             # Rails console
rails db:migrate          # Run migrations
rails db:rollback         # Rollback last migration
rails db:seed             # Seed database
rails db:reset            # Reset and seed database
rails test                # Run tests
rails spec                # Run RSpec tests
rails db:create           # Create databases
rails db:drop             # Drop databases
```

### Development Commands

```bash
bundle install            # Install gems
rails generate model      # Generate model
rails generate controller # Generate controller
rails generate migration  # Generate migration
rails routes              # Show all routes
rails credentials:edit    # Edit encrypted credentials
```

## 🔐 Authentication

### Login Endpoint

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

### Response

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "roles": ["student"],
    "name": "John Doe"
  }
}
```

### Using Token

```bash
curl -H "Authorization: Bearer <token>" http://localhost:3000/api/student/profile
```

## 📊 API Overview

### Public Routes (3 endpoints)

```bash
POST /api/auth/login
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

### Protected Routes (49+ endpoints)

```bash
Student:    /api/student/*         (15 endpoints)
Professor:  /api/professor/*       (13 endpoints)
Admin:      /api/admin/*           (5 endpoints)
Shared:     /api/announcements, /api/notifications (8 endpoints)
```

See [API_ENDPOINTS.md](./API_ENDPOINTS.md) for complete documentation.

## 🧪 Testing

### Run Tests

```bash
rails test                 # Run Minitest tests
bundle exec rspec          # Run RSpec tests
bundle exec rspec spec/models  # Run model tests only
```

### Test Structure

```bash
spec/
├── models/                # Model unit tests
├── requests/              # API integration tests
├── services/              # Service object tests
└── support/               # Test helpers and fixtures
```

## 🐳 Docker Deployment

### Build Image

```bash
docker build -t unione-rails .
```

### Run Container

```bash
docker run -p 3000:3000 \
  -e RAILS_ENV=production \
  -e DATABASE_URL=postgresql://user:pass@host/db \
  unione-rails
```

### Docker Compose

```bash
docker-compose up -d
```

## 📈 Project Timeline

| Week | Focus |
| ------ | ------- |
| 1 | Foundation (Auth, Models, Rails setup) |
| 2 | Student Portal Core |
| 3 | Academic Records |
| 4 | Professor Portal |
| 5 | Communication & Webhooks |
| 6 | Admin & Advanced Features |
| 7 | Integration & Polish |
| 8 | Testing & Deployment |

**Total**: 7-8 weeks

## 🆘 Troubleshooting

### Database Connection Failed

```bash
# Check PostgreSQL is running
psql -U unione -d unione_db

# Update database.yml with correct credentials
# Restart server
rails server
```

### API 401 Unauthorized

```bash
# Token expired or invalid
# Get new token:
curl -X POST http://localhost:3000/api/auth/login
```

### Port Already in Use

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
# Or use different port:
rails server -p 3001
```

## 📝 Environment Variables

Configure in `config/credentials.yml.enc` or `.env`:

```yaml
# Server
rails_env: development
port: 3000

# Database (PostgreSQL)
database:
  host: 127.0.0.1
  port: 5432
  name: unione_db
  username: unione
  password: 241996

# JWT
jwt_secret: your_jwt_secret_key_here
jwt_expire: 7d

# Mail
mail_host: localhost
mail_port: 1025

# Logging
log_level: debug
```

## 🤝 Contributing

1. Follow Rails conventions and RESTful patterns
2. Write tests for new features
3. Update documentation
4. Reference issues in commits
5. Use strong_parameters for all user input

## ✅ Implementation Status

- ✅ Core backend features implemented and operational
- ✅ Database schema, migrations, and seed data established
- ✅ REST API domains implemented (auth, student, professor, admin, shared)
- ✅ Webhooks, notifications, imports, uploads, GDPR, and GraphQL endpoint available
- ✅ CI, health checks, and structured logging delivered
- ⏳ Expanded endpoint test coverage and production hardening remain

## 📞 Support Resources

- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [PostgreSQL Docs](https://www.postgresql.org/docs)
- [Devise Authentication](https://github.com/heartcombo/devise)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [RSpec Testing](https://rspec.info/)

## 📄 License

MIT
