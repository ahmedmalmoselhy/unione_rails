# UniOne Rails - Docker Setup Guide

## 🐳 Container Architecture

```bash
┌─────────────────────────────────────────────────────────┐
│                     Docker Network                       │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Rails App   │  │  PostgreSQL   │  │    Redis      │  │
│  │   (Puma)      │  │   (Database)  │  │  (Sidekiq)    │  │
│  │   :3000       │  │   :5432       │  │   :6379       │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                  │                  │          │
│         └──────────────────┼──────────────────┘          │
│                            │                             │
│                    ┌───────▼────────┐                    │
│                    │  Shared Volumes │                    │
│                    │  (data persist) │                    │
│                    └────────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Docker Files Structure

```bash
unione_rails/
├── Dockerfile              # Rails app container
├── docker-compose.yml      # Multi-container orchestration
├── docker-compose.test.yml # Test environment
├── .dockerignore           # Files to exclude from build
├── entrypoint.sh           # Container entrypoint script
├── Dockerfile.dev          # Development-specific container
└── docker-compose.dev.yml  # Development overrides
```

---

## 🚀 Quick Start with Docker

### 1. Start All Services

```bash
docker-compose up -d
```

This starts:
- Rails app (port 3000)
- PostgreSQL database
- Redis (for Sidekiq/caching)

### 2. Setup Database

```bash
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
```

### 3. Access Application

- **Rails App**: http://localhost:3000
- **Database**: localhost:5432
- **Redis**: localhost:6379

### 4. View Logs

```bash
docker-compose logs -f web        # Rails app logs
docker-compose logs -f db         # Database logs
docker-compose logs -f redis      # Redis logs
docker-compose logs -f sidekiq    # Background job logs
```

### 5. Stop Services

```bash
docker-compose down              # Stop containers
docker-compose down -v           # Stop + remove volumes (fresh start)
```

---

## 🔧 Common Docker Commands

### Run Rails Commands

```bash
# Rails console
docker-compose exec web rails console

# Run migrations
docker-compose exec web rails db:migrate

# Run tests
docker-compose exec web bundle exec rspec

# Generate scaffold
docker-compose exec web rails generate scaffold User name:string email:string

# Run any Rails command
docker-compose exec web rails <command>
```

### Database Operations

```bash
# Access PostgreSQL shell
docker-compose exec db psql -U unione -d unione_db_development

# Backup database
docker-compose exec db pg_dump -U unione unione_db_development > backup.sql

# Restore database
docker-compose exec -T db psql -U unione unione_db_development < backup.sql

# Reset database
docker-compose exec web rails db:reset
```

### Background Jobs

```bash
# Start Sidekiq separately (if needed)
docker-compose up -d sidekiq

# View Sidekiq dashboard
# http://localhost:3000/sidekiq
```

### Rebuild Containers

```bash
# Rebuild after Gemfile changes
docker-compose build web
docker-compose up -d

# Rebuild everything
docker-compose build
docker-compose up -d

# Force rebuild without cache
docker-compose build --no-cache
```

---

## 📊 Docker Compose Services

### Development Stack

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Rails Application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
      - gem_cache:/usr/local/bundle
      - node_modules:/app/node_modules
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://unione:241996@db:5432/unione_db_development
      - REDIS_URL=redis://redis:6379/1
      - SECRET_KEY_BASE=your_secret_key_here_change_in_production
    depends_on:
      - db
      - redis
    networks:
      - unione_network

  # PostgreSQL Database
  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=unione
      - POSTGRES_PASSWORD=241996
      - POSTGRES_DB=unione_db_development
    ports:
      - "5432:5432"
    networks:
      - unione_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U unione"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis (Sidekiq, Caching, ActionCable)
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - unione_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Sidekiq (Background Jobs)
  sidekiq:
    build:
      context: .
      dockerfile: Dockerfile
    command: bundle exec sidekiq -C config/sidekiq.yml
    volumes:
      - .:/app
      - gem_cache:/usr/local/bundle
    environment:
      - RAILS_ENV=development
      - DATABASE_URL=postgresql://unione:241996@db:5432/unione_db_development
      - REDIS_URL=redis://redis:6379/1
    depends_on:
      - db
      - redis
    networks:
      - unione_network

  # Mailcatcher (Email Testing)
  mailcatcher:
    image: schickling/mailcatcher
    ports:
      - "1080:1080"
      - "1025:1025"
    networks:
      - unione_network

volumes:
  postgres_data:
  redis_data:
  gem_cache:
  node_modules:

networks:
  unione_network:
    driver: bridge
```

