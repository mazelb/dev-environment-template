#!/bin/bash
# Docker image analysis script

echo "=== Docker Image Analysis ==="

if [ -f "Dockerfile" ]; then
    echo "Analyzing Dockerfile..."

    # Check for multi-stage build
    if grep -q "FROM.*AS" Dockerfile; then
        echo "✅ Multi-stage build detected"
    else
        echo "⚠️  Consider using multi-stage build"
    fi

    # Check for non-root user
    if grep -q "USER" Dockerfile; then
        echo "✅ Non-root user configured"
    else
        echo "⚠️  Running as root (security risk)"
    fi

    # Check for health check
    if grep -q "HEALTHCHECK" Dockerfile; then
        echo "✅ Health check configured"
    else
        echo "⚠️  No health check defined"
    fi
fi

echo "=== Analysis Complete ==="
