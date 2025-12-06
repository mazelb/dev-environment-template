#!/bin/bash
# Performance profiling helper script

echo "=== Performance Check ==="

# Check for Python profiling
if [ -f "*.py" ]; then
    echo "Run Python profiler:"
    echo "python -m cProfile -o output.prof script.py"
    echo "python -m pstats output.prof"
fi

# Check for Node.js profiling
if [ -f "package.json" ]; then
    echo "Run Node.js profiler:"
    echo "node --prof app.js"
    echo "node --prof-process isolate-*.log > processed.txt"
fi

echo "Use Chrome DevTools for frontend performance profiling"
