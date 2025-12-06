#!/bin/bash
# Dependency audit script for Python, Node.js, and Kotlin projects

set -e

echo "=== Dependency Security Audit ==="

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "Checking Python dependencies..."
    if command -v pip-audit &> /dev/null; then
        pip-audit
    else
        echo "pip-audit not installed. Install with: pip install pip-audit"
    fi
fi

# Node.js
if [ -f "package.json" ]; then
    echo "Checking Node.js dependencies..."
    npm audit
fi

# Kotlin/Java
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo "Checking Kotlin/Java dependencies..."
    ./gradlew dependencyCheckAnalyze || echo "Add dependency-check plugin to Gradle"
fi

echo "=== Audit Complete ==="
