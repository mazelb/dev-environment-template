#!/bin/bash

###############################################################################
# Phase 1 Integration Test
# Tests the Foundation & Infrastructure implementation
###############################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."

TESTS_PASSED=0
TESTS_FAILED=0

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}  ✓ PASS${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}  ✗ FAIL${NC} $1"
    ((TESTS_FAILED++))
}

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check jq
    print_test "Checking for jq (JSON processor)"
    if command -v jq &> /dev/null; then
        print_pass "jq is installed: $(jq --version)"
    else
        print_fail "jq is not installed (required for archetype operations)"
        echo -e "${YELLOW}Install jq:${NC}"
        echo "  - Windows: choco install jq"
        echo "  - macOS: brew install jq"
        echo "  - Linux: apt-get install jq or yum install jq"
    fi

    # Check bash
    print_test "Checking for bash"
    if command -v bash &> /dev/null; then
        print_pass "bash is available: $(bash --version | head -n1)"
    else
        print_fail "bash is not available"
    fi
}

# Test 1.1: Configuration Directory Structure
test_config_structure() {
    print_header "Test 1.1: Configuration Directory Structure"

    print_test "Checking config/ directory exists"
    if [ -d "$ROOT_DIR/config" ]; then
        print_pass "config/ directory exists"
    else
        print_fail "config/ directory not found"
        return
    fi

    print_test "Checking config/optional-tools.json exists"
    if [ -f "$ROOT_DIR/config/optional-tools.json" ]; then
        print_pass "optional-tools.json exists"
    else
        print_fail "optional-tools.json not found"
    fi

    print_test "Validating optional-tools.json is valid JSON"
    if command -v jq &> /dev/null && [ -f "$ROOT_DIR/config/optional-tools.json" ]; then
        if jq empty "$ROOT_DIR/config/optional-tools.json" 2>/dev/null; then
            print_pass "optional-tools.json is valid JSON"
        else
            print_fail "optional-tools.json has invalid JSON"
        fi
    else
        print_fail "Cannot validate JSON (jq not available)"
    fi

    print_test "Checking config/archetypes.json exists"
    if [ -f "$ROOT_DIR/config/archetypes.json" ]; then
        print_pass "archetypes.json exists"
    else
        print_fail "archetypes.json not found"
    fi

    print_test "Validating archetypes.json is valid JSON"
    if command -v jq &> /dev/null && [ -f "$ROOT_DIR/config/archetypes.json" ]; then
        if jq empty "$ROOT_DIR/config/archetypes.json" 2>/dev/null; then
            print_pass "archetypes.json is valid JSON"
        else
            print_fail "archetypes.json has invalid JSON"
        fi
    else
        print_fail "Cannot validate JSON (jq not available)"
    fi
}

# Test 1.2: Archetypes Directory Structure
test_archetypes_structure() {
    print_header "Test 1.2: Archetypes Directory Structure"

    print_test "Checking archetypes/ directory exists"
    if [ -d "$ROOT_DIR/archetypes" ]; then
        print_pass "archetypes/ directory exists"
    else
        print_fail "archetypes/ directory not found"
        return
    fi

    print_test "Checking archetypes/README.md exists"
    if [ -f "$ROOT_DIR/archetypes/README.md" ]; then
        print_pass "archetypes/README.md exists"
    else
        print_fail "archetypes/README.md not found"
    fi

    print_test "Checking archetypes/base/ directory exists"
    if [ -d "$ROOT_DIR/archetypes/base" ]; then
        print_pass "archetypes/base/ directory exists"
    else
        print_fail "archetypes/base/ directory not found"
    fi

    print_test "Checking archetypes/rag-project/ directory exists"
    if [ -d "$ROOT_DIR/archetypes/rag-project" ]; then
        print_pass "archetypes/rag-project/ directory exists"
    else
        print_fail "archetypes/rag-project/ directory not found"
    fi
}

