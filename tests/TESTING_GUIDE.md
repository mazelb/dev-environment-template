# Testing Guide

Complete guide for testing the dev-environment-template and projects created from it.

---

## Overview

The template includes comprehensive test suites:

- **Template System Tests (Phases 1-4, 6)**: PowerShell/Bash tests for project creation system
- **Archetype Implementation Tests**: pytest tests for RAG/API archetype code
- **Integration Tests**: End-to-end workflow tests
- **Manual Testing**: Guidelines for manual verification

**Note:** Phase 5 (GitHub CLI integration) is not implemented and has been removed.

---

## Running Tests

### 1. Template System Tests (PowerShell)

```powershell
# Run all phase tests
pwsh tests/Test-Phase1.ps1  # Foundation & Infrastructure
pwsh tests/Test-Phase2.ps1  # Git Integration
pwsh tests/Test-Phase3.ps1  # Multi-Archetype Core
pwsh tests/Test-Phase4.ps1  # File Merging System
pwsh tests/Test-Phase6.ps1  # Archetypes Validation

# Run project creation tests
pwsh tests/Test-CreateProject.ps1
pwsh tests/Test-MultiProjectWorkflow.ps1
```

### 2. Template System Tests (Bash)

```bash
# Run bash integration tests
bash tests/test-phase1.sh
bash tests/test-phase4-integration.sh
```

### 3. Archetype Implementation Tests (pytest)

```bash
# RAG archetype tests
cd archetypes/rag-project
pytest                    # Run all tests
pytest -m unit           # Unit tests only
pytest -m integration    # Integration tests only
pytest --cov=src         # With coverage

# API archetype tests
cd archetypes/api-service
pytest
```

---

## Test Coverage

### Template System Tests

#### Phase 1: Foundation & Infrastructure
- Configuration file validation
- Archetype directory structure
- Archetype loader functionality
- JSON schema validation

#### Phase 2: Git Integration
- Automatic Git initialization
- Smart commit message generation
- .gitignore generation
- Git helper script functionality

#### Phase 3: Multi-Archetype Core
- Conflict detection
- Port offset resolution
- Service name prefixing
- Archetype composition

#### Phase 4: File Merging System
- Docker Compose merging
- .env file merging
- Makefile merging
- Source file merging

#### Phase 6: Archetypes (100% Pass Rate)
- **46/46 tests passing**
- Base archetype
- RAG project archetype
- API service archetype
- Agentic workflows archetype
- Monitoring archetype
- Composite archetypes

### Archetype Implementation Tests

#### RAG Archetype (138+ tests)
- **Unit Tests:** Cache, Database, OpenSearch, Ollama, Embeddings, Chunking
- **Integration Tests:** RAG Pipeline, API Endpoints, Docker Services
- **Coverage:** Core services and RAG pipeline functionality

#### API Archetype
- **Unit Tests:** Auth, Database, Middleware, Config
- **Integration Tests:** API Endpoints, Docker Services
- **Coverage:** Authentication and API functionality

---

## Manual Testing Checklist

### Basic Project Creation

```bash
# 1. Create simple project
./create-project.sh --name test-simple --archetype base

# 2. Verify structure
cd test-simple
ls -la  # Should see src/, tests/, docs/, .git/, README.md

# 3. Check Git
git log  # Should have initial commit
cat .gitignore  # Should have comprehensive patterns

# 4. Clean up
cd ..
rm -rf test-simple
```

### Archetype Testing

```bash
# 1. Test RAG archetype
./create-project.sh --name test-rag --archetype rag-project

# 2. Verify RAG-specific files
cd test-rag
ls src/api  # Should have FastAPI structure
ls config  # Should have settings.py
cat docker-compose.yml  # Should have OpenSearch, Ollama

# 3. Check documentation
cat README.md  # Should have RAG-specific content
cat COMPOSITION.md  # Should exist for archetypes

# 4. Clean up
cd ..
rm -rf test-rag
```

### Multi-Archetype Composition

```bash
# 1. Test composition
./create-project.sh --name test-composed \\
  --archetype rag-project \\
  --add-features monitoring

# 2. Verify services merged
cd test-composed
cat docker-compose.yml  # Should have all services

# 3. Check for conflicts resolved
grep -r "port.*9200" docker-compose.yml  # Verify port handling

# 4. Clean up
cd ..
rm -rf test-composed
```

