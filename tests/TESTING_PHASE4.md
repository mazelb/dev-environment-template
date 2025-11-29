# Phase 4 Testing Documentation

## Overview

This document describes the testing strategy, test cases, and procedures for validating Phase 4 (File Merging System) of the dev-environment-template project.

## Test Suite: Test-Phase4.ps1

**Location**: `tests/Test-Phase4.ps1`
**Total Tests**: 15
**Execution Time**: ~30-60 seconds
**Language**: PowerShell

## Test Coverage

### 1. Docker Compose Merger Tests

#### Test 1: Basic Functionality
- **Purpose**: Verify docker-compose-merger.sh can merge multiple compose files
- **Input**: Two docker-compose.yml files with different services
- **Expected**: Merged file contains all services from both inputs
- **Success Criteria**:
  - Script exits with code 0
  - Output file created
  - All services present in merged file

#### Test 2: Port Offset Resolution
- **Purpose**: Verify port conflict resolution with offsets
- **Input**: Two compose files with potentially conflicting ports
- **Expected**: Merged file with port offsets applied
- **Success Criteria**:
  - merge-with-resolution command succeeds
  - Output file created
  - Port conflicts resolved

### 2. Environment File Merger Tests

#### Test 3: Basic Merge
- **Purpose**: Verify .env file merging with conflict detection
- **Input**: Two .env files with some duplicate variables
- **Expected**: Merged file with conflict markers for duplicates
- **Success Criteria**:
  - Script exits with code 0
  - Output file created
  - Conflict markers present for duplicates

#### Test 4: Deduplication
- **Purpose**: Verify deduplication mode removes duplicates
- **Input**: Two .env files with duplicate variables
- **Expected**: Merged file with only one instance of each variable
- **Success Criteria**:
  - merge-dedup command succeeds
  - Duplicate variables removed (last value wins)
  - Only one instance of each variable

### 3. Makefile Merger Tests

#### Test 5: Target Namespacing
- **Purpose**: Verify Makefile merging with target namespacing
- **Input**: Two Makefiles with conflicting target names
- **Expected**: Merged Makefile with namespaced targets
- **Success Criteria**:
  - Script exits with code 0
  - Output file created
  - Targets namespaced (e.g., base-build, feature-build)
  - Composite 'all' target created

### 4. Source File Merger Tests

#### Test 6: Type Detection
- **Purpose**: Verify source file type detection
- **Input**: FastAPI Python file
- **Expected**: Correctly detected as 'fastapi' type
- **Success Criteria**:
  - detect-type command succeeds
  - Returns 'fastapi' for FastAPI files

#### Test 7: FastAPI Merging
- **Purpose**: Verify intelligent FastAPI file merging
- **Input**: Two FastAPI main.py files with different routes
- **Expected**: Merged file with consolidated imports and routes
- **Success Criteria**:
  - merge-fastapi command succeeds
  - Output file created
  - Imports consolidated
  - App instance created
  - Routes from both files present

### 5. Directory Merger Tests

#### Test 8: Conflict Detection
- **Purpose**: Verify directory merger detects file conflicts
- **Input**: Two directories with same-named files
- **Expected**: List of conflicts identified
- **Success Criteria**:
  - list-conflicts command succeeds
  - Conflicting files identified

#### Test 9: Full Merge
- **Purpose**: Verify full directory merging with strategy application
- **Input**: Two directories with various file types
- **Expected**: Merged directory with intelligent file merging
- **Success Criteria**:
  - merge command succeeds
  - Target directory created
  - Files merged according to strategies

### 6. Integration Tests

#### Test 10: Merger Scripts Exist
- **Purpose**: Verify all merger scripts are present
- **Expected**: All 5 merger scripts exist in scripts/ directory
- **Success Criteria**: All scripts found

#### Test 11: Scripts are Executable
- **Purpose**: Verify all scripts can be executed
- **Expected**: All scripts run without fatal errors
- **Success Criteria**: Scripts display help text

