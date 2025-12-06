# Path Formatting Audit Report
**Date:** December 4, 2025
**Project:** dev-environment-template
**Auditor:** Claude Code

---

## Executive Summary

Comprehensive audit of all bash and PowerShell scripts in the project to ensure proper cross-platform path formatting. The project is a Docker container template meant to work on Windows (WSL2), macOS, and Linux.

**Total Scripts Audited:** 43
- Bash scripts (.sh): 33
- PowerShell scripts (.ps1): 10

**Issues Found:** 15 path formatting issues in PowerShell scripts
**Issues in Bash Scripts:** 0 (all use POSIX-compliant paths)

---

## Findings

### ✅ Bash Scripts - All PASS

All 33 bash scripts use proper POSIX-style paths with forward slashes (`/`) and are cross-platform compatible.

**Key Scripts Reviewed:**
- `create-project.sh` - Main project creation script ✅
- `scripts/archetype-loader.sh` - Archetype loading ✅
- `scripts/docker-compose-merger.sh` - Docker compose merging ✅
- `scripts/env-merger.sh` - Environment file merging ✅
- All utility and merger scripts ✅

**Best Practices Found:**
- All use `SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"` for path detection
- All use forward slashes for path construction
- All use proper variable expansion with quotes
- No hardcoded Windows-style paths

---

### ⚠️ PowerShell Scripts - 15 Issues Found

PowerShell scripts have Windows-specific path formatting that should be fixed for better cross-platform compatibility.

#### Issue Category 1: Join-Path with Backslashes

**Problem:** Using backslashes in `Join-Path` second parameter makes code less readable and Windows-centric.

**Impact:** Medium - `Join-Path` handles this correctly but using forward slashes is clearer.

| File | Line | Current Code | Recommendation |
|------|------|--------------|----------------|
| `Test-CreateProject.ps1` | 10 | `Join-Path $ScriptDir "temp\test-projects"` | Use `"temp/test-projects"` |
| `Test-CreateProject.ps1` | 11 | `Join-Path $ScriptDir "temp\test-results.txt"` | Use `"temp/test-results.txt"` |
| `run-tests.ps1` | 134 | `Join-Path $rootDir "archetypes\rag-project"` | Use `"archetypes/rag-project"` |
| `run-tests.ps1` | 144 | `Join-Path $rootDir "archetypes\api-service"` | Use `"archetypes/api-service"` |

#### Issue Category 2: String Concatenation with Backslashes

**Problem:** Using string concatenation with backslashes creates Windows-only paths.

**Impact:** High - These will fail on Linux/macOS systems.

| File | Line | Current Code | Recommendation |
|------|------|--------------|----------------|
| `Test-MultiArchetype.ps1` | 9 | `$PSScriptRoot + "\.."` | Use `Join-Path $PSScriptRoot ".."` |
| `Test-ArchetypeStructure.ps1` | 66 | `$PSScriptRoot + "\.."` | Use `Join-Path $PSScriptRoot ".."` |
| `Test-GitIntegration.ps1` | 48 | `$PSScriptRoot + "\.."` | Use `Join-Path $PSScriptRoot ".."` |
| `Test-MultiProjectWorkflow.ps1` | 10 | `"$PSScriptRoot\..\".Path` | Use `Join-Path $PSScriptRoot ".."` |

#### Issue Category 3: String Interpolation with Backslashes

**Problem:** String interpolation with backslashes in paths creates Windows-only code.

**Impact:** High - Will fail on Linux/macOS, especially in Docker containers.

**Files Affected:**
- `Test-ArchetypeStructure.ps1` - 11 instances
  - Lines 105, 112, 119, 129, 132, 135, 154, 157, 160, 179, 191, 201, 205
- `Test-MultiArchetype.ps1` - 4 instances
  - Lines 29, 37, 82, 114
- `Test-GitIntegration.ps1` - 4 instances
  - Lines 80, 83, 100, 144, 147

**Pattern Found:**
```powershell
# ❌ WRONG - Windows-only
"$rootDir\scripts\archetype-loader.sh"
"$rootDir\archetypes\base\__archetype__.json"

# ✅ CORRECT - Cross-platform
Join-Path $rootDir "scripts/archetype-loader.sh"
Join-Path $rootDir "archetypes/base/__archetype__.json"
```

---

## Impact Assessment

### Docker Container Context

Since this is a template for Docker containers that will run Linux inside, **all paths passed to bash scripts or used in Docker contexts MUST use forward slashes**.

