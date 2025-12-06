###############################################################################
# API Archetype Core Test - Simplified version focusing on core services
# Tests project creation and core services (API, PostgreSQL, Redis, Celery Worker, Celery Beat)
# Focus on fast, reliable infrastructure validation
###############################################################################

param(
    [switch]$KeepProject,     # Keep test project after completion
    [switch]$SkipCleanup,     # Skip cleanup of Docker resources
    [switch]$Verbose          # Enable verbose output
)

$ErrorActionPreference = "Continue"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Split-Path -Parent $ScriptDir
$CreateProjectScript = Join-Path $TemplateDir "create-project.sh"
$TestOutputDir = Join-Path $ScriptDir "temp"
$TestProjectName = "test-api-core-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$TestProjectPath = Join-Path $TestOutputDir $TestProjectName
$TestResultsFile = Join-Path $TestOutputDir "api-core-test-results.txt"

$Script:TotalTests = 0
$Script:PassedTests = 0
$Script:FailedTests = 0
$Script:TestResults = @()
$Script:StartTime = Get-Date

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
    $Script:TestResults += @{ Status = "PASS"; Name = $TestName }
}

function Test-Failed {
    param([string]$TestName, [string]$Reason)
    $Script:FailedTests++
    $Script:TotalTests++
    Write-Host "✗ FAILED: $TestName" -ForegroundColor Red
    Write-Host "  Reason: $Reason" -ForegroundColor Red
    $Script:TestResults += @{ Status = "FAIL"; Name = $TestName; Reason = $Reason }
}

function Invoke-BashCommand {
    param([string]$Command, [string]$WorkingDirectory = $PWD)

    if ($Verbose) {
        Write-Host "  Executing: $Command" -ForegroundColor Gray
    }

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

function Setup-TestEnvironment {
    Write-Header "API ARCHETYPE CORE TEST"

    Write-Host "Test Configuration:" -ForegroundColor Cyan
    Write-Host "  Project Name: $TestProjectName"
    Write-Host "  Project Path: $TestProjectPath"
    Write-Host "  Keep Project: $KeepProject"
    Write-Host ""

    if (-not (Test-Path $TestOutputDir)) {
        New-Item -ItemType Directory -Force -Path $TestOutputDir | Out-Null
    }

    @"
API Archetype Core Test Results
Generated: $(Get-Date)
Project: $TestProjectName
==========================================

"@ | Out-File -FilePath $TestResultsFile

    Write-Host "✓ Test environment prepared" -ForegroundColor Green
}

function Cleanup-TestEnvironment {
    if ($SkipCleanup) {
        Write-Host "Skipping cleanup" -ForegroundColor Yellow
        return
    }

    Write-Section "Cleanup"

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

function Test-ProjectCreation {
    Write-Section "1. Project Creation"

    Write-Host "Creating API project from archetype..." -ForegroundColor Cyan

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
            return $true
        } else {
            Test-Failed "Project creation" "create-project.sh failed or directory not found"
            Write-Host "Exit Code: $($result.ExitCode)" -ForegroundColor Red
            Write-Host "Output: $($result.Output)" -ForegroundColor Red
            return $false
        }
    } finally {
        Pop-Location
    }
}

function Test-ProjectStructure {
    Write-Section "2. Project Structure Validation"

    $requiredPaths = @(
        @{ Path = "src"; Type = "Directory"; Description = "Source directory" },
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
        @{ Path = "alembic"; Type = "Directory"; Description = "Database migrations" },
        @{ Path = "docker-compose.yml"; Type = "File"; Description = "Docker Compose config" },
        @{ Path = "requirements.txt"; Type = "File"; Description = "Python dependencies" },
        @{ Path = ".env.example"; Type = "File"; Description = "Environment variables template" },
        @{ Path = "Dockerfile"; Type = "File"; Description = "API Dockerfile" }
    )

    $allPresent = $true
    foreach ($item in $requiredPaths) {
        $fullPath = Join-Path $TestProjectPath $item.Path
        $exists = if ($item.Type -eq "Directory") {
            Test-Path -Path $fullPath -PathType Container
        } else {
            Test-Path -Path $fullPath -PathType Leaf
        }

        if ($exists) {
            Write-Host "  ✓ $($item.Description): $($item.Path)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Missing: $($item.Path)" -ForegroundColor Red
            $allPresent = $false
        }
    }

    if ($allPresent) {
        Test-Passed "All required project structure elements present"
    } else {
        Test-Failed "Project structure" "Some required elements are missing"
    }
}

