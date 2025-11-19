# Multi-Archetype Composition: Implementation Guide

**Quick reference for implementing the multi-archetype composition system**

## Implementation Phases

### ✅ Phase 1: Core Infrastructure (2 weeks)

**Priority: HIGH | Status: Ready for implementation**

#### Tasks

1. **Update `create-project.sh`**
   - Add `--archetype` flag
   - Add `--add-features` flag
   - Add `--list-archetypes` flag
   - Add `--check-compatibility` flag
   - Add `--dry-run` flag

2. **Create archetype loader** (`scripts/archetype-loader.sh`)
   - Load `__archetype__.json` metadata
   - Validate archetype structure
   - List available archetypes
   - Check compatibility

3. **Create conflict resolver** (`scripts/conflict-resolver.sh`)
   - Detect port conflicts
   - Detect service name conflicts
   - Detect dependency conflicts
   - Generate conflict reports

#### Code Changes

**File: `create-project.sh`**

Add new flags to argument parser:

```bash
# Around line 30, add new variables
BASE_ARCHETYPE=""
FEATURE_ARCHETYPES=()
LIST_ARCHETYPES=false
CHECK_COMPAT=false
DRY_RUN=false

# Around line 150, add new cases
case $1 in
    --archetype)
        BASE_ARCHETYPE="$2"
        shift 2
        ;;
    --add-features)
        IFS=',' read -ra FEATURE_ARCHETYPES <<< "$2"
        shift 2
        ;;
    --list-archetypes)
        LIST_ARCHETYPES=true
        shift
        ;;
    --check-compatibility)
        CHECK_COMPAT=true
        shift
        ;;
    --dry-run)
        DRY_RUN=true
        shift
        ;;
    # ... existing cases
esac
```

Add archetype processing to main():

```bash
main() {
    parse_args "$@"

    # List archetypes if requested
    if [ "$LIST_ARCHETYPES" = true ]; then
        source scripts/archetype-loader.sh
        list_archetypes
        exit 0
    fi

    # Check compatibility if requested
    if [ "$CHECK_COMPAT" = true ]; then
        source scripts/archetype-loader.sh
        for feature in "${FEATURE_ARCHETYPES[@]}"; do
            check_compatibility "$BASE_ARCHETYPE" "$feature"
        done
        exit 0
    fi

    # Validate project name (existing)
    # ... existing code

    # Process archetypes
    if [ -n "$BASE_ARCHETYPE" ]; then
        process_archetypes
    fi

    # ... rest of existing code
}

process_archetypes() {
    print_header "Processing Archetypes"

    # Load base archetype
    source scripts/archetype-loader.sh
    BASE_METADATA=$(load_archetype "$BASE_ARCHETYPE")

    # Load feature archetypes
    FEATURE_METADATA=()
    for feature in "${FEATURE_ARCHETYPES[@]}"; do
        FEATURE_METADATA+=($(load_archetype "$feature"))
    done

    # Detect conflicts
    source scripts/conflict-resolver.sh
    generate_conflict_report "$BASE_METADATA" "${FEATURE_METADATA[@]}"

    # Apply base archetype
    apply_base_archetype "$BASE_ARCHETYPE"

    # Apply feature archetypes with conflict resolution
    local offset=100
    for feature in "${FEATURE_ARCHETYPES[@]}"; do
        apply_feature_archetype "$feature" "$offset"
        offset=$((offset + 100))
    done

    print_success "Archetypes processed"
}

apply_base_archetype() {
    local archetype=$1
    print_info "Applying base archetype: $archetype"

    # Copy archetype files
    rsync -av --exclude='__archetype__.json' \
        "archetypes/$archetype/" "$FULL_PROJECT_PATH/"

    # Process docker-compose
    if [ -f "archetypes/$archetype/docker-compose.yml" ]; then
        cp "archetypes/$archetype/docker-compose.yml" \
           "$FULL_PROJECT_PATH/docker-compose.$archetype.yml"
    fi

    print_success "Base archetype applied"
}

apply_feature_archetype() {
    local feature=$1
    local offset=$2
    print_info "Applying feature: $feature (offset: +$offset)"

    # Copy feature files
    rsync -av --exclude='__archetype__.json' \
        "archetypes/$feature/" "$FULL_PROJECT_PATH/"

    # Copy and resolve docker-compose
    if [ -f "archetypes/$feature/docker-compose.yml" ]; then
        cp "archetypes/$feature/docker-compose.yml" \
           "$FULL_PROJECT_PATH/docker-compose.$feature.yml"

        # Apply port offset
        source scripts/conflict-resolver.sh
        resolve_port_conflicts \
            "$FULL_PROJECT_PATH/docker-compose.$feature.yml" \
            "$offset"

        # Apply service prefix
        local prefix=$(jq -r '.composition.service_prefix' \
            "archetypes/$feature/__archetype__.json")
        resolve_service_name_conflicts \
            "$FULL_PROJECT_PATH/docker-compose.$feature.yml" \
            "$prefix"
    fi

    print_success "Feature applied: $feature"
}
```

