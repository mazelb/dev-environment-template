# Archetype Implementation Testing Guide

Guide for testing the actual code within each archetype using pytest, including unit tests, integration tests, and end-to-end tests.

**Last Updated:** December 5, 2025

---

## Table of Contents

1. [Overview](#overview)
2. [Test Categories](#test-categories)
3. [RAG Archetype Tests](#rag-archetype-tests)
4. [API Archetype Tests](#api-archetype-tests)
5. [Running Tests](#running-tests)
6. [Test Fixtures](#test-fixtures)
7. [Docker Testing](#docker-testing)
8. [Coverage Reporting](#coverage-reporting)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Overview

Archetype implementation tests validate the actual code within each archetype. These tests use pytest and are organized into three categories:

- **Unit Tests:** Test individual components in isolation
- **Integration Tests:** Test interaction between components
- **End-to-End Tests:** Test complete workflows

### Test File Structure

```
archetypes/
├── rag-project/
│   ├── pytest.ini                 # pytest configuration
│   ├── conftest.py                # Test fixtures
│   └── tests/
│       ├── unit/                  # Unit tests
│       │   ├── test_cache.py
│       │   ├── test_database.py
│       │   ├── test_opensearch.py
│       │   ├── test_ollama.py
│       │   ├── test_embeddings.py
│       │   └── test_chunking.py
│       ├── integration/           # Integration tests
│       │   ├── test_rag_pipeline.py
│       │   ├── test_api_endpoints.py
│       │   └── test_docker_services.py
│       └── e2e/                   # E2E tests
│           └── test_workflows.py
│
└── api-service/
    ├── pytest.ini
    ├── conftest.py
    └── tests/
        ├── unit/
        │   ├── test_auth.py
        │   ├── test_database.py
        │   └── test_middleware.py
        └── integration/
            ├── test_api_endpoints.py
            └── test_docker_services.py
```

---

## Test Categories

### Unit Tests (`-m unit`)

**Purpose:** Test individual components in isolation
**Dependencies:** Mocked
**Docker Required:** No
**Execution Time:** Fast (<1 minute)

**Example:**
```python
import pytest
from unittest.mock import Mock
from src.services.cache.client import RedisCache

@pytest.mark.unit
def test_redis_set_get():
    # Mock Redis client
    mock_redis = Mock()
    cache = RedisCache(client=mock_redis)

    # Test set/get
    cache.set("key", "value")
    mock_redis.set.assert_called_once_with("key", "value")

    mock_redis.get.return_value = "value"
    result = cache.get("key")
    assert result == "value"
```

### Integration Tests (`-m integration`)

**Purpose:** Test interaction between components
**Dependencies:** Some real, some mocked
**Docker Required:** Optional (depends on test)
**Execution Time:** Moderate (1-5 minutes)

**Example:**
```python
import pytest
from src.services.rag.pipeline import RAGPipeline

@pytest.mark.integration
async def test_rag_pipeline_end_to_end(
    mock_embedding_service,
    mock_opensearch_client,
    mock_ollama_client
):
    pipeline = RAGPipeline(
        embedding_service=mock_embedding_service,
        search_client=mock_opensearch_client,
        llm_client=mock_ollama_client
    )

    result = await pipeline.query("What is RAG?")

    assert result is not None
    assert "retrieval" in result.lower()
```

### End-to-End Tests (`-m e2e`)

**Purpose:** Test complete workflows
**Dependencies:** Real services
**Docker Required:** Yes
**Execution Time:** Slow (5-15 minutes)

**Example:**
```python
import pytest
from fastapi.testclient import TestClient
from src.api.main import app

@pytest.mark.e2e
@pytest.mark.docker
def test_full_rag_workflow(client: TestClient):
    # Upload document
    response = client.post("/documents", json={
        "title": "Test Doc",
        "content": "RAG combines retrieval and generation."
    })
    assert response.status_code == 201
    doc_id = response.json()["id"]

    # Query document
    response = client.post("/query", json={
        "question": "What is RAG?"
    })
    assert response.status_code == 200
    assert "retrieval" in response.json()["answer"].lower()
```

---

## RAG Archetype Tests

### Unit Tests (138+ tests)

**Test Files:**
- `test_cache.py` (9 tests) - Redis cache client
- `test_database.py` (9 tests) - SQLAlchemy database layer
- `test_opensearch.py` (9 tests) - OpenSearch client
- `test_ollama.py` (7 tests) - Ollama LLM client
- `test_embeddings.py` (7 tests) - Embedding service
- `test_chunking.py` (10 tests) - Text chunking service

**Run Unit Tests:**
```bash
cd archetypes/rag-project

# All unit tests
pytest -m unit

# Specific test file
pytest tests/unit/test_cache.py -v

# With coverage
pytest -m unit --cov=src --cov-report=html
```

### Integration Tests (15+ tests)

**Test Files:**
- `test_rag_pipeline.py` (15+ tests) - End-to-end RAG pipeline
- `test_api_endpoints.py` (10+ tests) - FastAPI endpoints
- `test_docker_services.py` (8+ tests) - Docker service connectivity

**Run Integration Tests:**
```bash
cd archetypes/rag-project

# Start Docker services first
docker-compose up -d
sleep 30  # Wait for services to be healthy

# Run integration tests
pytest -m integration -v

# Or use docker exec to run inside container
docker compose exec -T api pytest tests/integration/ -v
```

### E2E Tests

**Test Files:**
- `test_workflows.py` - Complete user workflows

**Run E2E Tests:**
```bash
cd archetypes/rag-project

# Ensure Docker services are running
docker-compose up -d

# Run E2E tests inside Docker
docker compose exec -T api pytest tests/e2e/ -v
```

---

## API Archetype Tests

### Unit Tests

**Test Files:**
- `test_auth.py` - JWT authentication, password hashing
- `test_database.py` - Database configuration and models
- `test_middleware.py` - Logging, rate limiting middleware
- `test_config.py` - Configuration management

**Run Unit Tests:**
```bash
cd archetypes/api-service

# All unit tests
pytest -m unit -v

# Specific component
pytest tests/unit/test_auth.py -v
```

### Integration Tests

**Test Files:**
- `test_api_endpoints.py` - API endpoint testing
- `test_docker_services.py` - Docker service connectivity

**Run Integration Tests:**
```bash
cd archetypes/api-service

# Start Docker services
docker-compose up -d

# Run integration tests
docker compose exec -T api pytest -m integration -v
```

---

## Running Tests

### Using PowerShell Script (Recommended)

```powershell
# Run all tests for all archetypes
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

# Verbose output
pytest -v

# Show print statements
pytest -s
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

### Running Tests Inside Docker

**Why run inside Docker:**
- ✅ Consistent test environment
- ✅ All dependencies available
- ✅ Proper service connectivity
- ✅ Correct Python path resolution

**Commands:**
```bash
cd archetypes/rag-project

# Start services
docker-compose up -d

# Run tests inside API container
docker compose exec -T api pytest tests/unit/ -v
docker compose exec -T api pytest tests/integration/ -v
docker compose exec -T api pytest tests/e2e/ -v

# With coverage
docker compose exec -T api pytest --cov=src --cov-report=term --cov-report=html
```

---

## Test Fixtures

### RAG Archetype Fixtures

Located in `archetypes/rag-project/conftest.py`:

```python
@pytest.fixture
def test_settings():
    """Test configuration settings"""
    return Settings(
        DATABASE_URL="sqlite:///test.db",
        REDIS_HOST="localhost",
        ENVIRONMENT="test"
    )

@pytest.fixture
def test_db_session():
    """Test database session"""
    engine = create_engine("sqlite:///test.db")
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()

@pytest.fixture
def mock_redis():
    """Mock Redis client"""
    return Mock(spec=Redis)

@pytest.fixture
def mock_opensearch_client():
    """Mock OpenSearch client"""
    return Mock(spec=OpenSearch)

@pytest.fixture
def sample_documents():
    """Sample documents for testing"""
    return [
        {"id": "1", "content": "Test document 1"},
        {"id": "2", "content": "Test document 2"}
    ]

@pytest.fixture
def client():
    """FastAPI test client"""
    return TestClient(app)
```

### API Archetype Fixtures

Located in `archetypes/api-service/conftest.py`:

```python
@pytest.fixture
def test_settings():
    """Test configuration"""
    return Settings(environment="test")

@pytest.fixture
def client():
    """FastAPI test client"""
    return TestClient(app)

@pytest.fixture
def auth_headers(client):
    """Authentication headers"""
    response = client.post("/auth/login", json={
        "username": "test",
        "password": "test123"
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}
```

---

## Docker Testing

### Prerequisites

```bash
# Install Docker and Docker Compose
docker --version
docker-compose --version

# Start Docker services
cd archetypes/rag-project
docker-compose up -d

# Check service health
docker-compose ps
docker-compose logs api
```

### Running Docker Tests

```bash
# Wait for services to be healthy
sleep 30

# Check service connectivity
docker compose exec -T api pytest tests/integration/test_docker_services.py -v

# Expected tests:
# - test_postgres_connection
# - test_redis_connection
# - test_opensearch_connection
# - test_ollama_connection
```

### Docker Test Markers

```python
@pytest.mark.docker
def test_requires_docker_services():
    """Test that requires Docker services running"""
    pass

# Skip Docker tests
pytest -m "not docker"

# Run only Docker tests
pytest -m docker
```

---

## Coverage Reporting

### Generate Coverage Reports

**RAG Archetype:**
```bash
cd archetypes/rag-project

# Generate HTML and terminal coverage
pytest --cov=src --cov-report=html --cov-report=term-missing

# View HTML report
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

**Inside Docker:**
```bash
docker compose exec -T api pytest --cov=src --cov-report=term --cov-report=html

# Coverage report saved in container, copy to host
docker compose cp api:/app/htmlcov ./htmlcov
```

### Coverage Targets

| Component | Target | Current |
|-----------|--------|---------|
| Overall | 80% | ~75% |
| Services | 85% | ~80% |
| API Endpoints | 90% | ~85% |
| Models | 95% | ~90% |

---

## Test Markers

Tests use pytest markers for organization:

```python
@pytest.mark.unit          # Unit tests
@pytest.mark.integration   # Integration tests
@pytest.mark.e2e           # End-to-end tests
@pytest.mark.docker        # Requires Docker
@pytest.mark.slow          # Slow-running tests
@pytest.mark.asyncio       # Async tests
```

**Usage:**
```bash
# Run only unit tests
pytest -m unit

# Run integration but not docker
pytest -m "integration and not docker"

# Run fast tests only
pytest -m "not slow"

# Run async tests
pytest -m asyncio
```

---

## Best Practices

### 1. Write Isolated Unit Tests

```python
# Good: Uses mocks, no external dependencies
@pytest.mark.unit
def test_cache_set(mock_redis):
    cache = RedisCache(client=mock_redis)
    cache.set("key", "value")
    mock_redis.set.assert_called_once()

# Bad: Requires real Redis
def test_cache_set():
    cache = RedisCache(host="localhost")
    cache.set("key", "value")  # Requires Redis running
```

### 2. Use Fixtures for Setup

```python
# Good: Reusable fixture
@pytest.fixture
def sample_user():
    return {"id": 1, "name": "Test User"}

def test_user_creation(sample_user):
    assert sample_user["name"] == "Test User"

# Bad: Setup in each test
def test_user_creation():
    user = {"id": 1, "name": "Test User"}
    assert user["name"] == "Test User"
```

### 3. Clean Up Test Data

```python
@pytest.fixture
def test_db_session():
    session = Session()
    yield session
    session.rollback()  # Clean up
    session.close()
```

### 4. Use Descriptive Test Names

```python
# Good: Clear what's being tested
def test_rag_pipeline_returns_relevant_results():
    pass

# Bad: Unclear
def test_rag():
    pass
```

### 5. Test Edge Cases

```python
def test_embedding_service_handles_empty_text():
    result = embedding_service.embed("")
    assert result == []

def test_embedding_service_handles_very_long_text():
    long_text = "a" * 10000
    result = embedding_service.embed(long_text)
    assert len(result) > 0
```

---

## Troubleshooting

### Tests Failing Due to Missing Dependencies

**Symptom:** `ModuleNotFoundError`

**Solution:**
```bash
# Install dependencies
cd archetypes/rag-project
pip install -r requirements.txt

# Or run inside Docker
docker compose exec -T api pytest
```

### Docker Tests Failing

**Symptom:** Connection errors to services

**Solution:**
```bash
# Check Docker is running
docker ps

# Start services
docker-compose up -d

# Wait for health checks
sleep 30
docker-compose ps

# Check logs
docker-compose logs api
```

### Import Errors

**Symptom:** `ModuleNotFoundError: No module named 'src'`

**Solution:**
```bash
# Set PYTHONPATH
export PYTHONPATH=/app

# Or use docker-compose environment
environment:
  - PYTHONPATH=/app
```

### Async Test Warnings

**Symptom:** `RuntimeWarning: coroutine was never awaited`

**Solution:**
```bash
# Install pytest-asyncio
pip install pytest-asyncio

# Mark async tests
@pytest.mark.asyncio
async def test_async_function():
    result = await async_function()
    assert result is not None
```

### Coverage Not Generated

**Symptom:** No htmlcov/ directory created

**Solution:**
```bash
# Install coverage packages
pip install pytest-cov

# Run with coverage flags
pytest --cov=src --cov-report=html
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Archetype Tests

on: [push, pull_request]

jobs:
  test-rag-archetype:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          cd archetypes/rag-project
          pip install -r requirements.txt

      - name: Run unit tests
        run: |
          cd archetypes/rag-project
          pytest -m unit --cov=src --cov-report=xml

      - name: Start Docker services
        run: |
          cd archetypes/rag-project
          docker-compose up -d
          sleep 30

      - name: Run integration tests
        run: |
          cd archetypes/rag-project
          docker compose exec -T api pytest -m integration

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## Reference

### Test Script Locations

```
archetypes/
├── rag-project/tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── api-service/tests/
    ├── unit/
    └── integration/
```

### Documentation

- Main README: `tests/README.md`
- This guide: `tests/guides/ARCHETYPE_IMPLEMENTATION_TESTING.md`
- Template system: `tests/guides/TEMPLATE_SYSTEM_TESTING.md`
- RAG archetype: `tests/rag-archetype/README.md`

---

**Last Updated:** December 5, 2025
**Status:** ✅ Complete and validated
**Maintainer:** Dev Environment Template Team
