# Code Quality Reference Guide

## Code Review Checklists

### Python Checklist

- [ ] PEP 8 compliance (use Black + Ruff)
- [ ] Type hints on all function signatures
- [ ] Docstrings (Google or NumPy style)
- [ ] No hardcoded secrets or credentials
- [ ] Proper exception handling
- [ ] Input validation (Pydantic models)
- [ ] Logging with appropriate levels
- [ ] Context managers for resources
- [ ] Async/await for I/O operations
- [ ] No SQL injection (parameterized queries)

### TypeScript/JavaScript Checklist

- [ ] ESLint passing with no warnings
- [ ] TypeScript strict mode enabled
- [ ] No `any` types (use proper types)
- [ ] Proper error handling (try/catch)
- [ ] Input validation (Zod schemas)
- [ ] No XSS vulnerabilities (sanitize input)
- [ ] Proper async/await usage
- [ ] React hooks rules followed
- [ ] Memoization for expensive computations
- [ ] No memory leaks (cleanup useEffect)

### Kotlin Checklist

- [ ] Kotlin idioms used (data classes, when, etc.)
- [ ] Null safety properly handled (?, ?:, !!)
- [ ] Extension functions where appropriate
- [ ] Coroutines for async operations
- [ ] Spring Boot best practices
- [ ] Proper exception handling
- [ ] Input validation (Bean Validation)
- [ ] Logging configuration
- [ ] No hardcoded values
- [ ] Unit tests with JUnit/Kotest

## Security Checklist (OWASP Top 10)

### A01: Broken Access Control
- [ ] Authorization checks on all endpoints
- [ ] No Insecure Direct Object References (IDOR)
- [ ] Proper role-based access control

### A02: Cryptographic Failures
- [ ] No hardcoded secrets
- [ ] Proper password hashing (bcrypt, argon2)
- [ ] HTTPS/TLS enforced
- [ ] Secure cookie flags (httpOnly, secure, sameSite)

### A03: Injection
- [ ] Parameterized queries (no string interpolation)
- [ ] Input validation on all user input
- [ ] Output encoding to prevent XSS
- [ ] Command injection prevention

### A04: Insecure Design
- [ ] Rate limiting on public endpoints
- [ ] CAPTCHA on sensitive operations
- [ ] Proper session management
- [ ] Security headers configured

### A07: Authentication Failures
- [ ] Strong password policy
- [ ] MFA available
- [ ] Session timeout configured
- [ ] Secure password reset flow

## Performance Checklist

### Database
- [ ] Indexes on frequently queried columns
- [ ] No N+1 query problems (use eager loading)
- [ ] Connection pooling configured
- [ ] Query timeout limits set
- [ ] Appropriate data types used

### API
- [ ] Response time < 200ms (p95)
- [ ] Caching implemented (Redis)
- [ ] Pagination for list endpoints
- [ ] Batch endpoints where applicable
- [ ] Compression enabled (gzip)

### Frontend
- [ ] Images optimized (WebP, compression)
- [ ] Code splitting implemented
- [ ] Lazy loading for routes
- [ ] Memoization for expensive renders
- [ ] Bundle size < 200KB (gzipped)

## Dependency Audit

### Python
```bash
# Check for vulnerabilities
pip-audit

# Check for outdated packages
pip list --outdated

# Update safely
pip install --upgrade package-name
```

### TypeScript/JavaScript
```bash
# Check for vulnerabilities
npm audit

# Fix automatically
npm audit fix

# Check for outdated packages
npm outdated
```

### Kotlin
```bash
# Check for vulnerabilities (Gradle)
./gradlew dependencyCheckAnalyze

# Update dependencies
./gradlew dependencyUpdates
```

## Common Anti-Patterns

### Python
- ❌ Using mutable default arguments
- ❌ Catching Exception without handling
- ❌ Using eval() or exec()
- ❌ Global variables
- ❌ Not using context managers for files

### TypeScript/JavaScript
- ❌ Modifying state directly in React
- ❌ Not handling promise rejections
- ❌ Using var instead of const/let
- ❌ Deeply nested callbacks
- ❌ Not cleaning up event listeners

### Kotlin
- ❌ Using !! (force unwrap) excessively
- ❌ Not using data classes for DTOs
- ❌ Blocking coroutine with runBlocking
- ❌ Not using sealed classes for state
- ❌ Ignoring nullable types

## Code Quality Metrics

### Acceptable Ranges
- **Cyclomatic Complexity**: < 10 per function
- **Function Length**: < 50 lines
- **File Length**: < 500 lines
- **Test Coverage**: > 80%
- **Maintainability Index**: > 65

### Tools

**Python**:
- radon (complexity)
- coverage (test coverage)
- bandit (security)
- mypy (type checking)

**TypeScript/JavaScript**:
- ESLint (linting)
- TypeScript compiler (types)
- Jest (coverage)
- Lighthouse (performance)

**Kotlin**:
- ktlint (linting)
- detekt (code smell detection)
- JaCoCo (coverage)
- SonarQube (quality)
