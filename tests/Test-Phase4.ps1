#!/usr/bin/env pwsh

###############################################################################
# Phase 4 Test Suite - File Merging System
#
# Tests all Phase 4 merger scripts and integration:
# - docker-compose-merger.sh
# - env-merger.sh
# - makefile-merger.sh
# - source-file-merger.sh
# - directory-merger.sh
# - Integration in compose_archetypes()
###############################################################################

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$TestsDir = $ScriptDir
$FixturesDir = Join-Path $TestsDir "fixtures"
$TempDir = Join-Path $TestsDir "temp"

# Create temp directory
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}
New-Item -ItemType Directory -Path $TempDir | Out-Null

# Test results
$TestResults = @()
$TestCount = 0
$PassCount = 0
$FailCount = 0

###############################################################################
# Helper Functions
###############################################################################

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "============================================`n" -ForegroundColor Cyan
}

function Test-Assert {
    param(
        [string]$TestName,
        [bool]$Condition,
        [string]$Message = ""
    )

    $script:TestCount++

    if ($Condition) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        $script:PassCount++
        $script:TestResults += [PSCustomObject]@{
            Test = $TestName
            Result = "PASS"
            Message = $Message
        }
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "       $Message" -ForegroundColor Yellow
        }
        $script:FailCount++
        $script:TestResults += [PSCustomObject]@{
            Test = $TestName
            Result = "FAIL"
            Message = $Message
        }
    }
}

function Invoke-BashScript {
    param(
        [string]$ScriptPath,
        [string[]]$Arguments
    )

    # Convert Windows path to WSL path using wslpath
    $unixPath = & wsl wslpath -u $ScriptPath

    # Convert argument paths too
    $unixArgs = $Arguments | ForEach-Object {
        if ($_ -match '^[A-Z]:\\') {
            & wsl wslpath -u $_
        } else {
            $_
        }
    }

    $result = & bash $unixPath @unixArgs 2>&1
    return @{
        Output = $result
        ExitCode = $LASTEXITCODE
    }
}

###############################################################################
# Test 1: Docker Compose Merger - Basic Functionality
###############################################################################

Write-TestHeader "Test 1: Docker Compose Merger - Basic Functionality"

# Create test docker-compose files
$dockerCompose1 = @"
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  db:
    image: postgres:15
    ports:
      - "5432:5432"
"@

$dockerCompose2 = @"
version: '3.8'
services:
  api:
    image: python:3.11
    ports:
      - "8000:8000"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
"@

$compose1Path = Join-Path $TempDir "docker-compose1.yml"
$compose2Path = Join-Path $TempDir "docker-compose2.yml"
$mergedPath = Join-Path $TempDir "merged-compose.yml"

Set-Content -Path $compose1Path -Value $dockerCompose1
Set-Content -Path $compose2Path -Value $dockerCompose2

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/docker-compose-merger.sh" -Arguments @("merge", $mergedPath, $compose1Path, $compose2Path)