---

## 🐳 Dockerfile (Production)

```dockerfile
# syntax=docker/dockerfile:1

# Base image
FROM ruby:3.2-slim AS base

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    curl \
    wkhtmltopdf \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set working directory
WORKDIR /app

# Install Node.js and Yarn (for asset pipeline)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# Copy Gemfile first (better caching)
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# Create non-root user
RUN useradd -m -s /bin/bash rails && \
    chown -R rails:rails /app /usr/local/bundle
USER rails

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Start Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

---

## 🛠️ Dockerfile.dev (Development)

```dockerfile
# syntax=docker/dockerfile:1

FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    curl \
    wkhtmltopdf \
    postgresql-client \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set working directory
WORKDIR /app

# Environment variables for development
ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle

# Copy Gemfile first
COPY Gemfile Gemfile.lock ./

# Install ALL gems (including development and test)
RUN bundle install

# Copy application code
COPY . .

# Create entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose port
EXPOSE 3000

# Default command (overridden by docker-compose.yml)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
```

---

## 🚪 Entrypoint Script

```bash
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
until pg_isready -h db -U unione; do
  echo "Waiting for database connection..."
  sleep 2
done

echo "Database is ready!"

# Then exec the container's main process (what's set as CMD)
exec "$@"
```

---

## 🧪 Docker Compose for Testing

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - RAILS_ENV=test
      - DATABASE_URL=postgresql://unione:241996@db:5432/unione_db_test
      - REDIS_URL=redis://redis:6379/2
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - test_network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=unione
      - POSTGRES_PASSWORD=241996
      - POSTGRES_DB=unione_db_test
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U unione"]
      interval: 5s
      timeout: 3s
      retries: 3
    networks:
      - test_network

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 3
    networks:
      - test_network

networks:
  test_network:
    driver: bridge
```

---

## 🚫 .dockerignore

```bash
# Version control
.git
.github
.gitignore

# Documentation (not needed in production)
*.md
docs/

# IDE files
.vscode
.idea
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs and temporary files
log/*.log
tmp/**/*

# Dependencies
node_modules/

# Test files
spec/
test/
coverage/

# Database files
*.sqlite3
*.db

# Environment files (use Docker secrets instead)
.env
.env.*

# Docker files (not needed inside container)
Dockerfile*
docker-compose*.yml
.dockerignore

# CI/CD files
.circleci/
.gitlab-ci.yml

# Backup files
*.bak
*.backup
```

---

## 🔐 Production Docker Compose

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://unione:${DB_PASSWORD}@db:5432/unione_db_production
      - REDIS_URL=redis://redis:6379/1
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
      - RAILS_LOG_TO_STDOUT=true
      - RAILS_SERVE_STATIC_FILES=true
    depends_on:
      - db
      - redis
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1024M
      replicas: 2
    networks:
      - production_network

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=unione
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=unione_db_production
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2048M
    networks:
      - production_network

  redis:
    image: redis:7-alpine
    volumes:
      - redis_prod_data:/data
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    networks:
      - production_network

  sidekiq:
    build:
      context: .
      dockerfile: Dockerfile
    command: bundle exec sidekiq -C config/sidekiq.yml
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgresql://unione:${DB_PASSWORD}@db:5432/unione_db_production
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/1
      - SECRET_KEY_BASE=${SECRET_KEY_BASE}
    depends_on:
      - db
      - redis
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    networks:
      - production_network

volumes:
  postgres_prod_data:
  redis_prod_data:

networks:
  production_network:
    driver: bridge
```

---

## 🎯 Common Docker Workflows

### 1. Fresh Start

```bash
# Stop everything and remove all data
docker-compose down -v

# Rebuild from scratch
docker-compose build --no-cache

# Start fresh
docker-compose up -d

# Setup database
docker-compose exec web rails db:create db:migrate db:seed
```

### 2. Development Iteration

```bash
# Start containers
docker-compose up -d

# Edit code on host machine (auto-reloads in container)

# View logs
docker-compose logs -f web

# Stop when done
docker-compose down
```

### 3. Database Migration

```bash
# Create migration
docker-compose exec web rails generate migration AddFieldToTable field:type

# Run migrations
docker-compose exec web rails db:migrate

