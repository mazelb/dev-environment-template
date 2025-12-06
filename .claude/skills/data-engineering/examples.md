# Data Engineering Examples

## Example: SQL Optimization

**Before**:
```sql
SELECT * FROM users WHERE email = 'test@example.com';
-- Seq Scan (cost=0.00..25.50) Time: 45ms
```

**After**:
```sql
CREATE INDEX idx_users_email ON users(email);
-- Index Scan (cost=0.14..8.16) Time: 2ms
-- 95% faster
```

## Example: N+1 Fix

**Before**: 100 queries for 100 users (2000ms)
**After**: 1 query with JOIN (150ms)
**Improvement**: 13x faster
