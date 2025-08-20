# DOCKER MANAGEMENT MAKEFILE

# Variables
PROJECT_NAME ?= myapp
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = docker-compose.yml
ENV_FILE = .env

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build up down restart logs shell test clean prune

# HELP
help:
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# DEVELOPMENT
submodule-init: ## Initialize submodules
	@echo "$(GREEN)Initializing submodules...$(NC)"
	git submodule update --init --recursive

submodule-update: ## Update submodules
	@echo "$(GREEN)Updating submodules...$(NC)"
	git submodule update --remote --merge

build: ## Build images without cache
	@echo "$(GREEN)Building images...$(NC)"
	$(DOCKER_COMPOSE) build --no-cache

up: ## Start application
	@echo "$(GREEN)Starting application...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Application started!$(NC)"
	@echo "$(YELLOW)API: http://localhost:3000$(NC)"
	@echo "$(YELLOW)Admin: http://localhost:3005$(NC)"
	@echo "$(YELLOW)MongoDB Express: http://localhost:8081$(NC)"
	@echo "$(YELLOW)Redis Commander: http://localhost:8082$(NC)"
	@echo "$(YELLOW)MailHog: http://localhost:8025$(NC)"

up-build: ## Build and start
	@echo "$(GREEN)Building and starting...$(NC)"
	$(DOCKER_COMPOSE) up -d --build

down: ## Stop application
	@echo "$(YELLOW)Stopping application...$(NC)"
	$(DOCKER_COMPOSE) down

restart: ## Restart application
	@echo "$(YELLOW)Restarting...$(NC)"
	$(DOCKER_COMPOSE) restart

# PRODUCTION
prod-up: ## Start in production mode
	@echo "$(GREEN)Starting production...$(NC)"
	$(DOCKER_COMPOSE) --profile production up -d

prod-build: ## Build for production
	@echo "$(GREEN)Building for production...$(NC)"
	$(DOCKER_COMPOSE) build --target production nestjs_api

# MONITORING
monitoring-up: ## Start monitoring tools
	@echo "$(GREEN)Starting monitoring...$(NC)"
	$(DOCKER_COMPOSE) --profile monitoring up -d
	@echo "$(YELLOW)Prometheus: http://localhost:9090$(NC)"
	@echo "$(YELLOW)Grafana: http://localhost:3001$(NC)"

# LOGS AND DEBUG
logs: ## Show all services logs
	$(DOCKER_COMPOSE) logs -f

logs-api: ## Show API logs
	$(DOCKER_COMPOSE) logs -f nestjs_api

logs-db: ## Show MongoDB logs
	$(DOCKER_COMPOSE) logs -f mongodb

logs-redis: ## Show Redis logs
	$(DOCKER_COMPOSE) logs -f redis

logs-admin: ## Show Admin logs
	$(DOCKER_COMPOSE) logs -f admin

# SHELL ACCESS
shell: ## Access API container shell
	$(DOCKER_COMPOSE) exec nestjs_api sh

shell-db: ## Access MongoDB shell
	$(DOCKER_COMPOSE) exec mongodb mongosh

shell-redis: ## Access Redis CLI
	$(DOCKER_COMPOSE) exec redis redis-cli

shell-admin: ## Access Admin container shell
	$(DOCKER_COMPOSE) exec admin sh

# TESTS
test: ## Run tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test

test-e2e: ## Run E2E tests
	@echo "$(GREEN)Running E2E tests...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test:e2e

test-cov: ## Run tests with coverage
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test:cov

# DATABASE
db-up: ## Start MongoDB only
	@echo "$(GREEN)Starting MongoDB...$(NC)"
	$(DOCKER_COMPOSE) up -d mongodb

db-test: ## Test database connection
	@echo "$(GREEN)Testing MongoDB connection...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test:db

db-seed: ## Seed database with test data
	@echo "$(GREEN)Seeding database...$(NC)"
	$(DOCKER_COMPOSE) exec nestjs_api npm run seed

db-migrate: ## Run migrations
	@echo "$(GREEN)Running migrations...$(NC)"
	$(DOCKER_COMPOSE) exec nestjs_api npm run migration:run

db-backup: ## Backup database
	@echo "$(GREEN)Backing up MongoDB...$(NC)"
	docker exec $$(docker-compose ps -q mongodb) mongodump --out /tmp/backup
	docker cp $$(docker-compose ps -q mongodb):/tmp/backup ./backups/$(shell date +%Y%m%d_%H%M%S)

db-restore: ## Restore database (usage: make db-restore BACKUP=backup_folder)
	@echo "$(GREEN)Restoring MongoDB...$(NC)"
	docker cp ./backups/$(BACKUP) $$(docker-compose ps -q mongodb):/tmp/restore
	docker exec $$(docker-compose ps -q mongodb) mongorestore /tmp/restore

# MAINTENANCE
clean: ## Clean stopped containers
	@echo "$(YELLOW)Cleaning containers...$(NC)"
	docker container prune -f

clean-images: ## Clean unused images
	@echo "$(YELLOW)Cleaning images...$(NC)"
	docker image prune -f

clean-volumes: ## Clean unused volumes (WARNING: data loss!)
	@echo "$(RED)WARNING: Cleaning volumes (data loss!)$(NC)"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ]
	docker volume prune -f

prune: ## Clean all Docker (WARNING: destructive)
	@echo "$(RED)WARNING: Complete Docker cleanup!$(NC)"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ]
	docker system prune -af --volumes

# UTILITIES
ps: ## Show container status
	$(DOCKER_COMPOSE) ps

stats: ## Show container statistics
	docker stats $$(docker-compose ps -q)

check-env: ## Check environment configuration
	@echo "$(GREEN)Checking environment...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)Missing .env file! Copy .env.example to .env$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN).env file found$(NC)"

init: check-env submodule-init ## Initialize project (first use)
	@echo "$(GREEN)Initializing project...$(NC)"
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Project initialized successfully!$(NC)"

# CI/CD
ci-test: ## Run CI/CD tests
	$(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.test.yml up --build --abort-on-container-exit

lint: ## Run linter
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run lint

format: ## Format code
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run format
