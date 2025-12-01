# Example: Code Quality Skill

---
name: code-quality
description: |
  Comprehensive code review, dependency auditing, and performance profiling.

  Automatically activates when you:
  - Ask for code review or quality assessment
  - Show code with potential issues
  - Request dependency audit or security scan
  - Mention performance profiling or optimization
  - Discuss technical debt or code smells

  Supports: Python, TypeScript/JavaScript, Kotlin
  Checks: Code style, security, dependencies, performance, testing

  Outputs prioritized findings (Critical → High → Medium → Low) with
  suggested fixes, code examples, and remediation steps.
allowed-tools: ["Read", "Grep", "Glob", "Bash(grep -r)", "Bash(find .)"]
---

# Code Quality Review Skill

This skill automatically helps maintain high code quality across your multi-language codebase.

## When This Skill Activates

Claude will invoke this skill when you:
1. **Request code review**: "Review the auth module for code quality"
2. **Show problematic code**: Paste code with obvious issues
3. **Ask about dependencies**: "Are our dependencies up to date?"
4. **Request security scan**: "Check this for vulnerabilities"
5. **Discuss performance**: "Is this function optimized?"
6. **Mention technical debt**: "What's the technical debt here?"

## What This Skill Does

### 1. Code Review

**For all languages**, checks:
- ✅ Code style and formatting consistency
- ✅ Naming conventions (variables, functions, classes)
- ✅ Code complexity and cyclomatic complexity
- ✅ Code duplication (DRY principle)
- ✅ Function/method length and cohesion
- ✅ Comment quality and documentation
- ✅ Error handling and logging
- ✅ Type safety (where applicable)

**Language-specific checks:**

**Python**:
- PEP 8 compliance
- Type hints (PEP 484)
- Docstrings (Google/NumPy style)
- List comprehensions vs loops
- Context managers for resources
- Async/await patterns
- FastAPI best practices
- SQLAlchemy query optimization

**TypeScript/JavaScript**:
- ESLint rule violations
- Type safety (strict mode)
- Promise handling (async/await)
- Immutability patterns
- React hooks rules
- Module imports organization
- Next.js best practices (App Router, Server Components)

**Kotlin**:
- Kotlin idioms
- Null safety
- Data classes
- Extension functions
- Coroutines best practices
- Spring Boot patterns

### 2. Dependency Auditing

**Scans package files:**
- `package.json` / `package-lock.json` (Node.js/TypeScript)
- `requirements.txt` / `pyproject.toml` (Python)
- `build.gradle` / `build.gradle.kts` (Kotlin)

**Checks for:**
- 🔴 **Critical**: Known CVEs and security vulnerabilities
- 🟡 **High**: Outdated major versions
- 🟢 **Medium**: Outdated minor versions
- ⚪ **Low**: Unused or duplicate dependencies

**Example output:**
```
CRITICAL VULNERABILITIES:
- express@4.17.1 → 4.18.2 (CVE-2022-24999: Remote Code Execution)
- lodash@4.17.15 → 4.17.21 (Prototype Pollution)

HIGH PRIORITY:
- axios@0.21.1 → 1.6.0 (SSRF vulnerability)
- node@16.14.0 → 20.10.0 (LTS upgrade available)

MEDIUM PRIORITY:
- react@17.0.2 → 18.2.0 (New features, performance)
- typescript@4.9.5 → 5.3.3 (Better type inference)

UNUSED DEPENDENCIES:
- moment (use date-fns instead)
- underscore (use lodash or native methods)

RECOMMENDATIONS:
1. Update critical packages immediately
2. Run: npm audit fix --force
3. Test thoroughly after updates
4. Configure Dependabot for automatic PRs
```

### 3. Performance Profiling

**Identifies:**
- 🔴 **Critical**: N+1 query problems
- 🔴 **Critical**: Memory leaks
- 🟡 **High**: Inefficient algorithms (O(n²) → O(n log n))
- 🟡 **High**: Blocking I/O in async contexts
- 🟢 **Medium**: Missing indexes on database queries
- 🟢 **Medium**: Unnecessary re-renders (React)

**Performance patterns checked:**

**Database queries:**
```python
# ❌ BAD: N+1 query problem
users = User.query.all()
for user in users:
    print(user.profile.bio)  # Separate query for each user

# ✅ GOOD: Eager loading
users = User.query.options(joinedload(User.profile)).all()
for user in users:
    print(user.profile.bio)  # Single query with JOIN
```

**Caching opportunities:**
```typescript
// ❌ BAD: Recalculating on every render
function UserList({ users }) {
  const sortedUsers = users.sort((a, b) => a.name.localeCompare(b.name));
  return <div>{sortedUsers.map(u => <User key={u.id} {...u} />)}</div>;
}

// ✅ GOOD: Memoized calculation
function UserList({ users }) {
  const sortedUsers = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  );
  return <div>{sortedUsers.map(u => <User key={u.id} {...u} />)}</div>;
}
```

