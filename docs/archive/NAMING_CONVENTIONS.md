# Naming Conventions

## Overview
This document defines the standardized naming conventions used across the dev-environment-template project.

---

## 1. Shell Scripts

### Location
`scripts/`, `tests/`, root directory

### Convention
- **Format**: `kebab-case.sh`
- **Extension**: Always use `.sh`
- **Examples**:
  - ✅ `create-project.sh`
  - ✅ `docker-compose-merger.sh`
  - ✅ `conflict-resolver.sh`
  - ✅ `test-multi-project-workflow.sh`
  - ❌ `createProject.sh`
  - ❌ `create_project.sh`

### Guidelines
- Use descriptive, action-oriented names
- Separate words with hyphens
- Keep names concise but clear
- Include `.sh` extension for all bash scripts

---

## 2. Bash Functions

### Convention
- **Format**: `snake_case`
- **Examples**:
  - ✅ `merge_docker_compose()`
  - ✅ `resolve_port_conflicts()`
  - ✅ `detect_service_name_conflicts()`
  - ✅ `print_success()`
  - ❌ `mergeDockerCompose()`
  - ❌ `resolve-port-conflicts()`

### Guidelines
- Use verb-noun pattern for action functions
- Use descriptive names that indicate purpose
- Keep utility functions short and clear (`print_info`, `get_value`)
- Private/internal functions can use `_` prefix (e.g., `_internal_helper`)

---

## 3. Docker Container Names

### Convention
- **Format**: `${PROJECT_NAME:-default}-service-name`
- **Pattern**: Always use `PROJECT_NAME` environment variable with fallback
- **Examples**:
  - ✅ `${PROJECT_NAME:-rag}-api`
  - ✅ `${PROJECT_NAME:-rag}-vector-db`
  - ✅ `${PROJECT_NAME:-api}-service`
  - ✅ `${PROJECT_NAME:-monitoring}-prometheus`
  - ❌ `api` (no prefix)
  - ❌ `prometheus` (hardcoded)
  - ❌ `myproject_api` (underscore separator)

### Guidelines
- **Always** use `${PROJECT_NAME}` prefix for namespace isolation
- Provide sensible defaults matching archetype name
- Use hyphens to separate prefix from service name
- Service names should be lowercase, hyphenated
- Archetype-specific defaults:
  - RAG projects: `${PROJECT_NAME:-rag}-*`
  - API services: `${PROJECT_NAME:-api}-*`
  - Monitoring: `${PROJECT_NAME:-monitoring}-*`

### Archetype Examples

#### rag-project
```yaml
services:
  api:
    container_name: ${PROJECT_NAME:-rag}-api
  vector-db:
    container_name: ${PROJECT_NAME:-rag}-vector-db
  ollama:
    container_name: ${PROJECT_NAME:-rag}-ollama
```

#### api-service
```yaml
services:
  api:
    container_name: ${PROJECT_NAME:-api}-service
  redis:
    container_name: ${PROJECT_NAME:-api}-redis
```

#### monitoring
```yaml
services:
  prometheus:
    container_name: ${PROJECT_NAME:-monitoring}-prometheus
  grafana:
    container_name: ${PROJECT_NAME:-monitoring}-grafana
  loki:
    container_name: ${PROJECT_NAME:-monitoring}-loki
  promtail:
    container_name: ${PROJECT_NAME:-monitoring}-promtail
```

---

## 4. Network Names

### Convention
- **Format**: `archetype-network` or `${PROJECT_NAME}-network`
- **Examples**:
  - ✅ `rag-network`
  - ✅ `api-network`
  - ✅ `monitoring`
  - ✅ `${PROJECT_NAME:-app}-network`

### Guidelines
- Use descriptive names matching archetype or service purpose
- Prefer static names for archetype-specific networks
- Use `${PROJECT_NAME}` prefix for project-scoped networks
- Keep names short and clear

---

## 5. Volume Names

### Convention
- **Format**: `service-data` or `${PROJECT_NAME}-service-data`
- **Examples**:
  - ✅ `chroma-data`
  - ✅ `ollama-data`
  - ✅ `prometheus-data`
  - ✅ `redis-data`
  - ❌ `data1`, `db_volume`

### Guidelines
- Use hyphenated lowercase names
- Include service name + `-data` suffix
- Volume names can be static (not prefixed) for archetype isolation
- Use descriptive names indicating content

---

## 6. Archetype Directory Structure