function Test-DockerComposeConfig {
    Write-Section "3. Docker Compose Validation"

    Write-Host "Validating Docker Compose configuration..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose config" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Docker Compose file is valid"
        if ($Verbose) {
            Write-Host "Services detected:" -ForegroundColor Gray
            Write-Host $result.Output -ForegroundColor DarkGray
        }
    } else {
        Test-Failed "Docker Compose validation" "Configuration is invalid"
        Write-Host $result.Output -ForegroundColor Red
    }
}

function Test-DockerServicesStartup {
    Write-Section "4. Docker Services Startup"

    Write-Host "Starting Docker services (this may take 2-3 minutes)..." -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose up -d" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Docker services started"

        Write-Host "Waiting for services to initialize (60 seconds)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60

        Write-Host "`nChecking service status:" -ForegroundColor Cyan
        $psResult = Invoke-BashCommand -Command "docker compose ps" -WorkingDirectory $TestProjectPath
        Write-Host $psResult.Output

        return $true
    } else {
        Test-Failed "Docker services startup" "Failed to start services"
        Write-Host $result.Output -ForegroundColor Red
        return $false
    }
}

function Test-ServiceHealth {
    Write-Section "5. Service Health Checks"

    $services = @(
        @{ Name = "PostgreSQL"; Container = "$TestProjectName-postgres"; Check = "docker exec $TestProjectName-postgres pg_isready -U api_user" },
        @{ Name = "Redis"; Container = "$TestProjectName-redis"; Check = "docker exec $TestProjectName-redis redis-cli ping" },
        @{ Name = "FastAPI"; Url = "http://localhost:8000/health" },
        @{ Name = "Celery Worker"; Container = "$TestProjectName-celery-worker"; Check = "docker exec $TestProjectName-celery-worker celery -A src.tasks inspect ping" },
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
                $allHealthy = $false
            }
        } elseif ($service.Url) {
            $healthy = $false
            for ($i = 1; $i -le 15; $i++) {
                try {
                    $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
                    if ($response.StatusCode -eq 200) {
                        $healthy = $true
                        break
                    }
                } catch { }
                Start-Sleep -Seconds 4
            }

            if ($healthy) {
                Test-Passed "$($service.Name) is healthy"
            } else {
                Test-Failed "$($service.Name) health check" "Service not responding after 60s"
                $allHealthy = $false
            }
        }
    }

    return $allHealthy
}

function Test-DockerInspection {
    Write-Section "6. Docker Container Inspection"

    Write-Host "Listing running containers:" -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose ps" -WorkingDirectory $TestProjectPath
    Write-Host $result.Output

    Write-Host "`nChecking container logs:" -ForegroundColor Cyan
    $containers = @("postgres", "redis", "api", "celery-worker", "celery-beat")
    foreach ($container in $containers) {
        Write-Host "`n--- $container logs (last 10 lines) ---" -ForegroundColor Yellow
        $result = Invoke-BashCommand -Command "docker logs --tail 10 $TestProjectName-$container 2>&1" -WorkingDirectory $TestProjectPath
        Write-Host $result.Output
    }

    Test-Passed "Docker inspection completed"
}

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
                Write-Host "  ✗ $($result.Name): $($result.Reason)" -ForegroundColor Red
            }
        }
        Write-Host ""
    }

    $successRate = if ($Script:TotalTests -gt 0) {
        [math]::Round(($Script:PassedTests / $Script:TotalTests) * 100, 2)
    } else { 0 }

    Write-Host "Success Rate:  $successRate%" -ForegroundColor $(if ($successRate -ge 80) { "Green" } else { "Yellow" })
    Write-Host ""

    if ($KeepProject) {
        Write-Host "Test project preserved at:" -ForegroundColor Cyan
        Write-Host "  $TestProjectPath" -ForegroundColor White
        Write-Host ""
        Write-Host "To test manually:" -ForegroundColor Yellow
        Write-Host "  cd '$TestProjectPath'" -ForegroundColor Gray
        Write-Host "  docker compose ps" -ForegroundColor Gray
        Write-Host "  curl http://localhost:8000/health" -ForegroundColor Gray
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
        Write-Host "⚠️  Some tests failed. Review the output above for details." -ForegroundColor Yellow
        return $false
    }
}

# Main execution
try {
    Setup-TestEnvironment

    $projectCreated = Test-ProjectCreation
    if ($projectCreated) {
        Test-ProjectStructure
        Test-DockerComposeConfig
        $servicesStarted = Test-DockerServicesStartup
        if ($servicesStarted) {
            Test-ServiceHealth
            Test-DockerInspection
        }

        $success = Print-Summary
        return $success

    } finally {
        Cleanup-TestEnvironment
    }

} catch {
    Write-Host "❌ Critical error during test execution:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
