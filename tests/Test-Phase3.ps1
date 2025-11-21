# Phase 3 Testing Script - Multi-Archetype Core
# Tests conflict detection, resolution, and archetype composition

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Phase 3: Multi-Archetype Core Tests  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$script:TestsPassed = 0
$script:TestsFailed = 0

function Test-Pass {
    param([string]$TestName)
    Write-Host "✓ PASS: $TestName" -ForegroundColor Green
    $script:TestsPassed++
}

function Test-Fail {
    param([string]$TestName, [string]$Reason)
    Write-Host "✗ FAIL: $TestName" -ForegroundColor Red
    Write-Host "  Reason: $Reason" -ForegroundColor Yellow
    $script:TestsFailed++
}

# Test 1: Conflict resolver script exists
Write-Host "Test 1: Conflict resolver script exists..." -NoNewline
if (Test-Path "scripts\conflict-resolver.sh") {
    Test-Pass "Conflict resolver script created"
} else {
    Test-Fail "Conflict resolver script missing" "File scripts/conflict-resolver.sh not found"
}

# Test 2: Check conflict detection functions exist
Write-Host "Test 2: Conflict detection functions exist..." -NoNewline
$conflictResolverContent = Get-Content "scripts\conflict-resolver.sh" -Raw
if ($conflictResolverContent -match "detect_port_conflicts\(\)" -and
    $conflictResolverContent -match "detect_service_name_conflicts\(\)" -and
    $conflictResolverContent -match "detect_dependency_conflicts\(\)") {
    Test-Pass "All conflict detection functions defined"
} else {
    Test-Fail "Conflict detection functions incomplete" "One or more detection functions missing"
}

# Test 3: Check conflict resolution functions exist
Write-Host "Test 3: Conflict resolution functions exist..." -NoNewline
if ($conflictResolverContent -match "resolve_port_conflicts\(\)" -and
    $conflictResolverContent -match "resolve_service_name_conflicts\(\)") {
    Test-Pass "All conflict resolution functions defined"
} else {
    Test-Fail "Conflict resolution functions incomplete" "One or more resolution functions missing"
}

# Test 4: Check comprehensive detection function
Write-Host "Test 4: Comprehensive detection function exists..." -NoNewline
if ($conflictResolverContent -match "detect_all_conflicts\(\)") {
    Test-Pass "detect_all_conflicts function defined"
} else {
    Test-Fail "detect_all_conflicts function missing" "Function not found in script"
}

# Test 5: Check CLI help and usage
Write-Host "Test 5: Conflict resolver has proper usage help..." -NoNewline
if ($conflictResolverContent -match "Usage:" -and $conflictResolverContent -match "detect-all") {
    Test-Pass "Conflict resolver has comprehensive help"
} else {
    Test-Fail "Conflict resolver help incomplete" "Usage information missing or incomplete"
}

# Test 6: Check yq/jq fallback support
Write-Host "Test 6: Fallback support for missing tools..." -NoNewline
if ($conflictResolverContent -match "YQ_AVAILABLE" -and $conflictResolverContent -match "JQ_AVAILABLE") {
    Test-Pass "Fallback support for yq/jq implemented"
} else {
    Test-Fail "Fallback support missing" "Tool availability checks not found"
}

# Test 7: compose_archetypes function exists in create-project.sh
Write-Host "Test 7: compose_archetypes function exists..." -NoNewline
$createProjectContent = Get-Content "create-project.sh" -Raw
if ($createProjectContent -match "compose_archetypes\(\)") {
    Test-Pass "compose_archetypes function defined"
} else {
    Test-Fail "compose_archetypes function missing" "Function not found in create-project.sh"
}

# Test 8: compose_archetypes is called in main
Write-Host "Test 8: compose_archetypes integrated in main flow..." -NoNewline
if ($createProjectContent -match "compose_archetypes.*BASE_ARCHETYPE") {
    Test-Pass "compose_archetypes called in main function"
} else {
    Test-Fail "compose_archetypes not integrated" "Function not called in main flow"
}

# Test 9: --add-features flag handling
Write-Host "Test 9: --add-features flag properly handled..." -NoNewline
if ($createProjectContent -match "--add-features" -and $createProjectContent -match "FEATURE_ARCHETYPES") {
    Test-Pass "--add-features flag implementation complete"
} else {
    Test-Fail "--add-features flag not properly handled" "Flag or variable handling missing"
}

