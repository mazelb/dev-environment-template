# Code Quality Review Examples

## Example 1: Python Security Vulnerability

**Issue**: SQL Injection in user endpoint

```python
# ❌ VULNERABLE CODE
def get_user(user_id: str):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query).fetchone()
```

**Finding**: CRITICAL - SQL Injection (OWASP A03)
**Risk**: Remote code execution, data breach

**Fixed Code**:
```python
# ✅ SECURE CODE
def get_user(user_id: str):
    query = "SELECT * FROM users WHERE id = %s"
    return db.execute(query, (user_id,)).fetchone()
```

## Example 2: TypeScript N+1 Query Problem

**Issue**: Performance degradation with multiple users

```typescript
// ❌ BAD: N+1 queries
async function getUsers() {
  const users = await db.user.findMany();
  for (const user of users) {
    user.profile = await db.profile.findUnique({
      where: { userId: user.id }
    });
  }
  return users;
}
```

**Finding**: HIGH - N+1 query problem
**Impact**: 100x slower with 100 users

**Fixed Code**:
```typescript
// ✅ GOOD: Single query with include
async function getUsers() {
  return await db.user.findMany({
    include: { profile: true }
  });
}
```

## Example 3: Dependency Vulnerability

**Finding**: Critical npm vulnerability

```
CRITICAL: lodash@4.17.15
CVE-2020-8203: Prototype Pollution
Fix: Update to lodash@4.17.21
```

**Remediation**:
```bash
npm install lodash@latest
npm audit fix
```