### Convention
```
archetypes/
├── archetype-name/          # kebab-case
│   ├── __archetype__.json
│   ├── docker-compose.yml
│   ├── requirements.txt
│   ├── README.md
│   ├── src/
│   ├── tests/
│   ├── config/
│   └── docs/
```

### Guidelines
- Archetype folders use `kebab-case`
- Special files use `snake_case` or standard conventions
- Docker files use standard Docker naming (`Dockerfile`, `docker-compose.yml`)
- Python files use `snake_case.py`

---

## 7. Environment Variables

### Convention
- **Format**: `SCREAMING_SNAKE_CASE`
- **Examples**:
  - ✅ `PROJECT_NAME`
  - ✅ `VECTOR_DB_HOST`
  - ✅ `OLLAMA_MODEL`
  - ✅ `API_SECRET_KEY`
  - ❌ `projectName`
  - ❌ `vector-db-host`

### Guidelines
- Use all uppercase with underscores
- Group related variables with common prefixes
- Provide defaults in docker-compose files: `${VAR_NAME:-default}`
- Document all required variables in `.env.example`

---

## 8. Service Names (docker-compose)

### Convention
- **Format**: `lowercase-hyphenated`
- **Examples**:
  - ✅ `api`
  - ✅ `vector-db`
  - ✅ `ollama`
  - ✅ `redis`
  - ❌ `API`, `VectorDb`, `vector_db`

### Guidelines
- Use short, descriptive names
- Prefer single-word names when clear (`api`, `redis`)
- Use hyphens for multi-word services (`vector-db`, `job-worker`)
- Service names should match their logical function

---

## 9. Test Files

### Convention
- **Bash**: `test-feature-name.sh` or `Test-FeatureName.ps1`
- **Python**: `test_feature_name.py`
- **Examples**:
  - ✅ `test-multi-project-workflow.sh`
  - ✅ `Test-MultiProjectWorkflow.ps1`
  - ✅ `test_phase1.sh`
  - ✅ `test_api_endpoints.py`

### Guidelines
- Bash test scripts: `test-` prefix, kebab-case
- PowerShell test scripts: `Test-` prefix, PascalCase
- Python test files: `test_` prefix, snake_case
- Place in `tests/` directory

---

## 10. Documentation Files

### Convention
- **Format**: `SCREAMING_SNAKE_CASE.md`
- **Examples**:
  - ✅ `README.md`
  - ✅ `SETUP_GUIDE.md`
  - ✅ `NAMING_CONVENTIONS.md`
  - ✅ `ARCHITECTURE_DIAGRAMS.md`
  - ❌ `setup-guide.md`
  - ❌ `NamingConventions.md`

### Guidelines
- Use all caps with underscores
- Place in `docs/` directory
- Use `.md` extension for Markdown
- Keep names descriptive and searchable

---

## Summary Table

| Component | Convention | Example |
|-----------|-----------|---------|
| Shell Scripts | `kebab-case.sh` | `create-project.sh` |
| Bash Functions | `snake_case()` | `merge_docker_compose()` |
| Container Names | `${PROJECT_NAME:-default}-service` | `${PROJECT_NAME:-rag}-api` |
| Networks | `archetype-network` | `rag-network` |
| Volumes | `service-data` | `chroma-data` |
| Environment Vars | `SCREAMING_SNAKE_CASE` | `PROJECT_NAME` |
| Service Names | `lowercase-hyphenated` | `vector-db` |
| Test Files (Bash) | `test-name.sh` | `test-phase1.sh` |
| Test Files (Python) | `test_name.py` | `test_api.py` |
| Documentation | `SCREAMING_SNAKE.md` | `SETUP_GUIDE.md` |

---

## Enforcement

### Pre-commit Checks
- Shell scripts must end in `.sh`
- No uppercase in shell script names (except extensions)
- Container names must use `${PROJECT_NAME}` prefix

### Code Review
- Verify new scripts follow naming conventions
- Check docker-compose files for proper container naming
- Ensure functions use snake_case

### Automated Validation
- Run `tests/test-naming-conventions.sh` to validate project structure
- CI/CD pipeline includes naming convention checks

---

## References
- [Docker Compose Best Practices](https://docs.docker.com/compose/compose-file/)
- [Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Python PEP 8](https://pep8.org/)

---

## Changelog
- 2025-11-24: Initial naming conventions established
- 2025-11-24: Standardized all archetype container names with `${PROJECT_NAME}` prefix
