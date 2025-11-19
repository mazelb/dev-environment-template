# Phase 2 Integration Test (PowerShell)
# Tests Git Integration implementation

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

# Main test suite
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║  Phase 2: Git Integration Test Suite                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

$rootDir = $PSScriptRoot + "\.."

# Test 2.1: Git Flag Changes
Write-TestHeader "Test 2.1: Git Initialization is Now Default"

Write-Test "Checking USE_GIT removed and SKIP_GIT added"
$createProjectContent = Get-Content "$rootDir\create-project.sh" -Raw

if ($createProjectContent -match "SKIP_GIT=false" -and $createProjectContent -notmatch "USE_GIT=false") {
    Write-Pass "SKIP_GIT variable added (Git is now default)"
} else {
    Write-Fail "Git flag variables not updated correctly"
}

Write-Test "Checking --no-git flag implemented"
if ($createProjectContent -match "--no-git") {
    Write-Pass "--no-git opt-out flag implemented"
} else {
    Write-Fail "--no-git flag not found"
}

Write-Test "Checking --git flag removed from help"
if ($createProjectContent -notmatch "-g, --git") {
    Write-Pass "--git flag removed from options"
} else {
    Write-Fail "--git flag still present (should be removed)"
}

# Test 2.2: Git Helper Script
Write-TestHeader "Test 2.2: Git Helper Script"

Write-Test "Checking scripts/git-helper.sh exists"
if (Test-Path "$rootDir\scripts\git-helper.sh") {
    Write-Pass "git-helper.sh exists"

    $gitHelperContent = Get-Content "$rootDir\scripts\git-helper.sh" -Raw

    Write-Test "Checking generate_commit_message() function"
    if ($gitHelperContent -match "generate_commit_message\(\)") {
        Write-Pass "generate_commit_message() function present"
    } else {
        Write-Fail "generate_commit_message() function missing"
    }

    Write-Test "Checking list_archetypes_with_versions() function"
    if ($gitHelperContent -match "list_archetypes_with_versions\(\)") {
        Write-Pass "list_archetypes_with_versions() function present"
    } else {
        Write-Fail "list_archetypes_with_versions() function missing"
    }

    Write-Test "Checking list_services_from_archetypes() function"
    if ($gitHelperContent -match "list_services_from_archetypes\(\)") {
        Write-Pass "list_services_from_archetypes() function present"
    } else {
        Write-Fail "list_services_from_archetypes() function missing"
    }

    Write-Test "Checking get_template_version() function"
    if ($gitHelperContent -match "get_template_version\(\)") {
        Write-Pass "get_template_version() function present"
    } else {
        Write-Fail "get_template_version() function missing"
    }
} else {
    Write-Fail "git-helper.sh not found"
}

# Test 2.3: Git Initialization Function
Write-TestHeader "Test 2.3: Git Initialization Function"

Write-Test "Checking initialize_git_repository() function"
if ($gitHelperContent -match "initialize_git_repository\(\)") {
    Write-Pass "initialize_git_repository() function present"

    Write-Test "Checking for error handling"
    if ($gitHelperContent -match "print_error" -and $gitHelperContent -match "return 1") {
        Write-Pass "Error handling implemented"
    } else {
        Write-Fail "Error handling not found"
    }

    Write-Test "Checking for git availability check"
    if ($gitHelperContent -match "command -v git") {
        Write-Pass "Git availability check present"
    } else {
        Write-Fail "Git availability check missing"
    }
} else {
    Write-Fail "initialize_git_repository() function missing"
}

# Test 2.4: Gitignore Generator
Write-TestHeader "Test 2.4: Smart .gitignore Generator"

Write-Test "Checking scripts/gitignore-generator.sh exists"
if (Test-Path "$rootDir\scripts\gitignore-generator.sh") {
    Write-Pass "gitignore-generator.sh exists"

    $gitignoreContent = Get-Content "$rootDir\scripts\gitignore-generator.sh" -Raw

    Write-Test "Checking generate_gitignore() function"
    if ($gitignoreContent -match "generate_gitignore\(\)") {
        Write-Pass "generate_gitignore() function present"
    } else {
        Write-Fail "generate_gitignore() function missing"
    }

    Write-Test "Checking generate_base_gitignore() function"
    if ($gitignoreContent -match "generate_base_gitignore\(\)") {
        Write-Pass "generate_base_gitignore() function present"
    } else {
        Write-Fail "generate_base_gitignore() function missing"
    }

    Write-Test "Checking get_archetype_patterns() function"
    if ($gitignoreContent -match "get_archetype_patterns\(\)") {
        Write-Pass "get_archetype_patterns() function present"
    } else {
        Write-Fail "get_archetype_patterns() function missing"
    }

    Write-Test "Checking add_tool_patterns() function"
    if ($gitignoreContent -match "add_tool_patterns\(\)") {
        Write-Pass "add_tool_patterns() function present"
    } else {
        Write-Fail "add_tool_patterns() function missing"
    }

    Write-Test "Checking tool-specific patterns included"
    $tools = @("postgresql", "opensearch", "ollama", "airflow")
    $toolsFound = 0
    foreach ($tool in $tools) {
        if ($gitignoreContent -match $tool) {
            $toolsFound++
        }
    }
    if ($toolsFound -eq $tools.Count) {
        Write-Pass "Tool-specific patterns present for all major tools"
    } else {
        Write-Fail "Missing tool-specific patterns ($toolsFound/$($tools.Count) found)"
    }
} else {
    Write-Fail "gitignore-generator.sh not found"
}

# Test 2.5: Integration in create-project.sh
Write-TestHeader "Test 2.5: Integration into Main Flow"

Write-Test "Checking git-helper.sh sourced in create-project.sh"
if ($createProjectContent -match "source.*git-helper\.sh") {
    Write-Pass "git-helper.sh is sourced"
} else {
    Write-Fail "git-helper.sh not sourced"
}

Write-Test "Checking gitignore-generator.sh sourced"
if ($createProjectContent -match "source.*gitignore-generator\.sh") {
    Write-Pass "gitignore-generator.sh is sourced"
} else {
    Write-Fail "gitignore-generator.sh not sourced"
}

Write-Test "Checking .gitignore generation call"
if ($createProjectContent -match "generate_gitignore") {
    Write-Pass ".gitignore generation integrated"
} else {
    Write-Fail ".gitignore generation not integrated"
}

Write-Test "Checking initialize_git_repository() call"
if ($createProjectContent -match "initialize_git_repository") {
    Write-Pass "Smart Git initialization integrated"
} else {
    Write-Fail "Smart Git initialization not integrated"
}

Write-Test "Checking Git initialization includes archetype info"
if ($createProjectContent -match "archetypes_list" -and $createProjectContent -match "tools_list") {
    Write-Pass "Git initialization passes archetype and tool information"
} else {
    Write-Fail "Git initialization missing archetype/tool context"
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
    Write-Host "✓ All tests passed! Phase 2 implementation is complete." -ForegroundColor Green
    exit 0
} else {
    $passRate = [math]::Round(($testsPassed * 100.0 / $total), 1)
    Write-Host "⚠ $testsFailed test(s) failed (${passRate}% pass rate)" -ForegroundColor Yellow

    if ($passRate -ge 90) {
        Write-Host ""
        Write-Host "Phase 2 is substantially complete!" -ForegroundColor Green
    }
    exit 1
}
