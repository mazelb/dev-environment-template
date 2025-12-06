# Test Suite Documentation

Comprehensive testing documentation for the dev-environment-template project.

**Last Updated:** December 5, 2025

---

## 🚀 Quick Start

**New to testing?** Start here: **[Quick Start Guide](./QUICK_START.md)**

**Need something specific?**
- **RAG Archetype Testing** → [rag-archetype/README.md](./rag-archetype/README.md)
- **Template System Testing** → [guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)
- **Archetype Implementation Testing** → [guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)

---

## 📚 Documentation Structure

```
tests/
├── README.md                          # This file - main entry point
├── QUICK_START.md                     # Quick start guide for all testing
│
├── guides/                            # Detailed testing guides
│   ├── TEMPLATE_SYSTEM_TESTING.md     # Template & archetype system tests
│   └── ARCHETYPE_IMPLEMENTATION_TESTING.md  # pytest-based code tests
│
├── rag-archetype/                     # RAG archetype specific docs
│   ├── README.md                      # RAG testing overview
│   ├── QUICK_REFERENCE.md             # Quick commands
│   ├── FULL_STACK_TESTING.md          # Full stack procedures
│   └── FIXES_HISTORY.md               # Infrastructure fixes history
│
└── archive/                           # Archived documentation
    └── [old documentation files]
```

---

## 🎯 Test Suite Overview

The dev-environment-template has **two distinct test suites**:

### 1. Template System Tests (PowerShell/Bash)

**Purpose:** Validate the project creation system

**What it tests:**
- Archetype structure and metadata
- File merging (docker-compose.yml, .gitignore, etc.)
- Git integration
- Multi-archetype composition
- Project creation workflow

**Test Scripts:**
```
Test-ArchetypeStructure.ps1
Test-ArchetypeValidation.ps1
Test-FileMerging.ps1
Test-GitIntegration.ps1
Test-MultiArchetype.ps1
Test-MultiProjectWorkflow.ps1
Test-CreateProject.ps1
```

**Documentation:** [guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)

---

### 2. Archetype Implementation Tests (pytest)

**Purpose:** Validate the actual code within each archetype

**What it tests:**
- Unit tests (isolated components)
- Integration tests (component interaction)
- End-to-end tests (complete workflows)
- Docker service connectivity
- API endpoints
- Code coverage

**Test Structure:**
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

**Documentation:** [guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)

---

## 🔧 Quick Commands

### Template System Tests

```powershell
# Validate all archetypes
pwsh tests/Test-ArchetypeValidation.ps1

# Test multi-archetype composition
pwsh tests/Test-MultiArchetype.ps1

# Test file merging
pwsh tests/Test-FileMerging.ps1
```

### RAG Archetype Tests

```powershell
# Full stack test (infrastructure + application)
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose

# Core infrastructure test only
pwsh tests/Test-RagArchetypeCore.ps1 -Verbose

# E2E validation
pwsh run-tests.ps1 -Archetype rag -TestType all -SkipDocker
```

### Archetype Implementation Tests

```bash
# RAG archetype unit tests
cd archetypes/rag-project
pytest -m unit

# RAG archetype integration tests (requires Docker)
docker-compose up -d
docker compose exec -T api pytest -m integration

# API archetype unit tests
cd archetypes/api-service
pytest -m unit
```

---

## 📊 Test Results Summary

### Template System Tests

| Test Suite | Status | Pass Rate |
|------------|--------|-----------|
| Archetype Validation | ✅ **PASS** | **100%** (48/48) |
| Archetype Structure | ✅ **PASS** | **100%** |
| File Merging | ✅ **PASS** | **100%** |
| Git Integration | ✅ **PASS** | **100%** |
| Multi-Archetype | ✅ **PASS** | **100%** |

### RAG Archetype Tests (December 5, 2025)

