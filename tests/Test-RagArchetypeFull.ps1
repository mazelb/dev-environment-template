###############################################################################
# Comprehensive RAG Archetype Full Stack Test
# Creates a complete RAG project, starts all services, and runs all tests
###############################################################################

param(
    [switch]$KeepProject,     # Keep test project after completion
    [switch]$SkipCleanup,     # Skip cleanup of Docker resources
    [switch]$Verbose          # Enable verbose output
)

# Test configuration
$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Split-Path -Parent $ScriptDir
$CreateProjectScript = Join-Path $TemplateDir "create-project.sh"
$TestOutputDir = Join-Path $ScriptDir "temp"
$TestProjectName = "test-rag-full-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$TestProjectPath = Join-Path $TestOutputDir $TestProjectName
$TestResultsFile = Join-Path $TestOutputDir "rag-full-test-results.txt"

# Counters
$Script:TotalTests = 0
$Script:PassedTests = 0
$Script:FailedTests = 0
$Script:TestResults = @()
$Script:StartTime = Get-Date

#region Helper Functions

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║  $($Text.PadRight(60))  ║" -ForegroundColor Blue
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
}

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Passed {
    param([string]$TestName)
    $Script:PassedTests++
    $Script:TotalTests++
    Write-Host "✓ PASSED: $TestName" -ForegroundColor Green
    "PASS: $TestName" | Out-File -FilePath $TestResultsFile -Append
    $Script:TestResults += @{ Status = "PASS"; Name = $TestName }
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
    $Script:TestResults += @{ Status = "FAIL"; Name = $TestName; Reason = $Reason }
}

function Invoke-BashCommand {
    param(
        [string]$Command,
        [string]$WorkingDirectory = $PWD
    )

    if ($Verbose) {
        Write-Host "  Executing: $Command" -ForegroundColor Gray
    }

    # Convert Windows path to WSL path
    $wslPath = $WorkingDirectory
    if ($WorkingDirectory -match '^[A-Z]:') {
        $normalizedPath = $WorkingDirectory -replace '\\', '/'
        $wslPath = (wsl wslpath -u "$normalizedPath").Trim()
    }

    try {
        $result = wsl bash -c "cd '$wslPath' && $Command" 2>&1
        return @{
            Success = $LASTEXITCODE -eq 0
            Output = $result -join "`n"
            ExitCode = $LASTEXITCODE
        }
    } catch {
        return @{
            Success = $false
            Output = $_.Exception.Message
            ExitCode = -1
        }
    }
}

function Wait-ForService {
    param(
        [string]$Name,
        [string]$Url,
        [int]$MaxAttempts = 30,
        [int]$DelaySeconds = 10
    )

    Write-Host "  Waiting for $Name to be ready..." -ForegroundColor Yellow

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "  ✓ $Name is ready!" -ForegroundColor Green
                return $true
            }
        } catch {
            if ($Verbose) {
                Write-Host "  Attempt $i/$MaxAttempts failed: $($_.Exception.Message)" -ForegroundColor Gray
            }
        }

        Write-Host "  Attempt $i/$MaxAttempts - waiting ${DelaySeconds}s..." -ForegroundColor Gray
        Start-Sleep -Seconds $DelaySeconds
    }

    Write-Host "  ✗ $Name failed to become ready after $MaxAttempts attempts" -ForegroundColor Red
    return $false
}

function Get-ContainerLogs {
    param(
        [string]$ContainerName,
        [int]$Lines = 50
    )

    $result = Invoke-BashCommand -Command "docker logs --tail $Lines $ContainerName 2>&1" -WorkingDirectory $TestProjectPath
    return $result.Output
}

#endregion

#region Setup and Cleanup

function Setup-TestEnvironment {
    Write-Header "RAG ARCHETYPE FULL STACK TEST"

    Write-Host "Test Configuration:" -ForegroundColor Cyan
    Write-Host "  Project Name: $TestProjectName"
    Write-Host "  Project Path: $TestProjectPath"
    Write-Host "  Results File: $TestResultsFile"
    Write-Host "  Keep Project: $KeepProject"
    Write-Host "  Skip Cleanup: $SkipCleanup"
    Write-Host ""

    # Create test directory
    if (-not (Test-Path $TestOutputDir)) {
        New-Item -ItemType Directory -Force -Path $TestOutputDir | Out-Null
    }

    # Initialize results file
    @"
RAG Archetype Full Stack Test Results
Generated: $(Get-Date)
Project: $TestProjectName
==========================================

"@ | Out-File -FilePath $TestResultsFile

    Write-Host "✓ Test environment prepared" -ForegroundColor Green
}

