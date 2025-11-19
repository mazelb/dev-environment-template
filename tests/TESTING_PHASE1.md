# Phase 1 Testing Guide

## Quick Test

To verify Phase 1 implementation is working:

### PowerShell (Recommended for Windows)
```powershell
.\tests\Test-Phase1.ps1
```

### Bash (Requires jq)
```bash
bash tests/test-phase1.sh
```

## Expected Results

**All tests should pass:**
- ✅ 26/26 tests passed in PowerShell
- ✅ 23/30 tests passed in Bash (7 failures due to missing jq are acceptable)

## What's Being Tested

### 1.1 Configuration Directory Structure
- [x] `config/` directory exists
- [x] `config/optional-tools.json` exists and is valid JSON
- [x] `config/archetypes.json` exists and is valid JSON

### 1.2 Archetypes Directory Structure
- [x] `archetypes/` directory exists
- [x] `archetypes/README.md` exists
- [x] `archetypes/base/` directory exists
- [x] `archetypes/rag-project/` directory exists

### 1.3 Archetype Metadata Schema
- [x] `archetypes/__archetype_schema__.json` exists
- [x] Schema is valid JSON
- [x] Schema has required properties (title, version)

### 1.4 Base Archetype
- [x] `archetypes/base/__archetype__.json` exists and is valid
- [x] Base archetype has required metadata (name, role)
- [x] Base archetype has directory structure (src/, tests/, docs/)
- [x] Base archetype has README.md

### 1.5 Archetype Loader Script
- [x] `scripts/archetype-loader.sh` exists
- [x] Script has required functions:
  - `load_archetype()`
  - `list_archetypes()`
  - `check_compatibility()`
- [x] Script can be sourced without errors

### 1.6 create-project.sh Integration
- [x] Archetype variables defined:
  - `BASE_ARCHETYPE`
  - `FEATURE_ARCHETYPES`
  - `ARCHETYPES_DIR`
- [x] Sources `archetype-loader.sh`
- [x] CLI flags implemented:
  - `--archetype`
  - `--add-features`
  - `--list-archetypes`
- [x] Help text includes archetype documentation

## Manual Testing

### 1. View Help
```bash
bash create-project.sh --help
```
Should display archetype options in the help text.

### 2. List Archetypes (requires jq)
```bash
bash create-project.sh --list-archetypes
```
Should display available base and feature archetypes.

### 3. Check Compatibility (requires jq)
```bash
bash scripts/archetype-loader.sh --check-compatibility base rag-project
```
Should check if archetypes are compatible.

### 4. Validate JSON Files
```powershell
# PowerShell
Get-Content config/optional-tools.json | ConvertFrom-Json
Get-Content config/archetypes.json | ConvertFrom-Json
Get-Content archetypes/__archetype_schema__.json | ConvertFrom-Json
Get-Content archetypes/base/__archetype__.json | ConvertFrom-Json
```

All should parse without errors.

## Troubleshooting

### Bash Tests Fail with "jq: command not found"
This is expected if jq is not installed. The PowerShell test suite is the primary test for Windows environments.

**To install jq:**
- Windows: `choco install jq` or `scoop install jq`
- macOS: `brew install jq`
- Linux: `apt-get install jq` or `yum install jq`

### Tests Report Missing Files
Verify you're running tests from the template root directory:
```bash
cd /path/to/dev-environment-template
```

### JSON Validation Errors
Use a JSON validator to check for syntax errors:
```powershell
# PowerShell validates automatically
Get-Content <file> | ConvertFrom-Json
```

## Next Steps

Once all Phase 1 tests pass, you can proceed to:
- **Phase 2:** Git Integration (automatic repository initialization)
- **Phase 3:** Multi-Archetype Core (composition and conflict resolution)
- **Phase 4:** File Merging System (intelligent file combination)

See `docs/IMPLEMENTATION_STRATEGY.md` for the complete roadmap.
