# UniOne Rails - Enhancement Roadmap (Verified)

Last Updated: April 15, 2026
Verification Status: Audited against live codebase and recent commits
Framework: Ruby on Rails 7.x + PostgreSQL + Sidekiq + ActionCable

---

## Roadmap Progress

All active roadmap items from the previous planning pass have been implemented in incremental commits.

### Completed Milestones

1. Documentation alignment with verified implementation
2. Professor grade import endpoint
3. Request specs for enhancement import flows
4. Production Docker setup
5. CI pipeline (GitHub Actions)
6. Monitoring and observability baseline (health + structured logging + Sentry initializer)
7. Admin import API consolidation
8. ActiveStorage upload APIs (user avatar, university logo)
9. Advanced backlog scaffolding (i18n locale endpoint, GDPR endpoint, GraphQL placeholder)

---

## Current State by Item

| Item | Status | Notes |
|---|---|---|
| Teaching assistant management | Complete | Implemented earlier and verified |
| Group projects management | Complete | Implemented earlier and verified |
| Professor grade import | Complete | Added to professor routes and controller |
| Admin import consolidation | Complete | New consolidated imports controller added |
| Production Docker setup | Complete | Dockerfile + docker-compose.prod + entrypoint |
| CI pipeline | Complete | GitHub Actions workflow with Postgres and Redis |
| Monitoring and observability | Complete (baseline) | Health endpoint and structured logging added |
| ActiveStorage uploads | Complete | Migration, storage config, avatar/logo APIs |
| i18n/GDPR/GraphQL backlog | Partial | Locale + GDPR implemented, GraphQL is placeholder only |

---

## Remaining Follow-Up Tasks

1. Run migrations and full test suite in an environment with Bundler available.
2. Add request specs for newly added observability, upload, and GDPR/locale endpoints.
3. Replace GraphQL placeholder with a full GraphQL schema if this becomes a product requirement.
4. Install and lock Sentry gems (if production error tracking is required in this deployment).

---

## Notes

- Legacy and versioned API routes are both preserved for compatibility.
- Work has been delivered as small commits to keep review and rollback safe.