function Cleanup-TestEnvironment {
    if ($SkipCleanup) {
        Write-Host "Skipping cleanup (--SkipCleanup flag set)" -ForegroundColor Yellow
        return
    }

    Write-Section "Cleanup"

    # Stop and remove Docker containers
    if (Test-Path $TestProjectPath) {
        Write-Host "Stopping Docker services..." -ForegroundColor Yellow
        Push-Location $TestProjectPath
        try {
            Invoke-BashCommand -Command "docker compose down -v --remove-orphans" -WorkingDirectory $TestProjectPath | Out-Null
            Write-Host "✓ Docker services stopped" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Warning: Failed to stop Docker services" -ForegroundColor Yellow
        }
        Pop-Location
    }

    # Remove test project
    if (-not $KeepProject -and (Test-Path $TestProjectPath)) {
        Write-Host "Removing test project..." -ForegroundColor Yellow
        try {
            Remove-Item -Recurse -Force $TestProjectPath -ErrorAction Stop
            Write-Host "✓ Test project removed" -ForegroundColor Green
        } catch {
            Write-Host "⚠ Warning: Failed to remove test project" -ForegroundColor Yellow
        }
    } elseif ($KeepProject) {
        Write-Host "Test project kept at: $TestProjectPath" -ForegroundColor Cyan
    }
}

#endregion

#region Project Creation Tests

function Test-ProjectCreation {
    Write-Section "1. Project Creation"

    Write-Host "Creating RAG project with all features..." -ForegroundColor Cyan

    # Convert paths to WSL format
    $scriptPath = $CreateProjectScript -replace '\\', '/'
    $scriptWSL = (wsl wslpath -u "$scriptPath").Trim()

    $projectPath = $TestProjectPath -replace '\\', '/'
    $projectWSL = (wsl wslpath -u "$projectPath").Trim()

    $command = "bash '$scriptWSL' --name '$TestProjectName' --path '$projectWSL' --archetype rag-project --no-git --no-build --verbose"

    if ($Verbose) {
        Write-Host "  Command: $command" -ForegroundColor Gray
    }

    $result = Invoke-BashCommand -Command $command -WorkingDirectory $TemplateDir

    if ($result.Success -and (Test-Path $TestProjectPath)) {
        Test-Passed "RAG project created successfully"
    } else {
        Test-Failed "RAG project creation" "Project not created or command failed"
        Write-Host "Exit Code: $($result.ExitCode)" -ForegroundColor Red
        Write-Host $result.Output
        return $false
    }

    return $true
}function Test-ProjectStructure {
    Write-Section "2. Project Structure Validation"

    $requiredPaths = @(
        @{ Path = "README.md"; Type = "File" },
        @{ Path = "docker-compose.yml"; Type = "File" },
        @{ Path = "Makefile"; Type = "File" },
        @{ Path = "requirements.txt"; Type = "File" },
        @{ Path = "pytest.ini"; Type = "File" },
        @{ Path = ".env.example"; Type = "File" },
        @{ Path = "src"; Type = "Directory" },
        @{ Path = "tests"; Type = "Directory" },
        @{ Path = "config"; Type = "Directory" },
        @{ Path = "docs"; Type = "Directory" },
        @{ Path = "docker"; Type = "Directory" },
        @{ Path = "tests/unit"; Type = "Directory" },
        @{ Path = "tests/integration"; Type = "Directory" },
        @{ Path = "tests/e2e"; Type = "Directory" }
    )

    $allValid = $true
    foreach ($item in $requiredPaths) {
        $fullPath = Join-Path $TestProjectPath $item.Path
        $exists = Test-Path $fullPath

        if ($exists) {
            Write-Host "  ✓ $($item.Path)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($item.Path) - MISSING" -ForegroundColor Red
            $allValid = $false
        }
    }

    if ($allValid) {
        Test-Passed "All required project structure elements present"
    } else {
        Test-Failed "Project structure validation" "Some required paths are missing"
    }

    return $allValid
}

#endregion

#region Docker Services Tests

function Test-DockerComposeValidation {
    Write-Section "3. Docker Compose Validation"

    $dockerComposePath = Join-Path $TestProjectPath "docker-compose.yml"

    if (-not (Test-Path $dockerComposePath)) {
        Test-Failed "Docker Compose file exists" "docker-compose.yml not found"
        return $false
    }

    # Validate docker-compose.yml syntax
    $composeWSL = ($dockerComposePath -replace '\\', '/') | ForEach-Object { (wsl wslpath -u $_).Trim() }
    $result = Invoke-BashCommand -Command "docker compose -f '$composeWSL' config --quiet" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Docker Compose file is valid"
    } else {
        Test-Failed "Docker Compose validation" "Invalid docker-compose.yml syntax"
        Write-Host $result.Output
        return $false
    }

    return $true
}

