#!/usr/bin/env pwsh
###############################################################################
# Test-Phase5.ps1
# Test Suite for Phase 5: GitHub Integration
#
# Tests GitHub CLI integration features:
# - GitHub repository creator script
# - CLI flags for GitHub operations
# - Error handling and graceful degradation
# - Integration into main flow
#
# Note: Phase 5 is NOT YET IMPLEMENTED in the codebase.
# These tests document what SHOULD be tested when Phase 5 is implemented.
###############################################################################

$ErrorActionPreference = "Stop"

# Color codes
$RED = "`e[0;31m"
$GREEN = "`e[0;32m"
$YELLOW = "`e[1;33m"
$BLUE = "`e[0;34m"
$CYAN = "`e[0;36m"
$NC = "`e[0m"

# Test counters
$script:TotalTests = 0
$script:PassedTests = 0
$script:FailedTests = 0
$script:SkippedTests = 0

# Project paths
$TemplateRoot = Split-Path -Parent $PSScriptRoot
$ScriptsDir = Join-Path $TemplateRoot "scripts"
$CreateProjectScript = Join-Path $TemplateRoot "create-project.sh"

# Helper functions
function Write-TestHeader {
    param([string]$Message)
    Write-Host "${BLUE}╔════════════════════════════════════════╗${NC}"
    Write-Host "${BLUE}║${NC} ${Message}${BLUE}${NC}"
    Write-Host "${BLUE}╚════════════════════════════════════════╝${NC}"
}

function Write-Test {
    param([string]$Message)
    $script:TotalTests++
    Write-Host -NoNewline "${CYAN}→${NC} ${Message}... "
}

function Write-Pass {
    param([string]$Message = "PASS")
    $script:PassedTests++
    Write-Host "${GREEN}✓ ${Message}${NC}"
}

function Write-Fail {
    param([string]$Message = "FAIL")
    $script:FailedTests++
    Write-Host "${RED}✗ ${Message}${NC}"
}

function Write-Skip {
    param([string]$Message = "SKIP")
    $script:SkippedTests++
    Write-Host "${YELLOW}⊘ ${Message}${NC}"
}

function Write-Info {
    param([string]$Message)
    Write-Host "${CYAN}ℹ${NC} ${Message}"
}

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "${BLUE}═══════════════════════════════════════════════════${NC}"
    Write-Host "${BLUE}${Message}${NC}"
    Write-Host "${BLUE}═══════════════════════════════════════════════════${NC}"
}

# Test 5.1: GitHub Repository Creator Script
Write-TestHeader "Test 5.1: GitHub Repository Creator Script"

Write-Test "Checking if github-repo-creator.sh exists"
$githubCreatorScript = Join-Path $ScriptsDir "github-repo-creator.sh"
if (Test-Path $githubCreatorScript) {
    Write-Pass "github-repo-creator.sh found"
} else {
    Write-Fail "github-repo-creator.sh NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for create_github_repo function"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "create_github_repo\(\)") {
        Write-Pass "create_github_repo() function exists"
    } else {
        Write-Fail "create_github_repo() function not found"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check function"
}

Write-Test "Checking for gh CLI prerequisite check"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "command -v gh") {
        Write-Pass "gh CLI check found"
    } else {
        Write-Fail "gh CLI prerequisite check missing"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check gh CLI check"
}

Write-Test "Checking for gh auth status check"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "gh auth status") {
        Write-Pass "gh authentication check found"
    } else {
        Write-Fail "gh authentication check missing"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check auth check"
}

Write-Test "Checking for configure_repo_settings function"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "configure_repo_settings\(\)") {
        Write-Pass "configure_repo_settings() function exists"
    } else {
        Write-Fail "configure_repo_settings() function not found"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check function"
}

# Test 5.2: GitHub CLI Flags in create-project.sh
Write-TestHeader "Test 5.2: GitHub CLI Flags"

Write-Test "Checking if create-project.sh exists"
if (Test-Path $CreateProjectScript) {
    Write-Pass "create-project.sh found"
} else {
    Write-Fail "create-project.sh not found"
}

$createProjectContent = Get-Content $CreateProjectScript -Raw

