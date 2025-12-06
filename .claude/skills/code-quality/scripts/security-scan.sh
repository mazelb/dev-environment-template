#!/bin/bash
# Security scanning script

set -e

echo "=== Security Scan ==="

# Python security scan
if command -v bandit &> /dev/null; then
    echo "Running Bandit (Python)..."
    bandit -r . -f json -o bandit-report.json || true
fi

# Node.js security scan
if [ -f "package.json" ]; then
    echo "Running npm audit..."
    npm audit --json > npm-audit.json || true
fi

# Check for secrets
if command -v gitleaks &> /dev/null; then
    echo "Scanning for secrets..."
    gitleaks detect --source . --report-path gitleaks-report.json || true
fi

echo "=== Security Scan Complete ==="
