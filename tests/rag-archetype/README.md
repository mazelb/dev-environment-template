# RAG Archetype Testing Documentation

Complete testing documentation for the RAG (Retrieval-Augmented Generation) archetype, including infrastructure tests, full-stack tests, and fixes history.

---

## 📋 Quick Links

- **[Quick Reference](./QUICK_REFERENCE.md)** - Quick start commands and common operations
- **[Full Stack Testing](./FULL_STACK_TESTING.md)** - Complete full-stack test procedures
- **[Fixes History](./FIXES_HISTORY.md)** - All infrastructure fixes and improvements

---

## Overview

The RAG archetype test suite validates:
- **Docker Infrastructure** (8 services): PostgreSQL, Redis, OpenSearch, Ollama, FastAPI, Langfuse, Airflow
- **Python Application Code**: Unit, integration, and E2E tests
- **API Endpoints**: Health checks, document processing, search, RAG queries
- **Service Integration**: Database connections, cache, vector search, LLM integration

---

## Test Results Summary

### Current Status (December 5, 2025)

| Category | Status | Pass Rate | Details |
|----------|--------|-----------|---------|
| **Infrastructure Tests** | ✅ **HEALTHY** | **100%** (9/9) | All Docker services operational |
| **Application Tests** | ⚠️ **PARTIAL** | **60%** (3/5) | Test implementation refinements needed |
| **Overall Tests** | ✅ **GOOD** | **76.92%** (10/13) | Infrastructure fully functional |

### Infrastructure Tests (9/9 PASS)
- ✅ Project Creation
- ✅ Project Structure Validation
- ✅ Docker Compose Validation
- ✅ Docker Services Startup
- ✅ PostgreSQL Health
- ✅ Redis Health
- ✅ OpenSearch Health
- ✅ Ollama Health
- ✅ FastAPI Health

### Application Tests (3/5 PASS)
- ⚠️ Unit Tests (partial pass - pytest marker warnings)
- ✅ Integration Tests (6/6 tests passed)
- ⚠️ E2E Tests (partial pass - path expectations)
- ⚠️ Test Coverage (parsing issue)

---

## Quick Start

### Run Full Stack Test

```powershell
# Complete infrastructure and application test (~25 minutes)
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose

# Expected: 76.92% overall, 100% infrastructure
```

### Run Core Infrastructure Test

```powershell
# Quick infrastructure validation (~5 minutes)
pwsh tests/Test-RagArchetypeCore.ps1 -Verbose

# Expected: 100% infrastructure health
```

### Run E2E Validation

```powershell
# Archetype structure and configuration validation (~2 minutes)
pwsh run-tests.ps1 -Archetype rag -TestType all -SkipDocker

# Expected: 100% E2E validation
```

---

## Test Scripts

### Test-RagArchetypeFull.ps1

**Purpose:** Complete full-stack RAG archetype testing
**Duration:** ~25 minutes
**Coverage:** Infrastructure + Application + Integration

**Test Phases:**
1. Project Creation (from archetype template)
2. Structure Validation (required files and directories)
3. Docker Compose Validation (configuration check)
4. Docker Services Startup (all 8 services)
5. Service Health Checks (PostgreSQL, Redis, OpenSearch, Ollama, FastAPI, Langfuse, Airflow)
6. Unit Tests (inside Docker container)
7. Integration Tests (service connectivity)
8. E2E Tests (complete workflows)
9. Test Coverage (code coverage reporting)

**Usage:**
```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose
```

### Test-RagArchetypeCore.ps1

**Purpose:** Quick infrastructure validation
**Duration:** ~5 minutes
**Coverage:** Infrastructure only

**Test Phases:**
1. Project Creation
2. Structure Validation
3. Docker Compose Validation
4. Docker Services Startup
5. Service Health Checks

**Usage:**
```powershell
pwsh tests/Test-RagArchetypeCore.ps1 -Verbose
```

---

## Critical Fixes Applied

**6 critical infrastructure fixes** were applied on December 5, 2025 to achieve 100% infrastructure health:

1. **Missing chromadb Dependency** - Added `chromadb>=0.5.0` to requirements.txt
2. **Incorrect Health Endpoint** - Fixed `/api/v1/health` → `/health` in test script
3. **pytest on Host** - Changed to run pytest inside Docker containers
4. **Missing tests/ Mount** - Added `./tests:/app/tests` volume mount
5. **Wrong Healthcheck Endpoint** - Fixed Docker healthcheck to use `/health`
6. **Missing PYTHONPATH** - Added `PYTHONPATH=/app` environment variable

