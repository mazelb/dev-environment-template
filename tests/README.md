# Test Suite Documentation

This directory contains comprehensive tests for the dev-environment-template project, covering both the RAG and API-Service archetypes.

## Test Structure

```
tests/
├── e2e/                           # End-to-end tests
│   └── test_archetype_creation.py # Archetype creation and validation
│
archetypes/
├── rag-project/
│   ├── pytest.ini                 # RAG pytest configuration
│   ├── conftest.py                # RAG test fixtures
│   └── tests/
│       ├── unit/                  # RAG unit tests
│       │   ├── test_cache.py
│       │   ├── test_database.py
│       │   ├── test_opensearch.py
│       │   ├── test_ollama.py
│       │   ├── test_embeddings.py
│       │   └── test_chunking.py
│       └── integration/           # RAG integration tests
│           ├── test_rag_pipeline.py
│           ├── test_api_endpoints.py
│           └── test_docker_services.py
│
└── api-service/
    ├── pytest.ini                 # API pytest configuration
    ├── conftest.py                # API test fixtures
    └── tests/
        ├── unit/                  # API unit tests
        │   ├── test_auth.py
        │   ├── test_database.py
        │   ├── test_middleware.py
        │   └── test_config.py
        └── integration/           # API integration tests
            ├── test_api_endpoints.py
            └── test_docker_services.py
```

## Test Categories

### Unit Tests (`-m unit`)
- Test individual components in isolation
- Use mocks for external dependencies
- Fast execution
- No Docker required

**RAG Archetype Unit Tests:**
- Cache service (Redis client)
- Database layer (SQLAlchemy)
- OpenSearch client
- Ollama client
- Embedding service
- Chunking service

**API Archetype Unit Tests:**
- Authentication (JWT, password hashing)
- Database configuration
- Middleware (logging, rate limiting)
- Configuration management

### Integration Tests (`-m integration`)
- Test interaction between components
- May use mocked external services
- Moderate execution time
- Some require Docker services

**RAG Archetype Integration Tests:**
- RAG pipeline end-to-end
- Service interactions (embedding → OpenSearch, chunking → embedding)
- API endpoints
- Docker service connectivity

**API Archetype Integration Tests:**
- Authentication flows
- Protected endpoints
- Database connections
- Redis connectivity

### End-to-End Tests (`-m e2e`)
- Test complete workflows
- Use real services when possible
- Slow execution
- Validate archetype structure and configuration

**E2E Tests:**
- Archetype directory structure
- Required files presence
- Docker Compose validity
- Requirements.txt validity
- Configuration file validity
- Documentation completeness

### Docker Tests (`-m docker`)
- Require Docker services running
- Test real service connectivity
- Slow execution
- Can be skipped with `--skip-docker`

## Running Tests

### Using PowerShell Script (Recommended)

```powershell
# Run all tests
.\run-tests.ps1

# Run unit tests only
.\run-tests.ps1 -TestType unit

# Run integration tests for RAG archetype
.\run-tests.ps1 -Archetype rag -TestType integration

# Run tests without Docker
.\run-tests.ps1 -SkipDocker

# Generate coverage report
.\run-tests.ps1 -Coverage

# Run specific archetype
.\run-tests.ps1 -Archetype api
```

### Using pytest Directly

**RAG Archetype:**
```bash
cd archetypes/rag-project

# All tests
pytest

# Unit tests only
pytest -m unit

# Integration tests
pytest -m integration

# Skip Docker tests
pytest -m "not docker"

# Specific test file
pytest tests/unit/test_cache.py

# With coverage
pytest --cov=src --cov-report=html
```

**API Archetype:**
```bash
cd archetypes/api-service

# All tests
pytest

# Unit tests only
pytest -m unit

# Integration tests
pytest -m integration
```

**E2E Tests:**
```bash
# From root directory
pytest tests/e2e/
```

## Test Markers

Tests are marked with pytest markers for selective execution:

- `@pytest.mark.unit` - Unit tests
- `@pytest.mark.integration` - Integration tests
- `@pytest.mark.e2e` - End-to-end tests
- `@pytest.mark.docker` - Requires Docker services
- `@pytest.mark.slow` - Slow-running tests
- `@pytest.mark.asyncio` - Async tests

## Prerequisites

### For Unit Tests
```bash
pip install -r requirements.txt
```

### For Integration and Docker Tests
1. Install Docker and Docker Compose
2. Start services:
   ```bash
   cd archetypes/rag-project  # or api-service
   docker-compose up -d
   ```
3. Wait for services to be healthy (30-60 seconds)

## Test Coverage

Generate coverage reports:

```bash
# RAG archetype
cd archetypes/rag-project
pytest --cov=src --cov-report=html --cov-report=term-missing

# API archetype
cd archetypes/api-service
pytest --cov=src --cov-report=html --cov-report=term-missing
```

View HTML reports:
- RAG: `archetypes/rag-project/htmlcov/index.html`
- API: `archetypes/api-service/htmlcov/index.html`

## Continuous Integration

Tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run Unit Tests
  run: |
    python -m pytest -m unit

- name: Run Integration Tests
  run: |
    docker-compose up -d
    sleep 30
    python -m pytest -m integration
```

## Test Fixtures

### RAG Archetype Fixtures
- `test_settings` - Test configuration
- `test_db_engine` - SQLite test database
- `test_db_session` - Database session
- `mock_redis` - Mock Redis client
- `mock_opensearch_client` - Mock OpenSearch
- `mock_ollama_client` - Mock Ollama
- `mock_embedding_service` - Mock embeddings
- `sample_documents` - Test documents
- `sample_chunks` - Test chunks
- `docker_compose_up` - Start Docker services
- `client` - FastAPI test client

### API Archetype Fixtures
- `test_settings` - Test configuration
- `client` - FastAPI test client
- `auth_headers` - Authentication headers
- `docker_compose_up` - Start Docker services
- `cleanup_db` - Clean up test database

## Troubleshooting

### Tests Failing Due to Missing Dependencies
```bash
pip install -r requirements.txt
```

### Docker Tests Failing
1. Check Docker is running: `docker ps`
2. Start services: `docker-compose up -d`
3. Wait for health checks: `docker-compose ps`
4. Check logs: `docker-compose logs`

### Import Errors
Ensure you're in the correct directory when running tests.

### Async Test Warnings
Install: `pip install pytest-asyncio`

## Best Practices

1. **Run unit tests frequently** during development
2. **Run integration tests** before committing
3. **Run full test suite** before merging
4. **Generate coverage reports** to identify gaps
5. **Use markers** to run relevant test subsets
6. **Mock external services** in unit tests
7. **Clean up test data** after each test

## Future Enhancements

- [ ] Add performance benchmarks
- [ ] Add load testing
- [ ] Add security testing
- [ ] Add API contract testing
- [ ] Improve Docker test isolation
- [ ] Add mutation testing
- [ ] Increase coverage to 90%+
