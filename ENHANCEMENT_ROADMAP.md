# UniOne Rails - Enhancement Roadmap

**Date**: April 12, 2026  
**Current Status**: 🟢 Production Ready (~95% complete)  
**Framework**: Ruby on Rails 7.2 + PostgreSQL + Sidekiq + ActionCable  
**Total Enhancements Identified**: 18 items  

---

## 📊 Enhancement Priority Matrix

### Rating Scale:

| Rating | Meaning |
|--------|---------|
| **Priority**: P0-P3 | P0=Critical, P1=High, P2=Medium, P3=Low |
| **Business Impact**: 1-5 | 1=Minimal, 3=Moderate, 5=Transformational |
| **Volume**: S/M/L/XL | S=<1 day, M=2-3 days, L=1 week, XL=2+ weeks |

---

## 🔴 P0 - Critical (Must Have Before Production)

| # | Enhancement | Priority | Impact | Volume | Effort |
|---|-------------|----------|--------|--------|--------|
| 1 | **Teaching Assistant Management** | P0 | 4/5 | M | 1-2 days |
| 2 | **Excel Import Controller Endpoints** | P0 | 5/5 | M | 2-3 days |
| 3 | **Group Projects Management** | P0 | 3/5 | M | 2-3 days |

---

## 🟠 P1 - High Priority (Should Have)

| # | Enhancement | Priority | Impact | Volume | Effort |
|---|-------------|----------|--------|--------|--------|
| 4 | **Test Coverage Expansion (80%+)** | P1 | 5/5 | XL | 1-2 weeks |
| 5 | **Production Dockerfile** | P1 | 4/5 | S | 1 day |
| 6 | **Exam Schedule Routes & Controller** | P1 | 3/5 | S | 0.5 days |

---

## 🟡 P2 - Medium Priority (Nice to Have)

| # | Enhancement | Priority | Impact | Volume | Effort |
|---|-------------|----------|--------|--------|--------|
| 7 | **Professor iCal Export** | P2 | 3/5 | S | 0.5 days |
| 8 | **CI/CD Pipeline (GitHub Actions)** | P2 | 4/5 | M | 2-3 days |
| 9 | **Monitoring & Observability** | P2 | 3/5 | M | 2 days |
| 10 | **API Versioning (/api/v1/)** | P2 | 3/5 | S | 1 day |
| 11 | **ActiveStorage File Uploads** | P2 | 3/5 | M | 2-3 days |

---

## 🟢 P3 - Low Priority (Future Enhancements)

| # | Enhancement | Priority | Impact | Volume | Effort |
|---|-------------|----------|--------|--------|--------|
| 12 | **Multilingual Support (I18n)** | P3 | 2/5 | L | 3-5 days |
| 13 | **Advanced Analytics Dashboard** | P3 | 2/5 | L | 1 week |
| 14 | **Bulk Operations** | P3 | 2/5 | M | 2-3 days |
| 15 | **GDPR Compliance** | P3 | 2/5 | M | 2 days |
| 16 | **Advanced Rate Limiting** | P3 | 2/5 | S | 1 day |
| 17 | **GraphQL API** | P3 | 2/5 | L | 1 week |
| 18 | **Frontend Application** | P3 | 2/5 | XL | 4-6 weeks |

---

## 📋 Detailed Breakdown

### P0-1: Teaching Assistant Management (1-2 days)
**Problem**: No `SectionTeachingAssistant` model or endpoints exist  
**What's Missing**:
- `SectionTeachingAssistant` model (professor assigned as TA to section)
- Admin CRUD endpoints for TA assignment
- Policy for scoped access
- Tests for model and endpoints

**Implementation**:
- Generate model with migrations
- Create `Api::Admin::SectionTeachingAssistantsController`
- Add routes: `GET/POST /api/admin/sections/:id/teaching-assistants`, `DELETE /api/admin/sections/:id/teaching-assistants/:ta_id`
- Create Pundit policy
- Add request specs

---

