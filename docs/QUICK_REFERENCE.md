# Quick Reference

**One-page cheat sheet for dev environment template and archetype system**

---

## Archetype Commands

```bash
# List all archetypes
./create-project.sh --list-archetypes

# Check compatibility
./create-project.sh --check-compatibility \\
  --archetype rag-project --add-features monitoring

# Preview (dry run)
./create-project.sh --name myapp \\
  --archetype rag-project \\
  --dry-run

# Create project (single archetype)
./create-project.sh --name myapp --archetype rag-project

# Create project (with features)
./create-project.sh --name myapp \\
  --archetype rag-project \\
  --add-features monitoring,agentic-workflows

# Create with GitHub
./create-project.sh --name myapp \\
  --archetype rag-project \\
  --github \\
  --description "My app"
```

---

## Available Archetypes

### Base Archetypes
- **base** - Minimal starter
- **rag-project** - RAG with OpenSearch + Ollama
- **api-service** - Production FastAPI

### Feature Archetypes
- **monitoring** - Prometheus + Grafana
- **agentic-workflows** - AI agent orchestration

### Composite Archetypes
- **composite-rag-agents** - RAG + Agents
- **composite-api-monitoring** - API + Monitoring
- **composite-full-stack** - Complete web app

---

## Docker Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down

# Rebuild
docker-compose build --no-cache

# Enter container
docker-compose exec dev bash

# Clean up
docker system prune -a
```

---

## VS Code Commands

```
# Reopen in container
Cmd/Ctrl+Shift+P → "Reopen in Container"

# Reload window
Cmd/Ctrl+Shift+P → "Developer: Reload Window"

# Open settings
Cmd/Ctrl+,

# Command palette
Cmd/Ctrl+Shift+P
```

---

## Archetype Types

| Type | Role | Example | Use When |
|------|------|---------|----------|
| **Base** | Primary structure | `rag-project` | Main application type |
| **Feature** | Add capability | `monitoring` | Enhance base |
| **Composite** | Pre-packaged | `rag-agentic-system` | Quick start |

---

## Port Offsets

| Archetype | Offset | Example Port |
|-----------|--------|--------------|
| Base | 0 | 8000 |
| Feature 1 | +100 | 8100 |
| Feature 2 | +200 | 8200 |
| Feature 3 | +300 | 8300 |

---

## File Merge Strategies

| File | Strategy | Result |
|------|----------|--------|
| `.env` | Append | All vars combined |
| `Makefile` | Namespace | `rag-run`, `agentic-run` |
| `docker-compose.yml` | Deep merge | All services |
| `requirements.txt` | Resolve | Compatible versions |
| `.gitignore` | Deduplicate | All patterns |
| `README.md` | Sections | Each archetype section |

---

## Conflict Resolution

| Conflict | Auto? | Strategy |
|----------|-------|----------|
| Ports | ✅ Yes | Offset +100 |
| Service names | ✅ Yes | Prefix |
| Dependencies | ⚠️ Mostly | Version intersection |
| Config files | ✅ Yes | Smart merge |
| Directories | ✅ Yes | Recursive merge |
| Makefile | ✅ Yes | Namespace |

---

## Common Combinations

```bash
# RAG + Agents
--archetype rag-project --add-features agentic-workflows

# API + Monitoring
--archetype api-service --add-features monitoring

# ML + MLOps
--archetype ml-training --add-features mlops

# RAG + Gateway + Monitoring
--archetype rag-project --add-features api-gateway,monitoring

# Pre-configured RAG + Agentic
--archetype rag-agentic-system
```

---

## Generated Files

Every multi-archetype project gets:

- `docker-compose.yml` - Base services
- `docker-compose.<archetype>.yml` - Per archetype
- `Makefile` - Namespaced commands
- `.env` - Merged configuration
- `requirements.txt` - Resolved dependencies
- `COMPOSITION.md` - Architecture guide
- `README.md` - Project overview

---

## Makefile Commands

```bash
make start               # Start all services
make stop                # Stop all services
make test                # Run all tests
make logs                # View all logs

make <archetype>-start   # Start one archetype
make <archetype>-test    # Test one archetype
make <archetype>-logs    # Logs for one archetype
```

---

## Troubleshooting

**Port already in use:**
```bash
# Check what's using it
lsof -i :8000

# Change in .env
echo "RAG_API_PORT=8001" >> .env
```

**Service not starting:**
```bash
# Check logs
make logs

# Check status
docker-compose ps

# Restart specific service
docker-compose restart <service>
```

**Dependency conflict:**
```bash
# Check requirements
cat requirements.txt

# Install manually
pip install package==version
```

---

## Best Practices

1. ✅ Start with base archetype
2. ✅ Add features incrementally
3. ✅ Check compatibility first
4. ✅ Use dry-run to preview
5. ✅ Read COMPOSITION.md after creation
6. ✅ Test each archetype separately
7. ✅ Use composite for common patterns

---

## File Locations

| What | Where |
|------|-------|
| Archetypes | `archetypes/` |
| Metadata | `archetypes/<name>/__archetype__.json` |
| Scripts | `scripts/` |
| Docs | `docs/` |
| Examples | `docs/MULTI_ARCHETYPE_EXAMPLES.md` |

---

## Getting Help

```bash
# List archetypes
./create-project.sh --list-archetypes

# Check compatibility
./create-project.sh --check-compatibility \
  --archetype base --add-features feature

# Preview
./create-project.sh --dry-run ...

# Read docs
cat MULTI_ARCHETYPE_COMPOSITION_DESIGN.md
cat docs/MULTI_ARCHETYPE_EXAMPLES.md
cat archetypes/README.md
```

---

## Quick Decision Tree

```
Need multiple archetypes?
├─ Common pattern? → Use composite (--archetype rag-agentic-system)
├─ Primary + enhancements? → Use layered (--archetype base --add-features f1,f2)
└─ Multiple equals? → Use modular (--archetypes a1,a2,a3) [v2.1+]
```

---

## Version Info

- **Current:** v1.0 (single archetype only)
- **v2.0:** Layered + Composite (12 weeks)
- **v2.1:** Modular composition (future)

---

**Full Documentation:**
- Design: `MULTI_ARCHETYPE_COMPOSITION_DESIGN.md`
- Examples: `docs/MULTI_ARCHETYPE_EXAMPLES.md`
- Implementation: `docs/IMPLEMENTATION_GUIDE.md`
- Comparison: `docs/STRATEGY_COMPARISON.md`
