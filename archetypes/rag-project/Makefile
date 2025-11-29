.PHONY: help start stop restart status logs health setup format lint test test-cov clean db-migrate db-upgrade db-downgrade

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Service management
start: ## Start all services
	docker compose up --build -d

stop: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

status: ## Show service status
	docker compose ps

logs: ## Show service logs (use: make logs SERVICE=api)
	@if [ -z "$(SERVICE)" ]; then \
		docker compose logs -f; \
	else \
		docker compose logs -f $(SERVICE); \
	fi

# Health checks
health: ## Check all services health
	@echo "Checking service health..."
	@echo "\n=== API Health ==="
	@curl -s http://localhost:8000/api/v1/health | python -m json.tool || echo "API not responding"
	@echo "\n=== PostgreSQL Health ==="
	@docker compose exec -T postgres pg_isready -U rag_user || echo "PostgreSQL not responding"
	@echo "\n=== Redis Health ==="
	@docker compose exec -T redis redis-cli ping || echo "Redis not responding"
	@echo "\n=== OpenSearch Health ==="
	@curl -s http://localhost:9200/_cluster/health | python -m json.tool || echo "OpenSearch not responding"
	@echo "\n=== Ollama Health ==="
	@curl -s http://localhost:11434/api/version | python -m json.tool || echo "Ollama not responding"
	@echo "\n=== Langfuse Health ==="
	@curl -s http://localhost:3000/api/public/health || echo "Langfuse not responding"

# Development setup
setup: ## Install Python dependencies
	pip install -r requirements.txt

setup-dev: ## Install development dependencies
	pip install -r requirements.txt
	pip install pytest pytest-asyncio pytest-cov ruff mypy pre-commit
	pre-commit install

# Code quality
format: ## Format code with ruff
	ruff format src/ tests/

lint: ## Lint and type check
	ruff check --fix src/ tests/
	mypy src/

# Testing
test: ## Run tests
	pytest tests/ -v

test-cov: ## Run tests with coverage
	pytest tests/ --cov=src --cov-report=html --cov-report=term

test-watch: ## Run tests in watch mode
	pytest-watch tests/ -v

# Database migrations
db-migrate: ## Create a new migration (use: make db-migrate MESSAGE="description")
	@if [ -z "$(MESSAGE)" ]; then \
		echo "Error: MESSAGE is required. Usage: make db-migrate MESSAGE='your message'"; \
		exit 1; \
	fi
	alembic revision --autogenerate -m "$(MESSAGE)"

db-upgrade: ## Apply all pending migrations
	alembic upgrade head

db-downgrade: ## Rollback last migration
	alembic downgrade -1

db-history: ## Show migration history
	alembic history

db-current: ## Show current migration version
	alembic current

# Docker utilities
shell: ## Open shell in API container
	docker compose exec api /bin/bash

db-shell: ## Open PostgreSQL shell
	docker compose exec postgres psql -U rag_user -d rag_db

redis-cli: ## Open Redis CLI
	docker compose exec redis redis-cli

# Data management
db-reset: ## Reset database (WARNING: destroys all data)
	@echo "WARNING: This will destroy all data. Press Ctrl+C to cancel..."
	@sleep 5
	docker compose down -v
	docker compose up -d postgres
	@sleep 10
	alembic upgrade head

seed: ## Seed database with sample data
	python scripts/seed_data.py

# Cleanup
clean: ## Clean up temporary files and caches
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.coverage" -delete
	rm -rf .pytest_cache htmlcov .ruff_cache .mypy_cache

clean-docker: ## Remove all Docker resources (WARNING: removes volumes)
	docker compose down -v --remove-orphans
	docker system prune -f

# OpenSearch utilities
opensearch-indices: ## List all OpenSearch indices
	curl -X GET "http://localhost:9200/_cat/indices?v"

opensearch-create-index: ## Create default index
	python scripts/setup_opensearch.py

# Ollama utilities
ollama-pull: ## Pull Ollama model (use: make ollama-pull MODEL=llama2)
	docker compose exec ollama ollama pull $(MODEL)

ollama-list: ## List downloaded Ollama models
	docker compose exec ollama ollama list

# Airflow utilities
airflow-init: ## Initialize Airflow database (first time setup)
	docker compose run --rm airflow-webserver db init || echo "Database already initialized"
	docker compose run --rm airflow-webserver users create \
		--username airflow \
		--firstname Airflow \
		--lastname Admin \
		--role Admin \
		--email admin@example.com \
		--password airflow || echo "User already exists"

airflow-start: ## Start Airflow services (scheduler + webserver)
	docker compose up -d airflow-scheduler airflow-webserver
	@echo "Airflow is starting..."
	@echo "Webserver: http://localhost:8080 (user: airflow, pass: airflow)"

airflow-stop: ## Stop Airflow services
	docker compose stop airflow-scheduler airflow-webserver

airflow-logs: ## View Airflow logs (use: make airflow-logs SERVICE=scheduler)
	@if [ -z "$(SERVICE)" ]; then \
		docker compose logs -f airflow-scheduler airflow-webserver; \
	else \
		docker compose logs -f airflow-$(SERVICE); \
	fi

airflow-shell: ## Open shell in Airflow webserver
	docker compose exec airflow-webserver /bin/bash

airflow-list-dags: ## List all DAGs
	docker compose exec airflow-webserver airflow dags list

airflow-trigger: ## Trigger a DAG (use: make airflow-trigger DAG_ID=hello_world)
	@if [ -z "$(DAG_ID)" ]; then \
		echo "Error: DAG_ID is required. Usage: make airflow-trigger DAG_ID=hello_world"; \
		exit 1; \
	fi
	docker compose exec airflow-webserver airflow dags trigger $(DAG_ID)

airflow-test-dag: ## Test a DAG (use: make airflow-test-dag DAG_ID=hello_world)
	@if [ -z "$(DAG_ID)" ]; then \
		echo "Error: DAG_ID is required. Usage: make airflow-test-dag DAG_ID=hello_world"; \
		exit 1; \
	fi
	docker compose exec airflow-webserver airflow dags test $(DAG_ID) $(shell date +%Y-%m-%d)

# Langfuse utilities
langfuse-status: ## Check Langfuse status
	@echo "Langfuse UI: http://localhost:3000"
	@curl -s http://localhost:3000/api/public/health || echo "Langfuse not responding"

langfuse-logs: ## View Langfuse logs
	docker compose logs -f langfuse

# Full stack operations
full-start: ## Start all services and run migrations
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 30
	make db-upgrade
	@echo "Stack is ready!"

full-reset: ## Complete reset and fresh start
	make clean-docker
	make full-start
	@echo "Full reset complete!"
