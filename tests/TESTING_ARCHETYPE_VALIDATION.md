# Archetype Validation Testing Guide

## Overview

This test suite validates the production-ready archetype library including RAG, Agentic Workflows, API services, monitoring, and composite archetypes. It verifies archetype metadata, service definitions, file structure, and Docker configurations.

**Status:** ✅ **IMPLEMENTED** - Test suite validates all existing archetypes.

## Test File

- **Location:** `tests/Test-ArchetypeValidation.ps1`
- **Type:** PowerShell test script
- **Purpose:** Validate archetype system implementation
- **Execution:** `pwsh tests/Test-ArchetypeValidation.ps1`

## Test Coverage

### 6.0 Archetypes Infrastructure (6 tests)

Tests the foundational archetype system:

| Test | Description | Validates |
|------|-------------|-----------|
| 6.0.1 | Archetypes directory | `archetypes/` exists |
| 6.0.2 | Schema definition | `archetypes/__archetype_schema__.json` exists |
| 6.0.3 | Schema validity | Schema is valid JSON |
| 6.0.4 | README | `archetypes/README.md` exists |
| 6.0.5 | Registry | `config/archetypes.json` exists |
| 6.0.6 | Registry validity | Registry is valid JSON |

**Expected State:** ✅ All tests PASS

### 6.1 Base Archetype (4 tests)

Tests the minimal base archetype:

| Test | Validates |
|------|-----------|
| 6.1.1 | `archetypes/base/` directory exists |
| 6.1.2 | `base/__archetype__.json` exists |
| 6.1.3 | Metadata is valid JSON |

**Expected State:** ✅ All tests PASS

### 6.2 RAG Project Archetype (13 tests)

Tests the production-ready RAG archetype (Phase 6.1):

| Test | Component | Validates |
|------|-----------|-----------|
| 6.2.1 | Directory | `archetypes/rag-project/` exists |
| 6.2.2 | Metadata | `__archetype__.json` exists |
| 6.2.3 | JSON validity | Metadata is valid JSON |
| 6.2.4 | Metadata fields | version, metadata, composition, dependencies, services present |
| 6.2.5 | Source directory | `src/` exists |
| 6.2.6 | Models | `src/models/` exists |
| 6.2.7 | Services | `src/services/` exists |
| 6.2.8 | API | `src/api/` exists (optional) |
| 6.2.9 | Tests | `tests/` exists |
| 6.2.10 | Docker Compose | `docker-compose.yml` exists (optional) |
| 6.2.11 | Requirements | `requirements.txt` exists |
| 6.2.12 | README | `README.md` exists |

**Expected State:** ✅ All required tests PASS, optional features may be skipped

**Archetype Details:**
- **Type:** Base archetype
- **Services:** API (FastAPI), Vector DB (ChromaDB), LLM (Ollama)
- **Ports:** 8000, 8001, 11434
- **Dependencies:** FastAPI, LangChain, ChromaDB, sentence-transformers
- **Compatible With:** monitoring, agentic-workflows, api-gateway

### 6.3 API Service Archetype (4 tests)

Tests the FastAPI service archetype:

| Test | Validates |
|------|-----------|
| 6.3.1 | `archetypes/api-service/` exists |
| 6.3.2 | `__archetype__.json` exists |
| 6.3.3 | Metadata is valid JSON |

**Expected State:** ✅ All tests PASS

### 6.4 Monitoring Archetype (7 tests)

Tests the monitoring stack archetype (Phase 6.3):

| Test | Component | Validates |
|------|-----------|-----------|
| 6.4.1 | Directory | `archetypes/monitoring/` exists |
| 6.4.2 | Metadata | `__archetype__.json` exists |
| 6.4.3 | JSON validity | Metadata is valid JSON |
| 6.4.4 | Prometheus | `prometheus/` directory exists |
| 6.4.5 | Grafana | `grafana/` directory exists |

**Expected State:** ✅ All tests PASS

**Archetype Details:**
- **Type:** Feature archetype
- **Services:** Prometheus, Grafana, Loki
- **Purpose:** Observability stack for metrics, logs, and dashboards

### 6.5 Agentic Workflows Archetype (7 tests)

Tests the autonomous agent archetype (Phase 6.4):

| Test | Component | Validates |
|------|-----------|-----------|
| 6.5.1 | Directory | `archetypes/agentic-workflows/` exists |
| 6.5.2 | Metadata | `__archetype__.json` exists |
| 6.5.3 | JSON validity | Metadata is valid JSON |
| 6.5.4 | Agents config | `agents` field in metadata |
| 6.5.5 | Source | `src/` directory exists |
| 6.5.6 | Requirements | `requirements.txt` exists |

**Expected State:** ✅ All tests PASS

