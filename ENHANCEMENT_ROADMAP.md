# UniOne Rails - Enhancement Roadmap (Verified)

**Last Updated**: April 15, 2026
**Verification Status**: Audited against live codebase
**Framework**: Ruby on Rails 7.x + PostgreSQL + Sidekiq + ActionCable

---

## Audit Summary

The previous roadmap marked several features as missing even though they are already implemented.

Implemented and verified:
- Teaching assistant management (model, policy, controller, routes)
- Group projects management (models, controller, routes)
- Admin student and grade import endpoints with template downloads
- Exam schedule endpoints and controller
- Professor schedule ICS export route
- API versioned routes under /api/v1 with legacy compatibility

---

## Current Priority Matrix (Open Items Only)

| # | Enhancement | Priority | Impact | Volume | Notes |
|---|-------------|----------|--------|--------|-------|
| 1 | Professor grade import endpoint | P0 | 5/5 | S | Grade import exists for admin only |
| 2 | Request specs for enhancement endpoints | P0 | 5/5 | M | TA/group project/import flows are under-tested |
| 3 | Production Docker setup | P0 | 4/5 | S | Dockerfile.dev exists, production files missing |
| 4 | CI pipeline (GitHub Actions) | P1 | 4/5 | M | No workflow file in repository |
| 5 | Monitoring and observability | P1 | 3/5 | M | Sentry/health checks not integrated |
| 6 | Import API consolidation | P2 | 3/5 | M | Import endpoints are split across controllers |
| 7 | ActiveStorage upload endpoints | P2 | 3/5 | M | Avatars/logos/documents still pending |
| 8 | Advanced backlog (GDPR, GraphQL, i18n) | P3 | 2/5 | L | Keep for later milestone |

---

## Execution Plan (Commit Per Step)

### Step 1 - Documentation alignment
- Update ENHANCEMENT_ROADMAP.md, Enhancements.md, CURRENT_STATUS.md with verified status.
- Commit message:
  - docs(roadmap): align enhancement status with verified implementation

### Step 2 - Professor grade import parity
- Add route for professor grade import.
- Add import action in professor grades controller using GradeImportService.
- Add validation for professor ownership of section and payload shape.
- Commit message:
  - feat(professor): add grade import endpoint and service integration

### Step 3 - Coverage for enhancement endpoints
- Add request specs for:
  - admin section teaching assistants
  - admin group projects
  - admin student import and grade import endpoints
  - professor grade import endpoint
- Commit message:
  - test(api): add request specs for enhancement endpoints

### Step 4 - Production containerization
- Add Dockerfile (production)
- Add docker-compose.prod.yml
- Add entrypoint script for db prepare
- Update docs
- Commit message:
  - ops(docker): add production container setup

---

## Definition of Done for Next Milestone

- Professor endpoint supports grade import with authorization checks.
- Core enhancement endpoints have request-level tests.
- Production Docker files build and boot successfully.
- Documentation reflects actual implementation state.

---

## Notes

- Keep legacy /api routes for backward compatibility while preferring /api/v1.
- Prefer incremental PRs with one milestone per commit group.