#### Test 12: compose_archetypes Integration
- **Purpose**: Verify integration into create-project.sh
- **Expected**: compose_archetypes function uses directory-merger.sh
- **Success Criteria**:
  - create-project.sh references directory-merger.sh
  - Merge logic implemented

### 7. Error Handling Tests

#### Test 13: Missing Input Files
- **Purpose**: Verify graceful handling of missing files
- **Input**: Nonexistent file path
- **Expected**: Appropriate error message, no crash
- **Success Criteria**: Graceful error handling

#### Test 14: CLI Interface Help
- **Purpose**: Verify all mergers provide help text
- **Expected**: Help text displayed when no arguments
- **Success Criteria**: Usage/Examples shown

#### Test 15: Fallback Behavior
- **Purpose**: Verify scripts work without optional tools (yq, jq)
- **Expected**: Fallback methods used successfully
- **Success Criteria**: Scripts succeed with or without tools

## Running the Tests

### Prerequisites

- PowerShell 5.1 or later
- Bash (Git Bash, WSL, or native Linux/macOS)
- Git installed
- Write permissions in tests directory

### Execution

```powershell
# Run all Phase 4 tests
./tests/Test-Phase4.ps1

# Or from root directory
pwsh -File ./tests/Test-Phase4.ps1
```

### Expected Output

```
============================================
Phase 4 Test Results Summary
============================================
Total Tests:  15
Passed:       15
Failed:       0
Success Rate: 100%
============================================

✓ All Phase 4 tests passed!
```

## Manual Testing Procedures

### 1. Docker Compose Merger

```bash
# Create test compose files
cat > base.yml << EOF
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
EOF

cat > feature.yml << EOF
version: '3.8'
services:
  api:
    image: python:3.11
    ports:
      - "8000:8000"
EOF

# Test merge
./scripts/docker-compose-merger.sh merge merged.yml base.yml feature.yml

# Test merge with resolution
./scripts/docker-compose-merger.sh merge-with-resolution resolved.yml base.yml feature.yml

# Verify output
cat merged.yml
cat resolved.yml
```

### 2. Environment File Merger

```bash
# Create test .env files
cat > .env1 << EOF
DATABASE_URL=postgres://localhost/db1
API_KEY=key123
DEBUG=true
EOF

cat > .env2 << EOF
REDIS_URL=redis://localhost:6379
API_KEY=key456
FEATURE=enabled
EOF

# Test merge with conflict markers
./scripts/env-merger.sh merge merged.env .env1 .env2

# Test merge with deduplication
./scripts/env-merger.sh merge-dedup dedup.env .env1 .env2

# Verify output
cat merged.env
cat dedup.env
```

### 3. Makefile Merger

```bash
# Create test Makefiles
cat > Makefile1 << EOF
.PHONY: build test

build:
	@echo "Building base"

test:
	@echo "Testing base"
EOF

cat > Makefile2 << EOF
.PHONY: build deploy

build:
	@echo "Building feature"

deploy:
	@echo "Deploying"
EOF

# Test merge
./scripts/makefile-merger.sh merge Makefile.merged Makefile1 Makefile2

# List targets
./scripts/makefile-merger.sh list-targets Makefile.merged

# Verify output
cat Makefile.merged
make -f Makefile.merged all
```

### 4. Source File Merger

```bash
# Create test FastAPI files
cat > main1.py << EOF
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Base"}
EOF

cat > main2.py << EOF
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}
EOF

# Test type detection
./scripts/source-file-merger.sh detect-type main1.py

# Test merge
./scripts/source-file-merger.sh merge-fastapi merged_main.py main1.py main2.py

# Verify output
cat merged_main.py
```

### 5. Directory Merger

```bash
# Create test directories
mkdir -p source1 source2

# Add test files
echo "Config 1" > source1/config.txt
echo "Config 2" > source2/config.txt
echo "# README 1" > source1/README.md
echo "# README 2" > source2/README.md

# List conflicts
./scripts/directory-merger.sh list-conflicts source1 source2

# Merge directories
./scripts/directory-merger.sh merge target source1 source2

# Verify output
ls -la target/
cat target/config.txt
cat target/README.md
```