### P0-2: Excel Import Controller Endpoints (2-3 days)
**Problem**: Services exist but no API endpoints to trigger them  
**What's Missing**:
- `Api::Admin::ImportController` with upload endpoints
- Template download endpoints
- `roo` gem for reading Excel files
- File upload with validation

**Implementation**:
- Add `roo` gem to Gemfile
- Create `Api::Admin::ImportController`:
  - `POST /api/admin/import/students` - Upload Excel/CSV
  - `POST /api/admin/import/grades` - Upload Excel/CSV
  - `POST /api/admin/import/professors` - Upload Excel/CSV
  - `GET /api/admin/import-templates/students.xlsx` - Download template
  - `GET /api/admin/import-templates/grades.xlsx` - Download template
- Wire up existing `StudentImportService` and `GradeImportService`
- Add file upload with ActiveStorage or multipart
- Add request specs

---

### P0-3: Group Projects Management (2-3 days)
**Problem**: Canonical feature but no model/controller  
**What's Missing**:
- `GroupProject` model (belongs_to :section, has_many :group_project_members)
- `GroupProjectMember` model (belongs_to :group_project, belongs_to :student)
- Admin CRUD endpoints
- Professor view endpoints for their sections
- Policies and tests

**Implementation**:
- Generate models with migrations
- Create `Api::Admin::GroupProjectsController`
- Create `Api::Professor::GroupProjectsController` (view-only for their sections)
- Add routes for member management
- Create Pundit policies
- Add request specs

---

### P1-4: Test Coverage Expansion (1-2 weeks)
**Problem**: Test coverage is <20%, target is 80%+  
**What's Missing**:
- 28 models need specs
- 31 controllers need request specs
- 15 services need specs
- 21 policies need specs
- 6 mailers need specs
- 5 jobs need specs
- 1 middleware needs spec
- 3 concerns need specs

**Implementation Priority**:
1. **Week 1**: Models (28 specs) + Services (15 specs)
2. **Week 2**: Controllers (31 request specs) + Policies (21 specs)
3. **Ongoing**: Mailers, Jobs, Middleware, Concerns

**Target**: 80%+ coverage with SimpleCov

---

### P1-5: Production Dockerfile (1 day)
**Problem**: Only `Dockerfile.dev` exists; production Dockerfile is only in documentation  
**What's Missing**:
- `Dockerfile` (production)
- `docker-compose.prod.yml`
- `entrypoint.sh` script

**Implementation**:
- Create production Dockerfile (multi-stage build)
- Create `docker-compose.prod.yml` with web, db, redis, sidekiq
- Create `entrypoint.sh` for database setup
- Test in staging environment

---

### P1-6: Exam Schedule Routes & Controller (0.5 days)
**Problem**: `ExamScheduleService` and `ExamScheduleMailer` exist but no routes  
**What's Missing**:
- `Api::Admin::ExamSchedulesController`
- Routes for exam schedule management
- Professor view endpoint

**Implementation**:
- Create `Api::Admin::ExamSchedulesController`:
  - `GET /api/admin/sections/:section_id/exam-schedule`
  - `POST /api/admin/sections/:section_id/exam-schedule`
  - `PATCH /api/admin/sections/:section_id/exam-schedule`
  - `POST /api/admin/sections/:section_id/exam-schedule/publish` - Triggers email
- Add routes
- Add request specs

---

### P2-7: Professor iCal Export (0.5 days)
**Problem**: Student has iCal export, professor doesn't  
**What's Missing**:
- `GET /api/professor/schedule/ics` endpoint

**Implementation**:
- Add route to professor routes
- Create action in `Api::Professor::SectionsController` or separate controller
- Use existing `ScheduleExporter` service
- Add request spec

---

### P2-8: CI/CD Pipeline (2-3 days)
**Problem**: No GitHub Actions or CI config  
**What's Missing**:
- `.github/workflows/ci.yml`
- Automated testing on push/PR
- Code coverage reporting
- Linting (RuboCop)
- Security scanning (Bundler-audit)

