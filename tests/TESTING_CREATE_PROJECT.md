# Create Project Testing Guide

Comprehensive test suite for `create-project.sh` functionality.

## Overview

The test suite validates all command-line options, archetypes, features, and edge cases for the project creation script. It includes 25 test cases covering:

- Command-line argument parsing
- Archetype composition (base, feature, composite)
- Optional tools integration
- Error handling
- Documentation generation
- Git integration
- Path handling (absolute and relative)

## Prerequisites

### Required
- Bash (Git Bash, WSL, or native Linux/macOS)
- Git
- Docker (for some archetype tests)

### Optional
- **jq** - Required for optional tools and preset tests
  - Without jq: 3 tests will be skipped
  - With jq: All 25 tests will run

Install jq:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Windows (Git Bash)
# Usually included with Git for Windows
# Or download from: https://stedolan.github.io/jq/download/
```

## Test Files

### Bash Test Suite
- **File**: `test-create-project.sh`
- **Platform**: Linux, macOS, WSL, Git Bash
- **Tests**: 25 comprehensive test cases

### PowerShell Test Suite
- **File**: `Test-CreateProject.ps1`
- **Platform**: Windows (PowerShell 5.1+)
- **Tests**: 18 core test cases
- **Requirement**: Bash must be available (Git Bash or WSL)

## Running Tests

### Bash (Linux/macOS/WSL)

```bash
# Make executable
chmod +x tests/test-create-project.sh

# Run all tests
./tests/test-create-project.sh

# View results
cat tests/temp/test-results.txt
```

### PowerShell (Windows)

```powershell
# Run all tests
.\tests\Test-CreateProject.ps1

# View results
Get-Content .\tests\temp\test-results.txt
```

## Test Categories

### 1. Information Commands (5 tests)

Tests that display information without creating projects:

- ✅ `--help` - Display usage information
- ✅ `--list-archetypes` - List all available archetypes
- ✅ `--list-features` - List feature archetypes
- ✅ `--list-tools` - List optional tools
- ✅ `--list-presets` - List tool presets

### 2. Dry Run Mode (1 test)

- ✅ `--dry-run` - Preview project without creating files

### 3. Base Archetypes (3 tests)

Tests for base archetype project creation:

- ✅ `base` archetype
- ✅ `rag-project` archetype
- ✅ `api-service` archetype

### 4. Feature Composition (3 tests)

Tests for adding features to base archetypes:

- ✅ Single feature (`--add-features monitoring`)
- ✅ Multiple features (`--add-features monitoring,agentic-workflows`)
- ✅ Composition documentation generation

### 5. Optional Tools (2 tests)

- ✅ Individual tools (`--tools fastapi,postgresql`)
- ✅ Tool presets (`--preset ai-agent`)

### 6. Path Handling (2 tests)

- ✅ Absolute path (`--path /full/path/to/project`)
- ✅ Relative path (`--path ./relative/path`)

### 7. Mode Flags (2 tests)

- ✅ Verbose mode (`--verbose`)
- ✅ No-git mode (`--no-git`)

### 8. Composite Archetypes (1 test)

- ✅ `composite-rag-agents` archetype

### 9. Error Handling (3 tests)

- ✅ Missing required arguments
- ✅ Invalid archetype name
- ✅ Existing directory conflict

### 10. Documentation & Structure (3 tests)

- ✅ Documentation generation (README.md, COMPOSITION.md)
- ✅ .gitignore generation
- ✅ Project structure creation (src/, tests/, docs/)

### 11. Combined Options (1 test)

- ✅ Multiple flags combined in single command

## Test Results

### Expected Output

```
╔════════════════════════════════════════╗
║   Create Project Test Suite      ║
╚════════════════════════════════════════╝

✓ Test environment setup complete

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TEST: Help Command (--help)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ PASSED: Help command displays usage

[... more tests ...]

╔════════════════════════════════════════╗
║   Test Summary                    ║
╚════════════════════════════════════════╝

Total Tests:   25
Passed:        25
Failed:        0
Skipped:       0

Success Rate:  100%

