#!/bin/bash

###############################################################################
# Comprehensive Test Suite for create-project.sh
# Tests all command-line options, archetypes, features, and edge cases
###############################################################################

# NOTE: Do not use 'set -e' as we need to handle test failures gracefully

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test configuration
# Get the absolute path to this script
if [ -n "${BASH_SOURCE[0]}" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
CREATE_PROJECT_SCRIPT="$TEMPLATE_DIR/create-project.sh"
TEST_OUTPUT_DIR="$SCRIPT_DIR/temp/test-projects"
TEST_RESULTS_FILE="$SCRIPT_DIR/temp/test-results.txt"

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Setup
setup_tests() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}Create Project Test Suite${NC}      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Clean up old test directory
    if [ -d "$TEST_OUTPUT_DIR" ]; then
        echo -e "${YELLOW}Cleaning up old test directory...${NC}"
        rm -rf "$TEST_OUTPUT_DIR"
    fi

    # Create fresh test directory
    mkdir -p "$TEST_OUTPUT_DIR"
    mkdir -p "$(dirname "$TEST_RESULTS_FILE")"

    # Initialize results file
    echo "Create Project Test Results - $(date)" > "$TEST_RESULTS_FILE"
    echo "===========================================" >> "$TEST_RESULTS_FILE"
    echo "" >> "$TEST_RESULTS_FILE"

    echo -e "${GREEN}✓${NC} Test environment setup complete"
    echo ""
}

# Test helper functions
print_test_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}TEST: $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

test_passed() {
    local test_name="$1"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
    echo -e "${GREEN}✓ PASSED${NC}: $test_name"
    echo "PASS: $test_name" >> "$TEST_RESULTS_FILE"
    TEST_RESULTS+=("PASS: $test_name")
}

test_failed() {
    local test_name="$1"
    local reason="$2"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
    echo -e "${RED}✗ FAILED${NC}: $test_name"
    echo -e "${RED}  Reason: $reason${NC}"
    echo "FAIL: $test_name - $reason" >> "$TEST_RESULTS_FILE"
    TEST_RESULTS+=("FAIL: $test_name - $reason")
}

test_skipped() {
    local test_name="$1"
    local reason="$2"
    ((SKIPPED_TESTS++))
    ((TOTAL_TESTS++))
    echo -e "${YELLOW}⊘ SKIPPED${NC}: $test_name"
    echo -e "${YELLOW}  Reason: $reason${NC}"
    echo "SKIP: $test_name - $reason" >> "$TEST_RESULTS_FILE"
    TEST_RESULTS+=("SKIP: $test_name - $reason")
}

cleanup_test_project() {
    local project_path="$1"
    if [ -d "$project_path" ]; then
        rm -rf "$project_path"
    fi
}

# Test 1: Basic help command
test_help_command() {
    print_test_header "Help Command (--help)"

    if bash "$CREATE_PROJECT_SCRIPT" --help > /dev/null 2>&1; then
        test_passed "Help command displays usage"
    else
        test_failed "Help command displays usage" "Command failed"
    fi
    echo ""
}

# Test 2: List archetypes
test_list_archetypes() {
    print_test_header "List Archetypes (--list-archetypes)"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --list-archetypes 2>&1)

    if echo "$output" | grep -q "BASE ARCHETYPES"; then
        if echo "$output" | grep -q "FEATURE ARCHETYPES"; then
            if echo "$output" | grep -q "COMPOSITE ARCHETYPES"; then
                test_passed "List archetypes shows all categories"
            else
                test_failed "List archetypes shows all categories" "Missing composite archetypes section"
            fi
        else
            test_failed "List archetypes shows all categories" "Missing feature archetypes section"
        fi
    else
        test_failed "List archetypes shows all categories" "Missing base archetypes section"
    fi
    echo ""
}

# Test 3: List features
test_list_features() {
    print_test_header "List Features (--list-features)"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --list-features 2>&1)

    if echo "$output" | grep -q "Feature Archetypes"; then
        test_passed "List features displays feature archetypes"
    else
        test_failed "List features displays feature archetypes" "No feature archetypes found in output"
    fi
    echo ""
}

# Test 4: List tools
test_list_tools() {
    print_test_header "List Tools (--list-tools)"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --list-tools 2>&1)

    if echo "$output" | grep -q "Available Optional Tools"; then
        test_passed "List tools displays available tools"
    else
        test_failed "List tools displays available tools" "Tools not displayed"
    fi
    echo ""
}

# Test 5: List presets
test_list_presets() {
    print_test_header "List Presets (--list-presets)"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --list-presets 2>&1)

    if echo "$output" | grep -q "Available Presets"; then
        test_passed "List presets displays available presets"
    else
        test_failed "List presets displays available presets" "Presets not displayed"
    fi
    echo ""
}