**Critical Points:**
1. **WSL Path Conversion:** The project correctly uses `wslpath -u` to convert Windows paths to WSL paths (found in `Test-CreateProject.ps1` and `Test-RagArchetypeFull.ps1`)
2. **Bash Script Invocation:** When PowerShell calls bash scripts, paths must be converted properly
3. **Docker Compose Context:** All docker-compose.yml paths use forward slashes (correct)
4. **Test Projects:** Created projects work correctly because the bash scripts handle paths properly

### Current Workarounds

The project has implemented good workarounds:
- `Test-CreateProject.ps1:102-119` - Excellent path conversion logic using `wslpath`
- `Test-RagArchetypeFull.ps1` - Similar path conversion logic
- All bash scripts are cross-platform by design

However, the PowerShell scripts themselves should also use forward slashes for consistency and maintainability.

---

## Recommendations

### Priority 1: Fix String Interpolation (High Impact)

All string interpolation with backslashes should be replaced with `Join-Path`:

```powershell
# Before
if (Test-Path "$rootDir\scripts\archetype-loader.sh") {

# After
$scriptPath = Join-Path $rootDir "scripts/archetype-loader.sh"
if (Test-Path $scriptPath) {
```

### Priority 2: Fix String Concatenation (High Impact)

Replace all string concatenation with `Join-Path`:

```powershell
# Before
$rootDir = $PSScriptRoot + "\.."

# After
$rootDir = Join-Path $PSScriptRoot ".."
# OR
$rootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
```

### Priority 3: Use Forward Slashes in Join-Path (Medium Impact)

While `Join-Path` handles backslashes correctly, using forward slashes improves readability:

```powershell
# Before
$TestOutputDir = Join-Path $ScriptDir "temp\test-projects"

# After
$TestOutputDir = Join-Path $ScriptDir "temp/test-projects"
```

---

## Proposed Fixes

### Files Requiring Updates

1. **Test-CreateProject.ps1**
   - Lines 10-11: Use forward slashes in Join-Path

2. **Test-MultiArchetype.ps1**
   - Line 9: Replace concatenation with Join-Path
   - Lines 29, 37, 82, 114: Use Join-Path for all paths

3. **Test-ArchetypeStructure.ps1**
   - Line 66: Replace concatenation with Join-Path
   - Lines 105-205: Use Join-Path for all 11 path references

4. **Test-GitIntegration.ps1**
   - Line 48: Replace concatenation with Join-Path
   - Lines 80-147: Use Join-Path for all path references

5. **Test-MultiProjectWorkflow.ps1**
   - Line 10: Use Join-Path instead of concatenation

6. **run-tests.ps1**
   - Lines 134, 144: Use forward slashes in Join-Path

---

## Testing Strategy

After fixes:
1. Run all PowerShell test scripts on Windows
2. Run all PowerShell test scripts in WSL2
3. Verify path conversion logic still works correctly
4. Confirm no regressions in test execution

---

## Best Practices Going Forward

### PowerShell Path Guidelines

1. **Always use `Join-Path`** for combining path components
2. **Prefer forward slashes** in Join-Path second parameter for clarity
3. **Never use string concatenation** with backslashes for paths
4. **Never use string interpolation** with backslashes for paths
5. **Use `Resolve-Path`** when you need absolute paths
6. **Use path conversion** when passing paths to bash scripts (already implemented)

### Example Template

```powershell
# ✅ GOOD - Cross-platform compatible
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Resolve-Path (Join-Path $ScriptDir "..")
$ScriptsDir = Join-Path $RootDir "scripts"
$ArchetypesDir = Join-Path $RootDir "archetypes/rag-project"
$ConfigFile = Join-Path $ScriptsDir "config/settings.json"

# When calling bash scripts
$scriptPath = Join-Path $RootDir "create-project.sh"
if ($scriptPath -match '^[A-Z]:[\\/]') {
    $normalizedPath = $scriptPath -replace '\\', '/'
    $scriptPath = (wsl wslpath -u "$normalizedPath").Trim()
}
```

---

## Conclusion

**Summary:**
- Bash scripts: ✅ All correct (0 issues)
- PowerShell scripts: ⚠️ 15 issues found across 6 files

**Risk Level:** Medium
- Current workarounds prevent critical failures
- Issues mainly affect code maintainability and consistency
- Fixes are straightforward and low-risk

**Recommendation:** Implement all proposed fixes to ensure full cross-platform compatibility and code maintainability.

---

**Next Steps:**
1. Apply fixes to PowerShell scripts
2. Test on Windows and WSL2
3. Update documentation with path handling guidelines
4. Add pre-commit hooks to prevent future issues