#### Testing

```bash
# Test 1: List archetypes
./create-project.sh --list-archetypes

# Test 2: Check compatibility
./create-project.sh --check-compatibility \
  --archetype rag-project \
  --add-features agentic-workflows

# Test 3: Dry run
./create-project.sh --name test1 \
  --archetype rag-project \
  --add-features agentic-workflows \
  --dry-run

# Test 4: Create project
./create-project.sh --name test1 \
  --archetype rag-project \
  --add-features agentic-workflows \
  --git
```

---

### 🔄 Phase 2: File Merging (2 weeks)

**Priority: HIGH | Status: Depends on Phase 1**

#### Tasks

1. **Create `.env` merger** (`scripts/env-merger.sh`)
2. **Create `Makefile` merger** (`scripts/makefile-merger.sh`)
3. **Create Docker Compose merger** (`scripts/docker-compose-merger.sh`)
4. **Create source file merger** (`scripts/source-file-merger.sh`)

#### Implementation: `.env` Merger

**File: `scripts/env-merger.sh`**

```bash
#!/bin/bash

merge_env_files() {
    local output_file=$1
    shift
    local input_files=("$@")

    echo "# Multi-Archetype Environment Configuration" > "$output_file"
    echo "# Generated: $(date)" >> "$output_file"
    echo "" >> "$output_file"

    for input in "${input_files[@]}"; do
        local archetype=$(basename $(dirname "$input"))
        echo "# ===== $archetype Configuration =====" >> "$output_file"
        cat "$input" >> "$output_file"
        echo "" >> "$output_file"
    done

    echo "# ===== Shared Configuration =====" >> "$output_file"
    echo "LOG_LEVEL=INFO" >> "$output_file"
}
```

#### Implementation: `Makefile` Merger

**File: `scripts/makefile-merger.sh`**

```bash
#!/bin/bash

merge_makefiles() {
    local output_file=$1
    shift
    local input_files=("$@")

    echo ".PHONY: help start stop test logs" > "$output_file"
    echo "" >> "$output_file"

    # Add help target
    echo "help:" >> "$output_file"
    echo "	@echo 'Available targets:'" >> "$output_file"
    echo "	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' \$(MAKEFILE_LIST) | \\" >> "$output_file"
    echo "		awk 'BEGIN {FS = \":.*?## \"}; {printf \"  \\033[36m%-20s\\033[0m %s\\n\", \$\$1, \$\$2}'" >> "$output_file"
    echo "" >> "$output_file"

    # Add namespaced targets from each archetype
    for input in "${input_files[@]}"; do
        local archetype=$(basename $(dirname "$input"))
        local prefix="${archetype//-/_}"

        echo "# ===== $archetype Targets =====" >> "$output_file"

        # Read input Makefile and add prefix
        while IFS= read -r line; do
            if [[ $line =~ ^[a-zA-Z_-]+: ]]; then
                local target=$(echo "$line" | cut -d':' -f1)
                echo "${prefix}_${line}" >> "$output_file"
            elif [[ ! $line =~ ^\.PHONY ]]; then
                echo "$line" >> "$output_file"
            fi
        done < "$input"

        echo "" >> "$output_file"
    done

    # Add composite targets
    echo "# ===== Composite Targets =====" >> "$output_file"
    echo "start: $(for f in "${input_files[@]}"; do \
        echo -n "$(basename $(dirname "$f") | tr '-' '_')_start "; done)" >> "$output_file"
    echo "	@echo '✓ All services started'" >> "$output_file"
}
```