**Archetype Details:**
- **Type:** Feature archetype
- **Capabilities:** Multi-agent orchestration, tool integration, workflow automation
- **Dependencies:** LangChain, LangGraph, Anthropic/OpenAI SDKs
- **Compatible With:** rag-project, api-service

### 6.6 Composite Archetypes (9 tests)

Tests the composite archetype system (Phase 6.5):

| Test | Component | Validates |
|------|-----------|-----------|
| 6.6.1 | Directory | `archetypes/composite-rag-agents/` exists |
| 6.6.2 | Metadata | `__archetype__.json` exists |
| 6.6.3 | Constituents | `composition.constituents` field exists |
| 6.6.4 | Composition | Combines rag-project + agentic-workflows |
| 6.6.5 | Integration script | `scripts/integrate_rag_agentic.sh` exists (optional) |
| 6.6.6 | Examples | `examples/` directory exists (optional) |
| 6.6.7 | Example files | Python example files present |
| 6.6.8 | README | `README.md` exists |

**Expected State:** ✅ All required tests PASS

**Composite Details:**
- **Name:** composite-rag-agents
- **Constituents:** rag-project + agentic-workflows
- **Purpose:** RAG system with autonomous agents
- **Integration:** Pre-resolved conflicts, unified API

### 6.7 Service Definitions Validation (2 tests)

Tests service definitions in archetype metadata:

| Test | Archetype | Validates |
|------|-----------|-----------|
| 6.7.1 | rag-project | Services defined with ports |
| 6.7.2 | monitoring | Services defined with ports |

**Expected State:** ✅ All tests PASS

### 6.8 Compatibility and Composition (2 tests)

Tests compatibility matrix definitions:

| Test | Archetype | Validates |
|------|-----------|-----------|
| 6.8.1 | rag-project | `compatible_features` field exists |
| 6.8.2 | agentic-workflows | `compatible_features` field exists |

**Expected State:** ✅ All tests PASS

### 6.9 Documentation (2 tests)

Tests archetype documentation:

| Test | Validates |
|------|-----------|
| 6.9.1 | Comprehensive README documents all archetypes |
| 6.9.2 | Example documentation files exist (optional) |

**Expected State:** ✅ All tests PASS

### 6.10 Registry Validation (4 tests)

Tests the archetype registry:

| Test | Validates |
|------|-----------|
| 6.10.1 | Registry contains `archetypes` field |
| 6.10.2 | Registered archetype count |
| 6.10.3 | `base` registered |
| 6.10.4 | `rag-project` registered |
| 6.10.5 | `agentic-workflows` registered |

**Expected State:** ✅ All tests PASS

## Test Execution

### Running Tests

```powershell
# Run Phase 6 tests
pwsh tests/Test-Phase6.ps1
```

### Expected Output

```
╔════════════════════════════════════════╗
║ Test 6.0: Archetypes Infrastructure
╚════════════════════════════════════════╝
→ Checking if archetypes/ directory exists... ✓ archetypes/ directory found
→ Checking for archetype schema definition... ✓ Archetype schema found
→ Validating archetype schema JSON... ✓ Schema is valid JSON
→ Checking for archetypes README... ✓ Archetypes README found
→ Checking for archetypes registry... ✓ Archetypes registry found
→ Validating archetypes registry JSON... ✓ Registry is valid JSON

╔════════════════════════════════════════╗
║ Test 6.2: RAG Project Archetype
╚════════════════════════════════════════╝
→ Checking for rag-project archetype directory... ✓ rag-project/ directory found
→ Checking for rag-project metadata... ✓ rag-project __archetype__.json found
→ Validating rag-project metadata JSON... ✓ Metadata is valid JSON
ℹ   All required metadata fields present
...

═══════════════════════════════════════════════════
Phase 6 Test Summary
═══════════════════════════════════════════════════

Total Tests:   60
Passed:        55
Failed:        0
Skipped:       5

Success Rate:  100% (excluding optional features)

✓ All required Phase 6 tests passed!

Phase 6 (Archetypes) Implementation Status:
  ✓ Archetype infrastructure complete
  ✓ Base archetype implemented
  ✓ RAG project archetype implemented
  ✓ API service archetype implemented
  ✓ Monitoring archetype implemented
  ✓ Agentic workflows archetype implemented
  ✓ Composite archetypes implemented
  ✓ Documentation complete
```

## Implementation Status

### Phase 6.0: Infrastructure ✅

- [x] `archetypes/` directory structure
- [x] `__archetype_schema__.json` - Metadata schema v2.0
- [x] `archetypes/README.md` - Comprehensive documentation (669 lines)
- [x] `config/archetypes.json` - Archetype registry

### Phase 6.1: RAG Project Archetype ✅

