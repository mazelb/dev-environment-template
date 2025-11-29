#!/usr/bin/env pwsh
###############################################################################
# Test-Phase6.ps1
# Test Suite for Phase 6: Archetypes Creation
#
# Tests the archetype system implementation:
# - Archetype directory structure
# - Metadata validation
# - Base archetypes (rag-project, agentic-workflows, api-service, monitoring)
# - Composite archetypes (composite-rag-agents)
# - Service definitions
# - Compatibility and composition rules
#
# Phase 6 includes multiple sub-phases:
# - 6.1: RAG Project Archetype
# - 6.2: API Service Archetype
# - 6.3: Monitoring Archetype
# - 6.4: Agentic Workflows Archetype
# - 6.5: Composite Archetypes
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
$ArchetypesDir = Join-Path $TemplateRoot "archetypes"
$ConfigDir = Join-Path $TemplateRoot "config"

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

function Test-JsonValid {
    param([string]$FilePath)
    try {
        $null = Get-Content $FilePath -Raw | ConvertFrom-Json
        return $true
    } catch {
        return $false
    }
}

function Get-JsonContent {
    param([string]$FilePath)
    return Get-Content $FilePath -Raw | ConvertFrom-Json
}

# Test 6.0: Archetypes Infrastructure
Write-TestHeader "Test 6.0: Archetypes Infrastructure"

Write-Test "Checking if archetypes/ directory exists"
if (Test-Path $ArchetypesDir) {
    Write-Pass "archetypes/ directory found"
} else {
    Write-Fail "archetypes/ directory NOT FOUND"
    exit 1
}

Write-Test "Checking for archetype schema definition"
$schemaFile = Join-Path $ArchetypesDir "__archetype_schema__.json"
if (Test-Path $schemaFile) {
    Write-Pass "Archetype schema found"
} else {
    Write-Fail "Archetype schema NOT FOUND"
}

Write-Test "Validating archetype schema JSON"
if (Test-Path $schemaFile) {
    if (Test-JsonValid $schemaFile) {
        Write-Pass "Schema is valid JSON"
    } else {
        Write-Fail "Schema JSON is INVALID"
    }
} else {
    Write-Skip "Schema file doesn't exist"
}

Write-Test "Checking for archetypes README"
$readmeFile = Join-Path $ArchetypesDir "README.md"
if (Test-Path $readmeFile) {
    Write-Pass "Archetypes README found"
} else {
    Write-Fail "Archetypes README NOT FOUND"
}

Write-Test "Checking for archetypes registry"
$registryFile = Join-Path $ConfigDir "archetypes.json"
if (Test-Path $registryFile) {
    Write-Pass "Archetypes registry found"
} else {
    Write-Fail "Archetypes registry NOT FOUND"
}

Write-Test "Validating archetypes registry JSON"
if (Test-Path $registryFile) {
    if (Test-JsonValid $registryFile) {
        Write-Pass "Registry is valid JSON"
    } else {
        Write-Fail "Registry JSON is INVALID"
    }
} else {
    Write-Skip "Registry file doesn't exist"
}

# Test 6.1: Base Archetype
Write-TestHeader "Test 6.1: Base Archetype"

$baseDir = Join-Path $ArchetypesDir "base"
Write-Test "Checking for base archetype directory"
if (Test-Path $baseDir) {
    Write-Pass "base/ directory found"
} else {
    Write-Fail "base/ directory NOT FOUND"
}

Write-Test "Checking for base archetype metadata"
$baseMetadata = Join-Path $baseDir "__archetype__.json"
if (Test-Path $baseMetadata) {
    Write-Pass "base __archetype__.json found"
} else {
    Write-Fail "base __archetype__.json NOT FOUND"
}

