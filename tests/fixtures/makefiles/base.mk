.PHONY: build test clean run

build:
	@echo "Building base application..."
	@docker-compose build

test:
	@echo "Running base tests..."
	@pytest tests/ -v

clean:
	@echo "Cleaning base build artifacts..."
	@rm -rf __pycache__ .pytest_cache
	@docker-compose down -v

run:
	@echo "Starting base application..."
	@docker-compose up -d

help:
	@echo "Base Application Makefile"
	@echo "  build  - Build Docker images"
	@echo "  test   - Run tests"
	@echo "  clean  - Clean artifacts"
	@echo "  run    - Start application"