# Test 1.3: Archetype Metadata Schema
test_archetype_schema() {
    print_header "Test 1.3: Archetype Metadata Schema"

    print_test "Checking __archetype_schema__.json exists"
    if [ -f "$ROOT_DIR/archetypes/__archetype_schema__.json" ]; then
        print_pass "__archetype_schema__.json exists"
    else
        print_fail "__archetype_schema__.json not found"
        return
    fi

    print_test "Validating __archetype_schema__.json is valid JSON"
    if command -v jq &> /dev/null; then
        if jq empty "$ROOT_DIR/archetypes/__archetype_schema__.json" 2>/dev/null; then
            print_pass "Schema is valid JSON"
        else
            print_fail "Schema has invalid JSON"
        fi
    else
        print_fail "Cannot validate JSON (jq not available)"
    fi

    print_test "Checking schema has required top-level properties"
    if command -v jq &> /dev/null; then
        local has_title=$(jq -r '.title' "$ROOT_DIR/archetypes/__archetype_schema__.json" 2>/dev/null)
        local has_version=$(jq -r '.version' "$ROOT_DIR/archetypes/__archetype_schema__.json" 2>/dev/null)
        if [ "$has_title" != "null" ] && [ "$has_version" != "null" ]; then
            print_pass "Schema has title and version"
        else
            print_fail "Schema missing title or version"
        fi
    else
        print_fail "Cannot validate (jq not available)"
    fi
}

# Test 1.4: Base Archetype
test_base_archetype() {
    print_header "Test 1.4: Base Archetype"

    print_test "Checking base/__archetype__.json exists"
    if [ -f "$ROOT_DIR/archetypes/base/__archetype__.json" ]; then
        print_pass "base/__archetype__.json exists"
    else
        print_fail "base/__archetype__.json not found"
        return
    fi

    print_test "Validating base archetype JSON"
    if command -v jq &> /dev/null; then
        if jq empty "$ROOT_DIR/archetypes/base/__archetype__.json" 2>/dev/null; then
            print_pass "Base archetype JSON is valid"
        else
            print_fail "Base archetype JSON is invalid"
        fi
    else
        print_fail "Cannot validate JSON (jq not available)"
    fi

    print_test "Checking base archetype has required metadata"
    if command -v jq &> /dev/null; then
        local name=$(jq -r '.metadata.name' "$ROOT_DIR/archetypes/base/__archetype__.json" 2>/dev/null)
        local role=$(jq -r '.composition.role' "$ROOT_DIR/archetypes/base/__archetype__.json" 2>/dev/null)
        if [ "$name" != "null" ] && [ "$role" != "null" ]; then
            print_pass "Base archetype has name='$name' and role='$role'"
        else
            print_fail "Base archetype missing required metadata"
        fi
    else
        print_fail "Cannot validate (jq not available)"
    fi

    print_test "Checking base archetype directory structure"
    local dirs_ok=true
    for dir in src tests docs; do
        if [ ! -d "$ROOT_DIR/archetypes/base/$dir" ]; then
            dirs_ok=false
            break
        fi
    done
    if [ "$dirs_ok" = true ]; then
        print_pass "Base archetype has src/, tests/, and docs/ directories"
    else
        print_fail "Base archetype missing required directories"
    fi

    print_test "Checking base archetype README.md"
    if [ -f "$ROOT_DIR/archetypes/base/README.md" ]; then
        print_pass "Base archetype has README.md"
    else
        print_fail "Base archetype missing README.md"
    fi
}

