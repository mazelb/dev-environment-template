# Phase 5 Testing Documentation: GitHub Integration

## Overview

This document describes the test suite for **Phase 5: GitHub Integration** as defined in `IMPLEMENTATION_STRATEGY.md`. Phase 5 adds GitHub CLI integration for automatic repository creation and initial push.

**Status:** ⚠️ **Phase 5 NOT YET IMPLEMENTED** - Test suite documents what should be tested when implementation is complete.

## Test File

- **Location:** `tests/Test-Phase5.ps1`
- **Type:** PowerShell test script
- **Purpose:** Validate GitHub integration features
- **Execution:** `pwsh tests/Test-Phase5.ps1`

## Test Coverage

### 5.1 GitHub Repository Creator Script (7 tests)

Tests the core GitHub repository creation functionality:

| Test | Description | Validates |
|------|-------------|-----------|
| 5.1.1 | Script exists | `scripts/github-repo-creator.sh` file present |
| 5.1.2 | Main function | `create_github_repo()` function exists |
| 5.1.3 | gh CLI check | Prerequisites check for GitHub CLI |
| 5.1.4 | Authentication check | Verifies `gh auth status` check |
| 5.1.5 | Configuration function | `configure_repo_settings()` exists |

**Expected State:** ❌ All tests FAIL (not implemented)

### 5.2 GitHub CLI Flags (8 tests)

Tests command-line flag parsing in `create-project.sh`:

| Flag | Variable | Description |
|------|----------|-------------|
| `--github` | `CREATE_GITHUB_REPO` | Enable GitHub repo creation |
| `--github-org ORG` | `GITHUB_ORG` | Organization/username |
| `--private` | `GITHUB_VISIBILITY="private"` | Private repository |
| `--public` | `GITHUB_VISIBILITY="public"` | Public repository |
| `--description TEXT` | `GITHUB_DESCRIPTION` | Repository description |

**Expected State:** ❌ All tests FAIL (not implemented)

### 5.3 Integration into Main Flow (3 tests)

Tests integration of GitHub creation into project creation workflow:

| Test | Validates |
|------|-----------|
| 5.3.1 | `github-repo-creator.sh` sourced in `create-project.sh` |
| 5.3.2 | `create_github_repo()` called in main flow |
| 5.3.3 | GitHub creation is conditional on `CREATE_GITHUB_REPO` flag |

**Expected State:** ❌ All tests FAIL (not implemented)

### 5.4 Help Text and Documentation (1 test)

Tests that help text documents GitHub flags:

| Test | Validates |
|------|-----------|
| 5.4.1 | `--github` flag documented in help text |

**Expected State:** ❌ Test FAIL (not implemented)

### 5.5 Error Handling and Graceful Degradation (3 tests)

Tests error handling for missing prerequisites:

| Test | Error Scenario | Expected Behavior |
|------|----------------|-------------------|
| 5.5.1 | gh CLI not installed | Error message + helpful link |
| 5.5.2 | Not authenticated | Error message + `gh auth login` instruction |
| 5.5.3 | Missing prerequisites | Script continues without GitHub creation |