Write-Test "Validating base archetype metadata JSON"
if (Test-Path $baseMetadata) {
    if (Test-JsonValid $baseMetadata) {
        Write-Pass "Metadata is valid JSON"
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

# Test 6.2: RAG Project Archetype
Write-TestHeader "Test 6.2: RAG Project Archetype"

$ragDir = Join-Path $ArchetypesDir "rag-project"
Write-Test "Checking for rag-project archetype directory"
if (Test-Path $ragDir) {
    Write-Pass "rag-project/ directory found"
} else {
    Write-Fail "rag-project/ directory NOT FOUND"
}

Write-Test "Checking for rag-project metadata"
$ragMetadata = Join-Path $ragDir "__archetype__.json"
if (Test-Path $ragMetadata) {
    Write-Pass "rag-project __archetype__.json found"
} else {
    Write-Fail "rag-project __archetype__.json NOT FOUND"
}

Write-Test "Validating rag-project metadata JSON"
if (Test-Path $ragMetadata) {
    if (Test-JsonValid $ragMetadata) {
        Write-Pass "Metadata is valid JSON"

        # Validate required fields
        $metadata = Get-JsonContent $ragMetadata
        $requiredFields = @("version", "metadata", "composition", "dependencies", "services")
        $missingFields = @()
        foreach ($field in $requiredFields) {
            if (-not $metadata.PSObject.Properties.Name.Contains($field)) {
                $missingFields += $field
            }
        }

        if ($missingFields.Count -eq 0) {
            Write-Info "  All required metadata fields present"
        } else {
            Write-Fail "  Missing fields: $($missingFields -join ', ')"
        }
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

Write-Test "Checking for rag-project source directory"
$ragSrcDir = Join-Path $ragDir "src"
if (Test-Path $ragSrcDir) {
    Write-Pass "src/ directory found"
} else {
    Write-Fail "src/ directory NOT FOUND"
}

Write-Test "Checking for rag-project models"
$ragModelsDir = Join-Path $ragSrcDir "models"
if (Test-Path $ragModelsDir) {
    Write-Pass "src/models/ directory found"
} else {
    Write-Fail "src/models/ directory NOT FOUND"
}

Write-Test "Checking for rag-project services"
$ragServicesDir = Join-Path $ragSrcDir "services"
if (Test-Path $ragServicesDir) {
    Write-Pass "src/services/ directory found"
} else {
    Write-Fail "src/services/ directory NOT FOUND"
}

Write-Test "Checking for rag-project API"
$ragApiDir = Join-Path $ragSrcDir "api"
if (Test-Path $ragApiDir) {
    Write-Pass "src/api/ directory found"
} else {
    Write-Skip "src/api/ directory not found (optional)"
}

Write-Test "Checking for rag-project tests"
$ragTestsDir = Join-Path $ragDir "tests"
if (Test-Path $ragTestsDir) {
    Write-Pass "tests/ directory found"
} else {
    Write-Fail "tests/ directory NOT FOUND"
}

Write-Test "Checking for rag-project Docker Compose"
$ragDockerCompose = Join-Path $ragDir "docker-compose.yml"
if (Test-Path $ragDockerCompose) {
    Write-Pass "docker-compose.yml found"
} else {
    Write-Skip "docker-compose.yml not found (optional)"
}

Write-Test "Checking for rag-project requirements.txt"
$ragRequirements = Join-Path $ragDir "requirements.txt"
if (Test-Path $ragRequirements) {
    Write-Pass "requirements.txt found"
} else {
    Write-Fail "requirements.txt NOT FOUND"
}

Write-Test "Checking for rag-project README"
$ragReadme = Join-Path $ragDir "README.md"
if (Test-Path $ragReadme) {
    Write-Pass "README.md found"
} else {
    Write-Fail "README.md NOT FOUND"
}

# Test 6.3: API Service Archetype
Write-TestHeader "Test 6.3: API Service Archetype"

$apiDir = Join-Path $ArchetypesDir "api-service"
Write-Test "Checking for api-service archetype directory"
if (Test-Path $apiDir) {
    Write-Pass "api-service/ directory found"
} else {
    Write-Fail "api-service/ directory NOT FOUND"
}

Write-Test "Checking for api-service metadata"
$apiMetadata = Join-Path $apiDir "__archetype__.json"
if (Test-Path $apiMetadata) {
    Write-Pass "api-service __archetype__.json found"
} else {
    Write-Fail "api-service __archetype__.json NOT FOUND"
}

Write-Test "Validating api-service metadata JSON"
if (Test-Path $apiMetadata) {
    if (Test-JsonValid $apiMetadata) {
        Write-Pass "Metadata is valid JSON"
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

# Test 6.4: Monitoring Archetype
Write-TestHeader "Test 6.4: Monitoring Archetype"

$monitoringDir = Join-Path $ArchetypesDir "monitoring"
Write-Test "Checking for monitoring archetype directory"
if (Test-Path $monitoringDir) {
    Write-Pass "monitoring/ directory found"
} else {
    Write-Fail "monitoring/ directory NOT FOUND"
}

Write-Test "Checking for monitoring metadata"
$monitoringMetadata = Join-Path $monitoringDir "__archetype__.json"
if (Test-Path $monitoringMetadata) {
    Write-Pass "monitoring __archetype__.json found"
} else {
    Write-Fail "monitoring __archetype__.json NOT FOUND"
}

Write-Test "Validating monitoring metadata JSON"
if (Test-Path $monitoringMetadata) {
    if (Test-JsonValid $monitoringMetadata) {
        Write-Pass "Metadata is valid JSON"
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

Write-Test "Checking for Prometheus configuration"
$prometheusDir = Join-Path $monitoringDir "prometheus"
if (Test-Path $prometheusDir) {
    Write-Pass "prometheus/ directory found"
} else {
    Write-Fail "prometheus/ directory NOT FOUND"
}

Write-Test "Checking for Grafana configuration"
$grafanaDir = Join-Path $monitoringDir "grafana"
if (Test-Path $grafanaDir) {
    Write-Pass "grafana/ directory found"
} else {
    Write-Fail "grafana/ directory NOT FOUND"
}

# Test 6.5: Agentic Workflows Archetype
Write-TestHeader "Test 6.5: Agentic Workflows Archetype"

$agenticDir = Join-Path $ArchetypesDir "agentic-workflows"
Write-Test "Checking for agentic-workflows archetype directory"
if (Test-Path $agenticDir) {
    Write-Pass "agentic-workflows/ directory found"
} else {
    Write-Fail "agentic-workflows/ directory NOT FOUND"
}

Write-Test "Checking for agentic-workflows metadata"
$agenticMetadata = Join-Path $agenticDir "__archetype__.json"
if (Test-Path $agenticMetadata) {
    Write-Pass "agentic-workflows __archetype__.json found"
} else {
    Write-Fail "agentic-workflows __archetype__.json NOT FOUND"
}

Write-Test "Validating agentic-workflows metadata JSON"
if (Test-Path $agenticMetadata) {
    if (Test-JsonValid $agenticMetadata) {
        Write-Pass "Metadata is valid JSON"

        # Check for agents configuration
        $metadata = Get-JsonContent $agenticMetadata
        if ($metadata.PSObject.Properties.Name.Contains("agents")) {
            Write-Info "  Agents configuration found in metadata"
        }
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

Write-Test "Checking for agentic-workflows source"
$agenticSrcDir = Join-Path $agenticDir "src"
if (Test-Path $agenticSrcDir) {
    Write-Pass "src/ directory found"
} else {
    Write-Fail "src/ directory NOT FOUND"
}

Write-Test "Checking for agentic-workflows requirements"
$agenticRequirements = Join-Path $agenticDir "requirements.txt"
if (Test-Path $agenticRequirements) {
    Write-Pass "requirements.txt found"
} else {
    Write-Fail "requirements.txt NOT FOUND"
}

# Test 6.6: Composite Archetypes
Write-TestHeader "Test 6.6: Composite Archetypes"

$compositeRagAgentsDir = Join-Path $ArchetypesDir "composite-rag-agents"
Write-Test "Checking for composite-rag-agents directory"
if (Test-Path $compositeRagAgentsDir) {
    Write-Pass "composite-rag-agents/ directory found"
} else {
    Write-Fail "composite-rag-agents/ directory NOT FOUND"
}

Write-Test "Checking for composite-rag-agents metadata"
$compositeMetadata = Join-Path $compositeRagAgentsDir "__archetype__.json"
if (Test-Path $compositeMetadata) {
    Write-Pass "composite-rag-agents __archetype__.json found"
} else {
    Write-Fail "composite-rag-agents __archetype__.json NOT FOUND"
}

Write-Test "Validating composite metadata structure"
if (Test-Path $compositeMetadata) {
    if (Test-JsonValid $compositeMetadata) {
        $metadata = Get-JsonContent $compositeMetadata

        # Check for composite-specific fields
        if ($metadata.composition.PSObject.Properties.Name.Contains("constituents")) {
            Write-Pass "Constituents field found (composite archetype)"

            $constituents = $metadata.composition.constituents
            if ($constituents -contains "rag-project" -and $constituents -contains "agentic-workflows") {
                Write-Info "  Combines: rag-project + agentic-workflows"
            }
        } else {
            Write-Fail "Missing 'constituents' field (required for composite)"
        }
    } else {
        Write-Fail "Metadata JSON is INVALID"
    }
} else {
    Write-Skip "Metadata file doesn't exist"
}

Write-Test "Checking for composite integration script"
$integrationScript = Join-Path $compositeRagAgentsDir "scripts" "integrate_rag_agentic.sh"
if (Test-Path $integrationScript) {
    Write-Pass "Integration script found"
} else {
    Write-Skip "Integration script not found (optional)"
}

Write-Test "Checking for composite examples"
$examplesDir = Join-Path $compositeRagAgentsDir "examples"
if (Test-Path $examplesDir) {
    Write-Pass "Examples directory found"
    $exampleFiles = Get-ChildItem $examplesDir -Filter "*.py" -ErrorAction SilentlyContinue
    if ($exampleFiles.Count -gt 0) {
        Write-Info "  Found $($exampleFiles.Count) example files"
    }
} else {
    Write-Skip "Examples directory not found (optional)"
}

Write-Test "Checking for composite README"
$compositeReadme = Join-Path $compositeRagAgentsDir "README.md"
if (Test-Path $compositeReadme) {
    Write-Pass "README.md found"
} else {
    Write-Fail "README.md NOT FOUND"
}

# Test 6.7: Service Definitions
Write-TestHeader "Test 6.7: Service Definitions Validation"

Write-Info "Validating service definitions in archetype metadata"

# Check RAG services
if (Test-Path $ragMetadata) {
    $ragData = Get-JsonContent $ragMetadata
    Write-Test "Checking rag-project services definition"
    if ($ragData.PSObject.Properties.Name.Contains("services")) {
        $serviceCount = ($ragData.services | Get-Member -MemberType NoteProperty).Count
        Write-Pass "$serviceCount services defined"
    } else {
        Write-Fail "No services defined"
    }
}

# Check Monitoring services
if (Test-Path $monitoringMetadata) {
    $monitoringData = Get-JsonContent $monitoringMetadata
    Write-Test "Checking monitoring services definition"
    if ($monitoringData.PSObject.Properties.Name.Contains("services")) {
        $serviceCount = ($monitoringData.services | Get-Member -MemberType NoteProperty).Count
        Write-Pass "$serviceCount services defined"
    } else {
        Write-Fail "No services defined"
    }
}

# Test 6.8: Compatibility Matrix
Write-TestHeader "Test 6.8: Compatibility and Composition"

Write-Info "Checking archetype compatibility definitions"

if (Test-Path $ragMetadata) {
    $ragData = Get-JsonContent $ragMetadata
    Write-Test "Checking rag-project compatibility"
    if ($ragData.composition.PSObject.Properties.Name.Contains("compatible_features")) {
        $compatibleCount = $ragData.composition.compatible_features.Count
        Write-Pass "$compatibleCount compatible features defined"
        Write-Info "  Compatible with: $($ragData.composition.compatible_features -join ', ')"
    } else {
        Write-Fail "No compatibility information"
    }
}

if (Test-Path $agenticMetadata) {
    $agenticData = Get-JsonContent $agenticMetadata
    Write-Test "Checking agentic-workflows compatibility"
    if ($agenticData.composition.PSObject.Properties.Name.Contains("compatible_features")) {
        $compatibleCount = $agenticData.composition.compatible_features.Count
        Write-Pass "$compatibleCount compatible features defined"
    } else {
        Write-Fail "No compatibility information"
    }
}

# Test 6.9: Documentation
Write-TestHeader "Test 6.9: Archetype Documentation"

Write-Test "Checking for comprehensive archetypes README"
if (Test-Path $readmeFile) {
    $readmeContent = Get-Content $readmeFile -Raw

    # Check if README documents all archetypes
    $archetypesToCheck = @("base", "rag-project", "api-service", "monitoring", "agentic-workflows", "composite")
    $documentsAll = $true
    $missingDocs = @()

    foreach ($archetype in $archetypesToCheck) {
        if ($readmeContent -notmatch $archetype) {
            $documentsAll = $false
            $missingDocs += $archetype
        }
    }

    if ($documentsAll) {
        Write-Pass "README documents all archetypes"
    } else {
        Write-Fail "README missing documentation for: $($missingDocs -join ', ')"
    }
} else {
    Write-Skip "README file doesn't exist"
}

Write-Test "Checking for archetype usage examples in docs"
$docsDir = Join-Path $TemplateRoot "docs"
$exampleDocs = Get-ChildItem $docsDir -Filter "*EXAMPLE*.md" -ErrorAction SilentlyContinue
if ($exampleDocs.Count -gt 0) {
    Write-Pass "Found $($exampleDocs.Count) example documentation files"
} else {
    Write-Skip "No example documentation found (optional)"
}

# Test 6.10: Registry Validation
Write-TestHeader "Test 6.10: Archetype Registry Validation"

if (Test-Path $registryFile) {
    $registry = Get-JsonContent $registryFile

    Write-Test "Checking if registry contains archetypes"
    if ($registry.PSObject.Properties.Name.Contains("archetypes")) {
        Write-Pass "Archetypes field found in registry"

        # Get count of registered archetypes (object properties)
        $registeredCount = ($registry.archetypes | Get-Member -MemberType NoteProperty).Count
        Write-Info "  Registered archetypes: $registeredCount"

        # Check if key archetypes are registered
        $expectedArchetypes = @("base", "rag-project", "agentic-workflows")
        foreach ($expected in $expectedArchetypes) {
            if ($registry.archetypes.PSObject.Properties.Name.Contains($expected)) {
                Write-Info "  ✓ $expected registered"
            } else {
                Write-Fail "  ✗ $expected NOT registered"
            }
        }
    } else {
        Write-Fail "No archetypes field in registry"
    }
} else {
    Write-Skip "Registry file doesn't exist"
}

# Print Summary
Write-Section "Phase 6 Test Summary"
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
    Write-Host "${YELLOW}⚠ Some Phase 6 tests failed${NC}"
    Write-Host "${CYAN}ℹ Review the failed tests above and fix the issues.${NC}"
    Write-Host ""
    exit 1
} else {
    if ($SkippedTests -gt 0) {
        $successRate = [math]::Round(($PassedTests / ($TotalTests - $SkippedTests)) * 100, 1)
        Write-Host "Success Rate:  ${GREEN}${successRate}% (excluding optional features)${NC}"
    } else {
        Write-Host "Success Rate:  ${GREEN}100%${NC}"
    }
    Write-Host ""
    Write-Host "${GREEN}✓ All required Phase 6 tests passed!${NC}"
    Write-Host ""
    Write-Host "${CYAN}Phase 6 (Archetypes) Implementation Status:${NC}"
    Write-Host "  ✓ Archetype infrastructure complete"
    Write-Host "  ✓ Base archetype implemented"
    Write-Host "  ✓ RAG project archetype implemented"
    Write-Host "  ✓ API service archetype implemented"
    Write-Host "  ✓ Monitoring archetype implemented"
    Write-Host "  ✓ Agentic workflows archetype implemented"
    Write-Host "  ✓ Composite archetypes implemented"
    Write-Host "  ✓ Documentation complete"
    Write-Host ""
    exit 0
}