# Test 1.5: Archetype Loader Script
test_archetype_loader() {
    print_header "Test 1.5: Archetype Loader Script"

    print_test "Checking archetype-loader.sh exists"
    if [ -f "$ROOT_DIR/scripts/archetype-loader.sh" ]; then
        print_pass "archetype-loader.sh exists"
    else
        print_fail "archetype-loader.sh not found"
        return
    fi

    print_test "Checking archetype-loader.sh is executable"
    if [ -x "$ROOT_DIR/scripts/archetype-loader.sh" ]; then
        print_pass "archetype-loader.sh is executable"
    else
        print_fail "archetype-loader.sh is not executable"
        chmod +x "$ROOT_DIR/scripts/archetype-loader.sh" 2>/dev/null && \
            echo -e "${YELLOW}  → Made executable${NC}"
    fi

    print_test "Checking archetype-loader.sh has required functions"
    local required_functions=("load_archetype" "list_archetypes" "check_compatibility")
    local functions_ok=true
    for func in "${required_functions[@]}"; do
        if ! grep -q "^${func}()" "$ROOT_DIR/scripts/archetype-loader.sh"; then
            functions_ok=false
            echo -e "${YELLOW}  → Missing function: $func${NC}"
        fi
    done
    if [ "$functions_ok" = true ]; then
        print_pass "All required functions present"
    else
        print_fail "Some required functions are missing"
    fi

    print_test "Testing archetype-loader.sh can be sourced"
    if source "$ROOT_DIR/scripts/archetype-loader.sh" 2>/dev/null; then
        print_pass "archetype-loader.sh can be sourced without errors"
    else
        print_fail "archetype-loader.sh has syntax errors"
    fi
}

# Test 1.6: create-project.sh Integration
test_create_project_integration() {
    print_header "Test 1.6: create-project.sh Integration"

    print_test "Checking create-project.sh exists"
    if [ -f "$ROOT_DIR/create-project.sh" ]; then
        print_pass "create-project.sh exists"
    else
        print_fail "create-project.sh not found"
        return
    fi

    print_test "Checking for archetype variables in create-project.sh"
    local has_vars=true
    for var in "BASE_ARCHETYPE" "FEATURE_ARCHETYPES" "ARCHETYPES_DIR"; do
        if ! grep -q "$var" "$ROOT_DIR/create-project.sh"; then
            has_vars=false
            echo -e "${YELLOW}  → Missing variable: $var${NC}"
        fi
    done
    if [ "$has_vars" = true ]; then
        print_pass "All archetype variables present"
    else
        print_fail "Some archetype variables are missing"
    fi

    print_test "Checking for archetype-loader.sh sourcing"
    if grep -q "source.*archetype-loader.sh" "$ROOT_DIR/create-project.sh"; then
        print_pass "create-project.sh sources archetype-loader.sh"
    else
        print_fail "create-project.sh does not source archetype-loader.sh"
    fi

    print_test "Checking for --archetype flag"
    if grep -q "\-\-archetype" "$ROOT_DIR/create-project.sh"; then
        print_pass "--archetype flag implemented"
    else
        print_fail "--archetype flag not found"
    fi

    print_test "Checking for --add-features flag"
    if grep -q "\-\-add-features" "$ROOT_DIR/create-project.sh"; then
        print_pass "--add-features flag implemented"
    else
        print_fail "--add-features flag not found"
    fi

    print_test "Checking for --list-archetypes flag"
    if grep -q "\-\-list-archetypes" "$ROOT_DIR/create-project.sh"; then
        print_pass "--list-archetypes flag implemented"
    else
        print_fail "--list-archetypes flag not found"
    fi

    print_test "Testing help output includes archetype options"
    if bash "$ROOT_DIR/create-project.sh" --help 2>/dev/null | grep -qi "archetype"; then
        print_pass "Help text includes archetype documentation"
    else
        print_fail "Help text missing archetype documentation"
    fi
}

# Summary
print_summary() {
    print_header "Test Summary"

    local total=$((TESTS_PASSED + TESTS_FAILED))
    echo -e "Total Tests: $total"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed! Phase 1 implementation is complete.${NC}"
        return 0
    else
        local pass_rate=$((TESTS_PASSED * 100 / total))
        echo -e "${YELLOW}⚠ $TESTS_FAILED test(s) failed (${pass_rate}% pass rate)${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}Phase 1: Foundation & Infrastructure Test Suite${NC}     ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites
    test_config_structure
    test_archetypes_structure
    test_archetype_schema
    test_base_archetype
    test_archetype_loader
    test_create_project_integration
    print_summary
}

main "$@"
