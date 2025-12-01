---
description: Perform security analysis and identify vulnerabilities
allowed-tools: ["Read", "Bash(grep -r)"]
model: claude-opus-4
---

# Security Review

Review code for security vulnerabilities and compliance with security best practices.

## Security Checklist (OWASP Top 10)

1. **A01: Broken Access Control**
   - Missing authorization checks
   - Insecure Direct Object References (IDOR)
   - Privilege escalation

2. **A02: Cryptographic Failures**
   - Hardcoded secrets/API keys
   - Weak encryption
   - Missing HTTPS/TLS
   - Insecure password storage

3. **A03: Injection**
   - SQL injection
   - Command injection
   - XSS (Cross-Site Scripting)
   - Path traversal

4. **A04: Insecure Design**
   - Missing rate limiting
   - No input validation
   - Weak authentication

5. **A07: Authentication Failures**
   - Weak password policies
   - Missing MFA
   - Session management issues
   - JWT vulnerabilities

## Language-Specific Security

### Python (FastAPI/Django)
- SQL injection via raw queries
- Pickle deserialization attacks
- eval() usage (code injection)
- Missing CSRF protection
- Unvalidated file uploads
- Missing rate limiting

### TypeScript/JavaScript (Next.js/React)
- XSS vulnerabilities
- npm package vulnerabilities
- Prototype pollution
- Missing input sanitization
- CORS misconfiguration
- Session hijacking

### Kotlin (Spring Boot)
- Deserialization attacks
- SQL injection via JPQL
- Missing CSRF tokens
- Weak cryptography
- XXE (XML External Entity)
- Path traversal

## Archetype-Specific Security

**For rag-project:**
- Validate LLM input/output
- Sanitize search queries
- Secure OpenSearch access
- Rate limit API endpoints
- Validate document uploads
- Secure Redis connections

**For api-service:**
- Validate all API inputs
- Implement JWT properly
- Rate limit endpoints
- Secure database queries
- Validate Celery task inputs
- Secure GraphQL queries

**For frontend:**
- Sanitize user input
- Implement CSP headers
- Prevent XSS attacks
- Secure API calls
- Validate redirects
- Secure localStorage usage

## Security Analysis Process

1. **Scan for Secrets**:
   - Hardcoded API keys
   - Database credentials
   - JWT secrets
   - Encryption keys

2. **Input Validation**:
   - Missing validation
   - Insufficient sanitization
   - Type coercion issues

3. **Authentication/Authorization**:
   - Weak authentication
   - Missing authorization checks
   - Session management

4. **Data Protection**:
   - Sensitive data exposure
   - Missing encryption
   - Insecure storage

5. **Dependencies**:
   - Vulnerable packages
   - Outdated libraries

## Output Format

Provide:
1. **Vulnerability Summary**: Overview of findings
2. **Critical Issues**: Must fix immediately
3. **High Priority**: Fix soon
4. **Medium Priority**: Fix in next sprint
5. **Low Priority**: Consider fixing
6. **Remediation**: Specific fixes for each issue
7. **Prevention**: Best practices to avoid future issues

## Example Output

```
SECURITY REVIEW REPORT
======================

Vulnerability Summary:
- 2 Critical issues found
- 3 High priority issues
- 4 Medium priority issues
- 1 Low priority issue

CRITICAL ISSUES (Fix Immediately):

1. SQL Injection in src/api/users.py:45
   Severity: CRITICAL (CVSS 9.8)
   OWASP: A03:2021 - Injection

   Vulnerable Code:
   ```python
   query = f"SELECT * FROM users WHERE id = {user_id}"
   cursor.execute(query)
   ```

   Risk: Remote code execution, data breach

   Fix:
   ```python
   query = "SELECT * FROM users WHERE id = %s"
   cursor.execute(query, (user_id,))
   ```

2. Hardcoded Secret in src/config.py:12
   Severity: CRITICAL (CVSS 9.1)
   OWASP: A02:2021 - Cryptographic Failures

   Vulnerable Code:
   ```python
   JWT_SECRET = "super-secret-key-12345"
   ```

   Risk: JWT token forgery, authentication bypass

   Fix:
   ```python
   JWT_SECRET = os.getenv("JWT_SECRET")
   if not JWT_SECRET:
       raise ValueError("JWT_SECRET must be set")
   ```

HIGH PRIORITY:

1. Missing Input Validation in src/api/endpoints.py:78
   Severity: HIGH (CVSS 7.5)
   OWASP: A04:2021 - Insecure Design

   Issue: No validation on user input

   Fix:
   ```python
   from pydantic import BaseModel, EmailStr, Field

   class UserInput(BaseModel):
       email: EmailStr
       age: int = Field(ge=0, le=150)
       name: str = Field(min_length=1, max_length=100)
   ```

2. Missing Rate Limiting
   Severity: HIGH
   OWASP: A04:2021 - Insecure Design

   Fix: Add slowapi rate limiting
   ```python
   from slowapi import Limiter
   limiter = Limiter(key_func=get_remote_address)
   @app.get("/api/users")
   @limiter.limit("10/minute")
   async def get_users():
       ...
   ```

PREVENTION MEASURES:
1. Use environment variables for all secrets
2. Implement input validation with Pydantic
3. Use parameterized queries (never string interpolation)
4. Add rate limiting on all public endpoints
5. Enable CORS with specific origins only
6. Run security scanners in CI/CD (bandit, safety)
7. Keep dependencies updated (Dependabot)

COMPLIANCE NOTES:
- GDPR: Ensure PII is encrypted at rest
- HIPAA: Add audit logging for all data access
- SOC 2: Implement comprehensive logging
```
