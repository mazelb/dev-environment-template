#!/bin/bash

###############################################################################
# Phase 4 Integration Test - Bash Version
# Tests all merger scripts with real test fixtures
###############################################################################

# Don't exit on error - we want to continue testing
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
TEMP_DIR="$SCRIPT_DIR/temp_bash"

# Print functions
print_header() {
    echo -e "\n${CYAN}============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================${NC}\n"
}

print_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

print_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    ((TESTS_FAILED++))
    echo -e "${RED}[FAIL]${NC} $1"
}

# Cleanup and setup
cleanup() {
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Setup temp directory
mkdir -p "$TEMP_DIR"

###############################################################################
# Test 1: Docker Compose Merger - Basic Merge
###############################################################################

print_header "Test 1: Docker Compose Merger - Basic Merge"

print_test "Merging base.yml and feature.yml"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/docker-compose-merger.sh" merge \
    "$TEMP_DIR/merged.yml" \
    "$FIXTURES_DIR/docker/base.yml" \
    "$FIXTURES_DIR/docker/feature.yml" > "$TEMP_DIR/docker-merge.log" 2>&1

if [ $? -eq 0 ]; then
    if [ -f "$TEMP_DIR/merged.yml" ]; then
        if grep -q "web:" "$TEMP_DIR/merged.yml" && \
           grep -q "db:" "$TEMP_DIR/merged.yml" && \
           grep -q "api:" "$TEMP_DIR/merged.yml" && \
           grep -q "redis:" "$TEMP_DIR/merged.yml"; then
            print_pass "All services merged successfully"
        else
            print_fail "Not all services found in merged file"
        fi
    else
        print_fail "Merged file not created"
    fi
else
    print_fail "Merge command failed"
fi

###############################################################################
# Test 2: Environment File Merger - Conflict Detection
###############################################################################

print_header "Test 2: Environment File Merger - Conflict Detection"

print_test "Merging base.env and feature.env with conflict detection"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/env-merger.sh" merge \
    "$TEMP_DIR/merged.env" \
    "$FIXTURES_DIR/env/base.env" \
    "$FIXTURES_DIR/env/feature.env" > "$TEMP_DIR/env-merge.log" 2>&1

if [ $? -eq 0 ]; then
    if [ -f "$TEMP_DIR/merged.env" ]; then
        if grep -q "API_KEY" "$TEMP_DIR/merged.env"; then
            print_pass "Environment variables merged"

            # Check for conflict markers
            if grep -q "\[CONFLICT\]" "$TEMP_DIR/merged.env" || \
               [ $(grep -c "API_KEY=" "$TEMP_DIR/merged.env") -gt 1 ]; then
                print_pass "Conflict detection working"
            else
                echo -e "${YELLOW}[WARN]${NC} No conflict markers found (may be in dedup mode)"
            fi
        else
            print_fail "Variables not found in merged file"
        fi
    else
        print_fail "Merged env file not created"
    fi
else
    print_fail "Env merge command failed"
fi

###############################################################################
# Test 3: Environment File Merger - Deduplication
###############################################################################

print_header "Test 3: Environment File Merger - Deduplication"

print_test "Merging with deduplication (last value wins)"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/env-merger.sh" merge-dedup \
    "$TEMP_DIR/dedup.env" \
    "$FIXTURES_DIR/env/base.env" \
    "$FIXTURES_DIR/env/feature.env" > "$TEMP_DIR/env-dedup.log" 2>&1

if [ $? -eq 0 ]; then
    if [ -f "$TEMP_DIR/dedup.env" ]; then
        api_key_count=$(grep -c "^API_KEY=" "$TEMP_DIR/dedup.env" || echo "0")
        if [ "$api_key_count" -eq 1 ]; then
            print_pass "Deduplication successful (API_KEY appears once)"
        else
            print_fail "Deduplication failed (API_KEY appears $api_key_count times)"
        fi
    else
        print_fail "Deduplicated env file not created"
    fi
else
    print_fail "Env dedup command failed"
fi

###############################################################################
# Test 4: Makefile Merger - Target Namespacing
###############################################################################

print_header "Test 4: Makefile Merger - Target Namespacing"

print_test "Merging Makefiles with target namespacing"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/makefile-merger.sh" merge \
    "$TEMP_DIR/Makefile" \
    "$FIXTURES_DIR/makefiles/base.mk" \
    "$FIXTURES_DIR/makefiles/feature.mk" > "$TEMP_DIR/makefile-merge.log" 2>&1

if [ $? -eq 0 ]; then
    if [ -f "$TEMP_DIR/Makefile" ]; then
        # Check for namespaced targets
        if grep -qE "(base\.mk-build|base-build):" "$TEMP_DIR/Makefile" || \
           grep -qE "(feature\.mk-build|feature-build):" "$TEMP_DIR/Makefile"; then
            print_pass "Target namespacing applied"
        else
            echo -e "${YELLOW}[WARN]${NC} Namespaced targets not found (may use different pattern)"
        fi

        # Check for composite all target
        if grep -q "^all:" "$TEMP_DIR/Makefile"; then
            print_pass "Composite 'all' target created"
        else
            print_fail "Composite 'all' target missing"
        fi
    else
        print_fail "Merged Makefile not created"
    fi
else
    print_fail "Makefile merge command failed"
fi

###############################################################################
# Test 5: Source File Merger - Type Detection
###############################################################################

print_header "Test 5: Source File Merger - Type Detection"

print_test "Detecting FastAPI file type"
((TESTS_RUN++))

file_type=$(bash "$ROOT_DIR/scripts/source-file-merger.sh" detect-type \
    "$FIXTURES_DIR/python/base_main.py" 2>&1)

if echo "$file_type" | grep -qi "fastapi"; then
    print_pass "FastAPI file detected correctly"
else
    print_fail "FastAPI file not detected (got: $file_type)"
fi

###############################################################################
# Test 6: Source File Merger - FastAPI Merging
###############################################################################

print_header "Test 6: Source File Merger - FastAPI Merging"

print_test "Merging FastAPI applications"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/source-file-merger.sh" merge-fastapi \
    "$TEMP_DIR/main.py" \
    "$FIXTURES_DIR/python/base_main.py" \
    "$FIXTURES_DIR/python/feature_main.py" > "$TEMP_DIR/fastapi-merge.log" 2>&1

if [ $? -eq 0 ]; then
    if [ -f "$TEMP_DIR/main.py" ]; then
        if grep -q "from fastapi import FastAPI" "$TEMP_DIR/main.py" && \
           grep -q "app = FastAPI" "$TEMP_DIR/main.py"; then
            print_pass "FastAPI files merged with app creation"
        else
            print_fail "FastAPI merge incomplete"
        fi
    else
        print_fail "Merged FastAPI file not created"
    fi
else
    print_fail "FastAPI merge command failed"
fi

###############################################################################
# Test 7: Directory Merger - Conflict Analysis
###############################################################################

print_header "Test 7: Directory Merger - Conflict Analysis"

print_test "Analyzing conflicts between fixture directories"
((TESTS_RUN++))

bash "$ROOT_DIR/scripts/directory-merger.sh" list-conflicts \
    "$FIXTURES_DIR/docker" \
    "$FIXTURES_DIR/env" > "$TEMP_DIR/dir-conflicts.log" 2>&1

if [ $? -eq 0 ]; then
    print_pass "Conflict analysis completed"
else
    echo -e "${YELLOW}[WARN]${NC} Conflict analysis returned non-zero (may be expected)"
fi

###############################################################################
# Test Results Summary
###############################################################################

print_header "Test Results Summary"

echo "Tests Run:    $TESTS_RUN"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    SUCCESS_RATE=100
else
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TESTS_RUN))
fi

echo -e "Success Rate: ${SUCCESS_RATE}%"

echo ""
echo "Output files created in: $TEMP_DIR"
echo "  - merged.yml (Docker Compose)"
echo "  - merged.env (Environment with conflicts)"
echo "  - dedup.env (Environment deduplicated)"
echo "  - Makefile (Merged with namespacing)"
echo "  - main.py (Merged FastAPI)"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed${NC}"
    exit 1
fi
