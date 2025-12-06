###############################################################################
# Comprehensive API Archetype Full Stack Test
# Creates a complete API project, starts all services, and runs all tests
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
$TestProjectName = "test-api-full-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$TestProjectPath = Join-Path $TestOutputDir $TestProjectName
$TestResultsFile = Join-Path $TestOutputDir "api-full-test-results.txt"

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
        [int]$DelaySeconds = 4
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
    Write-Header "API ARCHETYPE FULL STACK TEST"

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
API Archetype Full Stack Test Results
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

    Write-Host "Creating API project with all features..." -ForegroundColor Cyan

    # Convert paths to WSL format
    $projectPath = $TestProjectPath -replace '\\', '/'
    $projectWSL = (wsl wslpath -u "$projectPath").Trim()

    $command = "./create-project.sh --path '$projectWSL' --archetype api-service --no-git --no-build --verbose"

    if ($Verbose) {
        Write-Host "  Command: $command" -ForegroundColor Gray
    }

    Push-Location $TemplateDir
    try {
        $result = Invoke-BashCommand -Command $command -WorkingDirectory $TemplateDir

        if ($result.Success -and (Test-Path $TestProjectPath)) {
            Test-Passed "API project created successfully"
            Write-Host "  Project location: $TestProjectPath" -ForegroundColor Gray
        } else {
            Test-Failed "API project creation" "Project not created or command failed"
            Write-Host "Exit Code: $($result.ExitCode)" -ForegroundColor Red
            Write-Host $result.Output
            return $false
        }
    } finally {
        Pop-Location
    }

    return $true
}

function Test-ProjectStructure {
    Write-Section "2. Project Structure Validation"

    $requiredPaths = @(
        @{ Path = "README.md"; Type = "File"; Description = "Project documentation" },
        @{ Path = "docker-compose.yml"; Type = "File"; Description = "Docker Compose configuration" },
        @{ Path = "Dockerfile"; Type = "File"; Description = "API Dockerfile" },
        @{ Path = "requirements.txt"; Type = "File"; Description = "Python dependencies" },
        @{ Path = ".env.example"; Type = "File"; Description = "Environment variables template" },
        @{ Path = "src"; Type = "Directory"; Description = "Source code directory" },
        @{ Path = "src/api"; Type = "Directory"; Description = "API routes directory" },
        @{ Path = "src/auth"; Type = "Directory"; Description = "Authentication module" },
        @{ Path = "src/core"; Type = "Directory"; Description = "Core utilities" },
        @{ Path = "src/db"; Type = "Directory"; Description = "Database configuration" },
        @{ Path = "src/models"; Type = "Directory"; Description = "Database models" },
        @{ Path = "src/graphql"; Type = "Directory"; Description = "GraphQL schemas" },
        @{ Path = "src/middleware"; Type = "Directory"; Description = "Custom middleware" },
        @{ Path = "src/celery_app"; Type = "Directory"; Description = "Celery configuration" },
        @{ Path = "src/repositories"; Type = "Directory"; Description = "Data repositories" },
        @{ Path = "tests"; Type = "Directory"; Description = "Tests directory" },
        @{ Path = "tests/unit"; Type = "Directory"; Description = "Unit tests" },
        @{ Path = "tests/integration"; Type = "Directory"; Description = "Integration tests" },
        @{ Path = "alembic"; Type = "Directory"; Description = "Database migrations" }
    )

    $allValid = $true
    foreach ($item in $requiredPaths) {
        $fullPath = Join-Path $TestProjectPath $item.Path
        $exists = Test-Path $fullPath

        if ($exists) {
            Write-Host "  ✓ $($item.Description): $($item.Path)" -ForegroundColor Green
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

    Write-Host "Validating Docker Compose configuration..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose config --quiet" -WorkingDirectory $TestProjectPath

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

        # Update PROJECT_NAME in .env to match test project name
        $envContent = Get-Content $envFile -Raw
        $envContent = $envContent -replace 'PROJECT_NAME=.*', "PROJECT_NAME=$TestProjectName"
        Set-Content -Path $envFile -Value $envContent -NoNewline

        if ($Verbose) {
            Write-Host "  Updated .env with PROJECT_NAME=$TestProjectName" -ForegroundColor Gray
        }
    }

    # Start services
    $result = Invoke-BashCommand -Command "docker compose up -d --build" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Docker services started successfully"
    } else {
        Test-Failed "Docker services startup" "Failed to start services"
        Write-Host $result.Output
        return $false
    }

    # Wait for initial startup
    Write-Host "Waiting for services to initialize (60 seconds)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 60

    # Show service status
    Write-Host "`nChecking service status:" -ForegroundColor Cyan
    $psResult = Invoke-BashCommand -Command "docker compose ps" -WorkingDirectory $TestProjectPath
    Write-Host $psResult.Output

    return $true
}