# Test 10: Conflict resolver sourced in create-project.sh
Write-Host "Test 10: Conflict resolver sourced in create-project.sh..." -NoNewline
if ($createProjectContent -match "source.*conflict-resolver.sh") {
    Test-Pass "Conflict resolver properly sourced"
} else {
    Test-Fail "Conflict resolver not sourced" "Source statement missing"
}

# Test 11: Enhanced check_compatibility function
Write-Host "Test 11: Enhanced check_compatibility function..." -NoNewline
$archetypeLoaderContent = Get-Content "scripts\archetype-loader.sh" -Raw
if ($archetypeLoaderContent -match "Compatibility Check" -and
    $archetypeLoaderContent -match "detect_all_conflicts") {
    Test-Pass "check_compatibility function enhanced"
} else {
    Test-Fail "check_compatibility not fully enhanced" "Missing compatibility check improvements"
}

# Test 12: Port offset logic in compose_archetypes
Write-Host "Test 12: Port offset logic implemented..." -NoNewline
if ($createProjectContent -match "port_offset.*offset.*\(i \+ 1\)") {
    Test-Pass "Port offset calculation implemented"
} else {
    Test-Fail "Port offset logic missing" "Offset calculation not found"
}

# Test 13: Service prefix logic in compose_archetypes
Write-Host "Test 13: Service name prefixing implemented..." -NoNewline
if ($createProjectContent -match "resolve_service_name_conflicts") {
    Test-Pass "Service name prefixing integrated"
} else {
    Test-Fail "Service prefixing not integrated" "Function call not found"
}

# Test 14: COMPOSITION.md generation
Write-Host "Test 14: COMPOSITION.md generation..." -NoNewline
if ($createProjectContent -match "COMPOSITION.md" -and $createProjectContent -match "Archetype Composition") {
    Test-Pass "COMPOSITION.md generation implemented"
} else {
    Test-Fail "COMPOSITION.md generation missing" "Documentation generation not found"
}

# Test 15: Multi-file docker-compose support
Write-Host "Test 15: Multi-file docker-compose support..." -NoNewline
if ($createProjectContent -match "docker-compose.*\.yml.*feature") {
    Test-Pass "Multi-file docker-compose pattern implemented"
} else {
    Test-Fail "Multi-file docker-compose support incomplete" "Feature-specific compose file handling missing"
}

# Test 16: Archetype validation in compose_archetypes
Write-Host "Test 16: Archetype validation implemented..." -NoNewline
if ($createProjectContent -match "if \[ ! -d.*base_dir" -and $createProjectContent -match "Base archetype not found") {
    Test-Pass "Archetype validation implemented"
} else {
    Test-Fail "Archetype validation missing" "Directory existence checks not found"
}

# Test 17: Feature archetype iteration
Write-Host "Test 17: Feature archetype iteration..." -NoNewline
if ($createProjectContent -match "for i in.*feature_dirs") {
    Test-Pass "Feature archetype iteration implemented"
} else {
    Test-Fail "Feature iteration missing" "Loop over features not found"
}

# Test 18: Conflict detection integration in compose
Write-Host "Test 18: Conflict detection in composition flow..." -NoNewline
if ($createProjectContent -match "detect_all_conflicts.*metadata") {
    Test-Pass "Conflict detection integrated in composition"
} else {
    Test-Fail "Conflict detection not integrated" "Detection call not found in compose function"
}

# Test 19: Error handling in compose_archetypes
Write-Host "Test 19: Error handling in compose_archetypes..." -NoNewline
if ($createProjectContent -match "print_error.*archetype not found" -and $createProjectContent -match "return 1") {
    Test-Pass "Error handling implemented"
} else {
    Test-Fail "Error handling incomplete" "Error messages or return codes missing"
}

# Test 20: USE_ARCHETYPE flag check
Write-Host "Test 20: USE_ARCHETYPE flag check..." -NoNewline
if ($createProjectContent -match 'USE_ARCHETYPE.*=.*true' -and $createProjectContent -match 'compose_archetypes') {
    Test-Pass "USE_ARCHETYPE flag properly checked"
} else {
    Test-Fail "USE_ARCHETYPE flag not checked" "Conditional execution missing"
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Total Tests: $($script:TestsPassed + $script:TestsFailed)" -ForegroundColor White
Write-Host "Passed: $($script:TestsPassed)" -ForegroundColor Green
Write-Host "Failed: $($script:TestsFailed)" -ForegroundColor Red

if ($script:TestsFailed -eq 0) {
    Write-Host ""
    Write-Host "✓ All Phase 3 tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "✗ Some tests failed. Please review the output above." -ForegroundColor Red
    exit 1
}
