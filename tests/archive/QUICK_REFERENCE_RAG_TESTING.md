# Quick Reference: RAG Archetype Testing

## 🚀 One-Command Full Test

```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose
```

This single command will:
1. ✓ Create a RAG project
2. ✓ Validate project structure
3. ✓ Start Docker services
4. ✓ Run health checks
5. ✓ Execute all tests
6. ✓ Generate coverage
7. ✓ Clean up

---

## 📋 Manual Testing Steps

### 1. Create Project
```bash
./create-project.sh --name my-rag --archetype rag-project --no-git
cd my-rag
```

### 2. Start Services
```bash
cp .env.example .env
docker compose up -d
sleep 180  # Wait 3 minutes for startup
```

### 3. Verify Services
```bash
# Check containers
docker compose ps

# Health checks
curl http://localhost:8000/api/v1/health   # API
curl http://localhost:9200/_cluster/health # OpenSearch
curl http://localhost:11434/api/version    # Ollama
docker exec myrag-postgres pg_isready      # PostgreSQL
docker exec myrag-redis redis-cli ping     # Redis
```

### 4. Run Tests
```bash
# All tests
pytest -v

# By category
pytest tests/unit/ -v -m unit
pytest tests/integration/ -v -m integration
pytest tests/e2e/ -v

# With coverage
pytest --cov=src --cov-report=html
```

### 5. Cleanup
```bash
docker compose down -v
cd ..
rm -rf my-rag
```

---

## 🎯 Test Categories

### Unit Tests
```bash
cd archetypes/rag-project
pytest tests/unit/test_cache.py -v
pytest tests/unit/test_database.py -v
pytest tests/unit/test_opensearch.py -v
pytest tests/unit/test_ollama.py -v
pytest tests/unit/test_embeddings.py -v
pytest tests/unit/test_chunking.py -v
```

### Integration Tests
```bash
pytest tests/integration/test_rag_pipeline.py -v
pytest tests/integration/test_api_endpoints.py -v
pytest tests/integration/test_docker_services.py -v
pytest tests/integration/test_opensearch_integration.py -v
pytest tests/integration/test_llm_integration.py -v
```

### E2E Tests
```bash
pytest tests/e2e/test_rag_e2e.py -v
```

---

## 🐛 Quick Troubleshooting

### Services Won't Start
```powershell
# Check Docker
docker ps

# Check ports
netstat -ano | findstr "8000 9200 5432 6379 11434"

# View logs
docker compose logs api
docker compose logs opensearch
docker compose logs ollama
```

### Tests Fail
```bash
# Check Python environment
python --version  # Should be 3.11+
pip list | grep pytest

# Reinstall dependencies
pip install -r requirements.txt

# Run single test for debugging
pytest tests/unit/test_cache.py::test_cache_set_get -vv
```

### Cleanup Issues
```powershell
# Force cleanup
cd tests/temp
docker compose down -v --remove-orphans
cd ../..
Remove-Item -Recurse -Force tests/temp/*

# Clean Docker
docker system prune -f
```

---

## 📊 Expected Results

✓ Project Creation: ~30 seconds
✓ Docker Services: ~5 minutes
✓ Unit Tests: ~60 seconds
✓ Integration Tests: ~3 minutes
✓ E2E Tests: ~5 minutes
✓ Code Coverage: >70%
✓ **Total Time:** ~15 minutes

---

## 📁 Key Files

- `tests/Test-RagArchetypeFull.ps1` - Main test script
- `tests/TEST_RAG_FULL_STACK.md` - Complete documentation
- `tests/TESTING_GUIDE.md` - Overall testing guide
- `tests/RAG_ARCHETYPE_TEST_SUMMARY.md` - Detailed summary
- `archetypes/rag-project/` - RAG archetype source
- `archetypes/rag-project/tests/` - Test suites

---

## 🔗 Quick Links

```powershell
# View test results
cat tests/temp/rag-full-test-results.txt

# View coverage report
start htmlcov/index.html

# Check test project
cd tests/temp/test-rag-full-*
```

---

**Last Updated:** December 2, 2025
