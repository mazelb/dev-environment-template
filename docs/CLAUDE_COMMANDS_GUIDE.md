# Claude Code Commands Reference

## Core Commands

### `/explain` - Explain Code
Explains code functionality, design patterns, and logic.

**Usage**: `/explain @src/main.py`

**What it does**:
- Breaks down code purpose
- Identifies design patterns
- Explains dependencies
- Suggests improvements

### `/refactor` - Improve Code
Suggests refactoring and modernization.

**Usage**: `/refactor @src/services/user.py`

**What it does**:
- Improves readability
- Optimizes performance
- Adds type safety
- Follows best practices

### `/test` - Generate Tests
Creates comprehensive test suites.

**Usage**: `/test @src/api/endpoints.py`

**Supports**: pytest, Jest, Vitest, JUnit, Kotest

### `/document` - Add Documentation
Generates inline documentation.

**Usage**: `/document @src/models/`

**Formats**: Google docstrings (Python), JSDoc (TypeScript), KDoc (Kotlin)

## Analysis Commands

### `/optimize` - Performance Optimization
Identifies and fixes performance issues.

**Usage**: `/optimize @src/services/rag/pipeline.py`

**Finds**:
- N+1 queries
- Inefficient algorithms
- Missing caching
- Slow database queries

### `/debug` - Debug Issues
Helps diagnose and fix bugs.

**Usage**: `/debug` (then describe the issue)

### `/security` - Security Review
Performs OWASP Top 10 security analysis.

**Usage**: `/security @src/api/`

### `/architecture` - System Design Analysis
Analyzes architecture and design patterns.

**Usage**: `/architecture @archetypes/rag-project/`

## DevOps Commands

### `/docker-optimize` - Optimize Dockerfiles
Reviews and optimizes Docker configurations.

**Usage**: `/docker-optimize @Dockerfile`

**Provides**:
- Multi-stage builds
- Image size reduction
- Security hardening
- Build speed improvements

### `/ci-review` - CI/CD Pipeline Review
Optimizes GitHub Actions workflows.

**Usage**: `/ci-review @.github/workflows/ci.yml`

## Data Commands

### `/sql-optimize` - SQL Query Optimization
Optimizes database queries and schema.

**Usage**: `/sql-optimize` (then show query)

**Provides**:
- Index recommendations
- Query rewriting
- Execution plan analysis
- Performance improvements

## Usage Tips

1. **Reference Files**: Use `@file` syntax to include files
2. **Multiple Files**: `/test @src/services/ @src/models/`
3. **Natural Language**: Describe what you need in plain English
4. **Combine with Skills**: Commands work with auto-invoked skills

## Examples

```bash
# Explain a function
/explain @src/services/rag/pipeline.py

# Generate tests with coverage
/test @src/api/endpoints.py

# Optimize Docker image
/docker-optimize @Dockerfile

# Review SQL performance
/sql-optimize
```
