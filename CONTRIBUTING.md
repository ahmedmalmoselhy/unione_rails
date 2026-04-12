# Contributing to UniOne Rails

Thank you for your interest in contributing to the UniOne academic management platform!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Requests](#pull-requests)
- [Database Migrations](#database-migrations)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the community

## Getting Started

### Prerequisites

- Ruby >= 3.1.0
- PostgreSQL 15
- Redis 7+
- Docker & Docker Compose (recommended)

### Setup

```bash
# Clone the repository
git clone https://github.com/unione/unione_rails.git
cd unione_rails

# Install dependencies
bundle install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start development server
rails server
```

### Using Docker

```bash
docker-compose up -d
```

## Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/feature-name
   ```

2. **Make your changes**
   - Follow coding standards
   - Write tests
   - Update documentation

3. **Commit your changes**
   - Use conventional commit messages
   - Commit frequently with clear messages

4. **Push and create PR**
   ```bash
   git push origin feature/feature-name
   ```

## Coding Standards

### Ruby Style

- Use **2 spaces** for indentation
- Use **snake_case** for methods and variables
- Use **PascalCase** for classes and modules
- Maximum **80 characters** per line (soft limit)
- Use **single quotes** unless interpolation is needed

### Rails Conventions

- **Fat models, thin controllers** - Use service objects for business logic
- **Strong parameters** - Always permit explicitly
- **Pundit policies** - Authorization logic in policy classes
- **Eager loading** - Use `includes` to prevent N+1 queries
- **JSON responses** - Use consistent format:
  ```ruby
  render json: {
    success: true,
    message: 'Success message',
    data: { ... }
  }
  ```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test changes
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks

Examples:
```
feat: add student profile endpoint
fix: resolve namespace conflict in admin controllers
docs: update API documentation
test: add model specs for Student and Professor
```

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/student_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Writing Tests

- **Model specs** - Test validations, associations, methods
- **Request specs** - Test API endpoints
- **Service specs** - Test business logic
- Use **FactoryBot** for test data
- Target **80%+ coverage**

Example:
```ruby
RSpec.describe Student, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:faculty) }
  end

  describe 'validations' do
    it { should validate_presence_of(:student_number) }
  end
end
```

## Pull Requests

### Before Submitting

1. **Run the test suite**
   ```bash
   bundle exec rspec
   ```

2. **Check for linting issues**
   ```bash
   bundle exec rubocop
   ```

3. **Update documentation** if needed

4. **Rebase on main**
   ```bash
   git fetch origin
   git rebase origin/main
   ```

### PR Template

- **Description** - What does this PR do?
- **Changes** - Key changes made
- **Testing** - How was it tested?
- **Screenshots** - If applicable

## Database Migrations

### Creating Migrations

```bash
rails generate migration CreateNewTable
```

### Best Practices

- Add **foreign keys** with `foreign_key: true`
- Add **indexes** on frequently queried columns
- Use **t.timestamps** for all tables
- Make migrations **reversible** (avoid `change` with `execute`)
- Test migrations with existing data

### Running Migrations

```bash
# Run pending migrations
rails db:migrate

# Check migration status
rails db:migrate:status

# Rollback last migration
rails db:rollback
```

## Questions?

- Check the [README](README.md) for setup instructions
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API details
- Check [CHANGELOG.md](CHANGELOG.md) for recent changes
- Check [AUDIT_SUMMARY.md](AUDIT_SUMMARY.md) for project status

---

Thank you for contributing! 🎉
