<#
Multi-project archetype & composite build/run matrix test (PowerShell)
Creates a test folder one level up from repo and iterates through archetypes.
Requires Docker Desktop and WSL for path translation for create-project.sh
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path "$PSScriptRoot\..\").Path
$ParentWin = (Resolve-Path "$Root\..\").Path
$TestRootWin = Join-Path $ParentWin 'archetype-matrix-tests'
if (-not (Test-Path $TestRootWin)) { New-Item -ItemType Directory -Path $TestRootWin | Out-Null }

function Convert-ToWslPath([string]$winPath) {
    $winPath = $winPath -replace '\\','/'
    if ($winPath -match '^([A-Za-z]):') {
        $drive = $Matches[1].ToLower()
        $rest = $winPath.Substring(2)
        return "/mnt/$drive$rest"
    }
    return $winPath
}

$Archetypes = @('base','rag-project','api-service','monitoring','agentic-workflows')
$Composites = @('composite-rag-agents','composite-api-monitoring','composite-full-stack')
$CompositeFeatureMap = @{ 'composite-rag-agents'='rag-project:agentic-workflows'; 'composite-api-monitoring'='api-service:monitoring'; 'composite-full-stack'='rag-project:agentic-workflows,monitoring' }

$Results = @()

function Invoke-CreateAndTest([string]$Name,[string]$Archetype,[string]$Features,[string]$Tools) {
    Write-Host "`n==== Creating $Name (archetype=$Archetype features=$Features tools=$Tools) ===="
    $ProjectWin = Join-Path $TestRootWin $Name
    if (Test-Path $ProjectWin) { Remove-Item -Recurse -Force $ProjectWin }
    New-Item -ItemType Directory -Path $ProjectWin | Out-Null

    $ProjectWsl = Convert-ToWslPath $ProjectWin
    $featureArg = if ($Features) { "--add-features $Features" } else { '' }
    $toolArg    = if ($Tools)    { "--tools $Tools" } else { '' }

    $createCmd = "bash '$Root/create-project.sh' --path '$ProjectWsl' --archetype '$Archetype' $featureArg $toolArg --no-git"
    if (-not (bash -c "$createCmd" 2>$null)) {
        Write-Warning "CREATE_FAIL: $Name"
        $Results += "${Name}|CREATE_FAIL"
        return
    }

    $ComposeFile = Join-Path $ProjectWin 'docker-compose.yml'
    if (-not (Test-Path $ComposeFile)) {
        Write-Warning "NO_COMPOSE: $Name"
        $Results += "${Name}|NO_COMPOSE"
        return
    }

    Push-Location $ProjectWin
    try {
        docker-compose up -d --build | Out-Null
    } catch {
        Write-Warning "DOCKER_FAIL: $Name"
        $Results += "${Name}|DOCKER_FAIL"
        Pop-Location
        return
    }
    Start-Sleep -Seconds 5
    $running = (docker ps --format '{{.Names}}' | Select-String -Pattern $Name).Count
    if ($running -gt 0) { Write-Host "PASS: $Name ($running containers)"; $Results += "${Name}|PASS" } else { Write-Warning "RUNNING_ZERO: $Name"; $Results += "${Name}|RUNNING_ZERO" }
    docker-compose down -v | Out-Null
    Pop-Location
}

foreach ($a in $Archetypes) {
    $tools = switch ($a) { 'rag-project' { 'fastapi,postgresql' } 'api-service' { 'fastapi' } default { '' } }
    if ($a -eq 'agentic-workflows') {
        Invoke-CreateAndTest 'agentic-workflows-composed' 'rag-project' 'agentic-workflows' 'fastapi'
    } else {
        Invoke-CreateAndTest $a $a '' $tools
    }
    if ($a -eq 'monitoring') {
        Invoke-CreateAndTest 'rag-with-monitoring' 'rag-project' 'monitoring' 'fastapi'
    }
}

foreach ($c in $Composites) {
    Write-Host "`n==== Composite: $c ===="
    Invoke-CreateAndTest $c $c '' 'fastapi'
    if ($Results[-1] -match 'CREATE_FAIL') {
        Write-Host "Fallback attempt for $c"
        if ($CompositeFeatureMap.ContainsKey($c)) {
            $parts = $CompositeFeatureMap[$c].Split(':')
            Invoke-CreateAndTest "$c-fallback" $parts[0] $parts[1] 'fastapi'
        }
    }
}

Write-Host "`n================ Summary ================"
$Results | ForEach-Object { $n,$s = $_.Split('|'); "{0,-30} : {1}" -f $n,$s }

if ($Results | Select-String -Pattern 'FAIL|RUNNING_ZERO') { Write-Error "One or more failures"; exit 1 }
Write-Host "All projects passed."; exit 0
