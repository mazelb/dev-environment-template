#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Run comprehensive test suite for dev-environment-template

.DESCRIPTION
    Executes unit tests, integration tests, and e2e tests for both RAG and API archetypes

.PARAMETER TestType
    Type of tests to run: unit, integration, e2e, or all (default: all)

.PARAMETER Archetype
    Archetype to test: rag, api, or both (default: both)

.PARAMETER SkipDocker
    Skip tests that require Docker services

.PARAMETER Coverage
    Generate coverage report

.EXAMPLE
    .\run-tests.ps1 -TestType unit
    .\run-tests.ps1 -Archetype rag -TestType integration
    .\run-tests.ps1 -Coverage
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("unit", "integration", "e2e", "all")]
    [string]$TestType = "all",

    [Parameter(Mandatory=$false)]
    [ValidateSet("rag", "api", "both")]
    [string]$Archetype = "both",

    [Parameter(Mandatory=$false)]
    [switch]$SkipDocker,

    [Parameter(Mandatory=$false)]
    [switch]$Coverage
)

$ErrorActionPreference = "Continue"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = $scriptDir

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Dev Environment Template - Test Suite Runner" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Function to run tests for an archetype
function Run-ArchetypeTests {
    param(
        [string]$ArchetypeName,
        [string]$ArchetypePath,
        [string]$TestTypeArg,
        [bool]$SkipDockerTests,
        [bool]$RunCoverage
    )

    Write-Host "Testing $ArchetypeName Archetype" -ForegroundColor Yellow
    Write-Host "Path: $ArchetypePath" -ForegroundColor Gray
    Write-Host ""

    if (-not (Test-Path $ArchetypePath)) {
        Write-Host "❌ Archetype not found: $ArchetypePath" -ForegroundColor Red
        return $false
    }

    Push-Location $ArchetypePath

    try {
        # Check if pytest is available
        $pytestCheck = python -m pytest --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️  pytest not installed, installing dependencies..." -ForegroundColor Yellow
            python -m pip install -r requirements.txt -q
        }

        # Build pytest command
        $pytestArgs = @()

        # Test type markers
        switch ($TestTypeArg) {
            "unit" { $pytestArgs += "-m", "unit" }
            "integration" { $pytestArgs += "-m", "integration" }
            "e2e" { $pytestArgs += "-m", "e2e" }
            "all" {
                if ($SkipDockerTests) {
                    $pytestArgs += "-m", "not docker"
                }
            }
        }

        # Skip docker tests if requested
        if ($SkipDockerTests -and $TestTypeArg -ne "unit") {
            $pytestArgs += "-m", "not docker"
        }

        # Coverage
        if ($RunCoverage) {
            $pytestArgs += "--cov=src", "--cov-report=term-missing", "--cov-report=html"
        }

        # Run tests
        Write-Host "Running command: python -m pytest $($pytestArgs -join ' ')" -ForegroundColor Gray
        python -m pytest @pytestArgs

        $testResult = $LASTEXITCODE

        if ($testResult -eq 0) {
            Write-Host "✅ $ArchetypeName tests passed!" -ForegroundColor Green
        } else {
            Write-Host "❌ $ArchetypeName tests failed with exit code: $testResult" -ForegroundColor Red
        }

        Write-Host ""
        return ($testResult -eq 0)

    } catch {
        Write-Host "❌ Error running tests: $_" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

# Track results
$results = @{}

# Run RAG archetype tests
if ($Archetype -eq "rag" -or $Archetype -eq "both") {
    $ragPath = Join-Path $rootDir "archetypes\rag-project"
    $results["RAG"] = Run-ArchetypeTests -ArchetypeName "RAG" `
                                         -ArchetypePath $ragPath `
                                         -TestTypeArg $TestType `
                                         -SkipDockerTests $SkipDocker `
                                         -RunCoverage $Coverage
}

# Run API archetype tests
if ($Archetype -eq "api" -or $Archetype -eq "both") {
    $apiPath = Join-Path $rootDir "archetypes\api-service"
    $results["API"] = Run-ArchetypeTests -ArchetypeName "API" `
                                         -ArchetypePath $apiPath `
                                         -TestTypeArg $TestType `
                                         -SkipDockerTests $SkipDocker `
                                         -RunCoverage $Coverage
}

# Run E2E tests if requested
if ($TestType -eq "e2e" -or $TestType -eq "all") {
    Write-Host "Running End-to-End Tests" -ForegroundColor Yellow
    Write-Host ""

    Push-Location $rootDir

    try {
        $e2eArgs = @("-v", "tests/e2e/")

        if ($SkipDocker) {
            $e2eArgs += "-m", "not docker"
        }

        python -m pytest @e2eArgs
        $e2eResult = $LASTEXITCODE

        if ($e2eResult -eq 0) {
            Write-Host "✅ E2E tests passed!" -ForegroundColor Green
        } else {
            Write-Host "❌ E2E tests failed" -ForegroundColor Red
        }

        $results["E2E"] = ($e2eResult -eq 0)

    } catch {
        Write-Host "❌ Error running E2E tests: $_" -ForegroundColor Red
        $results["E2E"] = $false
    } finally {
        Pop-Location
    }

    Write-Host ""
}

# Summary
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true
foreach ($key in $results.Keys) {
    if ($results[$key]) {
        Write-Host "✅ $key" -ForegroundColor Green
    } else {
        Write-Host "❌ $key" -ForegroundColor Red
        $allPassed = $false
    }
}

Write-Host ""

if ($allPassed) {
    Write-Host "🎉 All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Some tests failed. Check output above for details." -ForegroundColor Yellow
    exit 1
}