**Completed Features:**
- [x] Complete directory structure
- [x] `__archetype__.json` with full metadata
- [x] Data models (`config.py`, `document.py`, `search.py`)
- [x] Services (`document_processor.py`, `embeddings.py`, `vector_store.py`, `llm.py`, `rag_pipeline.py`)
- [x] API endpoints (health, documents, search, RAG query)
- [x] Docker Compose with ChromaDB and Ollama
- [x] Comprehensive README (350+ lines)
- [x] Testing structure

**Documented in:** `docs/PHASE6_SUMMARY.md`

### Phase 6.2: API Service Archetype ✅

- [x] FastAPI application structure
- [x] Archetype metadata
- [x] Service definitions
- [x] Documentation

### Phase 6.3: Monitoring Archetype ✅

- [x] Prometheus configuration
- [x] Grafana dashboards
- [x] Loki logging setup
- [x] Docker Compose integration
- [x] Archetype metadata

### Phase 6.4: Agentic Workflows Archetype ✅

- [x] Agent framework structure
- [x] Multi-agent orchestration
- [x] Tool integration capabilities
- [x] Workflow definitions
- [x] Archetype metadata
- [x] Documentation

### Phase 6.5: Composite Archetypes ✅

**composite-rag-agents:**
- [x] Metadata with constituents (rag-project + agentic-workflows)
- [x] Integration script (`integrate_rag_agentic.sh`, 400+ lines)
- [x] Pre-resolved conflicts
- [x] Unified API combining RAG + Agents
- [x] Example scripts (4 Python examples)
- [x] Comprehensive README (600+ lines)
- [x] Examples documentation (400+ lines)

**Other Composites:**
- [x] `composite-api-monitoring`
- [x] `composite-full-stack`

## Archetype Metadata Schema

All archetypes follow the v2.0 metadata schema:

```json
{
  "version": "2.0",
  "metadata": {
    "name": "archetype-name",
    "display_name": "Display Name",
    "description": "...",
    "version": "1.0.0",
    "author": "...",
    "tags": ["tag1", "tag2"],
    "archetype_type": "base|feature|composite"
  },
  "composition": {
    "role": "base|feature",
    "compatible_features": ["feature1", "feature2"],
    "incompatible_with": [],
    "composable": true,
    "service_prefix": "prefix",
    "port_offset": 0
  },
  "dependencies": {
    "preset": "preset-name",
    "additional_tools": [],
    "python": {},
    "system": []
  },
  "services": {
    "service-name": {
      "port": 8000,
      "dockerfile": "Dockerfile",
      "description": "..."
    }
  },
  "gitignore_patterns": []
}
```

## Archetype Directory Structure

### Base Archetype Layout

```
archetypes/<archetype-name>/
├── __archetype__.json          # Metadata
├── README.md                   # Documentation
├── requirements.txt            # Python dependencies
├── docker-compose.yml          # Services (optional)
├── .env.example                # Environment template
├── src/                        # Source code
│   ├── models/                 # Data models
│   ├── services/               # Business logic
│   └── api/                    # API layer (optional)
├── tests/                      # Test suite
│   ├── unit/
│   └── integration/
├── config/                     # Configuration files
├── docs/                       # Additional documentation
└── .vscode/                    # VS Code settings (optional)
```

### Composite Archetype Layout

```
archetypes/<composite-name>/
├── __archetype__.json          # Metadata with constituents
├── README.md                   # Usage documentation
├── scripts/                    # Integration scripts
│   └── integrate_*.sh          # Archetype integration
├── examples/                   # Example applications
│   ├── basic_*.py
│   ├── advanced_*.py
│   └── streaming_*.py
├── docs/                       # Extended documentation
│   ├── EXAMPLES.md
│   ├── ARCHITECTURE.md
│   └── TROUBLESHOOTING.md
└── docker-compose.override.yml # Composite services (optional)
```

## Compatibility Matrix

| Archetype | Type | Compatible With |
|-----------|------|-----------------|
| base | base | (foundation) |
| rag-project | base | monitoring, agentic-workflows, api-gateway |
| api-service | base | monitoring, rag-project |
| monitoring | feature | (any base) |
| agentic-workflows | feature | rag-project, api-service |
| composite-rag-agents | composite | monitoring |
| composite-api-monitoring | composite | - |
| composite-full-stack | composite | - |

## Service Port Allocation

| Archetype | Service | Default Port | Port Offset |
|-----------|---------|--------------|-------------|
| rag-project | API | 8000 | 0 |
| rag-project | ChromaDB | 8001 | 0 |
| rag-project | Ollama | 11434 | 0 |
| monitoring | Prometheus | 9090 | 0 |
| monitoring | Grafana | 3000 | 0 |
| monitoring | Loki | 3100 | 0 |
| agentic-workflows | API | 8010 | +10 |