🎉 All tests passed!
```

### Test Results File

Results are saved to `tests/temp/test-results.txt`:

```
Create Project Test Results - [Date]
===========================================

PASS: Help command displays usage
PASS: List archetypes shows all categories
PASS: List features displays feature archetypes
[...]

===========================================
SUMMARY
===========================================
Total Tests: 25
Passed: 25
Failed: 0
Skipped: 0
Success Rate: 100%
```

## Test Details

### Test 1: Help Command
**Command**: `./create-project.sh --help`
**Expected**: Display usage information
**Validates**: Help text is complete and readable

### Test 2: List Archetypes
**Command**: `./create-project.sh --list-archetypes`
**Expected**: Show BASE, FEATURE, and COMPOSITE categories
**Validates**: All archetype types are displayed correctly

### Test 3: List Features
**Command**: `./create-project.sh --list-features`
**Expected**: Display all feature archetypes with descriptions
**Validates**: Feature archetypes are properly categorized

### Test 4: List Tools
**Command**: `./create-project.sh --list-tools`
**Expected**: Show all available optional tools
**Validates**: Tool configuration is loaded correctly

### Test 5: List Presets
**Command**: `./create-project.sh --list-presets`
**Expected**: Display all tool presets with descriptions
**Validates**: Preset configuration is accessible

### Test 6: Dry Run Mode
**Command**: `./create-project.sh --name test --archetype base --dry-run`
**Expected**: Show preview without creating files
**Validates**: No files/directories are created

### Test 7: Base Archetype
**Command**: `./create-project.sh --name test --archetype base --no-git --no-build`
**Expected**: Create project with base structure
**Validates**:
- Project directory created
- README.md exists
- Basic structure present

### Test 8: RAG Archetype
**Command**: `./create-project.sh --name test --archetype rag-project --no-git --no-build`
**Expected**: Create RAG project structure
**Validates**: RAG-specific files and configuration

### Test 9: API Service Archetype
**Command**: `./create-project.sh --name test --archetype api-service --no-git --no-build`
**Expected**: Create API service structure
**Validates**: API-specific configuration present

### Test 10: Feature Archetypes
**Command**: `./create-project.sh --name test --archetype base --add-features monitoring --no-git --no-build`
**Expected**: Compose base + monitoring
**Validates**:
- COMPOSITION.md created
- Feature files merged

### Test 11: Multiple Features
**Command**: `./create-project.sh --name test --archetype base --add-features monitoring,agentic-workflows --no-git --no-build`
**Expected**: Compose multiple features
**Validates**:
- All features mentioned in COMPOSITION.md
- No conflicts in merged files

### Test 12: Optional Tools
**Command**: `./create-project.sh --name test --archetype base --tools fastapi,postgresql --no-git --no-build`
**Expected**: Add optional tools to project
**Validates**:
- OPTIONAL_TOOLS.md created
- Tool-specific files present

### Test 13: Preset
**Command**: `./create-project.sh --name test --archetype base --preset ai-agent --no-git --no-build`
**Expected**: Apply preset tool collection
**Validates**: All preset tools are configured

### Test 14: Custom Path (Absolute)
**Command**: `./create-project.sh --path /full/path/test --archetype base --no-git --no-build`
**Expected**: Create project at specified absolute path
**Validates**: Path resolution works correctly

### Test 15: Custom Path (Relative)
**Command**: `./create-project.sh --path ./relative/test --archetype base --no-git --no-build`
**Expected**: Create project at relative path
**Validates**: Relative path handling works

### Test 16: Verbose Mode
**Command**: `./create-project.sh --name test --archetype base --verbose --no-git --no-build`
**Expected**: Display detailed execution information
**Validates**: Verbose output includes debug information

### Test 17: Composite Archetype
**Command**: `./create-project.sh --name test --archetype composite-rag-agents --no-git --no-build`
**Expected**: Create pre-composed project
**Validates**: Composite archetype loads correctly

### Test 18: No-Git Flag
**Command**: `./create-project.sh --name test --archetype base --no-git --no-build`
**Expected**: Skip Git initialization
**Validates**: No .git directory exists

### Test 19: Missing Arguments
**Command**: `./create-project.sh`
**Expected**: Display error message
**Validates**: Error handling for required arguments

### Test 20: Invalid Archetype
**Command**: `./create-project.sh --name test --archetype nonexistent --no-git --no-build`
**Expected**: Display error message
**Validates**: Error handling for invalid archetypes

### Test 21: Existing Directory
**Command**: `./create-project.sh --name test --path /existing/dir --archetype base`
**Expected**: Display error message
**Validates**: Prevents overwriting existing directories

### Test 22: Documentation Generation
**Command**: `./create-project.sh --name test --archetype rag-project --add-features monitoring --no-git --no-build`
**Expected**: Generate all documentation files
**Validates**:
- README.md created
- COMPOSITION.md created
- Content is accurate

### Test 23: .gitignore Generation
**Command**: `./create-project.sh --name test --archetype base --no-git --no-build`
**Expected**: Generate .gitignore file
**Validates**:
- .gitignore exists
- Contains relevant patterns

### Test 24: Project Structure
**Command**: `./create-project.sh --name test --archetype base --no-git --no-build`
**Expected**: Create standard directory structure
**Validates**:
- src/ directory exists
- tests/ directory exists
- docs/ directory exists

### Test 25: Combined Options
**Command**: `./create-project.sh --name test --path /path --archetype rag-project --add-features monitoring --tools fastapi,postgresql --verbose --no-git --no-build`
**Expected**: All options work together
**Validates**: Complex command combinations function correctly

## Troubleshooting

### Common Issues

#### Bash Not Found (Windows)
```
ERROR: bash not found. Please install Git Bash or WSL
```
**Solution**: Install Git for Windows or Windows Subsystem for Linux

#### Permission Denied
```
bash: ./test-create-project.sh: Permission denied
```
**Solution**: Make script executable
```bash
chmod +x tests/test-create-project.sh
```

#### jq Not Found
```
ERROR: jq is required for archetype operations
```
**Solution**: Install jq
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Windows (Git Bash)
# jq is usually included with Git for Windows
```

