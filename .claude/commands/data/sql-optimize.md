---
description: Optimize SQL queries and database schema for Python, TypeScript, Kotlin
allowed-tools: ["Read"]
model: claude-sonnet-4-5
---

# SQL Query Optimization

Analyze and optimize SQL queries, database schema, and data access patterns.

## Optimization Areas

1. **Query Performance**: Optimize slow queries
2. **Indexing Strategy**: Add appropriate indexes
3. **Schema Design**: Improve database schema
4. **Connection Pooling**: Optimize connections
5. **N+1 Queries**: Eliminate query multiplication

## Query Optimization Techniques

### 1. Use EXPLAIN ANALYZE
```sql
-- Analyze query execution plan
EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'test@example.com';

-- Look for:
-- - Seq Scan (bad) → Index Scan (good)
-- - High cost estimates
-- - Long execution times
```

### 2. Add Indexes
```sql
-- Before: Sequential scan (slow)
SELECT * FROM users WHERE email = 'test@example.com';
-- Seq Scan on users (cost=0.00..25.50 rows=1000)

-- Add index
CREATE INDEX idx_users_email ON users(email);

-- After: Index scan (fast)
-- Index Scan using idx_users_email (cost=0.14..8.16 rows=1)
```

### 3. Optimize JOINs
```sql
-- ❌ Bad: Multiple separate queries (N+1)
users = SELECT * FROM users;
for user in users:
    profile = SELECT * FROM profiles WHERE user_id = user.id

-- ✅ Good: Single query with JOIN
SELECT users.*, profiles.*
FROM users
LEFT JOIN profiles ON users.id = profiles.user_id;
```

### 4. Use Appropriate Data Types
```sql
-- ❌ Bad: VARCHAR for numbers
CREATE TABLE users (
    id VARCHAR(255),
    age VARCHAR(10)
);

-- ✅ Good: Appropriate types
CREATE TABLE users (
    id UUID PRIMARY KEY,
    age INTEGER CHECK (age >= 0 AND age <= 150)
);
```

## Language-Specific Optimizations

### Python (SQLAlchemy)
```python
# ❌ Bad: N+1 query problem
users = session.query(User).all()
for user in users:
    print(user.profile.bio)  # Separate query each time

# ✅ Good: Eager loading
from sqlalchemy.orm import joinedload
users = session.query(User).options(
    joinedload(User.profile)
).all()
for user in users:
    print(user.profile.bio)  # No additional queries
```

### TypeScript (Prisma)
```typescript
// ❌ Bad: N+1 queries
const users = await prisma.user.findMany();
for (const user of users) {
  const profile = await prisma.profile.findUnique({
    where: { userId: user.id }
  });
}

// ✅ Good: Include relation
const users = await prisma.user.findMany({
  include: { profile: true }
});
```

### Kotlin (Spring Data JPA)
```kotlin
// ❌ Bad: Lazy loading causes N+1
@Entity
class User {
    @OneToMany(fetch = FetchType.LAZY)
    val orders: List<Order>
}

// ✅ Good: Entity graph
@EntityGraph(attributePaths = ["orders"])
fun findAllWithOrders(): List<User>
```

## Common Performance Issues

### N+1 Queries
**Problem**: 1 query to fetch users, then N queries to fetch related data

**Solution**: Use eager loading, joins, or batching

### Missing Indexes
**Problem**: Full table scans for WHERE/ORDER BY clauses

**Solution**: Add indexes on frequently queried columns
```sql
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);
```

### Inefficient Pagination
```sql
-- ❌ Bad: OFFSET gets slower with larger offsets
SELECT * FROM users
ORDER BY id
LIMIT 10 OFFSET 10000;

-- ✅ Good: Keyset pagination
SELECT * FROM users
WHERE id > 10000
ORDER BY id
LIMIT 10;
```

### Unnecessary Columns
```sql
-- ❌ Bad: Selecting all columns
SELECT * FROM users;

-- ✅ Good: Select only needed columns
SELECT id, email, name FROM users;
```

## Indexing Strategy

### When to Add Indexes
- [ ] WHERE clause columns
- [ ] JOIN condition columns
- [ ] ORDER BY columns
- [ ] Foreign keys
- [ ] Unique constraints

### Index Types
- **B-Tree**: Default, good for most cases
- **Hash**: Equality comparisons only
- **GIN**: Full-text search, JSON fields
- **BRIN**: Large tables with natural order

### Composite Indexes
```sql
-- Index column order matters!
CREATE INDEX idx_orders_user_status_created
ON orders(user_id, status, created_at DESC);

-- Works for:
-- ✅ WHERE user_id = ?
-- ✅ WHERE user_id = ? AND status = ?
-- ✅ WHERE user_id = ? AND status = ? ORDER BY created_at

-- Doesn't work for:
-- ❌ WHERE status = ? (user_id not in WHERE)
```

## Archetype-Specific Optimizations

**For rag-project (OpenSearch):**
- Use k-NN for vector similarity
- Implement hybrid search (BM25 + k-NN)
- Add filters before vector search
- Use index aliases for zero-downtime reindexing

**For api-service (PostgreSQL):**
- Connection pooling (20-50 connections)
- Read replicas for read-heavy workloads
- Partitioning for large tables
- Materialized views for complex queries

**For frontend (API optimization):**
- GraphQL to avoid over-fetching
- Batch API requests
- Client-side caching (SWR, React Query)
- Pagination/infinite scroll

## Output Format

Provide:
1. **Query Analysis**: Current performance issues
2. **Execution Plan**: EXPLAIN ANALYZE output
3. **Optimized Query**: Improved version
4. **Index Recommendations**: Indexes to add
5. **Performance Gains**: Expected improvements
6. **Migration Script**: SQL to apply changes

## Example Output

```
Query Analysis:
Current query is slow due to:
- Sequential scan on users table
- N+1 query problem for profiles
- Missing index on email column
- Fetching unnecessary columns

Execution Plan:
```
Seq Scan on users  (cost=0.00..25.50 rows=1000 width=100)
  Filter: (email = 'test@example.com')
Planning time: 0.123 ms
Execution time: 45.234 ms
```

Optimized Query (SQLAlchemy):
```python
from sqlalchemy.orm import joinedload

users = session.query(User).options(
    joinedload(User.profile)
).filter(
    User.email == email
).all()
```

Index Recommendations:
```sql
-- Add index on email column
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Add composite index for common query pattern
CREATE INDEX CONCURRENTLY idx_orders_user_created
ON orders(user_id, created_at DESC);
```

Performance Gains:
- Query time: 45ms → 2ms (95% faster)
- Database load: 100 queries → 1 query (99% reduction)
- Memory usage: Similar

Migration Script:
```sql
-- migrations/versions/20250101_add_indexes.sql
BEGIN;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email
ON users(email);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_user_created
ON orders(user_id, created_at DESC);

COMMIT;
```

Testing:
```bash
# Before
time curl http://localhost:8000/users?email=test@example.com
# Real: 0.05s

# After
time curl http://localhost:8000/users?email=test@example.com
# Real: 0.002s
```
```
