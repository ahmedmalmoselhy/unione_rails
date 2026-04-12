.PHONY: help setup up down logs db migrate seed test console shell clean restart

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Build and setup the environment
	docker-compose build
	docker-compose run --rm web bundle install
	docker-compose run --rm web rails db:create
	docker-compose run --rm web rails db:migrate
	docker-compose run --rm web rails db:seed

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## Follow logs
	docker-compose logs -f

db: ## Open database console
	docker-compose exec db psql -U unione -d unione_db_development

migrate: ## Run database migrations
	docker-compose run --rm web rails db:migrate

rollback: ## Rollback last migration
	docker-compose run --rm web rails db:rollback

seed: ## Seed database
	docker-compose run --rm web rails db:seed

reset: ## Reset database (drop + create + migrate + seed)
	docker-compose run --rm web rails db:reset

test: ## Run tests
	docker-compose run --rm web bundle exec rspec

console: ## Open Rails console
	docker-compose exec web rails console

shell: ## Open shell in web container
	docker-compose exec web bash

clean: ## Remove containers and volumes
	docker-compose down -v

restart: ## Restart all services
	docker-compose restart