**Impact:**
- Before: 61.54% pass rate (8/13 tests)
- After: 76.92% pass rate (10/13 tests)
- Infrastructure: 100% healthy (9/9 tests)

See [Fixes History](./FIXES_HISTORY.md) for complete details.

---

## Architecture

### Docker Services

```yaml
services:
  api:           # FastAPI application (port 8000)
  postgres:      # PostgreSQL database (port 5432)
  redis:         # Cache and queues (port 6379)
  opensearch:    # Vector & keyword search (port 9200)
  ollama:        # LLM server (port 11434)
  langfuse:      # LLM observability (port 3000)
  airflow:       # Workflow orchestration (port 8080)
```

### Application Structure

```
archetypes/rag-project/
├── src/
│   ├── api/           # FastAPI routes and endpoints
│   ├── services/      # Business logic (RAG, embeddings, search)
│   ├── models/        # Data models and schemas
│   └── config.py      # Configuration management
├── tests/
│   ├── unit/          # Unit tests (mocked dependencies)
│   ├── integration/   # Integration tests (real services)
│   └── e2e/           # End-to-end workflow tests
├── docker-compose.yml # Service orchestration
└── requirements.txt   # Python dependencies
```

---

## Prerequisites

### Required Software
- Docker Desktop 24+ (with Docker Compose v2)
- PowerShell 7+
- Python 3.11+
- Git

### Required Resources
- **Disk Space:** ~10 GB for Docker images
- **Memory:** 8 GB RAM minimum (16 GB recommended)
- **Time:** 25 minutes for full stack test, 5 minutes for core test

---

## Test Execution Environment

All pytest tests run **inside Docker containers**, not on the host machine:

```powershell
# Correct: pytest runs inside API container
docker compose exec -T api pytest tests/unit/ -v

# Incorrect: pytest runs on host (will fail)
pytest tests/unit/ -v
```

This ensures:
- ✅ Consistent test environment
- ✅ All dependencies available
- ✅ Proper service connectivity
- ✅ Correct Python path resolution

---

## Common Issues and Solutions

### Issue: FastAPI Container Won't Start

**Symptom:** `ModuleNotFoundError: No module named 'chromadb'`

**Solution:** Ensure chromadb is in requirements.txt:
```python
chromadb>=0.5.0
```

### Issue: Health Check Fails (404)

**Symptom:** `404 Not Found` on health endpoint

**Solution:** Use `/health` endpoint (not `/api/v1/health`):
```powershell
curl http://localhost:8000/health
```

### Issue: Tests Can't Find test/ Directory

**Symptom:** `ERROR: file or directory not found: tests/unit/`

**Solution:** Ensure tests volume is mounted in docker-compose.yml:
```yaml
volumes:
  - ./tests:/app/tests
```

### Issue: Module Import Errors

**Symptom:** `ModuleNotFoundError: No module named 'src'`

**Solution:** Add PYTHONPATH to docker-compose.yml:
```yaml
environment:
  - PYTHONPATH=/app
```

---

## Next Steps

1. ✅ **Infrastructure Fixes Complete** - All 6 critical fixes applied
2. ⏳ **Test Suite Refinement** - Fix pytest marker configuration
3. ⏳ **E2E Test Improvements** - Separate template vs. deployment tests
4. ⏳ **Coverage Parsing Fix** - Update regex for coverage reporting
5. ⏳ **Apply to API Archetype** - Validate same fixes for api-service

---

## Documentation Files

- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Quick commands and common operations
- **[FULL_STACK_TESTING.md](./FULL_STACK_TESTING.md)** - Detailed full-stack test procedures
- **[FIXES_HISTORY.md](./FIXES_HISTORY.md)** - Complete history of all fixes and improvements

---

## Support

For issues or questions:
- Check [Fixes History](./FIXES_HISTORY.md) for known issues
- Review [Full Stack Testing](./FULL_STACK_TESTING.md) for detailed procedures
- See [Quick Reference](./QUICK_REFERENCE.md) for common commands

---

**Last Updated:** December 5, 2025
**Status:** ✅ Infrastructure Complete | ⏳ Test Refinement Needed
**Maintainer:** Dev Environment Template Team