---

### 🔧 Phase 3: Dependency Resolution (1 week)

**Priority: MEDIUM | Status: Depends on Phase 2**

#### Tools Required

- `pip-tools` for Python
- `npm-check-updates` for Node.js (optional)

#### Implementation

**File: `scripts/dependency-resolver.sh`**

```bash
#!/bin/bash

resolve_python_dependencies() {
    local output_file=$1
    shift
    local metadata_files=("$@")

    # Create temporary requirements.in file
    local temp_in=$(mktemp --suffix=.in)

    # Collect all dependencies with version specs
    for metadata in "${metadata_files[@]}"; do
        jq -r '.dependencies.python | to_entries[] |
            "\(.key)\(.value)"' "$metadata" >> "$temp_in"
    done

    # Use pip-compile to resolve
    if command -v pip-compile &> /dev/null; then
        pip-compile "$temp_in" -o "$output_file" --quiet --resolver=backtracking
    else
        # Fallback
        sort -u "$temp_in" > "$output_file"
    fi

    rm "$temp_in"
}
```

---

### 📚 Phase 4: Documentation & UX (1 week)

**Priority: MEDIUM | Status: Depends on Phase 3**

#### Tasks

1. **Auto-generate `COMPOSITION.md`**
2. **Add interactive prompts**
3. **Create usage guide**

#### Implementation: COMPOSITION.md Generator

**File: `scripts/documentation-generator.sh`**

```bash
#!/bin/bash

generate_composition_doc() {
    local output_file=$1
    local base_archetype=$2
    shift 2
    local feature_archetypes=("$@")

    cat > "$output_file" << EOF
# Project Composition Guide

This project combines multiple archetypes:

## Archetypes Used

### Base: $base_archetype
$(jq -r '.metadata.description' "archetypes/$base_archetype/__archetype__.json")

**Services:**
$(jq -r '.services | keys[]' "archetypes/$base_archetype/__archetype__.json" | sed 's/^/- /')

**Ports:**
$(jq -r '.conflicts.declare.ports[]' "archetypes/$base_archetype/__archetype__.json" | sed 's/^/- /')

EOF

    for feature in "${feature_archetypes[@]}"; do
        cat >> "$output_file" << EOF

### Feature: $feature
$(jq -r '.metadata.description' "archetypes/$feature/__archetype__.json")

**Services:**
$(jq -r '.services | keys[]' "archetypes/$feature/__archetype__.json" | sed 's/^/- /')

EOF
    done

    cat >> "$output_file" << EOF

## Quick Start

\`\`\`bash
# Start all services
make start

# View logs
make logs

# Stop all
make stop
\`\`\`

## Service URLs

$(generate_service_urls "$base_archetype" "${feature_archetypes[@]}")

EOF
}
```

---

### 🏗️ Phase 5: Create Archetypes (2 weeks)

**Priority: HIGH | Status: Can start in parallel with Phase 1-4**

#### Archetypes to Create

1. **rag-project** (base) - See `archetypes/rag-project/__archetype__.json`
2. **agentic-workflows** (feature)
3. **monitoring** (feature)
4. **api-gateway** (feature)
5. **rag-agentic-system** (composite)

#### Template: Feature Archetype

**File: `archetypes/monitoring/__archetype__.json`**

```json
{
  "version": "2.0",
  "metadata": {
    "name": "monitoring",
    "display_name": "Monitoring & Observability",
    "description": "Prometheus, Grafana, and Alertmanager for observability",
    "archetype_type": "feature"
  },
  "composition": {
    "role": "feature",
    "compatible_bases": ["*"],
    "service_prefix": "monitoring",
    "port_offset": 200
  },
  "dependencies": {
    "additional_tools": ["prometheus", "grafana"]
  },
  "conflicts": {
    "declare": {
      "ports": [9090, 3000, 9093],
      "services": ["prometheus", "grafana", "alertmanager"]
    },
    "resolution": {
      "ports": "offset",
      "services": "prefix"
    }
  },
  "services": {
    "prometheus": {
      "image": "prom/prometheus:latest",
      "ports": ["9090:9090"],
      "volumes": ["./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml"]
    },
    "grafana": {
      "image": "grafana/grafana:latest",
      "ports": ["3000:3000"],
      "environment": {
        "GF_SECURITY_ADMIN_PASSWORD": "admin"
      }
    }
  }
}
```

