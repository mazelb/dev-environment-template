# RAG Archetype Full Stack Test

## Overview

This comprehensive test script validates the entire RAG archetype by creating a complete project, starting all Docker services, and running all test suites (unit, integration, and end-to-end tests).

## What It Tests

### 1. Project Creation
- Creates a timestamped RAG project in `tests/temp/`
- Validates the create-project.sh script execution
- Ensures all archetype files are copied correctly

### 2. Project Structure
Validates presence of all required files and directories:
- Configuration files (docker-compose.yml, Makefile, requirements.txt, pytest.ini)
- Source directories (src/, tests/, config/, docs/, docker/)
- Test directories (tests/unit/, tests/integration/, tests/e2e/)

### 3. Docker Compose Validation
- Validates docker-compose.yml syntax
- Ensures all service definitions are correct
- Checks for configuration errors

### 4. Docker Services Startup
Starts all required services:
- **PostgreSQL** - Database for storing documents and metadata
- **Redis** - Cache layer for performance optimization
- **OpenSearch** - Vector database for embeddings and search
- **Ollama** - Local LLM service for embeddings and generation
- **FastAPI** - REST API service

### 5. Service Health Checks
Waits for and validates each service:
- PostgreSQL: `pg_isready` check
- Redis: `PING` command
- OpenSearch: HTTP health endpoint (port 9200)
- Ollama: API version endpoint (port 11434)
- FastAPI: Health endpoint (port 8000)

### 6. Unit Tests
Runs all unit tests with pytest:
- Cache service tests
- Database tests
- OpenSearch client tests
- Ollama client tests
- Embedding service tests
- Chunking service tests

### 7. Integration Tests
Runs integration tests against live services:
- RAG pipeline tests
- API endpoint tests
- Docker service integration
- Langfuse tracing integration
- Search and retrieval workflows

### 8. End-to-End Tests
Runs complete workflow tests:
- Full document ingestion pipeline
- Query and retrieval flow
- Multi-service coordination

### 9. Coverage Report
Generates code coverage metrics:
- Line coverage
- Branch coverage
- HTML coverage report
- Target: >70% overall coverage

## Usage

### Basic Usage

```powershell
# Run the complete test suite
pwsh tests/Test-RagArchetypeFull.ps1
```

This will:
1. Create a temporary RAG project
2. Start all Docker services
3. Wait for services to be healthy
4. Run all test suites
5. Generate coverage report
6. Clean up (stop containers, remove project)

### Options

#### Keep Project After Tests
```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -KeepProject
```
Preserves the test project directory for manual inspection. Useful for debugging test failures.

#### Skip Docker Cleanup
```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -SkipCleanup
```
Keeps Docker containers running after tests. Useful for:
- Inspecting container logs
- Testing API endpoints manually
- Debugging service interactions

#### Verbose Output
```powershell
pwsh tests/Test-RagArchetypeFull.ps1 -Verbose
```
Enables detailed output including:
- Command execution details
- Service startup progress
- Container logs on failures

#### Combined Options
```powershell
# Keep everything for debugging
pwsh tests/Test-RagArchetypeFull.ps1 -KeepProject -SkipCleanup -Verbose
```

## Expected Results

### Success Criteria
- ✓ All Docker services start within 5 minutes
- ✓ All service health checks pass
- ✓ Unit tests: >80% pass rate
- ✓ Integration tests: All critical paths covered
- ✓ E2E tests: Complete workflows functional
- ✓ Code coverage: >70%

### Typical Output
```
╔════════════════════════════════════════════════════════════════╗
║  RAG ARCHETYPE FULL STACK TEST                                 ║
╚════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Project Creation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ PASSED: RAG project created successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  2. Project Structure Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ README.md
  ✓ docker-compose.yml
  ✓ src
  ✓ tests
✓ PASSED: All required project structure elements present

...

╔════════════════════════════════════════════════════════════════╗
║  TEST SUMMARY                                                  ║
╚════════════════════════════════════════════════════════════════╝

Total Tests:   25
Passed:        25
Failed:        0

Success Rate:  100%

🎉 All tests passed!
```

## Troubleshooting

### Services Won't Start

**Problem:** Docker containers fail to start or become healthy

**Solutions:**
1. Check Docker is running: `docker ps`
2. Check for port conflicts: `netstat -ano | findstr "8000 9200 11434"`
3. Free up system resources (RAM, disk space)
4. Review container logs: `docker logs <container-name>`

### Tests Timeout

**Problem:** Health checks timeout waiting for services

**Solutions:**
1. Increase timeout in script (edit `MaxAttempts` parameter)
2. Ensure sufficient system resources
3. Check network connectivity
4. Verify no firewall blocking localhost ports

### Permission Errors

**Problem:** Cannot access files or run commands

**Solutions:**
1. Run PowerShell as Administrator
2. Check WSL permissions: `wsl whoami`
3. Ensure Docker has file sharing permissions

### Cleanup Issues

**Problem:** Cleanup fails or leaves resources

**Manual Cleanup:**
```powershell
# Stop and remove containers
cd tests/temp/test-rag-full-*
docker compose down -v --remove-orphans

# Remove test project
cd ..
rm -rf test-rag-full-*

# Remove dangling resources
docker system prune -f
```

## Test Results

Test results are saved to: `tests/temp/rag-full-test-results.txt`

The file contains:
- Timestamp of test execution
- Individual test results
- Summary statistics
- Project path (if preserved)

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: RAG Archetype Full Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Run RAG Full Stack Test
        run: |
          pwsh tests/Test-RagArchetypeFull.ps1
```

## Performance Benchmarks

Typical execution times on modern hardware:

| Phase | Duration |
|-------|----------|
| Project Creation | 10-30 seconds |
| Docker Services Startup | 2-5 minutes |
| Health Checks | 1-3 minutes |
| Unit Tests | 30-60 seconds |
| Integration Tests | 1-3 minutes |
| E2E Tests | 2-5 minutes |
| Coverage Report | 30 seconds |
| **Total** | **10-20 minutes** |

## Requirements

### System Requirements
- Windows 10/11 with WSL2 or Linux
- PowerShell 7.0+
- Docker Desktop or Docker Engine
- Git Bash or WSL
- 8GB+ RAM
- 10GB+ free disk space

### Software Requirements
- Docker Compose 2.0+
- Python 3.11+
- pytest
- bash

### Port Requirements
The following ports must be available:
- 5432 (PostgreSQL)
- 6379 (Redis)
- 8000 (FastAPI)
- 9200 (OpenSearch)
- 11434 (Ollama)

## Related Documentation

- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Overall testing guide
- [Test-CreateProject.ps1](Test-CreateProject.ps1) - Project creation tests
- [pytest.ini](../archetypes/rag-project/pytest.ini) - pytest configuration
- [docker-compose.yml](../archetypes/rag-project/docker-compose.yml) - Service definitions

## Support

For issues or questions:
1. Check [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)
2. Review test output and logs
3. Open a GitHub issue with:
   - Test results file
   - Container logs
   - System information

---

**Last Updated:** December 1, 2025
**Test Version:** 1.0.0
**Archetype Version:** 2.0
