###############################################################################
# Comprehensive Test Suite for create-project.sh (PowerShell)
# Tests all command-line options, archetypes, features, and edge cases
###############################################################################

# Test configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Split-Path -Parent $ScriptDir
$CreateProjectScript = Join-Path $TemplateDir "create-project.sh"
$TestOutputDir = Join-Path $ScriptDir "temp\test-projects"
$TestResultsFile = Join-Path $ScriptDir "temp\test-results.txt"

# Counters
$Script:TotalTests = 0
$Script:PassedTests = 0
$Script:FailedTests = 0
$Script:SkippedTests = 0
$Script:TestResults = @()

# Setup
function Setup-Tests {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║   Create Project Test Suite      ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""

    # Clean up old test directory
    if (Test-Path $TestOutputDir) {
        Write-Host "Cleaning up old test directory..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $TestOutputDir
    }

    # Create fresh test directory
    New-Item -ItemType Directory -Force -Path $TestOutputDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path $TestResultsFile) | Out-Null

    # Initialize results file
    "Create Project Test Results - $(Get-Date)" | Out-File -FilePath $TestResultsFile
    "===========================================" | Out-File -FilePath $TestResultsFile -Append
    "" | Out-File -FilePath $TestResultsFile -Append

    Write-Host "✓ Test environment setup complete" -ForegroundColor Green
    Write-Host ""
}

# Test helper functions
function Print-TestHeader {
    param([string]$TestName)
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST: $TestName" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
}

function Test-Passed {
    param([string]$TestName)
    $Script:PassedTests++
    $Script:TotalTests++
    Write-Host "✓ PASSED: $TestName" -ForegroundColor Green
    "PASS: $TestName" | Out-File -FilePath $TestResultsFile -Append
    $Script:TestResults += "PASS: $TestName"
}

function Test-Failed {
    param(
        [string]$TestName,
        [string]$Reason
    )
    $Script:FailedTests++
    $Script:TotalTests++
    Write-Host "✗ FAILED: $TestName" -ForegroundColor Red
    Write-Host "  Reason: $Reason" -ForegroundColor Red
    "FAIL: $TestName - $Reason" | Out-File -FilePath $TestResultsFile -Append
    $Script:TestResults += "FAIL: $TestName - $Reason"
}

function Test-Skipped {
    param(
        [string]$TestName,
        [string]$Reason
    )
    $Script:SkippedTests++
    $Script:TotalTests++
    Write-Host "⊘ SKIPPED: $TestName" -ForegroundColor Yellow
    Write-Host "  Reason: $Reason" -ForegroundColor Yellow
    "SKIP: $TestName - $Reason" | Out-File -FilePath $TestResultsFile -Append
    $Script:TestResults += "SKIP: $TestName - $Reason"
}

function Cleanup-TestProject {
    param([string]$ProjectPath)
    if (Test-Path $ProjectPath) {
        Remove-Item -Recurse -Force $ProjectPath
    }
}

function Invoke-BashScript {
    param(
        [string]$Script,
        [string[]]$Arguments
    )

    $bashCmd = "bash"
    $allArgs = @($Script) + $Arguments

    try {
        $output = & $bashCmd $allArgs 2>&1
        return @{
            Success = $LASTEXITCODE -eq 0
            Output = $output -join "`n"
        }
    } catch {
        return @{
            Success = $false
            Output = $_.Exception.Message
        }
    }
}

# Test 1: Basic help command
function Test-HelpCommand {
    Print-TestHeader "Help Command (--help)"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @("--help")

    if ($result.Success) {
        Test-Passed "Help command displays usage"
    } else {
        Test-Failed "Help command displays usage" "Command failed"
    }
    Write-Host ""
}

# Test 2: List archetypes
function Test-ListArchetypes {
    Print-TestHeader "List Archetypes (--list-archetypes)"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @("--list-archetypes")

    if ($result.Output -match "BASE ARCHETYPES" -and
        $result.Output -match "FEATURE ARCHETYPES" -and
        $result.Output -match "COMPOSITE ARCHETYPES") {
        Test-Passed "List archetypes shows all categories"
    } else {
        Test-Failed "List archetypes shows all categories" "Missing archetype categories"
    }
    Write-Host ""
}

# Test 3: List features
function Test-ListFeatures {
    Print-TestHeader "List Features (--list-features)"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @("--list-features")

    if ($result.Output -match "Feature Archetypes") {
        Test-Passed "List features displays feature archetypes"
    } else {
        Test-Failed "List features displays feature archetypes" "No feature archetypes found"
    }
    Write-Host ""
}

# Test 4: List tools
function Test-ListTools {
    Print-TestHeader "List Tools (--list-tools)"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @("--list-tools")

    if ($result.Output -match "Available Optional Tools") {
        Test-Passed "List tools displays available tools"
    } else {
        Test-Failed "List tools displays available tools" "Tools not displayed"
    }
    Write-Host ""
}