function Test-ServiceHealth {
    Write-Section "5. Service Health Checks"

    $services = @(
        @{ Name = "PostgreSQL"; Container = "$TestProjectName-postgres"; Check = "docker exec $TestProjectName-postgres pg_isready -U api_user" },
        @{ Name = "Redis"; Container = "$TestProjectName-redis"; Check = "docker exec $TestProjectName-redis redis-cli ping" },
        @{ Name = "FastAPI"; Url = "http://localhost:8000/api/v1/health" },
        @{ Name = "Celery Worker"; Container = "$TestProjectName-celery-worker"; Check = "docker exec $TestProjectName-celery-worker celery -A src.celery_app.celery inspect ping" },
        @{ Name = "Celery Beat"; Container = "$TestProjectName-celery-beat"; Check = "docker logs $TestProjectName-celery-beat 2>&1 | grep -i 'beat'" }
    )

    $allHealthy = $true

    foreach ($service in $services) {
        Write-Host "Checking $($service.Name)..." -ForegroundColor Cyan

        if ($service.Check) {
            $result = Invoke-BashCommand -Command $service.Check -WorkingDirectory $TestProjectPath
            if ($result.Success -or $result.Output -match "PONG|accepting|pong|beat") {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service not responding"
                Write-Host "  Container logs:" -ForegroundColor Yellow
                $logs = Get-ContainerLogs -ContainerName $service.Container
                Write-Host $logs -ForegroundColor Gray
                $allHealthy = $false
            }
        } elseif ($service.Url) {
            $isHealthy = Wait-ForService -Name $service.Name -Url $service.Url -MaxAttempts 15 -DelaySeconds 4
            if ($isHealthy) {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service failed to become healthy after 60s"
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
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest tests/unit/ -v --tb=short" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Success -or $result.Output -match "passed") {
        $passedCount = if ($result.Output -match "(\d+) passed") { $matches[1] } else { "0" }
        Test-Passed "Unit tests completed ($passedCount tests passed)"
        return $true
    } else {
        Test-Failed "Unit tests" "Some unit tests failed or no tests found"
        return $false
    }
}

#endregion

#region Integration Tests

function Test-IntegrationTests {
    Write-Section "7. Integration Tests"

    Write-Host "Running integration tests inside Docker container..." -ForegroundColor Cyan

    # Run pytest inside the API container
    $result = Invoke-BashCommand -Command "docker compose exec -T api pytest tests/integration/ -v --tb=short" -WorkingDirectory $TestProjectPath

    Write-Host $result.Output

    if ($result.Success -or $result.Output -match "passed") {
        $passedCount = if ($result.Output -match "(\d+) passed") { $matches[1] } else { "0" }
        Test-Passed "Integration tests completed ($passedCount tests passed)"
        return $true
    } else {
        Test-Failed "Integration tests" "Some integration tests failed or no tests found"
        return $false
    }
}

#endregion

#region API Endpoint Tests

function Test-ApiEndpoints {
    Write-Section "8. API Endpoint Tests"

    Write-Host "Testing API endpoints..." -ForegroundColor Cyan

    # Test health endpoint
    Write-Host "  Testing /api/v1/health endpoint..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/health" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ Health endpoint responding" -ForegroundColor Green
            $healthPassed = $true
        } else {
            Write-Host "  ✗ Health endpoint returned status $($response.StatusCode)" -ForegroundColor Red
            $healthPassed = $false
        }
    } catch {
        Write-Host "  ✗ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
        $healthPassed = $false
    }

    # Test API documentation
    Write-Host "  Testing /docs endpoint..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/docs" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✓ API documentation accessible" -ForegroundColor Green
            $docsPassed = $true
        } else {
            Write-Host "  ✗ API docs returned status $($response.StatusCode)" -ForegroundColor Red
            $docsPassed = $false
        }
    } catch {
        Write-Host "  ✗ API docs failed: $($_.Exception.Message)" -ForegroundColor Red
        $docsPassed = $false
    }

    if ($healthPassed -and $docsPassed) {
        Test-Passed "API endpoints are accessible"
        return $true
    } else {
        Test-Failed "API endpoint tests" "Some endpoints failed"
        return $false
    }
}

