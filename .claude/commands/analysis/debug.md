---
description: Debug issues, analyze errors, and find root causes
allowed-tools: ["Read", "Edit", "Bash(git log)", "Bash(git show)"]
model: claude-opus-4
---

# Debug Assistant

Help diagnose and fix issues in the code.

## Debugging Process

1. **Understanding**: What's the error or unexpected behavior?
2. **Root Cause**: What's likely causing the problem?
3. **Investigation**: How to verify the issue?
4. **Solution**: Provide a fix with explanation
5. **Prevention**: How to avoid similar issues?
6. **Testing**: Verify the fix works

## Context to Provide

If you have:
- **Error messages**: Include full stack trace
- **Unexpected behavior**: Describe expected vs actual
- **Recent changes**: Mention recent commits
- **Environment**: OS, versions, configurations
- **Reproduction steps**: How to trigger the issue

## Language-Specific Debugging

### Python
- Use `breakpoint()` for debugging
- Check `logging` output
- Verify type hints with mypy
- Check async/await usage
- Review exception handling
- Verify FastAPI dependencies

### TypeScript/JavaScript
- Check browser console for errors
- Use `debugger` statement
- Verify types with TypeScript compiler
- Check React component lifecycle
- Review promise handling
- Verify Next.js build output

### Kotlin
- Use debugger breakpoints
- Check coroutine context
- Verify null safety
- Review Spring Boot logs
- Check dependency injection
- Verify database transactions

## Common Issue Patterns

**Database Issues**:
- Connection pool exhaustion
- N+1 query problems
- Missing migrations
- Transaction deadlocks

**API Issues**:
- CORS errors
- Authentication failures
- Rate limiting
- Timeout problems

**Frontend Issues**:
- Hydration mismatches (Next.js)
- State management bugs
- Re-render loops
- Memory leaks

**Async Issues**:
- Race conditions
- Unhandled promise rejections
- Event loop blocking
- Deadlocks

## Archetype-Specific Debugging

**For rag-project:**
- OpenSearch connection issues
- Ollama model loading errors
- Embedding dimension mismatches
- RAG pipeline failures

**For api-service:**
- FastAPI dependency injection errors
- Celery task failures
- GraphQL resolver errors
- Database connection issues

**For frontend:**
- Next.js hydration errors
- React state bugs
- API integration issues
- Routing problems

## Analysis Steps

1. **Read Error Message**: Extract key information
2. **Check Recent Changes**: Review git history
3. **Identify Root Cause**: Trace back to source
4. **Propose Fix**: Provide solution
5. **Add Tests**: Prevent regression

## Output Format

Provide:
1. **Root Cause Analysis**: What's causing the issue
2. **Debugging Steps**: How to verify the problem
3. **Fixed Code**: Solution with explanation
4. **Prevention Measures**: Avoid future issues
5. **Test Cases**: Verify the fix works

## Example Output

```
Root Cause:
The error "KeyError: 'email'" occurs because the user object from
the database doesn't have an email field when using GraphQL queries
with partial field selection.

Debugging Steps:
1. Check GraphQL query - only requests 'id' and 'name'
2. Code assumes 'email' is always present
3. Database query doesn't include 'email' in SELECT

Solution:
Add email to GraphQL query OR make email field optional with
null check before access.

Fixed Code:
```python
# Option 1: Fix GraphQL query
query = """
  query GetUser {
    user {
      id
      name
      email  # Add missing field
    }
  }
"""

# Option 2: Handle missing field
email = user.get('email', None)
if email:
    send_notification(email)
```

Prevention:
1. Use TypeScript/Pydantic for type safety
2. Add integration tests for GraphQL queries
3. Use schema validation

Test Cases:
```python
def test_user_without_email():
    user = {"id": 1, "name": "Test"}
    # Should not raise KeyError
    result = process_user(user)
    assert result is not None
```
```