# Rollback if needed
docker-compose exec web rails db:rollback
```

### 4. Testing

```bash
# Run all tests
docker-compose exec web bundle exec rspec

# Run specific test file
docker-compose exec web bundle exec rspec spec/models/user_spec.rb

# Run with coverage
docker-compose exec web COVERAGE=true bundle exec rspec

# Run tests in separate container
docker-compose -f docker-compose.test.yml run --rm web bundle exec rspec
```

### 5. Debugging

```bash
# Access running container
docker-compose exec web bash

# Rails console
docker-compose exec web rails console

# Database console
docker-compose exec db psql -U unione -d unione_db_development

# View container resource usage
docker stats

# View detailed logs
docker-compose logs --tail=100 web
```

---

## 📊 Docker Environment Variables

### Development (.env file)

```bash
# Rails
RAILS_ENV=development
SECRET_KEY_BASE=dev_secret_key_base_change_me

# Database
DB_HOST=db
DB_PORT=5432
DB_USERNAME=unione
DB_PASSWORD=241996
DB_NAME=unione_db_development

# Redis
REDIS_URL=redis://redis:6379/1

# Mail (Mailcatcher)
SMTP_ADDRESS=mailcatcher
SMTP_PORT=1025
```

### Production (.env.production file)

```bash
# Rails
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)

# Database
DB_HOST=db
DB_PORT=5432
DB_USERNAME=unione
DB_PASSWORD=$(openssl rand -hex 32)
DB_NAME=unione_db_production

# Redis
REDIS_URL=redis://:redis_password@redis:6379/1
REDIS_PASSWORD=redis_password

# Sidekiq
SIDEKIQ_CONCURRENCY=5
```

---

## 🚀 Production Deployment Options

### Option 1: Docker Compose (Simple)

```bash
# Deploy with docker-compose
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Option 2: Kubernetes

```yaml
# kubernetes/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unione-rails
spec:
  replicas: 3
  selector:
    matchLabels:
      app: unione-rails
  template:
    metadata:
      labels:
        app: unione-rails
    spec:
      containers:
      - name: rails
        image: unione/rails:latest
        ports:
        - containerPort: 3000
        env:
        - name: RAILS_ENV
          value: production
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: unione-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: unione-rails-service
spec:
  selector:
    app: unione-rails
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: LoadBalancer
```

### Option 3: Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create unione-rails

# Add PostgreSQL addon
heroku addons:create heroku-postgresql:standard-0

# Add Redis addon
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set RAILS_ENV=production
heroku config:set SECRET_KEY_BASE=$(openssl rand -hex 64)

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
heroku run rails db:seed
```

---

## 🆘 Docker Troubleshooting

### Issue: Container won't start

```bash
# Check logs
docker-compose logs web

# Rebuild container
docker-compose build --no-cache web
docker-compose up -d web
```

### Issue: Database connection failed

```bash
# Check if database is running
docker-compose ps

# Wait for database health check
docker-compose logs -f db

# Test connection
docker-compose exec web pg_isready -h db -U unione
```

### Issue: Port already in use

```bash
# Kill process on port
lsof -ti:3000 | xargs kill -9

# Or change port in docker-compose.yml
# ports:
#   - "3001:3000"
```

### Issue: Gemfile changes not picked up

```bash
# Rebuild image
docker-compose build web
docker-compose up -d web
```

### Issue: Permission denied

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Or run container with correct user
docker-compose exec -u root web bash
```

### Issue: Volume data persists after rebuild

```bash
# Remove volumes
docker-compose down -v

# Recreate volumes
docker-compose up -d
```

---

## 📊 Docker Performance Tips

### 1. Use .dockerignore

Exclude unnecessary files from build context (see .dockerignore above)

### 2. Optimize Dockerfile layer caching

```dockerfile
# Copy Gemfile first (changes less frequently)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Then copy application code
COPY . .
```

### 3. Use multi-stage builds

```dockerfile
# Build stage
FROM ruby:3.2 AS builder
WORKDIR /app
COPY . .
RUN bundle exec rails assets:precompile

# Production stage
FROM ruby:3.2-slim
COPY --from=builder /app /app
```

### 4. Use Docker volumes for gems

```yaml
volumes:
  - gem_cache:/usr/local/bundle
```

### 5. Limit resource usage

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1024M
```

---

**Docker setup complete! Ready to containerize your Rails application.** 🐳
