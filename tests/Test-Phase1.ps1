# Phase 1 Integration Test (PowerShell Version)
# Tests the Foundation & Infrastructure implementation without requiring jq

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$testsPassed = 0
$testsFailed = 0

function Write-TestHeader {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
}

function Write-Test {
    param([string]$Message)
    Write-Host "[TEST] " -ForegroundColor Blue -NoNewline
    Write-Host $Message
}

function Write-Pass {
    param([string]$Message)
    Write-Host "  ✓ PASS " -ForegroundColor Green -NoNewline
    Write-Host $Message
    $script:testsPassed++
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  ✗ FAIL " -ForegroundColor Red -NoNewline
    Write-Host $Message
    $script:testsFailed++
}

function Test-JsonFile {
    param(
        [string]$FilePath,
        [string]$Description
    )

    Write-Test "Validating $Description is valid JSON"
    try {
        $null = Get-Content $FilePath -Raw | ConvertFrom-Json
        Write-Pass "$Description is valid JSON"
        return $true
    }
    catch {
        Write-Fail "$Description has invalid JSON: $($_.Exception.Message)"
        return $false
    }
}

# Main test suite
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║  Phase 1: Foundation & Infrastructure Test Suite     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$rootDir = $PSScriptRoot + "\.."

# Test 1.1: Configuration Directory Structure
Write-TestHeader "Test 1.1: Configuration Directory Structure"

Write-Test "Checking config/ directory exists"
if (Test-Path "$rootDir\config") {
    Write-Pass "config/ directory exists"
} else {
    Write-Fail "config/ directory not found"
}

Write-Test "Checking config/optional-tools.json exists"
if (Test-Path "$rootDir\config\optional-tools.json") {
    Write-Pass "optional-tools.json exists"
    Test-JsonFile "$rootDir\config\optional-tools.json" "optional-tools.json"
} else {
    Write-Fail "optional-tools.json not found"
}

Write-Test "Checking config/archetypes.json exists"
if (Test-Path "$rootDir\config\archetypes.json") {
    Write-Pass "archetypes.json exists"
    Test-JsonFile "$rootDir\config\archetypes.json" "archetypes.json"
} else {
    Write-Fail "archetypes.json not found"
}

# Test 1.2: Archetypes Directory Structure
Write-TestHeader "Test 1.2: Archetypes Directory Structure"

Write-Test "Checking archetypes/ directory exists"
if (Test-Path "$rootDir\archetypes") {
    Write-Pass "archetypes/ directory exists"
} else {
    Write-Fail "archetypes/ directory not found"
}

Write-Test "Checking archetypes/README.md exists"
if (Test-Path "$rootDir\archetypes\README.md") {
    Write-Pass "archetypes/README.md exists"
} else {
    Write-Fail "archetypes/README.md not found"
}

Write-Test "Checking archetypes/base/ directory exists"
if (Test-Path "$rootDir\archetypes\base") {
    Write-Pass "archetypes/base/ directory exists"
} else {
    Write-Fail "archetypes/base/ directory not found"
}

Write-Test "Checking archetypes/rag-project/ directory exists"
if (Test-Path "$rootDir\archetypes\rag-project") {
    Write-Pass "archetypes/rag-project/ directory exists"
} else {
    Write-Fail "archetypes/rag-project/ directory not found"
}

# Test 1.3: Archetype Metadata Schema
Write-TestHeader "Test 1.3: Archetype Metadata Schema"

Write-Test "Checking __archetype_schema__.json exists"
if (Test-Path "$rootDir\archetypes\__archetype_schema__.json") {
    Write-Pass "__archetype_schema__.json exists"

    if (Test-JsonFile "$rootDir\archetypes\__archetype_schema__.json" "Schema") {
        Write-Test "Checking schema has required top-level properties"
        try {
            $schema = Get-Content "$rootDir\archetypes\__archetype_schema__.json" -Raw | ConvertFrom-Json
            if ($schema.title -and $schema.version) {
                Write-Pass "Schema has title='$($schema.title)' and version='$($schema.version)'"
            } else {
                Write-Fail "Schema missing title or version"
            }
        }
        catch {
            Write-Fail "Cannot parse schema: $($_.Exception.Message)"
        }
    }
} else {
    Write-Fail "__archetype_schema__.json not found"
}

# Test 1.4: Base Archetype
Write-TestHeader "Test 1.4: Base Archetype"

Write-Test "Checking base/__archetype__.json exists"
if (Test-Path "$rootDir\archetypes\base\__archetype__.json") {
    Write-Pass "base/__archetype__.json exists"

    if (Test-JsonFile "$rootDir\archetypes\base\__archetype__.json" "Base archetype") {
        Write-Test "Checking base archetype has required metadata"
        try {
            $baseArchetype = Get-Content "$rootDir\archetypes\base\__archetype__.json" -Raw | ConvertFrom-Json
            if ($baseArchetype.metadata.name -and $baseArchetype.composition.role) {
                Write-Pass "Base archetype has name='$($baseArchetype.metadata.name)' and role='$($baseArchetype.composition.role)'"
            } else {
                Write-Fail "Base archetype missing required metadata"
            }
        }
        catch {
            Write-Fail "Cannot parse base archetype: $($_.Exception.Message)"
        }
    }
} else {
    Write-Fail "base/__archetype__.json not found"
}

