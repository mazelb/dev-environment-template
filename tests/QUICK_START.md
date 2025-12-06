# Testing Quick Start Guide

Get started with testing the dev-environment-template in under 5 minutes.

**Last Updated:** December 5, 2025

---

## 🎯 What Do You Want to Test?

Choose your testing scenario:

### 1. I want to validate archetypes are configured correctly
→ [Test Archetype Validation](#1-test-archetype-validation)

### 2. I want to test the RAG archetype
→ [Test RAG Archetype](#2-test-rag-archetype)

### 3. I want to run unit tests for archetype code
→ [Run Unit Tests](#3-run-unit-tests)

### 4. I want to run integration tests with Docker
→ [Run Integration Tests](#4-run-integration-tests)

### 5. I want to test multi-archetype composition
→ [Test Multi-Archetype](#5-test-multi-archetype-composition)

---

## 1. Test Archetype Validation

**What it does:** Validates all 7 archetypes have correct structure and configuration

**Time:** ~1 minute

**Prerequisites:** PowerShell 7+

**Command:**
```powershell
pwsh tests/Test-ArchetypeValidation.ps1
```

**Expected Output:**
```
✅ PASS: 48/48 tests (100%)

Validated archetypes:
- rag-project
- agentic-workflows
- api-service
- frontend
- monitoring
- base
- composite-rag-agents
```

**What's next?**
- Learn more: [guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)

---

## 2. Test RAG Archetype

### Option A: Quick Infrastructure Test (5 minutes)

**What it does:** Tests Docker services startup and health

**Command:**
```powershell
pwsh tests/Test-RagArchetypeCore.ps1 -Verbose
```

**Expected Output:**
```
✅ Project Creation
✅ Project Structure
✅ Docker Compose Validation
✅ Docker Services Startup
✅ PostgreSQL Health
✅ Redis Health
✅ OpenSearch Health
✅ Ollama Health
✅ FastAPI Health

PASS: 9/9 tests (100%)
```

---

### Option B: Full Stack Test (25 minutes)

**What it does:** Tests infrastructure + application code + integration

**Command:**
```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose
```

**Expected Output:**
```
✅ Infrastructure Tests: 9/9 (100%)
⚠️ Application Tests: 3/5 (60%)
✅ Overall: 10/13 (76.92%)

All Docker services healthy ✅
```

---

### Option C: E2E Validation (2 minutes)

**What it does:** Validates archetype structure and config (no Docker)

**Command:**
```powershell
pwsh run-tests.ps1 -Archetype rag -TestType all -SkipDocker
```

**Expected Output:**
```
✅ E2E Tests: 12/12 (100%)
```

**What's next?**
- Learn more: [rag-archetype/README.md](./rag-archetype/README.md)
- Quick reference: [rag-archetype/QUICK_REFERENCE.md](./rag-archetype/QUICK_REFERENCE.md)

---

## 3. Run Unit Tests

**What it does:** Tests individual components in isolation (no Docker needed)

**Time:** <1 minute

**Prerequisites:** Python 3.11+, pip

### RAG Archetype

```bash
# Install dependencies
cd archetypes/rag-project
pip install -r requirements.txt

# Run unit tests
pytest -m unit -v

# With coverage
pytest -m unit --cov=src --cov-report=html
```

**Expected Output:**
```
tests/unit/test_cache.py ........... PASSED
tests/unit/test_database.py ........ PASSED
tests/unit/test_opensearch.py ...... PASSED
tests/unit/test_ollama.py ......... PASSED
tests/unit/test_embeddings.py ..... PASSED
tests/unit/test_chunking.py ........ PASSED

========== 60 passed in 2.5s ==========
```

### API Archetype

```bash
cd archetypes/api-service
pip install -r requirements.txt
pytest -m unit -v
```

**What's next?**
- Learn more: [guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)

---

## 4. Run Integration Tests

**What it does:** Tests component interaction with real services

**Time:** 5-10 minutes

**Prerequisites:** Docker Desktop, Python 3.11+

### Step 1: Start Docker Services

```bash
cd archetypes/rag-project
docker-compose up -d
sleep 30  # Wait for services to be healthy
```

### Step 2: Verify Services

```bash
docker-compose ps
```

**Expected:**
```
NAME                STATUS          PORTS
rag-api            Up (healthy)    0.0.0.0:8000->8000/tcp
rag-postgres       Up (healthy)    0.0.0.0:5432->5432/tcp
rag-redis          Up (healthy)    0.0.0.0:6379->6379/tcp
rag-opensearch     Up (healthy)    0.0.0.0:9200->9200/tcp
rag-ollama         Up              0.0.0.0:11434->11434/tcp
```

### Step 3: Run Integration Tests

```bash
# Run inside Docker container (recommended)
docker compose exec -T api pytest -m integration -v

# Or run on host (requires service connectivity)
pytest -m integration -v
```

**Expected Output:**
```
tests/integration/test_rag_pipeline.py ........ PASSED
tests/integration/test_api_endpoints.py ....... PASSED
tests/integration/test_docker_services.py ..... PASSED

========== 25 passed in 45.2s ==========
```

### Step 4: Stop Services (when done)

```bash
docker-compose down
```

**What's next?**
- Learn more: [guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)
- Docker troubleshooting: [rag-archetype/FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md)

---

## 5. Test Multi-Archetype Composition

**What it does:** Tests combining multiple archetypes into one project

**Time:** 2-3 minutes

**Prerequisites:** PowerShell 7+

**Command:**
```powershell
pwsh tests/Test-MultiArchetype.ps1
```

**What it tests:**
- RAG + Agentic Workflows composition
- API + Monitoring + Frontend composition
- File merging (docker-compose.yml, .gitignore, etc.)
- Service integration
- Dependency resolution

**Expected Output:**
```
✅ Two-archetype composition (rag-project + agentic-workflows)
✅ Three-archetype composition (api + monitoring + frontend)
✅ File merging successful
✅ No service conflicts

PASS: All multi-archetype tests
```

**What's next?**
- Learn more: [guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)

---

## 🚨 Common Issues & Quick Fixes

### Issue: "pytest: command not found"

**Quick Fix:**
```bash
# Install dependencies
pip install -r requirements.txt

# Or run inside Docker
docker compose exec -T api pytest
```

---

### Issue: "ModuleNotFoundError: No module named 'src'"

**Quick Fix:**
```bash
# Set PYTHONPATH
export PYTHONPATH=/app

# Or add to docker-compose.yml
environment:
  - PYTHONPATH=/app
```

---

### Issue: Docker services won't start

**Quick Fix:**
```bash
# Check Docker is running
docker ps

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

### Issue: Health checks failing (404)

**Quick Fix:**
Ensure you're using the correct health endpoint: `/health` (not `/api/v1/health`)

```bash
# Test health endpoint
curl http://localhost:8000/health
```

---

### Issue: "Permission denied" on scripts

**Quick Fix:**
```bash
# Make scripts executable
chmod +x tests/*.ps1
chmod +x create-project.sh
```

---

## 📚 Next Steps

### If tests passed ✅
1. Read the detailed guides for your use case
2. Contribute your own tests
3. Set up CI/CD integration

### If tests failed ❌
1. Check the specific error message
2. Review troubleshooting sections in detailed guides:
   - [Template System Troubleshooting](./guides/TEMPLATE_SYSTEM_TESTING.md#troubleshooting)
   - [Archetype Implementation Troubleshooting](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md#troubleshooting)
   - [RAG Fixes History](./rag-archetype/FIXES_HISTORY.md)
3. Check GitHub issues or create a new one

---

## 📖 Full Documentation

**Main Documentation:**
- **[README.md](./README.md)** - Complete testing documentation overview

**Detailed Guides:**
- **[guides/TEMPLATE_SYSTEM_TESTING.md](./guides/TEMPLATE_SYSTEM_TESTING.md)** - Template & archetype system testing
- **[guides/ARCHETYPE_IMPLEMENTATION_TESTING.md](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md)** - pytest-based code testing

**RAG Archetype:**
- **[rag-archetype/README.md](./rag-archetype/README.md)** - RAG testing overview
- **[rag-archetype/QUICK_REFERENCE.md](./rag-archetype/QUICK_REFERENCE.md)** - RAG quick commands
- **[rag-archetype/FULL_STACK_TESTING.md](./rag-archetype/FULL_STACK_TESTING.md)** - RAG full stack procedures
- **[rag-archetype/FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md)** - Infrastructure fixes history

---

## 💡 Pro Tips

### Tip 1: Run Fast Tests First

```bash
# Start with unit tests (fast)
pytest -m unit

# Then integration tests (moderate)
pytest -m integration

# Finally E2E tests (slow)
pytest -m e2e
```

### Tip 2: Skip Slow Tests During Development

```bash
# Skip Docker and slow tests
pytest -m "not docker and not slow"
```

### Tip 3: Use Verbose Mode for Debugging

```bash
# See detailed output
pytest -v -s

# Or for PowerShell scripts
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose
```

### Tip 4: Generate Coverage Reports

```bash
# HTML coverage report
pytest --cov=src --cov-report=html

# Open in browser
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

### Tip 5: Run Tests in Parallel (Advanced)

```bash
# Install pytest-xdist
pip install pytest-xdist

# Run tests in parallel
pytest -n auto
```

---

## 🎓 Learning Path

### Beginner
1. ✅ Run archetype validation tests
2. ✅ Run RAG core infrastructure test
3. ✅ Read this quick start guide

### Intermediate
1. ✅ Run unit tests for RAG archetype
2. ✅ Run integration tests with Docker
3. ✅ Read detailed testing guides
4. ✅ Generate coverage reports

### Advanced
1. ✅ Run full stack RAG test
2. ✅ Test multi-archetype composition
3. ✅ Write your own tests
4. ✅ Set up CI/CD integration
5. ✅ Contribute to test suite

---

## 🔗 Quick Links

| Link | Description |
|------|-------------|
| [README.md](./README.md) | Main testing documentation |
| [Template System Testing](./guides/TEMPLATE_SYSTEM_TESTING.md) | Template & archetype tests |
| [Archetype Implementation Testing](./guides/ARCHETYPE_IMPLEMENTATION_TESTING.md) | pytest-based tests |
| [RAG Archetype Testing](./rag-archetype/README.md) | RAG-specific testing |
| [RAG Quick Reference](./rag-archetype/QUICK_REFERENCE.md) | RAG commands |
| [RAG Fixes History](./rag-archetype/FIXES_HISTORY.md) | Infrastructure fixes |

---

## ❓ Need Help?

1. **Check the documentation** - Most answers are in the detailed guides
2. **Review fixes history** - [rag-archetype/FIXES_HISTORY.md](./rag-archetype/FIXES_HISTORY.md)
3. **Check GitHub issues** - Someone may have had the same problem
4. **Create an issue** - If you found a bug or need help

---

**Last Updated:** December 5, 2025
**Status:** ✅ Ready to use
**Maintainer:** Dev Environment Template Team