| Category | Status | Pass Rate |
|----------|--------|-----------|
| **Infrastructure** | ✅ **HEALTHY** | **100%** (9/9) |
| **Application** | ⚠️ **PARTIAL** | **60%** (3/5) |
| **Overall** | ✅ **GOOD** | **76.92%** (10/13) |

**Details:** [rag-archetype/README.md](./rag-archetype/README.md)

---

## 📖 Detailed Guides

### For Template System Testing

**[Template System Testing Guide](./guides/TEMPLATE_SYSTEM_TESTING.md)**

Complete guide covering:
- Archetype structure validation
- Archetype metadata testing
- File merging logic
- Git integration
- Multi-archetype composition
- Multi-project workflows
- Troubleshooting

**Use this guide if you:**
- Want to add a new archetype
- Need to test archetype composition
- Are debugging file merging issues
- Want to understand the project creation system

---

### For Archetype Implementation Testing

**[Archetype Implementation Testing Guide](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)**

Complete guide covering:
- Unit testing with pytest
- Integration testing
- End-to-end testing
- Docker testing
- Test fixtures
- Coverage reporting
- Best practices

**Use this guide if you:**
- Are writing tests for archetype code
- Need to test API endpoints
- Want to run tests in Docker
- Are generating coverage reports

---

### For RAG Archetype Testing

**[RAG Archetype Testing](./rag-archetype/README.md)**

RAG-specific documentation:
- **[README.md](./rag-archetype/README.md)** - Overview and test results
- **[QUICK_REFERENCE.md](./rag-archetype/QUICK_REFERENCE.md)** - Quick commands
- **[FULL_STACK_TESTING.md](./rag-archetype/FULL_STACK_TESTING.md)** - Detailed procedures
- **[FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md)** - Infrastructure fixes

**Use this if you:**
- Are testing the RAG archetype
- Need to debug RAG infrastructure issues
- Want to understand RAG test fixes
- Are running full-stack RAG tests

---

## 🏃 Running Tests

### Using PowerShell (Recommended)

```powershell
# Run all template system tests
pwsh tests/Test-ArchetypeValidation.ps1

# Run RAG archetype full stack test
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose

# Run archetype implementation tests
.\run-tests.ps1 -Archetype rag -TestType all
```

### Using pytest Directly

```bash
# RAG archetype tests
cd archetypes/rag-project
pytest -m unit                    # Unit tests
pytest -m integration             # Integration tests
pytest --cov=src --cov-report=html  # With coverage

# API archetype tests
cd archetypes/api-service
pytest -m unit
pytest -m integration
```

### Using Docker

```bash
# Start services
cd archetypes/rag-project
docker-compose up -d

# Run tests inside Docker
docker compose exec -T api pytest tests/unit/ -v
docker compose exec -T api pytest tests/integration/ -v
docker compose exec -T api pytest tests/e2e/ -v
```

---

## 🎯 Test Categories Explained

### Unit Tests

**What:** Test individual components in isolation
**Dependencies:** Mocked
**Docker Required:** No
**Speed:** Fast (<1 minute)

**Example:**
```python
@pytest.mark.unit
def test_cache_set_get(mock_redis):
    cache = RedisCache(client=mock_redis)
    cache.set("key", "value")
    assert cache.get("key") == "value"
```

### Integration Tests

**What:** Test interaction between components
**Dependencies:** Some real, some mocked
**Docker Required:** Optional
**Speed:** Moderate (1-5 minutes)

**Example:**
```python
@pytest.mark.integration
async def test_rag_pipeline(embedding_service, search_client, llm_client):
    pipeline = RAGPipeline(embedding_service, search_client, llm_client)
    result = await pipeline.query("What is RAG?")
    assert "retrieval" in result.lower()
```

### End-to-End Tests

**What:** Test complete workflows
**Dependencies:** Real services
**Docker Required:** Yes
**Speed:** Slow (5-15 minutes)

**Example:**
```python
@pytest.mark.e2e
@pytest.mark.docker
def test_full_rag_workflow(client):
    # Upload document
    response = client.post("/documents", json={...})
    assert response.status_code == 201

    # Query document
    response = client.post("/query", json={...})
    assert response.status_code == 200
```

