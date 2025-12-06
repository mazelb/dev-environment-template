# Template System Testing Guide

Complete guide for testing the dev-environment-template project creation system, including archetype structure, validation, file merging, git integration, and multi-archetype composition.

**Last Updated:** December 5, 2025

---

## Table of Contents

1. [Overview](#overview)
2. [Test Scripts](#test-scripts)
3. [Archetype Structure Tests](#archetype-structure-tests)
4. [Archetype Validation Tests](#archetype-validation-tests)
5. [File Merging Tests](#file-merging-tests)
6. [Git Integration Tests](#git-integration-tests)
7. [Multi-Archetype Composition Tests](#multi-archetype-composition-tests)
8. [Multi-Project Workflow Tests](#multi-project-workflow-tests)
9. [Running Tests](#running-tests)
10. [Troubleshooting](#troubleshooting)

---

## Overview

The template system tests validate the `create-project.sh` script and archetype composition system. These tests ensure:

- Archetype metadata and structure are correct
- File merging works properly (docker-compose.yml, .gitignore, etc.)
- Git integration functions correctly
- Multi-archetype composition produces valid projects
- Project creation workflow is reliable

### Test Categories

| Category | Test Script | Purpose |
|----------|-------------|---------|
| **Archetype Structure** | Test-ArchetypeStructure.ps1 | Validate archetype config and structure |
| **Archetype Validation** | Test-ArchetypeValidation.ps1 | Validate production archetypes |
| **File Merging** | Test-FileMerging.ps1 | Test file merging logic |
| **Git Integration** | Test-GitIntegration.ps1 | Test git initialization and commits |
| **Multi-Archetype** | Test-MultiArchetype.ps1 | Test multi-archetype composition |
| **Multi-Project** | Test-MultiProjectWorkflow.ps1 | Test multiple project creation |
| **Project Creation** | Test-CreateProject.ps1 | End-to-end project creation |

---

## Test Scripts

### Test-ArchetypeStructure.ps1

**Purpose:** Validate archetype configuration and structure

**Tests:**
1. Archetype directory structure
2. Archetype metadata (archetype.json)
3. Required files presence
4. Configuration file validity

**Usage:**
```powershell
pwsh tests/Test-ArchetypeStructure.ps1
```

---

### Test-ArchetypeValidation.ps1

**Purpose:** Validate production-ready archetype library

**Tests:**
1. Archetypes infrastructure (6 tests)
   - Archetypes directory exists
   - Schema definition exists
   - Schema is valid JSON
   - README exists
   - Registry exists
   - Registry is valid JSON

2. Individual archetypes validation (7 archetypes × 6 tests = 42 tests)
   - **RAG Project** (rag-project/)
   - **Agentic Workflows** (agentic-workflows/)
   - **API Service** (api-service/)
   - **Frontend** (frontend/)
   - **Monitoring** (monitoring/)
   - **Base** (base/)
   - **Composite RAG+Agents** (composite-rag-agents/)

**Per-Archetype Tests:**
- Archetype directory exists
- archetype.json exists and is valid
- README.md exists
- docker-compose.yml exists and is valid (if applicable)
- Service definitions are correct
- Volume mappings are correct

**Usage:**
```powershell
pwsh tests/Test-ArchetypeValidation.ps1
```

**Expected Output:**
```
✅ PASS: 48/48 tests (100%)
```

---

### Test-FileMerging.ps1

**Purpose:** Test file merging logic for multi-archetype composition

**Tests:**
1. docker-compose.yml merging
   - Service merging (no conflicts)
   - Volume merging
   - Network merging
   - Environment variable handling

2. .gitignore merging
   - Pattern deduplication
   - Comment preservation
   - Section organization

3. requirements.txt merging (Python)
   - Dependency deduplication
   - Version conflict resolution
   - Comment preservation

4. package.json merging (JavaScript)
   - Dependency merging
   - Script merging
   - Metadata handling

**Usage:**
```powershell
pwsh tests/Test-FileMerging.ps1
```

**Test Scenarios:**

#### docker-compose.yml Merging

```yaml
# Archetype A:
services:
  api:
    image: python:3.11
    ports:
      - "8000:8000"

# Archetype B:
services:
  db:
    image: postgres:16
    ports:
      - "5432:5432"

# Expected Merged Result:
services:
  api:
    image: python:3.11
    ports:
      - "8000:8000"
  db:
    image: postgres:16
    ports:
      - "5432:5432"
```

#### .gitignore Merging

```gitignore
# Archetype A:
*.pyc
__pycache__/
.env

# Archetype B:
node_modules/
.env
dist/

# Expected Merged Result (deduplicated):
*.pyc
__pycache__/
.env
node_modules/
dist/
```

---

### Test-GitIntegration.ps1

**Purpose:** Test git initialization and repository setup

**Tests:**
1. Git repository initialization
2. Initial commit creation
3. .gitignore setup
4. Branch configuration
5. Remote repository setup (optional)

**Usage:**
```powershell
pwsh tests/Test-GitIntegration.ps1
```

**Test Cases:**

```powershell
# Test 1: Initialize git repository
git init
# Expected: .git/ directory created

# Test 2: Initial commit
git add .
git commit -m "Initial commit from template"
# Expected: Commit created with all files

# Test 3: .gitignore respected
echo "temp.txt" > .gitignore
echo "test" > temp.txt
git status
# Expected: temp.txt not listed in untracked files
```

---

### Test-MultiArchetype.ps1

**Purpose:** Test multi-archetype composition

**Tests:**
1. Two-archetype composition (rag-project + agentic-workflows)
2. Three-archetype composition (api-service + monitoring + frontend)
3. File conflict resolution
4. Service integration
5. Dependency merging

**Usage:**
```powershell
pwsh tests/Test-MultiArchetype.ps1
```

**Test Scenarios:**

#### Scenario 1: RAG + Agentic Workflows

```bash
./create-project.sh --name rag-agents --archetype rag-project,agentic-workflows
```

**Expected Merged Services:**
- PostgreSQL (from RAG)
- Redis (from RAG)
- OpenSearch (from RAG)
- Ollama (from RAG)
- FastAPI (from RAG)
- Langfuse (from RAG)
- LangGraph workflows (from Agentic)

#### Scenario 2: API + Monitoring + Frontend

```bash
./create-project.sh --name full-stack --archetype api-service,monitoring,frontend
```

**Expected Merged Services:**
- API backend (from api-service)
- PostgreSQL (from api-service)
- Redis (from api-service)
- Prometheus (from monitoring)
- Grafana (from monitoring)
- Next.js frontend (from frontend)

---

### Test-MultiProjectWorkflow.ps1

**Purpose:** Test creating multiple projects in sequence

**Tests:**
1. Create multiple projects without conflicts
2. Verify each project is independent
3. Test different archetype combinations
4. Cleanup and isolation

**Usage:**
```powershell
pwsh tests/Test-MultiProjectWorkflow.ps1
```

**Test Workflow:**

```powershell
# Create Project 1
./create-project.sh --name project1 --archetype rag-project
cd project1 && docker-compose up -d && cd ..

# Create Project 2
./create-project.sh --name project2 --archetype api-service
cd project2 && docker-compose up -d && cd ..

# Create Project 3
./create-project.sh --name project3 --archetype frontend
cd project3 && npm install && cd ..

# Expected: All 3 projects exist and are independent
```

---

### Test-CreateProject.ps1

**Purpose:** End-to-end project creation testing

**Tests:**
1. Project creation with single archetype
2. Project structure validation
3. File permissions
4. Configuration file validity
5. Docker Compose validation
6. Dependency installation (optional)

**Usage:**
```powershell
pwsh tests/Test-CreateProject.ps1
```

---

## Running Tests

### Run All Template Tests

```powershell
# Run all tests in sequence
pwsh tests/Test-ArchetypeStructure.ps1
pwsh tests/Test-ArchetypeValidation.ps1
pwsh tests/Test-FileMerging.ps1
pwsh tests/Test-GitIntegration.ps1
pwsh tests/Test-MultiArchetype.ps1
pwsh tests/Test-MultiProjectWorkflow.ps1
pwsh tests/Test-CreateProject.ps1
```

### Run Individual Test Suites

```powershell
# Archetype structure and validation
pwsh tests/Test-ArchetypeStructure.ps1
pwsh tests/Test-ArchetypeValidation.ps1

# File merging
pwsh tests/Test-FileMerging.ps1

# Project creation
pwsh tests/Test-CreateProject.ps1

# Multi-archetype composition
pwsh tests/Test-MultiArchetype.ps1
```

### Using Bash (Linux/macOS)

```bash
# Archetype structure tests
bash tests/test-archetype-structure.sh

# File merging integration tests
bash tests/test-file-merging-integration.sh
```

---

## Expected Test Results

### Test-ArchetypeValidation.ps1

```
✅ Archetypes Infrastructure Tests
   ✅ Archetypes directory exists
   ✅ Schema definition exists
   ✅ Schema is valid JSON
   ✅ README exists
   ✅ Registry exists
   ✅ Registry is valid JSON

✅ RAG Project Archetype Tests
   ✅ Archetype directory exists
   ✅ archetype.json exists and valid
   ✅ README.md exists
   ✅ docker-compose.yml valid
   ✅ Service definitions correct
   ✅ Volume mappings correct

[... similar for all 7 archetypes ...]

PASS: 48/48 tests (100%)
```

### Test-MultiArchetype.ps1

```
✅ Test: rag-project + agentic-workflows composition
   ✅ Project created successfully
   ✅ docker-compose.yml merged correctly
   ✅ All services defined
   ✅ No service conflicts
   ✅ requirements.txt merged
   ✅ .gitignore merged

✅ Test: api-service + monitoring + frontend composition
   ✅ Project created successfully
   ✅ Three-way merge successful
   ✅ All services running
   ✅ No port conflicts

PASS: All multi-archetype tests
```

---

## Archetype Structure Requirements

Each archetype must have the following structure:

```
archetypes/{archetype-name}/
├── archetype.json              # Metadata and configuration
├── README.md                   # Archetype documentation
├── docker-compose.yml          # Service definitions (optional)
├── requirements.txt            # Python dependencies (optional)
├── package.json                # JavaScript dependencies (optional)
├── .env.example                # Environment variables template
├── .gitignore                  # Git ignore patterns
├── src/                        # Source code (optional)
├── tests/                      # Tests (optional)
└── docs/                       # Documentation (optional)
```

### archetype.json Schema

```json
{
  "name": "archetype-name",
  "version": "1.0.0",
  "description": "Archetype description",
  "type": "base|rag|api|frontend|monitoring|composite",
  "language": ["python", "typescript", "kotlin"],
  "services": [
    {
      "name": "service-name",
      "type": "database|cache|search|api|frontend|monitoring",
      "port": 8000,
      "healthcheck": "/health"
    }
  ],
  "dependencies": {
    "python": ["package>=version"],
    "node": ["package@version"]
  },
  "environment": {
    "required": ["ENV_VAR"],
    "optional": ["OPTIONAL_VAR"]
  }
}
```

---

## File Merging Rules

### docker-compose.yml

```yaml
# Rule 1: Services are merged by name
# If service names differ → both included
# If service names match → conflict error

# Rule 2: Volumes are deduplicated
volumes:
  - ./src:/app/src      # From archetype A
  - ./tests:/app/tests  # From archetype B
  # Result: Both volumes included

# Rule 3: Networks are merged
networks:
  - app-network         # From archetype A
  - monitoring-network  # From archetype B
  # Result: Both networks included

# Rule 4: Ports must not conflict
# 8000:8000 in archetype A
# 8000:8000 in archetype B
# Result: ERROR - port conflict
```

### .gitignore

```gitignore
# Rule: Lines are deduplicated, order preserved
# Archetype A:
*.pyc
.env

# Archetype B:
.env
node_modules/

# Result:
*.pyc
.env
node_modules/
```

### requirements.txt

```python
# Rule: Dependencies are merged, highest version wins
# Archetype A:
fastapi>=0.100.0
pydantic>=2.0.0

# Archetype B:
fastapi>=0.104.0
sqlalchemy>=2.0.0

# Result:
fastapi>=0.104.0      # Higher version
pydantic>=2.0.0
sqlalchemy>=2.0.0
```

---

## Troubleshooting

### Test Failures

#### Issue: Archetype validation fails

**Symptom:** `archetype.json not found` or `invalid JSON`

**Solution:**
```bash
# Check archetype.json exists
ls archetypes/*/archetype.json

# Validate JSON syntax
cat archetypes/rag-project/archetype.json | jq .
```

#### Issue: docker-compose.yml merge fails

**Symptom:** `Service name conflict` or `Port conflict`

**Solution:**
```bash
# Check for service name conflicts
grep "services:" archetypes/*/docker-compose.yml

# Check for port conflicts
grep "ports:" archetypes/*/docker-compose.yml
```

#### Issue: File permissions error

**Symptom:** `Permission denied` when creating projects

**Solution:**
```bash
# Make create-project.sh executable
chmod +x create-project.sh

# Run with proper permissions
./create-project.sh --name test --archetype base
```

### Common Errors

#### Error: "Archetype not found"

```bash
# Check archetypes directory
ls archetypes/

# Verify archetype name spelling
./create-project.sh --list
```

#### Error: "Git not initialized"

```bash
# Initialize git manually
cd project-name
git init
git add .
git commit -m "Initial commit"
```

#### Error: "Docker Compose validation failed"

```bash
# Validate docker-compose.yml
docker-compose -f project-name/docker-compose.yml config

# Check for syntax errors
yamllint project-name/docker-compose.yml
```

---

## Best Practices

1. **Always validate archetypes** before adding to production
2. **Test multi-archetype compositions** for common combinations
3. **Check file merging** for potential conflicts
4. **Verify Docker Compose** files after merging
5. **Test git integration** for each archetype
6. **Document archetype dependencies** in archetype.json
7. **Use semantic versioning** for archetypes
8. **Keep archetype structure consistent** across all archetypes

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Template System Tests

on: [push, pull_request]

jobs:
  test-archetypes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install PowerShell
        run: |
          sudo apt-get update
          sudo apt-get install -y powershell

      - name: Run Archetype Structure Tests
        run: pwsh tests/Test-ArchetypeStructure.ps1

      - name: Run Archetype Validation Tests
        run: pwsh tests/Test-ArchetypeValidation.ps1

      - name: Run File Merging Tests
        run: pwsh tests/Test-FileMerging.ps1

      - name: Run Multi-Archetype Tests
        run: pwsh tests/Test-MultiArchetype.ps1
```

---

## Reference

### Test Script Locations

```
tests/
├── Test-ArchetypeStructure.ps1
├── Test-ArchetypeValidation.ps1
├── Test-FileMerging.ps1
├── Test-GitIntegration.ps1
├── Test-MultiArchetype.ps1
├── Test-MultiProjectWorkflow.ps1
├── Test-CreateProject.ps1
├── test-archetype-structure.sh
└── test-file-merging-integration.sh
```

### Documentation

- Main README: `tests/README.md`
- This guide: `tests/guides/TEMPLATE_SYSTEM_TESTING.md`
- RAG archetype: `tests/rag-archetype/README.md`

---

**Last Updated:** December 5, 2025
**Status:** ✅ Complete and validated
**Maintainer:** Dev Environment Template Team