# Test 6: Dry run mode
test_dry_run() {
    print_test_header "Dry Run Mode (--dry-run)"

    local test_name="test-dry-run"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --dry-run 2>&1)

    if echo "$output" | grep -q "Dry Run Preview"; then
        if [ ! -d "$project_path" ]; then
            test_passed "Dry run shows preview without creating files"
        else
            test_failed "Dry run shows preview without creating files" "Directory was created"
            cleanup_test_project "$project_path"
        fi
    else
        test_failed "Dry run shows preview without creating files" "No preview shown"
    fi
    echo ""
}

# Test 7: Create project with base archetype
test_base_archetype() {
    print_test_header "Base Archetype (--archetype base)"

    local test_name="test-base-archetype"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/README.md" ]; then
                test_passed "Base archetype creates project structure"
            else
                test_failed "Base archetype creates project structure" "README.md not created"
            fi
        else
            test_failed "Base archetype creates project structure" "Project directory not created"
        fi
    else
        test_failed "Base archetype creates project structure" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 8: Create project with RAG archetype
test_rag_archetype() {
    print_test_header "RAG Archetype (--archetype rag-project)"

    local test_name="test-rag-archetype"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype rag-project --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/README.md" ]; then
                test_passed "RAG archetype creates project structure"
            else
                test_failed "RAG archetype creates project structure" "README.md not created"
            fi
        else
            test_failed "RAG archetype creates project structure" "Project directory not created"
        fi
    else
        test_failed "RAG archetype creates project structure" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 9: Create project with API service archetype
test_api_service_archetype() {
    print_test_header "API Service Archetype (--archetype api-service)"

    local test_name="test-api-service"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype api-service --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            test_passed "API service archetype creates project structure"
        else
            test_failed "API service archetype creates project structure" "Project directory not created"
        fi
    else
        test_failed "API service archetype creates project structure" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 10: Create project with feature archetypes
test_feature_archetypes() {
    print_test_header "Feature Archetypes (--add-features)"

    local test_name="test-features"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --add-features monitoring --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/COMPOSITION.md" ]; then
                test_passed "Feature archetypes composition works"
            else
                test_failed "Feature archetypes composition works" "COMPOSITION.md not created"
            fi
        else
            test_failed "Feature archetypes composition works" "Project directory not created"
        fi
    else
        test_failed "Feature archetypes composition works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 11: Create project with multiple features
test_multiple_features() {
    print_test_header "Multiple Features (--add-features monitoring,agentic-workflows)"

    local test_name="test-multi-features"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --add-features monitoring,agentic-workflows --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/COMPOSITION.md" ]; then
                local comp_content
                comp_content=$(cat "$project_path/COMPOSITION.md")
                if echo "$comp_content" | grep -q "monitoring" && echo "$comp_content" | grep -q "agentic-workflows"; then
                    test_passed "Multiple features composition works"
                else
                    test_failed "Multiple features composition works" "Features not mentioned in COMPOSITION.md"
                fi
            else
                test_failed "Multiple features composition works" "COMPOSITION.md not created"
            fi
        else
            test_failed "Multiple features composition works" "Project directory not created"
        fi
    else
        test_failed "Multiple features composition works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 12: Create project with optional tools
test_optional_tools() {
    print_test_header "Optional Tools (--tools fastapi,postgresql)"

    local test_name="test-tools"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --tools fastapi,postgresql --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/OPTIONAL_TOOLS.md" ]; then
                test_passed "Optional tools integration works"
            else
                test_failed "Optional tools integration works" "OPTIONAL_TOOLS.md not created"
            fi
        else
            test_failed "Optional tools integration works" "Project directory not created"
        fi
    else
        test_failed "Optional tools integration works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 13: Create project with preset
test_preset() {
    print_test_header "Preset (--preset ai-agent)"

    local test_name="test-preset"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --preset ai-agent --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ -f "$project_path/OPTIONAL_TOOLS.md" ]; then
                test_passed "Preset integration works"
            else
                test_failed "Preset integration works" "OPTIONAL_TOOLS.md not created"
            fi
        else
            test_failed "Preset integration works" "Project directory not created"
        fi
    else
        test_failed "Preset integration works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 14: Create project with custom path (absolute)
test_custom_path_absolute() {
    print_test_header "Custom Path - Absolute (--path)"

    local test_name="test-custom-path"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --path "$project_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            test_passed "Custom absolute path works"
        else
            test_failed "Custom absolute path works" "Project directory not created at specified path"
        fi
    else
        test_failed "Custom absolute path works" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 15: Create project with custom path (relative)
test_custom_path_relative() {
    print_test_header "Custom Path - Relative (--path)"

    local test_name="test-relative-path"
    local relative_path="./temp/$test_name"
    local full_path="$SCRIPT_DIR/$relative_path"

    cd "$SCRIPT_DIR"
    if bash "$CREATE_PROJECT_SCRIPT" --path "$relative_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$full_path" ]; then
            test_passed "Custom relative path works"
        else
            test_failed "Custom relative path works" "Project directory not created at specified path"
        fi
    else
        test_failed "Custom relative path works" "Command failed"
    fi

    cleanup_test_project "$full_path"
    cd - > /dev/null
    echo ""
}

# Test 16: Verbose mode
test_verbose_mode() {
    print_test_header "Verbose Mode (--verbose)"

    local test_name="test-verbose"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --verbose --no-git --no-build 2>&1)

    if echo "$output" | grep -q "Resolved project path"; then
        test_passed "Verbose mode provides detailed output"
    else
        test_failed "Verbose mode provides detailed output" "Verbose output not detected"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 17: Composite archetype
test_composite_archetype() {
    print_test_header "Composite Archetype (--archetype composite-rag-agents)"

    local test_name="test-composite"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype composite-rag-agents --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            test_passed "Composite archetype creates project"
        else
            test_failed "Composite archetype creates project" "Project directory not created"
        fi
    else
        test_failed "Composite archetype creates project" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 18: No-git flag
test_no_git_flag() {
    print_test_header "No Git Flag (--no-git)"

    local test_name="test-no-git"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path" ]; then
            if [ ! -d "$project_path/.git" ]; then
                test_passed "No-git flag prevents Git initialization"
            else
                test_failed "No-git flag prevents Git initialization" ".git directory exists"
            fi
        else
            test_failed "No-git flag prevents Git initialization" "Project directory not created"
        fi
    else
        test_failed "No-git flag prevents Git initialization" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 19: Error handling - missing required arguments
test_missing_arguments() {
    print_test_header "Error Handling - Missing Arguments"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" 2>&1 || true)

    if echo "$output" | grep -q "Either --name or --path is required"; then
        test_passed "Error handling for missing required arguments"
    else
        test_failed "Error handling for missing required arguments" "Expected error message not shown"
    fi
    echo ""
}

# Test 20: Error handling - invalid archetype
test_invalid_archetype() {
    print_test_header "Error Handling - Invalid Archetype"

    local test_name="test-invalid"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype nonexistent-archetype --no-git --no-build 2>&1 || true)

    if echo "$output" | grep -q "not found"; then
        test_passed "Error handling for invalid archetype"
    else
        test_failed "Error handling for invalid archetype" "Expected error message not shown"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 21: Error handling - directory already exists
test_existing_directory() {
    print_test_header "Error Handling - Existing Directory"

    local test_name="test-existing"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    # Create directory first
    mkdir -p "$project_path"

    local output
    output=$(bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --no-git --no-build 2>&1 || true)

    if echo "$output" | grep -q "already exists"; then
        test_passed "Error handling for existing directory"
    else
        test_failed "Error handling for existing directory" "Expected error message not shown"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 22: Documentation generation
test_documentation_generation() {
    print_test_header "Documentation Generation"

    local test_name="test-docs"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype rag-project --add-features monitoring --no-git --no-build > /dev/null 2>&1; then
        if [ -f "$project_path/README.md" ] && [ -f "$project_path/COMPOSITION.md" ]; then
            test_passed "Documentation files generated correctly"
        else
            test_failed "Documentation files generated correctly" "Missing documentation files"
        fi
    else
        test_failed "Documentation files generated correctly" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 23: .gitignore generation
test_gitignore_generation() {
    print_test_header ".gitignore Generation"

    local test_name="test-gitignore"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -f "$project_path/.gitignore" ]; then
            if grep -q "__pycache__" "$project_path/.gitignore"; then
                test_passed ".gitignore file generated with content"
            else
                test_failed ".gitignore file generated with content" "gitignore appears empty or incomplete"
            fi
        else
            test_failed ".gitignore file generated with content" ".gitignore not created"
        fi
    else
        test_failed ".gitignore file generated with content" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 24: Project structure creation
test_project_structure() {
    print_test_header "Project Structure Creation"

    local test_name="test-structure"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" --name "$test_name" --path "$project_path" --archetype base --no-git --no-build > /dev/null 2>&1; then
        if [ -d "$project_path/src" ] && [ -d "$project_path/tests" ] && [ -d "$project_path/docs" ]; then
            test_passed "Project directory structure created"
        else
            test_failed "Project directory structure created" "Missing src/, tests/, or docs/ directories"
        fi
    else
        test_failed "Project directory structure created" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Test 25: Combined options test
test_combined_options() {
    print_test_header "Combined Options Test"

    local test_name="test-combined"
    local project_path="$TEST_OUTPUT_DIR/$test_name"

    if bash "$CREATE_PROJECT_SCRIPT" \
        --name "$test_name" \
        --path "$project_path" \
        --archetype rag-project \
        --add-features monitoring \
        --tools fastapi,postgresql \
        --verbose \
        --no-git \
        --no-build > /dev/null 2>&1; then

        if [ -d "$project_path" ] && \
           [ -f "$project_path/README.md" ] && \
           [ -f "$project_path/COMPOSITION.md" ] && \
           [ -f "$project_path/OPTIONAL_TOOLS.md" ]; then
            test_passed "Combined options work together"
        else
            test_failed "Combined options work together" "Missing expected files"
        fi
    else
        test_failed "Combined options work together" "Command failed"
    fi

    cleanup_test_project "$project_path"
    echo ""
}

# Summary report
print_summary() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}Test Summary${NC}                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Total Tests:   ${TOTAL_TESTS}"
    echo -e "${GREEN}Passed:        ${PASSED_TESTS}${NC}"
    echo -e "${RED}Failed:        ${FAILED_TESTS}${NC}"
    echo -e "${YELLOW}Skipped:       ${SKIPPED_TESTS}${NC}"
    echo ""

    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}Failed Tests:${NC}"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ "$result" == FAIL:* ]]; then
                echo -e "  ${RED}✗${NC} ${result#FAIL: }"
            fi
        done
        echo ""
    fi

    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi

    echo -e "Success Rate:  ${success_rate}%"
    echo ""

    # Write summary to file
    echo "" >> "$TEST_RESULTS_FILE"
    echo "===========================================" >> "$TEST_RESULTS_FILE"
    echo "SUMMARY" >> "$TEST_RESULTS_FILE"
    echo "===========================================" >> "$TEST_RESULTS_FILE"
    echo "Total Tests: $TOTAL_TESTS" >> "$TEST_RESULTS_FILE"
    echo "Passed: $PASSED_TESTS" >> "$TEST_RESULTS_FILE"
    echo "Failed: $FAILED_TESTS" >> "$TEST_RESULTS_FILE"
    echo "Skipped: $SKIPPED_TESTS" >> "$TEST_RESULTS_FILE"
    echo "Success Rate: ${success_rate}%" >> "$TEST_RESULTS_FILE"

    echo -e "${CYAN}Full results saved to: $TEST_RESULTS_FILE${NC}"
    echo ""

    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        return 1
    fi
}

# Main test execution
main() {
    setup_tests

    # Check if create-project.sh exists
    if [ ! -f "$CREATE_PROJECT_SCRIPT" ]; then
        echo -e "${RED}ERROR: create-project.sh not found at $CREATE_PROJECT_SCRIPT${NC}"
        exit 1
    fi

    # Check if jq is available (required for some tests)
    JQ_AVAILABLE=false

    # Try to find jq in various locations (Windows compatibility)
    if command -v jq &> /dev/null; then
        JQ_AVAILABLE=true
    elif [ -f "/c/Users/$USER/.local/bin/jq.exe" ]; then
        # Add Windows user local bin to PATH
        export PATH="$PATH:/c/Users/$USER/.local/bin"
        if command -v jq.exe &> /dev/null; then
            # Create symlink or alias for jq
            alias jq='jq.exe'
            JQ_AVAILABLE=true
        fi
    fi

    if [ "$JQ_AVAILABLE" = true ]; then
        echo -e "${GREEN}✓${NC} jq is available - all tests will run"
    else
        echo -e "${YELLOW}⚠${NC} jq not found - tests requiring jq will be skipped"
        echo -e "${CYAN}  Install jq:${NC}"
        echo -e "${CYAN}    Linux: sudo apt-get install jq${NC}"
        echo -e "${CYAN}    macOS: brew install jq${NC}"
        echo -e "${CYAN}    Windows: Downloaded to ~/.local/bin/jq.exe (restart shell)${NC}"
    fi
    echo ""

    # Run all tests
    test_help_command
    test_list_archetypes
    test_list_features
    test_list_tools
    test_list_presets
    test_dry_run
    test_base_archetype
    test_rag_archetype
    test_api_service_archetype
    test_feature_archetypes
    test_multiple_features

    # Tests that require jq
    if [ "$JQ_AVAILABLE" = true ]; then
        test_optional_tools
        test_preset
    else
        test_skipped "Optional tools integration" "jq not available"
        test_skipped "Preset integration" "jq not available"
    fi

    test_custom_path_absolute
    test_custom_path_relative
    test_verbose_mode
    test_composite_archetype
    test_no_git_flag
    test_missing_arguments
    test_invalid_archetype
    test_existing_directory
    test_documentation_generation
    test_gitignore_generation
    test_project_structure

    # Combined options test (requires jq)
    if [ "$JQ_AVAILABLE" = true ]; then
        test_combined_options
    else
        test_skipped "Combined options" "jq not available"
    fi

    # Print summary
    print_summary
}

# Run tests
main "$@"