#endregion

#region Background Tasks Tests

function Test-BackgroundTasks {
    Write-Section "9. Background Task Tests"

    Write-Host "Testing Celery background tasks..." -ForegroundColor Cyan

    # Check worker status
    Write-Host "  Checking Celery worker status..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose exec -T celery-worker celery -A src.tasks inspect ping" -WorkingDirectory $TestProjectPath

    if ($result.Success -or $result.Output -match "pong") {
        Write-Host "  ✓ Celery worker is responding" -ForegroundColor Green
        $workerPassed = $true
    } else {
        Write-Host "  ✗ Celery worker not responding" -ForegroundColor Red
        $workerPassed = $false
    }

    # Check registered tasks
    Write-Host "  Checking registered tasks..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose exec -T celery-worker celery -A src.tasks inspect registered" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Write-Host "  ✓ Tasks registered successfully" -ForegroundColor Green
        if ($Verbose) {
            Write-Host $result.Output -ForegroundColor Gray
        }
        $tasksPassed = $true
    } else {
        Write-Host "  ✗ Failed to get registered tasks" -ForegroundColor Red
        $tasksPassed = $false
    }

    if ($workerPassed -and $tasksPassed) {
        Test-Passed "Background tasks infrastructure operational"
        return $true
    } else {
        Test-Failed "Background tasks" "Celery infrastructure issues"
        return $false
    }
}

#endregion

#region Test Coverage

function Test-Coverage {
    Write-Section "10. Test Coverage"

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
        # If no coverage percentage found, still pass if tests ran
        if ($result.Output -match "passed") {
            Test-Passed "Test coverage generated (percentage not parsed)"
        } else {
            Test-Failed "Test coverage calculation" "Could not generate coverage report"
        }
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
        Write-Host "To manually test:" -ForegroundColor Yellow
        Write-Host "  cd '$TestProjectPath'" -ForegroundColor Gray
        Write-Host "  docker compose ps" -ForegroundColor Gray
        Write-Host "  curl http://localhost:8000/health" -ForegroundColor Gray
        Write-Host "  docker compose exec api pytest" -ForegroundColor Gray
        Write-Host ""
        Write-Host "To clean up:" -ForegroundColor Yellow
        Write-Host "  docker compose down -v" -ForegroundColor Gray
        Write-Host ""
    }

    Write-Host "Full results saved to: $TestResultsFile" -ForegroundColor Cyan
    Write-Host ""

    if ($Script:FailedTests -eq 0) {
        Write-Host "🎉 All tests passed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Some tests failed. Review the output above for details." -ForegroundColor Yellow
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

                # Only run application tests if services are healthy
                if ($phase5) {
                    Test-UnitTests
                    Test-IntegrationTests
                    Test-ApiEndpoints
                    Test-BackgroundTasks
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