**Algorithm efficiency:**
```python
# ❌ BAD: O(n²) nested loops
def find_duplicates(nums: list[int]) -> list[int]:
    duplicates = []
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] == nums[j] and nums[i] not in duplicates:
                duplicates.append(nums[i])
    return duplicates

# ✅ GOOD: O(n) with set
def find_duplicates(nums: list[int]) -> list[int]:
    seen = set()
    duplicates = []
    for num in nums:
        if num in seen and num not in duplicates:
            duplicates.append(num)
        seen.add(num)
    return duplicates
```

### 4. Security Scanning

**OWASP Top 10 checks:**

1. **A01: Broken Access Control**
   - Missing authorization checks
   - Insecure Direct Object References

2. **A02: Cryptographic Failures**
   - Hardcoded secrets
   - Weak encryption
   - Missing HTTPS

3. **A03: Injection**
   - SQL injection (unsanitized queries)
   - Command injection
   - XSS vulnerabilities

4. **A04: Insecure Design**
   - Missing rate limiting
   - No input validation
   - Weak authentication

5. **A07: Authentication Failures**
   - Weak password policies
   - Missing MFA
   - Session management issues

**Example findings:**
```
CRITICAL SECURITY ISSUES:

1. SQL Injection Vulnerability (src/api/users.py:45)
   ❌ query = f"SELECT * FROM users WHERE id = {user_id}"
   ✅ query = "SELECT * FROM users WHERE id = %s"
      cursor.execute(query, (user_id,))

2. Hardcoded Secret (src/config.py:12)
   ❌ API_KEY = "sk-1234567890abcdef"
   ✅ API_KEY = os.getenv("API_KEY")

3. Missing Input Validation (src/api/endpoints.py:78)
   ❌ user_data = request.json
   ✅ from pydantic import BaseModel
      class UserInput(BaseModel):
          email: EmailStr
          age: int = Field(ge=0, le=150)
      user_data = UserInput(**request.json)
```

## Archetype-Specific Analysis

### RAG Project Archetype
- OpenSearch query efficiency
- Embedding model selection
- Chunking strategy optimization
- Vector similarity search performance
- Ollama model configuration

### API Service Archetype
- FastAPI endpoint optimization
- Celery task queue performance
- Database query optimization
- GraphQL resolver efficiency
- Async/await patterns

### Frontend Archetype
- React component optimization
- Bundle size analysis
- Lazy loading implementation
- Image optimization
- API call batching

## Output Format

Results are organized by severity:

```
CODE QUALITY REPORT
Generated: 2025-12-01 10:30 AM

=== CRITICAL ISSUES (Fix Immediately) ===
1. [Security] SQL Injection in src/api/users.py:45
   Impact: Remote code execution
   Fix: Use parameterized queries

2. [Performance] N+1 Query in src/services/orders.py:112
   Impact: 100x slower on large datasets
   Fix: Use eager loading with joinedload()

=== HIGH PRIORITY (Fix This Sprint) ===
1. [Dependencies] express@4.17.1 has critical CVE
   Fix: npm install express@latest

2. [Performance] Missing database index on users.email
   Fix: CREATE INDEX idx_users_email ON users(email);

=== MEDIUM PRIORITY (Technical Debt) ===
1. [Code Quality] Function too complex: process_order() (CC=15)
   Suggestion: Extract helper functions

2. [Testing] Missing test coverage in auth module (35%)
   Suggestion: Add unit tests for edge cases

=== LOW PRIORITY (Nice to Have) ===
1. [Style] Inconsistent naming: snake_case vs camelCase
2. [Documentation] Missing docstrings in 12 functions

=== SUMMARY ===
Total Issues: 12
Critical: 2
High: 4
Medium: 4
Low: 2

Estimated Fix Time: 6-8 hours
```

## Integration with Your Workflow

This skill works seamlessly with:
- **Docker Development**: Analyzes Dockerfiles and docker-compose.yml
- **Git Workflow**: Checks recent commits for quality issues
- **CI/CD**: Suggests GitHub Actions quality gates
- **Team Review**: Provides consistent review standards

## Example Usage

**You don't invoke this skill manually.** Claude activates it automatically:

```
You: "Review the authentication module for security issues"
Claude: [Activates code-quality skill]
        → Scans src/auth/ directory
        → Checks for security vulnerabilities
        → Analyzes dependencies
        → Reviews code patterns
        → Provides prioritized findings with fixes

You: "Are our Python dependencies up to date?"
Claude: [Activates code-quality skill]
        → Scans requirements.txt
        → Checks for CVEs
        → Identifies outdated packages
        → Suggests update strategy

You: "Why is this endpoint slow?"
Claude: [Activates code-quality skill]
        → Analyzes performance patterns
        → Identifies N+1 queries
        → Suggests caching strategy
        → Provides optimized code
```

---

**This skill will be saved as:** `.claude/skills/code-quality/SKILL.md`

**Supporting files:**
- `reference.md` - Detailed checklists and standards
- `examples.md` - Real-world code review examples
- `scripts/dependency-audit.sh` - Automated dependency scanner
- `scripts/performance-check.sh` - Performance profiling helper
- `scripts/security-scan.sh` - Security vulnerability scanner