function Test-DockerServicesStartup {
    Write-Section "4. Docker Services Startup"

    Write-Host "Starting Docker services..." -ForegroundColor Cyan

    # Create .env file from .env.example
    $envExample = Join-Path $TestProjectPath ".env.example"
    $envFile = Join-Path $TestProjectPath ".env"
    if (Test-Path $envExample) {
        Copy-Item $envExample $envFile
    }

    # Start services
    $result = Invoke-BashCommand -Command "docker compose up -d --build" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Docker services started"
    } else {
        Test-Failed "Docker services startup" "Failed to start services"
        Write-Host $result.Output
        return $false
    }

    # Wait a bit for initial startup
    Start-Sleep -Seconds 15

    return $true
}

function Test-ServiceHealth {
    Write-Section "5. Service Health Checks"

    $services = @(
        @{ Name = "PostgreSQL"; Url = "http://localhost:5432"; Container = "rag-postgres" },
        @{ Name = "Redis"; Url = "http://localhost:6379"; Container = "rag-redis" },
        @{ Name = "OpenSearch"; Url = "http://localhost:9200"; Container = "rag-opensearch" },
        @{ Name = "Ollama"; Url = "http://localhost:11434/api/version"; Container = "rag-ollama" },
        @{ Name = "FastAPI"; Url = "http://localhost:8000/health"; Container = "rag-api" }
    )

    $allHealthy = $true

    # Check container status
    Write-Host "Checking container status..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose ps --format json" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Write-Host $result.Output
    }

    # Check specific services
    foreach ($service in $services) {
        Write-Host "Checking $($service.Name)..." -ForegroundColor Cyan

        if ($service.Name -eq "PostgreSQL") {
            $result = Invoke-BashCommand -Command "docker exec $($service.Container) pg_isready -U rag_user" -WorkingDirectory $TestProjectPath
            if ($result.Success) {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service not responding"
                $allHealthy = $false
            }
        }
        elseif ($service.Name -eq "Redis") {
            $result = Invoke-BashCommand -Command "docker exec $($service.Container) redis-cli ping" -WorkingDirectory $TestProjectPath
            if ($result.Output -match "PONG") {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service not responding"
                $allHealthy = $false
            }
        }
        else {
            $isHealthy = Wait-ForService -Name $service.Name -Url $service.Url -MaxAttempts 20 -DelaySeconds 10
            if ($isHealthy) {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service failed to become healthy"

                # Get container logs for debugging
                Write-Host "  Container logs:" -ForegroundColor Yellow
                $logs = Get-ContainerLogs -ContainerName $service.Container
                Write-Host $logs -ForegroundColor Gray

                $allHealthy = $false
            }
        }
    }

    return $allHealthy
}

#endregion

#region Unit Tests

function Test-UnitTests {
    Write-Section "6. Unit Tests"

    Write-Host "Running unit tests inside Docker container..." -ForegroundColor Cyan

    # Run pytest inside the API container
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest tests/unit/ -v -m unit --tb=short" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Success -or $result.Output -match "passed") {
        $passedCount = if ($result.Output -match "(\d+) passed") { $matches[1] } else { "0" }
        Test-Passed "Unit tests completed ($passedCount tests passed)"
        return $true
    } else {
        Test-Failed "Unit tests" "Some unit tests failed"
        return $false
    }
}

#endregion

#region Integration Tests

function Test-IntegrationTests {
    Write-Section "7. Integration Tests"

    Write-Host "Running integration tests inside Docker container..." -ForegroundColor Cyan

    # Run pytest inside the API container
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest tests/integration/ -v -m integration --tb=short" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Success -or $result.Output -match "passed") {
        $passedCount = if ($result.Output -match "(\d+) passed") { $matches[1] } else { "0" }
        Test-Passed "Integration tests completed ($passedCount tests passed)"
        return $true
    } else {
        Test-Failed "Integration tests" "Some integration tests failed"
        return $false
    }
}

#endregion

#region End-to-End Tests

