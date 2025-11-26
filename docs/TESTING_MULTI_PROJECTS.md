# Multi-Project Archetype & Composite Test Workflow

This document explains how to run the automated matrix test that creates projects for each archetype and composite, builds Docker services, validates container startup, and tears them down.

## Scripts

| Script | Purpose | Platform |
|--------|---------|----------|
| `tests/test-multi-project-workflow.sh` | Bash workflow (WSL/Git Bash) | Linux/WSL |
| `tests/Test-MultiProjectWorkflow.ps1` | PowerShell workflow | Windows |

## What is Tested

1. Base archetypes: `base`, `rag-project`, `api-service`, `monitoring`
2. Feature archetypes (composed): `agentic-workflows` (with `rag-project`)
3. Monitoring as feature with RAG (`rag-with-monitoring`)
4. Composite archetypes: `composite-rag-agents`, `composite-api-monitoring`, `composite-full-stack`
5. Fallback composition if composite direct creation fails (using predefined base + features map)
6. Docker build & container startup (counts running containers)
7. Clean teardown (`docker-compose down -v`) to release resources

## Output

A summary table prints each project and result:

```
rag-project                    : PASS
agentic-workflows-composed     : PASS
composite-rag-agents           : PASS
composite-full-stack-fallback  : PASS
... etc
```

Failure states include: `CREATE_FAIL`, `DOCKER_FAIL`, `RUNNING_ZERO`, `NO_COMPOSE`.

## Requirements

- Docker Desktop running
- Adequate disk & network resources
- WSL (for Bash script) due to Windows path translation constraints in `create-project.sh`
- Git Bash acceptable if WSL path mapping works

## Usage

### Bash (WSL)
```bash
cd dev-environment-template
bash tests/test-multi-project-workflow.sh
```

### PowerShell
```powershell
cd dev-environment-template
pwsh tests/Test-MultiProjectWorkflow.ps1
```

## Test Folder Location

Projects are created in a parent-level folder:
```
../archetype-matrix-tests/
```
Relative to repository root. Each project folder is removed and recreated per run.

## Adjustments

- Add/remove archetypes in `ARCHETYPES` or `COMPOSITES` arrays (bash) or `$Archetypes` / `$Composites` (PowerShell).
- Update fallback map when introducing new composite patterns.
- Set env var `SKIP_BUILD=1` (future enhancement) to skip Docker builds for faster dry runs.

## Exit Codes

- `0` if all PASS / SKIP
- `1` if any failure state occurs

## Next Enhancements

- Parallel builds (GNU Parallel)
- Container health endpoint validation
- Log tailing on failure
- Timing metrics per build

---
Generated automatically by multi-project workflow integration.