**Expected State:** ⊘ Tests SKIPPED (script doesn't exist)

### 5.6 CI/CD Workflow Templates (3 tests, optional)

Tests optional CI/CD workflow generation:

| Test | File | Purpose |
|------|------|---------|
| 5.6.1 | `templates/.github/workflows/` | Workflows directory |
| 5.6.2 | `templates/.github/workflows/ci.yml` | CI workflow template |
| 5.6.3 | `templates/.github/workflows/docker-build.yml` | Docker build workflow |

**Expected State:** ⊘ Tests SKIPPED (optional features)

### 5.7 Documentation (3 tests)

Tests GitHub integration documentation:

| Test | File | Content Validates |
|------|------|-------------------|
| 5.7.1 | `docs/GIT_GITHUB_INTEGRATION.md` | File exists |
| 5.7.2 | Documentation coverage | `--github` flag documented |
| 5.7.3 | Setup instructions | `gh auth login` documented |

**Expected State:** ✅ Tests PASS (documentation exists, even though implementation doesn't)

## Test Execution

### Running Tests

```powershell
# Run Phase 5 tests
pwsh tests/Test-Phase5.ps1
```

### Expected Output

```
╔════════════════════════════════════════╗
║ Test 5.1: GitHub Repository Creator Script
╚════════════════════════════════════════╝
→ Checking if github-repo-creator.sh exists... ✗ github-repo-creator.sh NOT FOUND (Phase 5 not implemented)
→ Checking for create_github_repo function... ⊘ Script doesn't exist - cannot check function
...

═══════════════════════════════════════════════════
Phase 5 Test Summary
═══════════════════════════════════════════════════

Total Tests:   25
Passed:        3
Failed:        12
Skipped:       10

Success Rate:  20.0%

⚠ IMPORTANT: Phase 5 (GitHub Integration) is NOT YET IMPLEMENTED
ℹ These tests document what should be tested when Phase 5 is implemented.
ℹ See IMPLEMENTATION_STRATEGY.md Phase 5 for implementation details.

ℹ Next Steps:
  1. Implement scripts/github-repo-creator.sh
  2. Add --github, --github-org, --private, --public flags to create-project.sh
  3. Integrate GitHub creation into main flow
  4. Re-run this test suite to validate implementation
```

## Implementation Status

### What's Documented (✅)

- `docs/GIT_GITHUB_INTEGRATION.md` - Comprehensive GitHub integration guide
- `docs/IMPLEMENTATION_CHECKLIST_GIT.md` - Implementation checklist
- `docs/IMPLEMENTATION_STRATEGY.md` Phase 5 - Detailed implementation plan

### What's NOT Implemented (❌)

1. **`scripts/github-repo-creator.sh`**
   - `create_github_repo()` function
   - `configure_repo_settings()` function
   - Error handling for missing gh CLI
   - Error handling for authentication

2. **`create-project.sh` modifications**
   - `--github` flag
   - `--github-org ORG` flag
   - `--private` flag
   - `--public` flag
   - `--description TEXT` flag
   - Sourcing `github-repo-creator.sh`
   - Calling `create_github_repo()` in main flow

3. **CI/CD templates (optional)**
   - `.github/workflows/ci.yml`
   - `.github/workflows/docker-build.yml`

## Implementation Checklist

To implement Phase 5 and pass all tests:

### Step 1: Create `scripts/github-repo-creator.sh`

```bash
#!/bin/bash

create_github_repo() {
    local project_name=$1
    local github_org=$2
    local visibility=$3  # public or private
    local description=$4
    local project_path=$5

    # Check gh CLI installed
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not found"
        print_info "Install: https://cli.github.com/"
        return 1
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated"
        print_info "Run: gh auth login"
        return 1
    fi

    # Create repository
    cd "$project_path"

    local repo_name="$project_name"
    if [ -n "$github_org" ]; then
        repo_name="$github_org/$project_name"
    fi

    gh repo create "$repo_name" \
        --$visibility \
        --description "$description" \
        --source=. \
        --remote=origin \
        --push

    if [ $? -eq 0 ]; then
        configure_repo_settings "$repo_name"
        return 0
    else
        print_error "Failed to create GitHub repository"
        return 1
    fi
}

configure_repo_settings() {
    local repo_name=$1

    # Enable issues and projects
    gh repo edit "$repo_name" \
        --enable-issues \
        --enable-projects \
        --delete-branch-on-merge

    # Add topics (extract from archetype metadata)
    # gh repo edit "$repo_name" --add-topic rag --add-topic ai
}
```

### Step 2: Add flags to `create-project.sh`

```bash
# Add to variable declarations
CREATE_GITHUB_REPO=false
GITHUB_ORG=""
GITHUB_VISIBILITY="public"
GITHUB_DESCRIPTION=""

# Add to argument parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        --github)
            CREATE_GITHUB_REPO=true
            shift
            ;;
        --github-org)
            GITHUB_ORG="$2"
            shift 2
            ;;
        --private)
            GITHUB_VISIBILITY="private"
            shift
            ;;
        --public)
            GITHUB_VISIBILITY="public"
            shift
            ;;
        --description)
            GITHUB_DESCRIPTION="$2"
            shift 2
            ;;
        # ... other flags
    esac
done
```

### Step 3: Source and call in main flow

```bash
# Source the script
if [ -f "$SCRIPT_DIR/scripts/github-repo-creator.sh" ]; then
    source "$SCRIPT_DIR/scripts/github-repo-creator.sh"
fi

# In main() function, after Git initialization
if [ "$CREATE_GITHUB_REPO" = true ]; then
    create_github_repo \
        "$PROJECT_NAME" \
        "$GITHUB_ORG" \
        "$GITHUB_VISIBILITY" \
        "$GITHUB_DESCRIPTION" \
        "$FULL_PROJECT_PATH"
fi
```

### Step 4: Update help text

Add documentation for new flags to `show_help()` function.

### Step 5: Re-run tests

```powershell
pwsh tests/Test-Phase5.ps1
```

Expected: All tests should pass (except optional CI/CD workflow tests).

## Success Criteria

Phase 5 implementation is complete when:

- [ ] All 22 required tests pass (excluding optional CI/CD tests)
- [ ] `--github` flag creates GitHub repository
- [ ] Repository settings configured automatically
- [ ] Initial commit pushed successfully
- [ ] Error handling works for all failure modes
- [ ] Help text documents all GitHub flags
- [ ] Graceful degradation when gh CLI not available

## Related Documentation

- `IMPLEMENTATION_STRATEGY.md` - Phase 5 detailed plan
- `GIT_GITHUB_INTEGRATION.md` - User guide for GitHub integration
- `IMPLEMENTATION_CHECKLIST_GIT.md` - Implementation checklist
- `Test-Phase2.ps1` - Git integration tests (prerequisite)

## Testing Best Practices

1. **Run tests before implementation** to understand requirements
2. **Implement incrementally** and re-run tests frequently
3. **Test manually** with real GitHub repositories (use test account)
4. **Check error handling** by testing without gh CLI, without auth, etc.
5. **Document any deviations** from the test suite expectations

## Naming Clarification

⚠️ **Important:** There's a naming discrepancy in the repository:

- **`docs/PHASE5_SUMMARY.md`**: Documents testing/validation work (creating Test-Phase4.ps1), NOT GitHub integration
- **`IMPLEMENTATION_STRATEGY.md` Phase 5**: GitHub Integration (what this test suite covers)

This test suite (`Test-Phase5.ps1`) follows the **IMPLEMENTATION_STRATEGY.md** phase numbering, which is the authoritative source for phase definitions.

## Next Steps

1. Review `IMPLEMENTATION_STRATEGY.md` Phase 5 section
2. Follow implementation checklist above
3. Implement `scripts/github-repo-creator.sh`
4. Add flags to `create-project.sh`
5. Re-run test suite to validate
6. Update this document with actual test results
7. Consider implementing optional CI/CD workflow templates

## Maintenance

When Phase 5 is implemented:

1. Update this document with actual test results
2. Remove "NOT YET IMPLEMENTED" warnings
3. Add screenshots or example outputs
4. Document any implementation variations
5. Add troubleshooting section if needed