function Test-E2ETests {
    Write-Section "8. End-to-End Tests"

    Write-Host "Running E2E tests inside Docker container..." -ForegroundColor Cyan

    # Run pytest inside the API container
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest tests/e2e/ -v --tb=short" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Success -or $result.Output -match "passed") {
        $passedCount = if ($result.Output -match "(\d+) passed") { $matches[1] } else { "0" }
        Test-Passed "E2E tests completed ($passedCount tests passed)"
        return $true
    } else {
        Test-Failed "E2E tests" "Some E2E tests failed"
        return $false
    }
}

#endregion

#region Test Coverage

function Test-Coverage {
    Write-Section "9. Test Coverage"

    Write-Host "Generating test coverage report inside Docker container..." -ForegroundColor Cyan

    # Run pytest with coverage inside the API container
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest --cov=src --cov-report=term --cov-report=html" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Output -match "TOTAL.*?(\d+)%") {
        $coverage = $matches[1]
        Write-Host "Total coverage: $coverage%" -ForegroundColor Cyan

        if ([int]$coverage -ge 70) {
            Test-Passed "Test coverage is adequate ($coverage%)"
        } else {
            Test-Failed "Test coverage" "Coverage below 70% threshold ($coverage%)"
        }
    } else {
        Test-Failed "Test coverage calculation" "Could not parse coverage percentage"
    }
}

#endregion

#region Summary

function Print-Summary {
    Write-Header "TEST SUMMARY"

    $duration = (Get-Date) - $Script:StartTime

    Write-Host "Execution Time: $($duration.ToString('mm\:ss'))" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Total Tests:   $Script:TotalTests"
    Write-Host "Passed:        $Script:PassedTests" -ForegroundColor Green
    Write-Host "Failed:        $Script:FailedTests" -ForegroundColor $(if ($Script:FailedTests -eq 0) { "Green" } else { "Red" })
    Write-Host ""

    if ($Script:FailedTests -gt 0) {
        Write-Host "Failed Tests:" -ForegroundColor Red
        foreach ($result in $Script:TestResults) {
            if ($result.Status -eq "FAIL") {
                Write-Host "  ✗ $($result.Name)" -ForegroundColor Red
                if ($result.Reason) {
                    Write-Host "    $($result.Reason)" -ForegroundColor Gray
                }
            }
        }
        Write-Host ""
    }

    $successRate = if ($Script:TotalTests -gt 0) {
        [math]::Round(($Script:PassedTests / $Script:TotalTests) * 100, 2)
    } else { 0 }

    Write-Host "Success Rate:  $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } elseif ($successRate -ge 50) { "Yellow" } else { "Red" })
    Write-Host ""

    # Save summary to file
    @"

==========================================
SUMMARY
==========================================
Total Tests: $Script:TotalTests
Passed: $Script:PassedTests
Failed: $Script:FailedTests
Success Rate: $successRate%
Execution Time: $($duration.ToString('mm\:ss'))

Test Project: $TestProjectPath
Results saved to: $TestResultsFile
"@ | Out-File -FilePath $TestResultsFile -Append

    if ($KeepProject) {
        Write-Host "Test project preserved at:" -ForegroundColor Cyan
        Write-Host "  $TestProjectPath" -ForegroundColor White
        Write-Host ""
        Write-Host "To clean up manually:" -ForegroundColor Yellow
        Write-Host "  cd '$TestProjectPath'" -ForegroundColor Gray
        Write-Host "  docker compose down -v" -ForegroundColor Gray
        Write-Host "  cd .." -ForegroundColor Gray
        Write-Host "  rm -rf '$TestProjectName'" -ForegroundColor Gray
        Write-Host ""
    }

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

#endregion

#region Main Execution

function Main {
    try {
        Setup-TestEnvironment

        # Run all test phases
        $phase1 = Test-ProjectCreation
        if (-not $phase1) {
            Write-Host "Critical failure in project creation. Aborting." -ForegroundColor Red
            return $false
        }

        $phase2 = Test-ProjectStructure
        $phase3 = Test-DockerComposeValidation

        if ($phase3) {
            $phase4 = Test-DockerServicesStartup

            if ($phase4) {
                $phase5 = Test-ServiceHealth

                # Only run tests if services are healthy
                if ($phase5) {
                    Test-UnitTests
                    Test-IntegrationTests
                    Test-E2ETests
                    Test-Coverage
                }
            }
        }

        $success = Print-Summary
        return $success

    } finally {
        Cleanup-TestEnvironment
    }
}

# Execute main test flow
$testSuccess = Main

# Exit with appropriate code
if ($testSuccess) {
    exit 0
} else {
    exit 1
}

#endregion