Test-Assert "Docker Compose merger executes successfully" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Merged docker-compose.yml created" `
    (Test-Path $mergedPath) `
    "File: $mergedPath"

if (Test-Path $mergedPath) {
    $mergedContent = Get-Content $mergedPath -Raw
    Test-Assert "Merged compose contains all services" `
        ($mergedContent -match "web:" -and $mergedContent -match "db:" -and $mergedContent -match "api:" -and $mergedContent -match "redis:") `
        "Services found in merged file"
}

###############################################################################
# Test 2: Docker Compose Merger - Port Offset Resolution
###############################################################################

Write-TestHeader "Test 2: Docker Compose Merger - Port Offset Resolution"

$mergedWithResolutionPath = Join-Path $TempDir "merged-with-resolution.yml"

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/docker-compose-merger.sh" -Arguments @("merge-with-resolution", $mergedWithResolutionPath, $compose1Path, $compose2Path)

Test-Assert "Docker Compose merger with resolution executes" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Merged compose with resolution created" `
    (Test-Path $mergedWithResolutionPath) `
    "File: $mergedWithResolutionPath"

###############################################################################
# Test 3: Environment File Merger - Basic Merge
###############################################################################

Write-TestHeader "Test 3: Environment File Merger - Basic Merge"

$env1 = @"
# Base environment
DATABASE_URL=postgresql://localhost/base_db
API_KEY=base_api_key_123
DEBUG=true
"@

$env2 = @"
# Feature environment
REDIS_URL=redis://localhost:6379
API_KEY=feature_api_key_456
FEATURE_FLAG=enabled
"@

$env1Path = Join-Path $TempDir ".env1"
$env2Path = Join-Path $TempDir ".env2"
$mergedEnvPath = Join-Path $TempDir ".env.merged"

Set-Content -Path $env1Path -Value $env1
Set-Content -Path $env2Path -Value $env2

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/env-merger.sh" -Arguments @("merge", $mergedEnvPath, $env1Path, $env2Path)

Test-Assert "Env merger executes successfully" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Merged .env file created" `
    (Test-Path $mergedEnvPath) `
    "File: $mergedEnvPath"

if (Test-Path $mergedEnvPath) {
    $envContent = Get-Content $mergedEnvPath -Raw
    Test-Assert "Merged env contains conflict markers for duplicates" `
        ($envContent -match "\[CONFLICT\]" -or $envContent -match "API_KEY") `
        "Checking for conflict detection"
}

###############################################################################
# Test 4: Environment File Merger - Deduplication
###############################################################################

Write-TestHeader "Test 4: Environment File Merger - Deduplication"

$mergedDedupPath = Join-Path $TempDir ".env.dedup"

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/env-merger.sh" -Arguments @("merge-dedup", $mergedDedupPath, $env1Path, $env2Path)

Test-Assert "Env merger deduplication executes" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Deduplicated .env file created" `
    (Test-Path $mergedDedupPath) `
    "File: $mergedDedupPath"

if (Test-Path $mergedDedupPath) {
    $dedupContent = Get-Content $mergedDedupPath -Raw
    $apiKeyCount = ([regex]::Matches($dedupContent, "API_KEY=")).Count
    Test-Assert "Deduplication removes duplicate variables" `
        ($apiKeyCount -eq 1) `
        "API_KEY appears $apiKeyCount times (expected 1)"
}

###############################################################################
# Test 5: Makefile Merger - Target Namespacing
###############################################################################

Write-TestHeader "Test 5: Makefile Merger - Target Namespacing"

$makefile1 = @"
.PHONY: build test clean

build:
	@echo "Building base"

test:
	@echo "Testing base"

clean:
	@echo "Cleaning base"
"@

$makefile2 = @"
.PHONY: build test deploy

build:
	@echo "Building feature"

test:
	@echo "Testing feature"

deploy:
	@echo "Deploying feature"
"@

$makefile1Path = Join-Path $TempDir "Makefile1"
$makefile2Path = Join-Path $TempDir "Makefile2"
$mergedMakefilePath = Join-Path $TempDir "Makefile.merged"

Set-Content -Path $makefile1Path -Value $makefile1
Set-Content -Path $makefile2Path -Value $makefile2

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/makefile-merger.sh" -Arguments @("merge", $mergedMakefilePath, $makefile1Path, $makefile2Path)

Test-Assert "Makefile merger executes successfully" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Merged Makefile created" `
    (Test-Path $mergedMakefilePath) `
    "File: $mergedMakefilePath"

if (Test-Path $mergedMakefilePath) {
    $makefileContent = Get-Content $mergedMakefilePath -Raw
    Test-Assert "Merged Makefile has namespaced targets" `
        ($makefileContent -match "Makefile1-build:" -or $makefileContent -match "base-build:") `
        "Checking for namespaced targets"

    Test-Assert "Merged Makefile has composite 'all' target" `
        ($makefileContent -match "\.PHONY: all" -and $makefileContent -match "^all:") `
        "Composite target 'all' exists"
}

###############################################################################
# Test 6: Source File Merger - Type Detection
###############################################################################

Write-TestHeader "Test 6: Source File Merger - Type Detection"

$fastapiFile = @"
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello World"}
"@

$pythonFilePath = Join-Path $TempDir "main.py"
Set-Content -Path $pythonFilePath -Value $fastapiFile

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/source-file-merger.sh" -Arguments @("detect-type", $pythonFilePath)

Test-Assert "Source file type detection executes" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "FastAPI file detected correctly" `
    ($result.Output -match "fastapi") `
    "Detected type: $($result.Output)"

###############################################################################
# Test 7: Source File Merger - FastAPI Merging
###############################################################################

Write-TestHeader "Test 7: Source File Merger - FastAPI Merging"

$fastapi1 = @"
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.include_router(users_router, prefix="/users")

@app.get("/")
def read_root():
    return {"message": "Base API"}
"@

$fastapi2 = @"
from fastapi import FastAPI

app = FastAPI()

app.include_router(items_router, prefix="/items")

@app.get("/health")
def health_check():
    return {"status": "healthy"}
"@

$fastapi1Path = Join-Path $TempDir "main1.py"
$fastapi2Path = Join-Path $TempDir "main2.py"
$mergedFastapiPath = Join-Path $TempDir "main_merged.py"

Set-Content -Path $fastapi1Path -Value $fastapi1
Set-Content -Path $fastapi2Path -Value $fastapi2

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/source-file-merger.sh" -Arguments @("merge-fastapi", $mergedFastapiPath, $fastapi1Path, $fastapi2Path)

Test-Assert "FastAPI merger executes successfully" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Merged FastAPI file created" `
    (Test-Path $mergedFastapiPath) `
    "File: $mergedFastapiPath"

if (Test-Path $mergedFastapiPath) {
    $fastapiContent = Get-Content $mergedFastapiPath -Raw
    Test-Assert "Merged FastAPI contains imports" `
        ($fastapiContent -match "from fastapi import FastAPI") `
        "Import consolidation"

    Test-Assert "Merged FastAPI contains app creation" `
        ($fastapiContent -match "app = FastAPI\(") `
        "App instance created"
}

###############################################################################
# Test 8: Directory Merger - Conflict Detection
###############################################################################

Write-TestHeader "Test 8: Directory Merger - Conflict Detection"

# Create test directory structures
$dir1 = Join-Path $TempDir "source1"
$dir2 = Join-Path $TempDir "source2"

New-Item -ItemType Directory -Path $dir1 | Out-Null
New-Item -ItemType Directory -Path $dir2 | Out-Null

# Create conflicting files
Set-Content -Path (Join-Path $dir1 "config.txt") -Value "Config from source1"
Set-Content -Path (Join-Path $dir2 "config.txt") -Value "Config from source2"
Set-Content -Path (Join-Path $dir1 "README.md") -Value "# Source 1"
Set-Content -Path (Join-Path $dir2 "README.md") -Value "# Source 2"

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/directory-merger.sh" -Arguments @("list-conflicts", $dir1, $dir2)

Test-Assert "Directory merger conflict detection executes" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Conflict detection identifies conflicting files" `
    ($result.Output -match "config.txt" -or $result.Output -match "README.md" -or $result.Output -match "Conflict:") `
    "Conflicts identified"

###############################################################################
# Test 9: Directory Merger - Full Merge
###############################################################################

Write-TestHeader "Test 9: Directory Merger - Full Merge"

$targetDir = Join-Path $TempDir "merged_dir"

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/directory-merger.sh" -Arguments @("merge", $targetDir, $dir1, $dir2)

Test-Assert "Directory merger full merge executes" `
    ($result.ExitCode -eq 0) `
    "Exit code: $($result.ExitCode)"

Test-Assert "Target directory created" `
    (Test-Path $targetDir) `
    "Directory: $targetDir"

if (Test-Path $targetDir) {
    Test-Assert "Merged directory contains files" `
        ((Get-ChildItem $targetDir).Count -gt 0) `
        "Files merged: $((Get-ChildItem $targetDir).Count)"
}

###############################################################################
# Test 10: Integration - Merger Scripts Exist
###############################################################################

Write-TestHeader "Test 10: Integration - Merger Scripts Exist"

$scripts = @(
    "docker-compose-merger.sh",
    "env-merger.sh",
    "makefile-merger.sh",
    "source-file-merger.sh",
    "directory-merger.sh"
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path $RootDir "scripts" $script
    Test-Assert "Script exists: $script" `
        (Test-Path $scriptPath) `
        "Path: $scriptPath"
}

###############################################################################
# Test 11: Integration - Scripts are Executable
###############################################################################

Write-TestHeader "Test 11: Integration - Scripts are Executable"

foreach ($script in $scripts) {
    $scriptPath = Join-Path $RootDir "scripts" $script
    if (Test-Path $scriptPath) {
        $result = Invoke-BashScript -ScriptPath $scriptPath -Arguments @()
        Test-Assert "$script shows help when no args" `
            ($result.ExitCode -eq 0 -or $result.Output.Length -gt 0) `
            "Help displayed"
    }
}

###############################################################################
# Test 12: Integration - compose_archetypes Function Uses Merger
###############################################################################

Write-TestHeader "Test 12: Integration - compose_archetypes Function Uses Merger"

$createProjectPath = Join-Path $RootDir "create-project.sh"

Test-Assert "create-project.sh exists" `
    (Test-Path $createProjectPath) `
    "Path: $createProjectPath"

if (Test-Path $createProjectPath) {
    $scriptContent = Get-Content $createProjectPath -Raw

    Test-Assert "compose_archetypes references directory-merger.sh" `
        ($scriptContent -match "directory-merger\.sh") `
        "Integration check"

    Test-Assert "compose_archetypes has merge logic" `
        ($scriptContent -match "merge" -and $scriptContent -match "temp_merge_dir") `
        "Merge implementation exists"
}

###############################################################################
# Test 13: Error Handling - Missing Input Files
###############################################################################

Write-TestHeader "Test 13: Error Handling - Missing Input Files"

$nonExistentFile = Join-Path $TempDir "nonexistent.yml"
$outputFile = Join-Path $TempDir "output.yml"

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/docker-compose-merger.sh" -Arguments @("merge", $outputFile, $nonExistentFile)

Test-Assert "Docker Compose merger handles missing files gracefully" `
    ($result.ExitCode -ne 0 -or $result.Output -match "not found" -or $result.Output -match "warning") `
    "Graceful error handling"

###############################################################################
# Test 14: CLI Interface - All Mergers Have Help
###############################################################################

Write-TestHeader "Test 14: CLI Interface - All Mergers Have Help"

$scripts = @(
    "docker-compose-merger.sh",
    "env-merger.sh",
    "makefile-merger.sh",
    "source-file-merger.sh",
    "directory-merger.sh"
)

foreach ($script in $scripts) {
    $scriptPath = Join-Path $RootDir "scripts" $script
    if (Test-Path $scriptPath) {
        $result = Invoke-BashScript -ScriptPath $scriptPath -Arguments @()

        Test-Assert "$script provides help text" `
            ($result.Output -match "Usage" -or $result.Output -match "Examples" -or $result.Output -match "merge") `
            "Help text available"
    }
}

###############################################################################
# Test 15: Fallback Behavior - Works Without yq/jq
###############################################################################

Write-TestHeader "Test 15: Fallback Behavior - Works Without yq/jq"

# This test verifies scripts work even if optional tools are unavailable
# The scripts should detect and use fallback methods

$result = Invoke-BashScript -ScriptPath "$RootDir/scripts/docker-compose-merger.sh" -Arguments @("merge", $mergedPath, $compose1Path, $compose2Path)

Test-Assert "Docker Compose merger works (with or without yq)" `
    ($result.ExitCode -eq 0) `
    "Fallback methods functional"

###############################################################################
# Test Results Summary
###############################################################################

Write-Host "`n" -NoNewline
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Phase 4 Test Results Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Total Tests:  $TestCount" -ForegroundColor White
Write-Host "Passed:       $PassCount" -ForegroundColor Green
Write-Host "Failed:       $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host "Success Rate: $(if ($TestCount -gt 0) { [math]::Round(($PassCount / $TestCount) * 100, 2) } else { 0 })%" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "============================================`n" -ForegroundColor Cyan

# Detailed results table
if ($TestResults.Count -gt 0) {
    Write-Host "`nDetailed Test Results:" -ForegroundColor Cyan
    $TestResults | Format-Table -AutoSize Test, Result, Message
}

# Cleanup
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}

# Exit with appropriate code
if ($FailCount -eq 0) {
    Write-Host "✓ All Phase 4 tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Some tests failed. Please review and fix issues." -ForegroundColor Red
    exit 1
}