## Testing Best Practices

### Manual Testing

After implementation changes, manually test:

1. **Metadata Validation:**
   ```powershell
   # Validate all archetype metadata files
   Get-ChildItem archetypes\*\__archetype__.json | ForEach-Object {
       Get-Content $_ | ConvertFrom-Json | Out-Null
       Write-Host "✓ $($_.Directory.Name)"
   }
   ```

2. **Archetype Creation:**
   ```bash
   # Test creating project from archetype
   ./create-project.sh --name test-rag --archetype rag-project

   # Test composite archetype
   ./create-project.sh --name test-composite --archetype composite-rag-agents
   ```

3. **Service Validation:**
   ```bash
   cd test-rag
   docker-compose up -d
   docker-compose ps  # All services should be running
   curl http://localhost:8000/health  # Should return 200 OK
   ```

### Automated Testing

```powershell
# Run all phase tests in sequence
pwsh tests/Test-Phase1.ps1
pwsh tests/Test-Phase2.ps1
pwsh tests/Test-Phase3.ps1
pwsh tests/Test-Phase4.ps1
pwsh tests/Test-Phase6.ps1
```

### CI/CD Integration

```yaml
# .github/workflows/test-archetypes.yml
name: Test Archetypes

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test Phase 6
        run: pwsh tests/Test-Phase6.ps1
```

## Success Criteria

Phase 6 implementation is complete when:

- [x] All infrastructure tests pass (6.0)
- [x] Base archetype validated (6.1)
- [x] RAG archetype complete with all features (6.2)
- [x] API service archetype implemented (6.3)
- [x] Monitoring archetype implemented (6.4)
- [x] Agentic workflows archetype implemented (6.5)
- [x] Composite archetype system working (6.6)
- [x] Service definitions validated (6.7)
- [x] Compatibility matrix defined (6.8)
- [x] Documentation comprehensive (6.9)
- [x] Registry properly configured (6.10)

**Current Status:** ✅ **ALL CRITERIA MET**

## Related Documentation

- `IMPLEMENTATION_STRATEGY.md` - Phase 6 detailed plan
- `PHASE6_SUMMARY.md` - Implementation summary
- `archetypes/README.md` - User guide for archetypes (669 lines)
- `docs/MULTI_ARCHETYPE_COMPOSITION_DESIGN.md` - Design document
- `docs/MULTI_ARCHETYPE_EXAMPLES.md` - Usage examples

## Archetype-Specific Documentation

Each archetype includes:
- `__archetype__.json` - Metadata and configuration
- `README.md` - Usage guide and quickstart
- `docs/` - Extended documentation (some archetypes)
- `examples/` - Example applications (composite archetypes)

## Known Issues and Limitations

### Current Limitations

1. **Port Conflicts:** Manual port offset required when composing multiple base archetypes
2. **Dependency Resolution:** Python package conflicts need manual resolution
3. **Service Health Checks:** Not all Docker Compose files include health checks

### Future Enhancements

- [ ] Automatic port conflict resolution
- [ ] Dependency conflict pre-checking
- [ ] Health check standardization
- [ ] More composite archetype combinations
- [ ] Archetype versioning and updates

## Troubleshooting

### Common Issues

**Issue:** Metadata JSON validation fails
```powershell
# Solution: Check JSON syntax
Get-Content archetypes\<name>\__archetype__.json | ConvertFrom-Json
```

**Issue:** Missing required directories
```powershell
# Solution: Check directory structure
Test-Path archetypes\<name>\src
Test-Path archetypes\<name>\tests
```

**Issue:** Service port conflicts
```bash
# Solution: Check port availability
docker ps --format "{{.Ports}}"
```

## Maintenance

### Adding New Archetypes

1. Create directory structure following standard layout
2. Define `__archetype__.json` metadata
3. Implement source code and tests
4. Add to `config/archetypes.json` registry
5. Document in `archetypes/README.md`
6. Update `Test-Phase6.ps1` with new tests
7. Run test suite to validate

### Updating Existing Archetypes

1. Modify archetype files
2. Update `version` in `__archetype__.json`
3. Update documentation
4. Re-run `Test-Phase6.ps1`
5. Test manual project creation
6. Update PHASE6_SUMMARY.md if needed

## Test Maintenance

This test suite should be updated when:
- Adding new archetypes
- Modifying archetype metadata schema
- Changing directory structure conventions
- Adding new required fields
- Implementing optional features

## Next Steps

1. ✅ Phase 6 complete - all tests passing
2. ⏳ Create additional composite archetypes
3. ⏳ Implement archetype versioning system
4. ⏳ Add archetype update mechanism
