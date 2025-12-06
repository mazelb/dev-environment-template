#!/bin/bash
# Container security scanning

set -e

echo "=== Container Security Scan ==="

if command -v trivy &> /dev/null; then
    echo "Running Trivy security scan..."
    trivy image --severity HIGH,CRITICAL myapp:latest
else
    echo "Trivy not installed. Install: brew install trivy"
fi

if command -v docker &> /dev/null; then
    echo "Checking for running containers as root..."
    docker ps --format '{{.Names}}: {{.Image}}' | while read line; do
        container=$(echo $line | cut -d: -f1)
        docker exec $container whoami 2>/dev/null || echo "$container: cannot check user"
    done
fi

echo "=== Security Scan Complete ==="