**Implementation**:
- Create GitHub Actions workflow
- Configure PostgreSQL service container
- Run tests with coverage
- Upload coverage to Codecov
- Add RuboCop linting
- Add Bundler security audit

---

### P2-9: Monitoring & Observability (2 days)
**Problem**: No error tracking or health monitoring  
**What's Missing**:
- Sentry integration
- Health check endpoint with service status
- Structured logging
- Request ID tracing

**Implementation**:
- Add `sentry-ruby` gem
- Configure Sentry in initializer
- Create `Api::HealthController` with DB/Redis/Sidekiq checks
- Add structured logging (JSON format in production)
- Add request ID middleware

---

### P2-10: API Versioning (1 day)
**Problem**: No explicit versioning, using `/api/` prefix only  
**What's Missing**:
- URL-based versioning (`/api/v1/`)
- Backward compatibility layer

**Implementation**:
- Add version constraint to routes
- Create `/api/v1/` namespace
- Keep legacy routes with deprecation warning
- Add `X-API-Version` response header

---

### P2-11: ActiveStorage File Uploads (2-3 days)
**Problem**: ActiveStorage is required but no upload endpoints exist  
**What's Missing**:
- File upload endpoints for avatars, logos, documents
- Controller actions to handle uploads
- Policies for upload permissions

**Implementation**:
- Add `Api::Users::AvatarController`
- Add `Api::Admin::UniversityLogosController`
- Configure ActiveStorage for local/cloud storage
- Add file upload validation
- Add request specs

---

### P3-12: Multilingual Support (3-5 days)
**Problem**: English only; `name_ar` fields exist but no I18n  
**What's Missing**:
- Rails I18n configuration
- Arabic locale files
- Locale switching endpoint
- Translated error messages and emails

**Implementation**:
- Configure I18n in `application.rb`
- Create `config/locales/ar.yml`
- Add locale switching middleware
- Translate mailer templates
- Add `GET/PUT /api/locale` endpoint

---

### P3-13: Advanced Analytics Dashboard (1 week)
**Problem**: Basic dashboard exists but lacks predictive insights  
**What's Missing**:
- Enrollment trend forecasting
- Student performance prediction
- Course demand analysis
- Professor workload optimization

**Implementation**:
- Create `Api::Admin::AnalyticsController` with advanced endpoints
- Add statistical analysis services
- Add caching for expensive queries
- Add request specs

---

### P3-14: Bulk Operations (2-3 days)
**Problem**: No bulk enrollment, grade updates, transfers  
**What's Missing**:
- `POST /api/admin/bulk/enroll` - Bulk enrollment
- `POST /api/admin/bulk/grades` - Bulk grade updates
- `POST /api/admin/bulk/transfer` - Bulk student transfers

**Implementation**:
- Create `Api::Admin::BulkOperationsController`
- Add service objects for bulk operations
- Add transaction safety
- Add request specs

---

### P3-15: GDPR Compliance (2 days)
**Problem**: No data export or anonymization  
**What's Missing**:
- Data export endpoint
- Account anonymization endpoint

**Implementation**:
- Create `Api::Users::GdprController`
- Add `GET /api/user/gdpr/export` - JSON data export
- Add `POST /api/user/gdpr/anonymize` - Account anonymization
- Add audit logging for GDPR actions

---

### P3-16: Advanced Rate Limiting (1 day)
**Problem**: Basic rate limiting exists but no headers  
**What's Missing**:
- Rate limit headers in responses
- Per-user rate limits based on role