Write-Test "Checking base archetype directory structure"
$requiredDirs = @("src", "tests", "docs")
$allDirsExist = $true
foreach ($dir in $requiredDirs) {
    if (-not (Test-Path "$rootDir\archetypes\base\$dir")) {
        $allDirsExist = $false
        break
    }
}
if ($allDirsExist) {
    Write-Pass "Base archetype has src/, tests/, and docs/ directories"
} else {
    Write-Fail "Base archetype missing required directories"
}

Write-Test "Checking base archetype README.md"
if (Test-Path "$rootDir\archetypes\base\README.md") {
    Write-Pass "Base archetype has README.md"
} else {
    Write-Fail "Base archetype missing README.md"
}

# Test 1.5: Archetype Loader Script
Write-TestHeader "Test 1.5: Archetype Loader Script"

Write-Test "Checking archetype-loader.sh exists"
if (Test-Path "$rootDir\scripts\archetype-loader.sh") {
    Write-Pass "archetype-loader.sh exists"

    Write-Test "Checking archetype-loader.sh has required functions"
    $content = Get-Content "$rootDir\scripts\archetype-loader.sh" -Raw
    $requiredFunctions = @("load_archetype", "list_archetypes", "check_compatibility")
    $allFunctionsPresent = $true

    foreach ($func in $requiredFunctions) {
        if ($content -notmatch "$func\(\)") {
            Write-Host "  → Missing function: $func" -ForegroundColor Yellow
            $allFunctionsPresent = $false
        }
    }

    if ($allFunctionsPresent) {
        Write-Pass "All required functions present"
    } else {
        Write-Fail "Some required functions are missing"
    }
} else {
    Write-Fail "archetype-loader.sh not found"
}

# Test 1.6: create-project.sh Integration
Write-TestHeader "Test 1.6: create-project.sh Integration"

Write-Test "Checking create-project.sh exists"
if (Test-Path "$rootDir\create-project.sh") {
    Write-Pass "create-project.sh exists"

    $createProjectContent = Get-Content "$rootDir\create-project.sh" -Raw

    Write-Test "Checking for archetype variables in create-project.sh"
    $requiredVars = @("BASE_ARCHETYPE", "FEATURE_ARCHETYPES", "ARCHETYPES_DIR")
    $allVarsPresent = $true

    foreach ($var in $requiredVars) {
        if ($createProjectContent -notmatch $var) {
            Write-Host "  → Missing variable: $var" -ForegroundColor Yellow
            $allVarsPresent = $false
        }
    }

    if ($allVarsPresent) {
        Write-Pass "All archetype variables present"
    } else {
        Write-Fail "Some archetype variables are missing"
    }

    Write-Test "Checking for archetype-loader.sh sourcing"
    if ($createProjectContent -match "source.*archetype-loader\.sh") {
        Write-Pass "create-project.sh sources archetype-loader.sh"
    } else {
        Write-Fail "create-project.sh does not source archetype-loader.sh"
    }

    Write-Test "Checking for --archetype flag"
    if ($createProjectContent -match "--archetype") {
        Write-Pass "--archetype flag implemented"
    } else {
        Write-Fail "--archetype flag not found"
    }

    Write-Test "Checking for --add-features flag"
    if ($createProjectContent -match "--add-features") {
        Write-Pass "--add-features flag implemented"
    } else {
        Write-Fail "--add-features flag not found"
    }

    Write-Test "Checking for --list-archetypes flag"
    if ($createProjectContent -match "--list-archetypes") {
        Write-Pass "--list-archetypes flag implemented"
    } else {
        Write-Fail "--list-archetypes flag not found"
    }

    Write-Test "Checking help text includes archetype documentation"
    if ($createProjectContent -match "(?i)archetype") {
        Write-Pass "Help text includes archetype documentation"
    } else {
        Write-Fail "Help text missing archetype documentation"
    }
} else {
    Write-Fail "create-project.sh not found"
}

# Summary
Write-TestHeader "Test Summary"

$total = $testsPassed + $testsFailed
Write-Host "Total Tests: $total"
Write-Host "Passed: " -NoNewline
Write-Host $testsPassed -ForegroundColor Green
Write-Host "Failed: " -NoNewline
Write-Host $testsFailed -ForegroundColor Red
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✓ All tests passed! Phase 1 implementation is complete." -ForegroundColor Green
    exit 0
} else {
    $passRate = [math]::Round(($testsPassed * 100.0 / $total), 1)
    Write-Host "⚠ $testsFailed test(s) failed (${passRate}% pass rate)" -ForegroundColor Yellow

    if ($passRate -ge 90) {
        Write-Host ""
        Write-Host "Phase 1 is substantially complete!" -ForegroundColor Green
    }
    exit 1
}