---

### 🚀 Phase 6: Testing & Release (2 weeks)

**Priority: HIGH | Status: Final phase**

#### Test Plan

1. **Unit Tests**
   ```bash
   # Test archetype loader
   ./scripts/archetype-loader.sh --validate rag-project

   # Test conflict resolver
   ./scripts/conflict-resolver.sh --detect \
     archetypes/rag-project/__archetype__.json \
     archetypes/agentic-workflows/__archetype__.json
   ```

2. **Integration Tests**
   ```bash
   # Create all example projects
   ./create-project.sh --name test-rag --archetype rag-project
   ./create-project.sh --name test-rag-agentic \
     --archetype rag-project --add-features agentic-workflows
   ```

3. **Performance Tests**
   ```bash
   # Measure project creation time
   time ./create-project.sh --name perf-test --archetype rag-project
   ```

---

## Quick Commands

### Development

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Test archetype loader
./scripts/archetype-loader.sh --list

# Validate archetype
./scripts/archetype-loader.sh --validate rag-project

# Test conflict detection
./scripts/conflict-resolver.sh --detect \
  archetypes/base/__archetype__.json \
  archetypes/rag-project/__archetype__.json
```

### Testing

```bash
# Create test project
./create-project.sh --name test1 \
  --archetype rag-project \
  --add-features agentic-workflows

# Verify structure
cd test1
ls -la
cat COMPOSITION.md
cat Makefile
cat docker-compose*.yml

# Start services
make start

# Check services
docker-compose ps

# Clean up
cd ..
rm -rf test1
```

---

## Checklist

### Phase 1: Core Infrastructure
- [ ] Update `create-project.sh` with new flags
- [ ] Create `scripts/archetype-loader.sh`
- [ ] Create `scripts/conflict-resolver.sh`
- [ ] Test archetype listing
- [ ] Test compatibility checking
- [ ] Test project creation with single archetype

### Phase 2: File Merging
- [ ] Create `scripts/env-merger.sh`
- [ ] Create `scripts/makefile-merger.sh`
- [ ] Create `scripts/docker-compose-merger.sh`
- [ ] Create `scripts/source-file-merger.sh`
- [ ] Test `.env` merging
- [ ] Test `Makefile` merging
- [ ] Test Docker Compose merging

### Phase 3: Dependency Resolution
- [ ] Install `pip-tools`
- [ ] Create `scripts/dependency-resolver.sh`
- [ ] Test Python dependency resolution
- [ ] Handle version conflicts

### Phase 4: Documentation
- [ ] Create `scripts/documentation-generator.sh`
- [ ] Auto-generate `COMPOSITION.md`
- [ ] Create usage guide
- [ ] Add examples

### Phase 5: Create Archetypes
- [ ] Create `base` archetype
- [ ] Create `rag-project` archetype
- [ ] Create `agentic-workflows` archetype
- [ ] Create `monitoring` archetype
- [ ] Create `rag-agentic-system` composite

### Phase 6: Testing & Release
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Performance testing
- [ ] Documentation review
- [ ] Release v2.0.0

---

## Estimated Timeline

| Phase | Duration | Dependencies | Priority |
|-------|----------|--------------|----------|
| Phase 1 | 2 weeks | None | HIGH |
| Phase 2 | 2 weeks | Phase 1 | HIGH |
| Phase 3 | 1 week | Phase 2 | MEDIUM |
| Phase 4 | 1 week | Phase 3 | MEDIUM |
| Phase 5 | 2 weeks | None (parallel) | HIGH |
| Phase 6 | 2 weeks | All above | HIGH |

**Total: 10-12 weeks** (with some parallel work)

---

## Support

For questions or issues:
1. Check `MULTI_ARCHETYPE_COMPOSITION_DESIGN.md`
2. Review `docs/MULTI_ARCHETYPE_EXAMPLES.md`
3. Open GitHub issue
4. Join discussions

---

**Ready to implement!** 🚀