---

## 🛠️ Prerequisites

### For Template System Tests

- PowerShell 7+
- Git
- Docker and Docker Compose (optional, for some tests)

### For Archetype Implementation Tests

- Python 3.11+
- pip
- Docker and Docker Compose
- pytest and dependencies

**Install dependencies:**
```bash
cd archetypes/rag-project
pip install -r requirements.txt
```

---

## 📈 Coverage Reporting

### Generate Coverage Reports

```bash
cd archetypes/rag-project

# Generate HTML and terminal coverage
pytest --cov=src --cov-report=html --cov-report=term-missing

# View HTML report
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

### Inside Docker

```bash
docker compose exec -T api pytest --cov=src --cov-report=term --cov-report=html

# Copy coverage report from container
docker compose cp api:/app/htmlcov ./htmlcov
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** Tests can't find modules

**Solution:**
```bash
# Set PYTHONPATH
export PYTHONPATH=/app

# Or add to docker-compose.yml
environment:
  - PYTHONPATH=/app
```

**Issue:** Docker tests failing

**Solution:**
```bash
# Check Docker is running
docker ps

# Start services
docker-compose up -d

# Wait for health checks
sleep 30

# Check logs
docker-compose logs api
```

**Issue:** pytest not found

**Solution:**
```bash
# Install dependencies
pip install -r requirements.txt

# Or run inside Docker
docker compose exec -T api pytest
```

For more troubleshooting:
- Template System: [guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md#troubleshooting)
- Archetype Implementation: [guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md#troubleshooting)
- RAG Archetype: [rag-archetype/FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md)

---

## 📝 Test Markers

Tests use pytest markers for selective execution:

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
pytest -m unit              # Run only unit tests
pytest -m "not docker"      # Skip Docker tests
pytest -m "integration and not slow"  # Fast integration tests
```

---

## 🔄 CI/CD Integration

Tests can be integrated into GitHub Actions workflows:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test-template-system:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Archetype Validation
        run: pwsh tests/Test-ArchetypeValidation.ps1

  test-rag-archetype:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Run Unit Tests
        run: |
          cd archetypes/rag-project
          pip install -r requirements.txt
          pytest -m unit --cov=src
```

---

## 🎓 Best Practices

1. **Run unit tests frequently** during development
2. **Run integration tests** before committing
3. **Run full test suite** before merging
4. **Generate coverage reports** to identify gaps
5. **Use markers** to run relevant test subsets
6. **Mock external services** in unit tests
7. **Clean up test data** after each test
8. **Document test failures** in GitHub issues

---

## 📚 Additional Resources

### Documentation Files

- **[QUICK_START.md](./QUICK_START.md)** - Quick start guide for all testing
- **[guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)** - Template system testing
- **[guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)** - Archetype code testing
- **[rag-archetype/README.md](./rag-archetype/README.md)** - RAG archetype testing

### Test Scripts

Located in `tests/` directory:
```
Test-RagArchetypeFull.ps1          # RAG full stack test
Test-RagArchetypeCore.ps1          # RAG core infrastructure
Test-ArchetypeValidation.ps1       # Archetype validation
Test-ArchetypeStructure.ps1        # Archetype structure
Test-FileMerging.ps1               # File merging
Test-GitIntegration.ps1            # Git integration
Test-MultiArchetype.ps1            # Multi-archetype composition
Test-MultiProjectWorkflow.ps1      # Multi-project workflow
Test-CreateProject.ps1             # Project creation
```

### Support

For issues or questions:
- Check the specific guide for your test type
- Review [rag-archetype/FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md) for known issues
- Consult [QUICK_START.md](./QUICK_START.md) for common commands

---

**Last Updated:** December 5, 2025
**Status:** ✅ Complete and validated
**Maintainer:** Dev Environment Template Team