### 6. Full Integration Test

```bash
# Create test archetypes
mkdir -p archetypes/test-base archetypes/test-feature

# Add files to base archetype
cat > archetypes/test-base/__archetype__.json << EOF
{
  "id": "test-base",
  "name": "Test Base",
  "version": "1.0.0"
}
EOF

cat > archetypes/test-base/docker-compose.yml << EOF
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "8080:80"
EOF

# Add files to feature archetype
cat > archetypes/test-feature/__archetype__.json << EOF
{
  "id": "test-feature",
  "name": "Test Feature",
  "version": "1.0.0"
}
EOF

cat > archetypes/test-feature/docker-compose.yml << EOF
version: '3.8'
services:
  api:
    image: python:3.11
    ports:
      - "8000:8000"
EOF

# Create project with composition
./create-project.sh \
  --archetype test-base \
  --features test-feature \
  --name test-integration \
  --no-git

# Verify merged output
cd test-integration
cat docker-compose.yml
cat COMPOSITION.md
```

## Success Criteria

### Phase 4 Complete Success
- ✅ All 15 automated tests pass (100%)
- ✅ All merger scripts executable
- ✅ Manual tests produce expected output
- ✅ Integration test creates valid project
- ✅ No critical bugs or errors

### Acceptable Results
- ✅ At least 13/15 tests pass (87%+)
- ✅ Known issues documented
- ✅ Core functionality works
- ✅ Integration test succeeds

### Requires Fixes
- ❌ Less than 13 tests pass
- ❌ Merger scripts fail to execute
- ❌ Integration test fails
- ❌ Data loss or corruption

## Known Issues & Limitations

### Current Limitations
1. **FastAPI Only**: Source file merger only supports FastAPI intelligently
   - Flask, Express planned for future
   - Fallback to generic merge with markers

2. **No AST Parsing**: Python merging uses text processing
   - Future enhancement: Use Python AST module
   - More precise code merging needed

3. **Basic YAML Fallback**: Without yq, basic concatenation used
   - Install yq for best results
   - Fallback works but less intelligent

### Workarounds
- For Flask/Express: Use generic merge and manually resolve
- For complex Python: Review merged file and adjust
- For best YAML merging: Install yq (`brew install yq` or `apt install yq`)

## Troubleshooting

### Tests Fail to Execute
**Problem**: PowerShell script won't run
**Solution**: Check execution policy
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Bash Scripts Not Found
**Problem**: Scripts not executable
**Solution**: Make scripts executable
```bash
chmod +x scripts/*.sh
```

### Path Issues
**Problem**: Scripts can't find files
**Solution**: Run from repository root
```bash
cd /path/to/dev-environment-template
./tests/Test-Phase4.ps1
```

### Merger Failures
**Problem**: Merger scripts exit with errors
**Solution**: Check prerequisites
```bash
# Verify bash available
bash --version

# Verify sed/grep available
sed --version
grep --version

# Optional: Install yq for better YAML
yq --version
```

## Next Steps

After Phase 4 testing completes successfully:

1. **Commit Results**: Git commit test files and results
2. **Update Documentation**: Update documentation with test results
3. **Create Archetypes**: Build example archetypes showcasing merging
4. **Performance Testing**: Test with large projects
5. **User Acceptance**: Have others test the system

## Test Maintenance

### Adding New Tests
1. Add test function to Test-Phase4.ps1
2. Increment TestCount appropriately
3. Use Test-Assert for consistent reporting
4. Document new test in this file

### Updating Tests
1. Update test logic as features change
2. Update expected results
3. Document changes in this file

### Test Data
- Test data generated on-the-fly in temp directory
- No persistent test fixtures required
- Cleanup automatic after test run

## Conclusion

This comprehensive test suite validates all Phase 4 functionality:
- Individual merger scripts
- CLI interfaces
- Error handling
- Integration with compose_archetypes
- Fallback behaviors

**Target**: 100% test pass rate
**Minimum Acceptable**: 87% test pass rate
**Current Status**: Ready for execution