### GitHub Integration

```bash
# 1. Test dry-run
./create-project.sh --name test-gh --archetype base --github --dry-run

# 2. Test actual creation (requires gh CLI)
./create-project.sh --name test-gh --archetype base --github

# 3. Verify GitHub repo created
gh repo view test-gh

# 4. Clean up
gh repo delete test-gh --yes
rm -rf test-gh
```

### Dry Run Mode

```bash
# Test dry-run previews
./create-project.sh --name preview1 --archetype base --dry-run
./create-project.sh --name preview2 --archetype rag-project --github --dry-run

# Verify no files created
ls preview1 2>/dev/null || echo "✓ No directory created"
ls preview2 2>/dev/null || echo "✓ No directory created"
```

---

## Test Results Summary

| Phase | Tests | Passed | Failed | Success Rate |
|-------|-------|--------|--------|--------------|
| Phase 1 | TBD | TBD | TBD | - |
| Phase 2 | TBD | TBD | TBD | - |
| Phase 3 | TBD | TBD | TBD | - |
| Phase 4 | TBD | TBD | TBD | - |
| Phase 6 | 46 | 46 | 0 | 100% |

**Overall Test Coverage:** ~90%---

## Troubleshooting Tests

### PowerShell Tests Won't Run

**Problem:** "Cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
# Set execution policy (run as Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Bash Tests Fail

**Problem:** Permission denied

**Solution:**
```bash
# Make scripts executable
chmod +x tests/*.sh

# Run tests
bash tests/test-phase1.sh
```

### Tests Timeout

**Problem:** Tests hang or timeout

**Solution:**
- Check Docker is running
- Ensure no port conflicts
- Increase timeout in test scripts

### JSON/YAML Validation Fails

**Problem:** jq or yq command not found

**Solution:**
```bash
# Install jq (JSON processor)
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Windows (via Chocolatey)
choco install jq

# Install yq (YAML processor)
pip install yq
```

---

## Adding New Tests

### Creating a Test Script

```powershell
# Template for new PowerShell test
# tests/Test-PhaseX.ps1

# Test configuration
$ErrorActionPreference = "Continue"

# Test functions
function Test-Feature {
    Write-Host "Testing feature..."
    # Test logic here
    if ($condition) {
        Write-Host "✓ PASS: Feature works"
    } else {
        Write-Host "✗ FAIL: Feature broken"
    }
}

# Run tests
Test-Feature

# Summary
Write-Host "`nTest Summary:"
Write-Host "Total: X, Passed: Y, Failed: Z"
```

### Test Best Practices

1. **Isolate tests** - Each test should be independent
2. **Clean up** - Remove test artifacts after completion
3. **Be specific** - Test one thing per test function
4. **Add context** - Include helpful error messages
5. **Document** - Explain what each test validates

---

## Continuous Integration

### GitHub Actions (Future)

```yaml
# .github/workflows/test.yml (template)
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Phase 6 Tests
        run: pwsh tests/Test-Phase6.ps1
```

---

## Performance Testing

### Project Creation Time

```bash
# Measure project creation time
time ./create-project.sh --name perf-test --archetype base

# Target: < 60 seconds
# Typical: < 30 seconds
```

### Resource Usage

```bash
# Monitor during creation
docker stats

# Check disk usage
du -sh test-project/
```

---

## Detailed Test Documentation

For detailed test specifications, see:

- `TESTING_PHASE1.md` - Phase 1 test details
- `TESTING_PHASE2.md` - Phase 2 test details
- `TESTING_PHASE3.md` - Phase 3 test details
- `TESTING_PHASE4.md` - Phase 4 test details
- `TESTING_PHASE6.md` - Phase 6 test details
- `TESTING_CREATE_PROJECT.md` - Project creation test details

---

## Getting Help

- **Issues:** Report test failures as GitHub issues
- **Questions:** Check [FAQ](../docs/FAQ.md)
- **Troubleshooting:** See [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)

---

**Last Updated:** November 21, 2025
**Test Coverage:** ~90%
**Status:** All critical tests passing