**Implementation**:
- Update `rack-attack` configuration
- Add `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers
- Add role-based rate limiting
- Add middleware tests

---

### P3-17: GraphQL API (1 week)
**Problem**: REST-only, no GraphQL support  
**What's Missing**:
- GraphQL schema
- Resolvers for all models
- GraphQL endpoint

**Implementation**:
- Add `graphql` gem
- Create GraphQL types for all models
- Create resolvers
- Add GraphQL endpoint at `/graphql`
- Add tests

---

### P3-18: Frontend Application (4-6 weeks)
**Problem**: API-only, no UI  
**What's Missing**:
- Complete React/Vue frontend
- All portal pages
- Authentication flow
- Real-time features

**Implementation**:
- Separate project (not in this repo)
- Follow FRONTEND_IMPLEMENTATION_GUIDE.md from Node.js

---

## 💡 Quick Wins (High Impact, Low Volume)

| # | Enhancement | Impact | Volume | Why First? |
|---|-------------|--------|--------|------------|
| 6 | Exam Schedule Routes | 3/5 | S (0.5 days) | Services already exist |
| 7 | Professor iCal Export | 3/5 | S (0.5 days) | Service already exists |
| 10 | API Versioning | 3/5 | S (1 day) | Safe API evolution |
| 5 | Production Dockerfile | 4/5 | S (1 day) | Deployment ready |

**Total**: 3 days for 4 critical items

---

## 📦 Dependencies to Add

### P0 Items:
```ruby
gem 'roo'                    # Excel file reading
```

### P1 Items:
```ruby
# (No new gems needed)
```

### P2 Items:
```ruby
gem 'sentry-ruby'            # Error tracking
gem 'sentry-rails'           # Rails integration
```

### P3 Items:
```ruby
gem 'graphql'                # GraphQL API
gem 'i18n-js'                # JavaScript I18n (if needed)
```

---

## 📊 Implementation Priority Order

### Phase 1: Complete Missing Features (Week 1)
1. Teaching Assistant Management (1-2 days)
2. Excel Import Endpoints (2-3 days)
3. Group Projects (2-3 days)
4. Exam Schedule Routes (0.5 days)
5. Professor iCal Export (0.5 days)

**Total**: ~1 week

### Phase 2: Production Readiness (Week 2)
6. Test Coverage (ongoing, start with models+services)
7. Production Dockerfile (1 day)
8. CI/CD Pipeline (2-3 days)
9. Monitoring & Observability (2 days)
10. API Versioning (1 day)

**Total**: ~2 weeks (including test coverage start)

### Phase 3: Advanced Features (Week 3-4)
11. ActiveStorage File Uploads (2-3 days)
12. Bulk Operations (2-3 days)
13. GDPR Compliance (2 days)
14. Multilingual Support (3-5 days)

**Total**: ~2 weeks

### Phase 4: Future Enhancements (Month 2+)
15. Advanced Analytics (1 week)
16. Advanced Rate Limiting (1 day)
17. GraphQL API (1 week)
18. Frontend Application (4-6 weeks, separate project)

---

## 🎯 Success Metrics

### Phase 1 Success Criteria:
- [ ] TA model and CRUD working
- [ ] Excel files accepted for import
- [ ] Group projects manageable via API
- [ ] Exam schedules publishable with email
- [ ] Professor can export schedule to iCal

### Phase 2 Success Criteria:
- [ ] Test coverage >50% (models+services done)
- [ ] Production Dockerfile exists and builds
- [ ] CI pipeline runs on every PR
- [ ] Sentry captures errors in production
- [ ] API versioned at /api/v1/

### Phase 3 Success Criteria:
- [ ] File uploads working (avatars, logos)
- [ ] Bulk operations functional
- [ ] GDPR export and anonymization working
- [ ] Arabic locale supported

---

## 🚀 Next Immediate Steps

### Week 1, Day 1-2:
1. Generate SectionTeachingAssistant model and migration
2. Create admin CRUD endpoints for TA management
3. Test TA assignment flow

### Week 1, Day 3-4:
1. Add `roo` gem to Gemfile
2. Create ImportController with upload endpoints
3. Test Excel import for students and grades

### Week 1, Day 5:
1. Generate GroupProject and GroupProjectMember models
2. Create admin CRUD endpoints
3. Test group project management

---

**Status**: 🟢 Ready for Implementation  
**Total Estimated Timeline**: 4-6 weeks for P0-P2 items  
**MVP Timeline**: 1 week (Phase 1 only)

---

**Last Updated**: April 12, 2026  
**Maintained By**: UniOne Development Team  
**Next Review**: After Phase 1 completion
