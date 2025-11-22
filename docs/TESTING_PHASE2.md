# Phase 2 Testing Guide - Git Integration

## Quick Test

To verify Phase 2 implementation:

```powershell
.\tests\Test-Phase2.ps1
```

## Expected Results

✅ **22/22 tests passed (100%)**

## What's Being Tested

### 2.1 Git Initialization is Now Default

- [x] `SKIP_GIT` variable added (replaces `USE_GIT=false`)
- [x] `--no-git` opt-out flag implemented
- [x] `--git` flag removed (no longer needed)

### 2.2 Smart Commit Message Generator

- [x] `scripts/git-helper.sh` exists
- [x] `generate_commit_message()` creates detailed commit messages
- [x] `list_archetypes_with_versions()` extracts archetype metadata
- [x] `list_services_from_archetypes()` lists services
- [x] `get_template_version()` retrieves version info

### 2.3 Git Initialization Function

- [x] `initialize_git_repository()` handles complete Git setup
- [x] Error handling for failed Git operations
- [x] Git availability check before operations

### 2.4 Smart .gitignore Generator

- [x] `scripts/gitignore-generator.sh` exists
- [x] `generate_gitignore()` creates comprehensive .gitignore
- [x] `generate_base_gitignore()` provides base patterns
- [x] `get_archetype_patterns()` extracts archetype-specific patterns
- [x] `add_tool_patterns()` adds tool-specific patterns
- [x] Patterns for PostgreSQL, OpenSearch, Ollama, Airflow, etc.

### 2.5 Integration into Main Flow

- [x] `git-helper.sh` sourced in `create-project.sh`
- [x] `gitignore-generator.sh` sourced
- [x] `.gitignore` generation integrated into project creation
- [x] Smart Git initialization called with archetype context
- [x] Archetype and tool information passed to Git functions

## Manual Testing

### 1. Test Automatic Git Initialization

```bash
# Create a test project (Git should init automatically)
bash create-project.sh --name test-git-auto --tools fastapi,postgresql

# Verify Git was initialized
cd ../test-git-auto
git log --oneline
```

Expected: Git repository initialized with a detailed commit message including tools and archetypes.

### 2. Test --no-git Flag

```bash
# Create project without Git
bash create-project.sh --name test-no-git --tools langchain --no-git

# Verify no Git repo
cd ../test-no-git
ls -la .git
```

Expected: No `.git` directory should exist.

### 3. Test Smart Commit Message

```bash
# Create project with archetypes
bash create-project.sh --name test-commit --archetype base --add-features rag-project

cd ../test-commit
git log --format=full
```

Expected commit message should include:

- Project name
- Template version
- Archetypes with versions
- Services from archetypes
- Tools/configuration
- Generation timestamp

### 4. Test Smart .gitignore

```bash
# Create project with various tools
bash create-project.sh --name test-gitignore --tools postgresql,opensearch,ollama

# Check .gitignore content
cd ../test-gitignore
cat .gitignore
```

Expected: .gitignore should contain:

- Base patterns (Python, Node, etc.)
- PostgreSQL-specific patterns (`postgres-data/`)
- OpenSearch-specific patterns (`opensearch-data/`)
- Ollama-specific patterns (`ollama-data/`)

### 5. Test Git Helper Functions

```bash
# Source the git-helper script
source scripts/git-helper.sh

# Test version retrieval
get_template_version

# Test commit message generation
generate_commit_message "TestProject" "base rag-project" "fastapi postgresql" ""
```

Expected: Functions work independently and produce formatted output.

## Feature Highlights

### ✅ Automatic Git Initialization

Every new project gets a Git repository by default:

- No need to manually run `git init`
- Comprehensive initial commit created automatically
- Use `--no-git` to opt out if needed

### ✅ Smart Commit Messages

Initial commits now include:

```
Initial commit: my-project

Project created from dev-environment-template v1.0.0

Archetypes:
  - base (1.0.0)
  - rag-project (1.0.0)

Services:
  - opensearch (from rag-project)
  - ollama (from rag-project)
  - fastapi (from rag-project)

Tools/Configuration:
  Preset: ai-agent
  Tools: langchain, postgresql

---
Generated: 2025-11-19 12:34:56
Template: https://github.com/mazelb/dev-environment-template
```

### ✅ Archetype-Aware .gitignore

Generated .gitignore files include:

- **Base patterns**: Python, Node.js, IDE files
- **Archetype patterns**: From archetype metadata
- **Tool patterns**: Database data dirs, service-specific files
- **Custom section**: For project-specific additions

### ✅ Robust Error Handling

- Checks if Git is installed before operations
- Graceful fallback if helpers unavailable
- Clear error messages and warnings

## Success Criteria (from Implementation Strategy)

- [x] Every new project has `.git/` directory
- [x] Initial commit includes all files
- [x] Commit message includes archetype metadata
- [x] `.gitignore` is comprehensive and archetype-aware
- [x] `--no-git` flag works correctly

## Troubleshooting

### "Git not found" Warning

Git is not installed or not in PATH. Install Git:

- Windows: Download from [git-scm.com](https://git-scm.com)
- macOS: `brew install git`
- Linux: `apt-get install git` or `yum install git`

### Smart Features Not Working

If Git initialization falls back to basic mode, check that helper scripts are sourced:

```bash
grep "source.*git-helper" create-project.sh
```

### .gitignore Missing Tool Patterns

Ensure tools are passed correctly to the generator. Check the `generate_gitignore` call includes tool list.

## Next Steps

Phase 2 is complete! Next up:

**Phase 3: Multi-Archetype Core**

- Conflict detection (ports, service names, dependencies)
- Port offset resolver
- Service name prefixing
- Multi-archetype CLI flags
- Archetype composition logic
- Compatibility checking

See `docs/IMPLEMENTATION_STRATEGY.md` for Phase 3 details.
