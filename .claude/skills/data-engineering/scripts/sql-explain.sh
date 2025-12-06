#!/bin/bash
# SQL query analyzer

echo "=== SQL Query Analysis ==="

if command -v psql &> /dev/null; then
    echo "Use EXPLAIN ANALYZE to analyze queries:"
    echo "psql -U user -d database -c 'EXPLAIN ANALYZE SELECT ...;'"
else
    echo "PostgreSQL client not installed"
fi

echo "
Query Optimization Checklist:
- [ ] Add indexes on WHERE columns
- [ ] Add indexes on JOIN columns
- [ ] Use LIMIT for large results
- [ ] Avoid SELECT *
- [ ] Use EXISTS instead of COUNT for checks
"
