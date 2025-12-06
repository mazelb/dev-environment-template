# Data Engineering Reference

## SQL Optimization Patterns

### N+1 Query Problem
```python
# ❌ BAD: N+1 queries
users = session.query(User).all()
for user in users:
    print(user.profile.bio)  # Separate query

# ✅ GOOD: Eager loading
users = session.query(User).options(
    joinedload(User.profile)
).all()
```

### Index Strategy
- WHERE clauses: Index the column
- JOIN conditions: Index both sides
- ORDER BY: Consider indexed column
- Composite indexes: Most selective first

### Query Patterns
```sql
-- Use LIMIT for large result sets
SELECT * FROM users LIMIT 100;

-- Use EXISTS instead of COUNT for existence checks
SELECT EXISTS(SELECT 1 FROM users WHERE email = ?);

-- Use pagination with keyset (not OFFSET)
SELECT * FROM users WHERE id > ? ORDER BY id LIMIT 10;
```

## Data Quality Checks

### Schema Validation
- NOT NULL constraints
- CHECK constraints
- FOREIGN KEY constraints
- UNIQUE constraints
- DEFAULT values

### Data Validation
```python
from pydantic import BaseModel, Field

class UserData(BaseModel):
    email: EmailStr
    age: int = Field(ge=0, le=150)
    name: str = Field(min_length=1, max_length=100)
```
