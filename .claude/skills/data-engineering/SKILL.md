---
name: data-engineering
description: |
  Automatically reviews data pipelines, optimizes SQL queries, and ensures data quality.

  Activates when you mention: data pipeline, ETL, SQL optimization, query performance,
  data quality, schema design, Airflow DAG, database index, slow query.

  Provides: Pipeline design patterns, SQL query optimization, index recommendations,
  data validation strategies, schema improvements.

  Supports: PostgreSQL, MySQL, SQLAlchemy, Prisma, Spring Data JPA
allowed-tools: ["Read"]
---

# Data Engineering Skill

Automatically optimizes data pipelines, SQL queries, and data quality.

## When This Skill Activates

Claude invokes this skill when you:
1. Show SQL queries or database code
2. Mention slow queries or performance
3. Discuss data pipelines or ETL
4. Ask about data quality
5. Work with database schema

## What This Skill Does

### 1. SQL Query Optimization

**Identifies**:
- N+1 query problems
- Missing indexes
- Inefficient JOINs
- Unnecessary columns in SELECT
- Lack of query limits

**Example Optimization**:
```sql
-- Before: Sequential scan (45ms)
SELECT * FROM users WHERE email = 'test@example.com';

-- Add index
CREATE INDEX idx_users_email ON users(email);

-- After: Index scan (2ms) - 95% faster
```

### 2. Data Pipeline Design

**Best Practices**:
- Idempotency (safe to rerun)
- Error handling and retries
- Monitoring and alerting
- Data validation
- Incremental processing

### 3. Data Quality

**Checks for**:
- Schema validation
- Null handling
- Duplicate detection
- Referential integrity
- Data type consistency

## Archetype-Specific Optimizations

**For rag-project**:
- OpenSearch indexing optimization
- Batch document processing
- Embedding caching strategies
- Vector search performance

**For api-service**:
- Database query optimization
- SQLAlchemy eager loading
- Connection pooling
- Query result caching

## Output Format

Provides:
1. **Query Analysis**: Performance issues
2. **Execution Plan**: EXPLAIN output
3. **Optimized Query**: Improved version
4. **Index Recommendations**: SQL to create indexes
5. **Performance Gains**: Expected improvements

## Example Usage

```
User: "This query is slow: SELECT * FROM users JOIN profiles..."
Claude: [Activates data-engineering skill]
- Identifies N+1 problem
- Suggests eager loading
- Recommends indexes
- Provides optimized query

Result: 2000ms → 150ms (13x faster)
```
