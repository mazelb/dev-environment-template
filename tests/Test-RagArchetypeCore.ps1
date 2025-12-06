###############################################################################
# RAG Archetype Core Test - Simplified version focusing on core services
# Tests project creation and core services (API, PostgreSQL, Redis, OpenSearch, Ollama)
# Excludes Airflow and other complex services for faster, more reliable testing
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
$TestProjectName = "test-rag-core-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$TestProjectPath = Join-Path $TestOutputDir $TestProjectName
$TestResultsFile = Join-Path $TestOutputDir "rag-core-test-results.txt"

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
    Write-Header "RAG ARCHETYPE CORE TEST"

    Write-Host "Test Configuration:" -ForegroundColor Cyan
    Write-Host "  Project Name: $TestProjectName"
    Write-Host "  Project Path: $TestProjectPath"
    Write-Host "  Keep Project: $KeepProject"
    Write-Host ""

    if (-not (Test-Path $TestOutputDir)) {
        New-Item -ItemType Directory -Force -Path $TestOutputDir | Out-Null
    }

    @"
RAG Archetype Core Test Results
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

    Write-Host "Creating RAG project..." -ForegroundColor Cyan

    $scriptPath = $CreateProjectScript -replace '\\', '/'
    $scriptWSL = (wsl wslpath -u "$scriptPath").Trim()

    $projectPath = $TestProjectPath -replace '\\', '/'
    $projectWSL = (wsl wslpath -u "$projectPath").Trim()

    $command = "bash '$scriptWSL' --name '$TestProjectName' --path '$projectWSL' --archetype rag-project --no-git --no-build --verbose"

    $result = Invoke-BashCommand -Command $command -WorkingDirectory $TemplateDir

    if ($result.Success -and (Test-Path $TestProjectPath)) {
        Test-Passed "RAG project created successfully"
        return $true
    } else {
        Test-Failed "RAG project creation" "Project not created"
        Write-Host $result.Output
        return $false
    }
}

function Test-ProjectStructure {
    Write-Section "2. Project Structure Validation"

    $requiredPaths = @(
        "README.md", "docker-compose.yml", "Makefile", "requirements.txt",
        "pytest.ini", ".env.example", "src", "tests", "config", "docs"
    )

    $allValid = $true
    foreach ($path in $requiredPaths) {
        $fullPath = Join-Path $TestProjectPath $path
        if (Test-Path $fullPath) {
            Write-Host "  ✓ $path" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $path - MISSING" -ForegroundColor Red
            $allValid = $false
        }
    }

    if ($allValid) {
        Test-Passed "All required project structure elements present"
    } else {
        Test-Failed "Project structure validation" "Some required paths missing"
    }

    return $allValid
}

function Test-CoreServicesStartup {
    Write-Section "3. Core Services Startup (excluding Airflow)"

    Write-Host "Modifying docker-compose.yml to exclude Airflow services..." -ForegroundColor Cyan

    # Create .env file
    $envExample = Join-Path $TestProjectPath ".env.example"
    $envFile = Join-Path $TestProjectPath ".env"
    if (Test-Path $envExample) {
        Copy-Item $envExample $envFile
    }

    # Start only core services (exclude airflow)
    Write-Host "Starting core services: API, PostgreSQL, Redis, OpenSearch, Ollama..." -ForegroundColor Cyan

    $services = @("postgres", "redis", "opensearch", "ollama", "api")
    $serviceList = $services -join " "

    $result = Invoke-BashCommand -Command "docker compose up -d $serviceList" -WorkingDirectory $TestProjectPath

    if ($result.Success) {
        Test-Passed "Core Docker services started"
        Start-Sleep -Seconds 20  # Give services time to initialize
        return $true
    } else {
        Test-Failed "Core Docker services startup" "Failed to start services"
        Write-Host $result.Output
        return $false
    }
}

function Test-ServiceHealth {
    Write-Section "4. Service Health Checks"

    $services = @(
        @{ Name = "PostgreSQL"; Container = "$TestProjectName-postgres"; Check = "docker exec $TestProjectName-postgres pg_isready -U rag_user" },
        @{ Name = "Redis"; Container = "$TestProjectName-redis"; Check = "docker exec $TestProjectName-redis redis-cli ping" },
        @{ Name = "OpenSearch"; Url = "http://localhost:9200/_cluster/health" },
        @{ Name = "Ollama"; Url = "http://localhost:11434/api/version" },
        @{ Name = "FastAPI"; Url = "http://localhost:8000/api/v1/health" }
    )

    $allHealthy = $true

    foreach ($service in $services) {
        Write-Host "Checking $($service.Name)..." -ForegroundColor Cyan

        if ($service.Check) {
            $result = Invoke-BashCommand -Command $service.Check -WorkingDirectory $TestProjectPath
            if ($result.Success -or $result.Output -match "PONG|accepting") {
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
    Write-Section "5. Docker Container Inspection"

    Write-Host "Listing running containers:" -ForegroundColor Cyan
    $result = Invoke-BashCommand -Command "docker compose ps" -WorkingDirectory $TestProjectPath
    Write-Host $result.Output

    Write-Host "`nChecking container logs:" -ForegroundColor Cyan
    $containers = @("postgres", "redis", "opensearch", "ollama", "api")
    foreach ($container in $containers) {
        Write-Host "`n--- $container logs (last 10 lines) ---" -ForegroundColor Yellow
        $result = Invoke-BashCommand -Command "docker logs --tail 10 $TestProjectName-$container" -WorkingDirectory $TestProjectPath
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
        Write-Host "  curl http://localhost:8000/api/v1/health" -ForegroundColor Gray
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
        Write-Host "❌ Some tests failed" -ForegroundColor Red
        return $false
    }
}

function Main {
    try {
        Setup-TestEnvironment

        $phase1 = Test-ProjectCreation
        if (-not $phase1) {
            Write-Host "Critical failure in project creation. Aborting." -ForegroundColor Red
            return $false
        }

        Test-ProjectStructure
        $phase3 = Test-CoreServicesStartup

        if ($phase3) {
            Test-ServiceHealth
            Test-DockerInspection
        }

        $success = Print-Summary
        return $success

    } finally {
        Cleanup-TestEnvironment
    }
}

$testSuccess = Main

if ($testSuccess) {
    exit 0
} else {
    exit 1
}