# Test 5: List presets
function Test-ListPresets {
    Print-TestHeader "List Presets (--list-presets)"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @("--list-presets")

    if ($result.Output -match "Available Presets") {
        Test-Passed "List presets displays available presets"
    } else {
        Test-Failed "List presets displays available presets" "Presets not displayed"
    }
    Write-Host ""
}

# Test 6: Dry run mode
function Test-DryRun {
    Print-TestHeader "Dry Run Mode (--dry-run)"

    $testName = "test-dry-run"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--dry-run"
    )

    if ($result.Output -match "Dry Run Preview" -and -not (Test-Path $projectPath)) {
        Test-Passed "Dry run shows preview without creating files"
    } else {
        Test-Failed "Dry run shows preview without creating files" "Preview not shown or files created"
        Cleanup-TestProject $projectPath
    }
    Write-Host ""
}

# Test 7: Create project with base archetype
function Test-BaseArchetype {
    Print-TestHeader "Base Archetype (--archetype base)"

    $testName = "test-base-archetype"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path $projectPath) -and (Test-Path (Join-Path $projectPath "README.md"))) {
        Test-Passed "Base archetype creates project structure"
    } else {
        Test-Failed "Base archetype creates project structure" "Project or README not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 8: Create project with RAG archetype
function Test-RagArchetype {
    Print-TestHeader "RAG Archetype (--archetype rag-project)"

    $testName = "test-rag-archetype"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "rag-project",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path $projectPath) -and (Test-Path (Join-Path $projectPath "README.md"))) {
        Test-Passed "RAG archetype creates project structure"
    } else {
        Test-Failed "RAG archetype creates project structure" "Project or README not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 9: Create project with feature archetypes
function Test-FeatureArchetypes {
    Print-TestHeader "Feature Archetypes (--add-features)"

    $testName = "test-features"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--add-features", "monitoring",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path $projectPath) -and (Test-Path (Join-Path $projectPath "COMPOSITION.md"))) {
        Test-Passed "Feature archetypes composition works"
    } else {
        Test-Failed "Feature archetypes composition works" "COMPOSITION.md not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 10: Create project with multiple features
function Test-MultipleFeatures {
    Print-TestHeader "Multiple Features (--add-features monitoring,agentic-workflows)"

    $testName = "test-multi-features"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--add-features", "monitoring,agentic-workflows",
        "--no-git",
        "--no-build"
    )

    $compositionPath = Join-Path $projectPath "COMPOSITION.md"
    if ((Test-Path $compositionPath)) {
        $content = Get-Content $compositionPath -Raw
        if ($content -match "monitoring" -and $content -match "agentic-workflows") {
            Test-Passed "Multiple features composition works"
        } else {
            Test-Failed "Multiple features composition works" "Features not in COMPOSITION.md"
        }
    } else {
        Test-Failed "Multiple features composition works" "COMPOSITION.md not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 11: Create project with optional tools
function Test-OptionalTools {
    Print-TestHeader "Optional Tools (--tools fastapi,postgresql)"

    $testName = "test-tools"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--tools", "fastapi,postgresql",
        "--no-git",
        "--no-build"
    )

    if (Test-Path (Join-Path $projectPath "OPTIONAL_TOOLS.md")) {
        Test-Passed "Optional tools integration works"
    } else {
        Test-Failed "Optional tools integration works" "OPTIONAL_TOOLS.md not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 12: Create project with preset
function Test-Preset {
    Print-TestHeader "Preset (--preset ai-agent)"

    $testName = "test-preset"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--preset", "ai-agent",
        "--no-git",
        "--no-build"
    )

    if (Test-Path (Join-Path $projectPath "OPTIONAL_TOOLS.md")) {
        Test-Passed "Preset integration works"
    } else {
        Test-Failed "Preset integration works" "OPTIONAL_TOOLS.md not created"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 13: Verbose mode
function Test-VerboseMode {
    Print-TestHeader "Verbose Mode (--verbose)"

    $testName = "test-verbose"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--verbose",
        "--no-git",
        "--no-build"
    )

    if ($result.Output -match "Resolved project path") {
        Test-Passed "Verbose mode provides detailed output"
    } else {
        Test-Failed "Verbose mode provides detailed output" "Verbose output not detected"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 14: No-git flag
function Test-NoGitFlag {
    Print-TestHeader "No Git Flag (--no-git)"

    $testName = "test-no-git"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path $projectPath) -and -not (Test-Path (Join-Path $projectPath ".git"))) {
        Test-Passed "No-git flag prevents Git initialization"
    } else {
        Test-Failed "No-git flag prevents Git initialization" ".git directory exists"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 15: Error handling - missing arguments
function Test-MissingArguments {
    Print-TestHeader "Error Handling - Missing Arguments"

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @()

    if ($result.Output -match "Either --name or --path is required") {
        Test-Passed "Error handling for missing required arguments"
    } else {
        Test-Failed "Error handling for missing required arguments" "Expected error not shown"
    }
    Write-Host ""
}

# Test 16: Error handling - existing directory
function Test-ExistingDirectory {
    Print-TestHeader "Error Handling - Existing Directory"

    $testName = "test-existing"
    $projectPath = Join-Path $TestOutputDir $testName

    # Create directory first
    New-Item -ItemType Directory -Force -Path $projectPath | Out-Null

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--no-git",
        "--no-build"
    )

    if ($result.Output -match "already exists") {
        Test-Passed "Error handling for existing directory"
    } else {
        Test-Failed "Error handling for existing directory" "Expected error not shown"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 17: Documentation generation
function Test-DocumentationGeneration {
    Print-TestHeader "Documentation Generation"

    $testName = "test-docs"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "rag-project",
        "--add-features", "monitoring",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path (Join-Path $projectPath "README.md")) -and
        (Test-Path (Join-Path $projectPath "COMPOSITION.md"))) {
        Test-Passed "Documentation files generated correctly"
    } else {
        Test-Failed "Documentation files generated correctly" "Missing documentation files"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Test 18: Project structure creation
function Test-ProjectStructure {
    Print-TestHeader "Project Structure Creation"

    $testName = "test-structure"
    $projectPath = Join-Path $TestOutputDir $testName

    $result = Invoke-BashScript -Script $CreateProjectScript -Arguments @(
        "--name", $testName,
        "--path", $projectPath,
        "--archetype", "base",
        "--no-git",
        "--no-build"
    )

    if ((Test-Path (Join-Path $projectPath "src")) -and
        (Test-Path (Join-Path $projectPath "tests")) -and
        (Test-Path (Join-Path $projectPath "docs"))) {
        Test-Passed "Project directory structure created"
    } else {
        Test-Failed "Project directory structure created" "Missing directories"
    }

    Cleanup-TestProject $projectPath
    Write-Host ""
}

# Summary report
function Print-Summary {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║   Test Summary                    ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Total Tests:   $Script:TotalTests"
    Write-Host "Passed:        $Script:PassedTests" -ForegroundColor Green
    Write-Host "Failed:        $Script:FailedTests" -ForegroundColor Red
    Write-Host "Skipped:       $Script:SkippedTests" -ForegroundColor Yellow
    Write-Host ""

    if ($Script:FailedTests -gt 0) {
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($result in $Script:TestResults) {
            if ($result -match "^FAIL:") {
                Write-Host "  ✗ $($result.Substring(6))" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    $successRate = if ($Script:TotalTests -gt 0) {
        [math]::Round(($Script:PassedTests / $Script:TotalTests) * 100, 2)
    } else { 0 }

    Write-Host "Success Rate:  $successRate%"
    Write-Host ""

    # Write summary to file
    "" | Out-File -FilePath $TestResultsFile -Append
    "===========================================" | Out-File -FilePath $TestResultsFile -Append
    "SUMMARY" | Out-File -FilePath $TestResultsFile -Append
    "===========================================" | Out-File -FilePath $TestResultsFile -Append
    "Total Tests: $Script:TotalTests" | Out-File -FilePath $TestResultsFile -Append
    "Passed: $Script:PassedTests" | Out-File -FilePath $TestResultsFile -Append
    "Failed: $Script:FailedTests" | Out-File -FilePath $TestResultsFile -Append
    "Skipped: $Script:SkippedTests" | Out-File -FilePath $TestResultsFile -Append
    "Success Rate: $successRate%" | Out-File -FilePath $TestResultsFile -Append

    Write-Host "Full results saved to: $TestResultsFile" -ForegroundColor Cyan
    Write-Host ""

    if ($Script:FailedTests -eq 0) {
        Write-Host "🎉 All tests passed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Some tests failed" -ForegroundColor Red
        return $false
    }
}

# Main test execution
function Main {
    Setup-Tests

    # Check if create-project.sh exists
    if (-not (Test-Path $CreateProjectScript)) {
        Write-Host "ERROR: create-project.sh not found at $CreateProjectScript" -ForegroundColor Red
        exit 1
    }

    # Check if bash is available
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: bash not found. Please install Git Bash or WSL" -ForegroundColor Red
        exit 1
    }

    # Run all tests
    Test-HelpCommand
    Test-ListArchetypes
    Test-ListFeatures
    Test-ListTools
    Test-ListPresets
    Test-DryRun
    Test-BaseArchetype
    Test-RagArchetype
    Test-FeatureArchetypes
    Test-MultipleFeatures
    Test-OptionalTools
    Test-Preset
    Test-VerboseMode
    Test-NoGitFlag
    Test-MissingArguments
    Test-ExistingDirectory
    Test-DocumentationGeneration
    Test-ProjectStructure

    # Print summary
    $success = Print-Summary

    if ($success) {
        exit 0
    } else {
        exit 1
    }
}

# Run tests
Main