#### Test Directory Cleanup
If tests fail due to leftover directories:
```bash
# Clean up test artifacts
rm -rf tests/temp/test-projects/*
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Test Create Project

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq

      - name: Run tests
        run: |
          chmod +x tests/test-create-project.sh
          ./tests/test-create-project.sh

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: tests/temp/test-results.txt
```

## Test Coverage

| Category | Coverage |
|----------|----------|
| Command-line arguments | 100% |
| Archetype types | 100% |
| Feature composition | 100% |
| Optional tools | 100% |
| Error handling | 90% |
| Path handling | 100% |
| Documentation generation | 100% |
| Git integration | 75% |

## Adding New Tests

To add a new test:

1. **Create test function**:
```bash
test_new_feature() {
    print_test_header "New Feature Test"

    local test_name="test-new-feature"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    # Run create-project.sh
    if bash "$CREATE_PROJECT_SCRIPT" [args]; then
        # Validate results
        if [ -f "$project_path/expected-file" ]; then
            test_passed "New feature works"
        else
            test_failed "New feature works" "Expected file not found"
        fi
    else
        test_failed "New feature works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}
```

2. **Add to main execution**:
```bash
# In main() function
test_new_feature
```

3. **Update documentation**:
- Add test description to this file
- Update test count in summary

## Test Maintenance

### Regular Checks

- Run tests before committing changes
- Update tests when adding new features
- Verify tests pass on multiple platforms
- Keep test documentation current

### Performance

Current test suite execution time:
- Bash: ~30-60 seconds (25 tests)
- PowerShell: ~40-70 seconds (18 tests)

## Contributing

When contributing new features to `create-project.sh`:

1. Write tests first (TDD approach)
2. Ensure all existing tests still pass
3. Add new tests for new functionality
4. Update this documentation
5. Run full test suite before submitting PR

## See Also

- [USAGE_GUIDE.md](../docs/USAGE_GUIDE.md) - How to use create-project.sh
- [ARCHETYPE_GUIDE.md](../docs/ARCHETYPE_GUIDE.md) - Archetype documentation
- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - General testing guidelines
