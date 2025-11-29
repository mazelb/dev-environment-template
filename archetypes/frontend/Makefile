.PHONY: help install dev build start lint format test clean

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Frontend Archetype - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# ==============================
# Development
# ==============================

install: ## Install dependencies
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm install
	@echo "$(GREEN)Dependencies installed!$(NC)"

dev: ## Start development server
	@echo "$(BLUE)Starting development server...$(NC)"
	npm run dev

build: ## Build for production
	@echo "$(BLUE)Building for production...$(NC)"
	npm run build
	@echo "$(GREEN)Build complete!$(NC)"

start: ## Start production server
	@echo "$(BLUE)Starting production server...$(NC)"
	npm start

# ==============================
# Code Quality
# ==============================

lint: ## Run ESLint
	@echo "$(BLUE)Running ESLint...$(NC)"
	npm run lint

type-check: ## Run TypeScript type checking
	@echo "$(BLUE)Running TypeScript type checking...$(NC)"
	npm run type-check

format: ## Format code with Prettier
	@echo "$(BLUE)Formatting code...$(NC)"
	npm run format
	@echo "$(GREEN)Code formatted!$(NC)"

format-check: ## Check code formatting
	@echo "$(BLUE)Checking code formatting...$(NC)"
	npm run format:check

# ==============================
# Testing
# ==============================

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	npm test

test-ui: ## Run tests with UI
	@echo "$(BLUE)Running tests with UI...$(NC)"
	npm run test:ui

test-coverage: ## Run tests with coverage
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	npm run test:coverage
	@echo "$(GREEN)Coverage report generated!$(NC)"

# ==============================
# Docker
# ==============================

docker-build: ## Build Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	docker build -t frontend-archetype .
	@echo "$(GREEN)Docker image built!$(NC)"

docker-run: ## Run Docker container
	@echo "$(BLUE)Running Docker container...$(NC)"
	docker run -p 3000:3000 \
		-e NEXT_PUBLIC_API_URL=http://localhost:8000 \
		-e NEXT_PUBLIC_GRAPHQL_URL=http://localhost:8000/graphql \
		-e NEXT_PUBLIC_WS_URL=ws://localhost:8000 \
		frontend-archetype

docker-stop: ## Stop Docker container
	@echo "$(BLUE)Stopping Docker container...$(NC)"
	docker stop $$(docker ps -q --filter ancestor=frontend-archetype)

# ==============================
# Cleanup
# ==============================

clean: ## Clean build artifacts
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf .next
	rm -rf node_modules/.cache
	rm -rf coverage
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-all: ## Clean all generated files
	@echo "$(RED)WARNING: This will remove node_modules and all build artifacts!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf .next node_modules coverage; \
		echo "$(GREEN)All files cleaned!$(NC)"; \
	else \
		echo "$(BLUE)Cancelled.$(NC)"; \
	fi

# ==============================
# Setup
# ==============================

setup: ## Complete setup (install + env file)
	@echo "$(BLUE)Setting up frontend...$(NC)"
	@if [ ! -f .env.local ]; then \
		cp .env.example .env.local; \
		echo "$(GREEN)Created .env.local from .env.example$(NC)"; \
	fi
	make install
	@echo "$(GREEN)Setup complete!$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Update .env.local with your API URLs"
	@echo "  2. Run 'make dev' to start development server"
