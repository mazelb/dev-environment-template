.PHONY: help start stop restart status health logs shell

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)API Service - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# ==============================
# Service Management
# ==============================

start: ## Start all services
	@echo "$(BLUE)Starting API Service...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services started!$(NC)"
	@echo "API: http://localhost:8000"
	@echo "GraphQL: http://localhost:8000/graphql"
	@echo "Flower: http://localhost:5555"
	@echo "Docs: http://localhost:8000/docs"

stop: ## Stop all services
	@echo "$(BLUE)Stopping services...$(NC)"
	docker-compose down
	@echo "$(GREEN)Services stopped!$(NC)"

restart: ## Restart all services
	@echo "$(BLUE)Restarting services...$(NC)"
	docker-compose restart
	@echo "$(GREEN)Services restarted!$(NC)"

status: ## Show service status
	@echo "$(BLUE)Service Status:$(NC)"
	@docker-compose ps

health: ## Check service health
	@echo "$(BLUE)Checking service health...$(NC)"
	@echo "API Health:"
	@curl -s http://localhost:8000/health | jq || echo "$(RED)API not responding$(NC)"
	@echo "\nRedis:"
	@docker-compose exec -T redis redis-cli ping || echo "$(RED)Redis not responding$(NC)"
	@echo "\nPostgreSQL:"
	@docker-compose exec -T postgres pg_isready -U api_user || echo "$(RED)PostgreSQL not responding$(NC)"

logs: ## View logs (SERVICE=api,redis,postgres,celery-worker,flower)
	@if [ "$(SERVICE)" ]; then \
		docker-compose logs -f $(SERVICE); \
	else \
		docker-compose logs -f; \
	fi

# ==============================
# Development
# ==============================

shell: ## Open API service shell
	docker-compose exec api /bin/bash

redis-cli: ## Open Redis CLI
	docker-compose exec redis redis-cli

db-shell: ## Open PostgreSQL shell
	docker-compose exec postgres psql -U api_user -d api_db

# ==============================
# Database Operations
# ==============================

db-migrate: ## Create new database migration (MESSAGE="description")
	@if [ -z "$(MESSAGE)" ]; then \
		echo "$(RED)ERROR: MESSAGE is required$(NC)"; \
		echo "Usage: make db-migrate MESSAGE=\"your migration description\""; \
		exit 1; \
	fi
	docker-compose exec api alembic revision --autogenerate -m "$(MESSAGE)"

db-upgrade: ## Apply database migrations
	@echo "$(BLUE)Applying database migrations...$(NC)"
	docker-compose exec api alembic upgrade head
	@echo "$(GREEN)Migrations applied!$(NC)"

db-downgrade: ## Rollback last migration
	@echo "$(BLUE)Rolling back last migration...$(NC)"
	docker-compose exec api alembic downgrade -1
	@echo "$(GREEN)Migration rolled back!$(NC)"

db-history: ## Show migration history
	docker-compose exec api alembic history

db-current: ## Show current migration
	docker-compose exec api alembic current

db-reset: ## Reset database (WARNING: destroys all data)
	@echo "$(RED)WARNING: This will destroy all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		docker-compose up -d postgres redis; \
		sleep 5; \
		make db-upgrade; \
		echo "$(GREEN)Database reset complete!$(NC)"; \
	else \
		echo "$(BLUE)Cancelled.$(NC)"; \
	fi

# ==============================
# Celery Operations
# ==============================

celery-status: ## Show Celery worker status
	docker-compose exec celery-worker celery -A src.celery_app.celery status

celery-inspect: ## Inspect Celery workers
	docker-compose exec celery-worker celery -A src.celery_app.celery inspect stats

celery-purge: ## Purge all tasks from queue
	@echo "$(RED)This will purge ALL tasks from the queue!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose exec celery-worker celery -A src.celery_app.celery purge -f; \
		echo "$(GREEN)Queue purged!$(NC)"; \
	else \
		echo "$(BLUE)Cancelled.$(NC)"; \
	fi

celery-logs: ## View Celery worker logs
	docker-compose logs -f celery-worker

flower-logs: ## View Flower logs
	docker-compose logs -f flower

# ==============================
# Code Quality
# ==============================

format: ## Format code with black
	docker-compose exec api black src/ tests/

lint: ## Lint code with pylint
	docker-compose exec api pylint src/

# ==============================
# Testing
# ==============================

test: ## Run tests
	docker-compose exec api pytest tests/ -v

test-cov: ## Run tests with coverage
	docker-compose exec api pytest tests/ -v --cov=src --cov-report=html --cov-report=term-missing
	@echo "$(GREEN)Coverage report: htmlcov/index.html$(NC)"

test-unit: ## Run unit tests only
	docker-compose exec api pytest tests/unit/ -v

test-integration: ## Run integration tests only
	docker-compose exec api pytest tests/integration/ -v

# ==============================
# Setup & Installation
# ==============================

setup: ## Install dependencies
	docker-compose build --no-cache
	docker-compose up -d
	@echo "$(BLUE)Waiting for services to be ready...$(NC)"
	sleep 10
	make db-upgrade
	@echo "$(GREEN)Setup complete!$(NC)"

setup-dev: ## Install development dependencies
	docker-compose exec api pip install -r requirements.txt

# ==============================
# Cleanup
# ==============================

clean: ## Clean up temporary files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	rm -rf htmlcov/ .pytest_cache/ .mypy_cache/
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-docker: ## Remove all Docker resources
	@echo "$(RED)WARNING: This will remove ALL Docker containers, volumes, and networks!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v --remove-orphans; \
		echo "$(GREEN)Docker cleanup complete!$(NC)"; \
	else \
		echo "$(BLUE)Cancelled.$(NC)"; \
	fi

# ==============================
# Monitoring
# ==============================

metrics: ## Show Prometheus metrics
	@curl -s http://localhost:8000/metrics

celery-flower: ## Open Flower dashboard in browser
	@echo "$(BLUE)Opening Flower dashboard...$(NC)"
	@which xdg-open > /dev/null && xdg-open http://localhost:5555 || open http://localhost:5555 || echo "$(BLUE)Flower: http://localhost:5555$(NC)"