Write-Test "Checking for --github flag"
if ($createProjectContent -match "--github\)") {
    Write-Pass "--github flag exists"
} else {
    Write-Fail "--github flag NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for --github-org flag"
if ($createProjectContent -match "--github-org\)") {
    Write-Pass "--github-org flag exists"
} else {
    Write-Fail "--github-org flag NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for --private flag"
if ($createProjectContent -match "--private\)") {
    Write-Pass "--private flag exists"
} else {
    Write-Fail "--private flag NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for --public flag"
if ($createProjectContent -match "--public\)") {
    Write-Pass "--public flag exists"
} else {
    Write-Fail "--public flag NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for --description flag"
if ($createProjectContent -match "--description\)") {
    Write-Pass "--description flag exists"
} else {
    Write-Fail "--description flag NOT FOUND (Phase 5 not implemented)"
}

Write-Test "Checking for CREATE_GITHUB_REPO variable"
if ($createProjectContent -match "CREATE_GITHUB_REPO=") {
    Write-Pass "CREATE_GITHUB_REPO variable exists"
} else {
    Write-Fail "CREATE_GITHUB_REPO variable NOT FOUND"
}

Write-Test "Checking for GITHUB_ORG variable"
if ($createProjectContent -match "GITHUB_ORG=") {
    Write-Pass "GITHUB_ORG variable exists"
} else {
    Write-Fail "GITHUB_ORG variable NOT FOUND"
}

Write-Test "Checking for GITHUB_VISIBILITY variable"
if ($createProjectContent -match "GITHUB_VISIBILITY=") {
    Write-Pass "GITHUB_VISIBILITY variable exists"
} else {
    Write-Fail "GITHUB_VISIBILITY variable NOT FOUND"
}

# Test 5.3: Integration into Main Flow
Write-TestHeader "Test 5.3: Integration into Main Flow"

Write-Test "Checking github-repo-creator.sh sourced in create-project.sh"
if ($createProjectContent -match "source.*github-repo-creator\.sh") {
    Write-Pass "github-repo-creator.sh is sourced"
} else {
    Write-Fail "github-repo-creator.sh NOT sourced (Phase 5 not implemented)"
}

Write-Test "Checking for GitHub repo creation call"
if ($createProjectContent -match "create_github_repo") {
    Write-Pass "create_github_repo() is called"
} else {
    Write-Fail "create_github_repo() NOT called (Phase 5 not implemented)"
}

Write-Test "Checking if GitHub creation is conditional"
if ($createProjectContent -match "if.*CREATE_GITHUB_REPO.*true") {
    Write-Pass "GitHub creation is conditional on flag"
} else {
    Write-Fail "Conditional GitHub creation NOT FOUND"
}

# Test 5.4: Help Text and Documentation
Write-TestHeader "Test 5.4: Help Text and Documentation"

Write-Test "Checking help text includes --github flag"
if ($createProjectContent -match "help.*--github" -or $createProjectContent -match "--github.*help") {
    Write-Pass "Help text mentions --github flag"
} else {
    Write-Fail "Help text doesn't document --github flag"
}

# Test 5.5: Error Handling
Write-TestHeader "Test 5.5: Error Handling and Graceful Degradation"

Write-Info "These tests check that the script handles missing prerequisites gracefully"

Write-Test "Checking for 'gh not found' error handling"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "GitHub CLI not found" -or $githubCreatorContent -match "gh.*not found") {
        Write-Pass "Error message for missing gh CLI found"
    } else {
        Write-Fail "Missing error handling for gh CLI not installed"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check error handling"
}

Write-Test "Checking for 'not authenticated' error handling"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "not authenticated" -or $githubCreatorContent -match "gh auth login") {
        Write-Pass "Error message for authentication found"
    } else {
        Write-Fail "Missing error handling for authentication"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check error handling"
}

Write-Test "Checking for graceful continuation without gh CLI"
if (Test-Path $githubCreatorScript) {
    $githubCreatorContent = Get-Content $githubCreatorScript -Raw
    if ($githubCreatorContent -match "return 1" -or $githubCreatorContent -match "return \$\?") {
        Write-Pass "Script can continue without GitHub creation"
    } else {
        Write-Fail "Script doesn't handle missing gh gracefully"
    }
} else {
    Write-Skip "Script doesn't exist - cannot check graceful handling"
}

# Test 5.6: CI/CD Workflow Templates (Optional)
Write-TestHeader "Test 5.6: CI/CD Workflow Templates (Optional)"

Write-Info "These tests check for optional CI/CD workflow generation"

$workflowsDir = Join-Path $TemplateRoot "templates" ".github" "workflows"
Write-Test "Checking for GitHub workflows directory"
if (Test-Path $workflowsDir) {
    Write-Pass "Workflows directory exists"
} else {
    Write-Skip "Workflows directory not found (optional feature)"
}

Write-Test "Checking for CI workflow template"
$ciWorkflow = Join-Path $workflowsDir "ci.yml"
if (Test-Path $ciWorkflow) {
    Write-Pass "CI workflow template exists"
} else {
    Write-Skip "CI workflow template not found (optional)"
}

Write-Test "Checking for Docker build workflow template"
$dockerWorkflow = Join-Path $workflowsDir "docker-build.yml"
if (Test-Path $dockerWorkflow) {
    Write-Pass "Docker build workflow exists"
} else {
    Write-Skip "Docker build workflow not found (optional)"
}

# Test 5.7: Documentation
Write-TestHeader "Test 5.7: Documentation"

Write-Test "Checking for GitHub integration documentation"
$githubDoc = Join-Path $TemplateRoot "docs" "GIT_GITHUB_INTEGRATION.md"
if (Test-Path $githubDoc) {
    Write-Pass "GIT_GITHUB_INTEGRATION.md found"
} else {
    Write-Fail "GIT_GITHUB_INTEGRATION.md not found"
}

Write-Test "Checking if documentation covers --github flag"
if (Test-Path $githubDoc) {
    $docContent = Get-Content $githubDoc -Raw
    if ($docContent -match "--github") {
        Write-Pass "Documentation covers --github flag"
    } else {
        Write-Fail "Documentation missing --github flag details"
    }
} else {
    Write-Skip "Cannot check documentation content"
}

Write-Test "Checking if documentation covers gh CLI setup"
if (Test-Path $githubDoc) {
    $docContent = Get-Content $githubDoc -Raw
    if ($docContent -match "gh auth login" -or $docContent -match "GitHub CLI") {
        Write-Pass "Documentation covers gh CLI setup"
    } else {
        Write-Fail "Documentation missing gh CLI setup"
    }
} else {
    Write-Skip "Cannot check documentation content"
}

# Print Summary
Write-Section "Phase 5 Test Summary"
Write-Host ""
Write-Host "Total Tests:   ${TotalTests}"
Write-Host "Passed:        ${GREEN}${PassedTests}${NC}"
Write-Host "Failed:        ${RED}${FailedTests}${NC}"
Write-Host "Skipped:       ${YELLOW}${SkippedTests}${NC}"
Write-Host ""

if ($FailedTests -gt 0) {
    $successRate = [math]::Round(($PassedTests / ($TotalTests - $SkippedTests)) * 100, 1)
    Write-Host "Success Rate:  ${YELLOW}${successRate}%${NC}"
    Write-Host ""
    Write-Host "${YELLOW}⚠ IMPORTANT: Phase 5 (GitHub Integration) is NOT YET IMPLEMENTED${NC}"
    Write-Host "${CYAN}ℹ These tests document what should be tested when Phase 5 is implemented.${NC}"
    Write-Host "${CYAN}ℹ See IMPLEMENTATION_STRATEGY.md Phase 5 for implementation details.${NC}"
    Write-Host ""
    Write-Host "${CYAN}ℹ Next Steps:${NC}"
    Write-Host "  1. Implement scripts/github-repo-creator.sh"
    Write-Host "  2. Add --github, --github-org, --private, --public flags to create-project.sh"
    Write-Host "  3. Integrate GitHub creation into main flow"
    Write-Host "  4. Re-run this test suite to validate implementation"
    Write-Host ""
    exit 1
} else {
    Write-Host "Success Rate:  ${GREEN}100%${NC}"
    Write-Host ""
    Write-Host "${GREEN}✓ All tests passed!${NC}"
    Write-Host ""
    exit 0
}
