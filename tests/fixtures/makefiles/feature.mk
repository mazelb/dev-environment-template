.PHONY: build test deploy lint

build:
	@echo "Building feature modules..."
	@docker-compose -f docker-compose.feature.yml build

test:
	@echo "Running feature tests..."
	@pytest tests/feature/ -v --cov

deploy:
	@echo "Deploying feature..."
	@docker-compose -f docker-compose.feature.yml up -d

lint:
	@echo "Linting feature code..."
	@pylint src/feature/

help:
	@echo "Feature Module Makefile"
	@echo "  build  - Build feature images"
	@echo "  test   - Run feature tests"
	@echo "  deploy - Deploy feature"
	@echo "  lint   - Lint feature code"
