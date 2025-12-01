---
description: Suggest code improvements and refactoring for Python, TypeScript, Kotlin
allowed-tools: ["Read", "Edit"]
model: claude-sonnet-4-5
argument-hint: "[file or code to refactor]"
---

# Code Refactoring

Refactor the provided code to improve quality while maintaining functionality.

## Refactoring Goals

1. **Readability**: Make code easier to understand
2. **Performance**: Optimize where beneficial
3. **Maintainability**: Easier to modify and extend
4. **Best Practices**: Follow language-specific conventions
5. **Error Handling**: Improve error handling and logging
6. **Type Safety**: Add or improve type annotations

## Language-Specific Patterns

### Python
- Use type hints (PEP 484)
- Context managers for resources
- List/dict comprehensions
- Dataclasses for data structures
- Async/await for I/O operations
- FastAPI dependency injection

### TypeScript/JavaScript
- Use TypeScript strict mode
- Immutability patterns
- React hooks best practices
- Next.js App Router patterns
- Async/await over promises
- Proper error boundaries

### Kotlin
- Data classes over POJOs
- Extension functions
- Null safety with ?. and ?:
- Coroutines for async
- Sealed classes for state
- Spring Boot patterns

## Guidelines

- Keep the same functionality (no behavioral changes)
- Use modern language features and idioms
- Add comments only for complex logic
- Follow consistent naming conventions
- Extract reusable components where appropriate
- Consider archetype-specific patterns

## Archetype-Specific Patterns

**For rag-project:**
- Separate indexing/retrieval/generation concerns
- Use dependency injection for services
- Proper async context managers
- Structured error handling for LLM calls

**For api-service:**
- RESTful endpoint design
- Proper Pydantic models
- Database session management
- Background task patterns

**For frontend:**
- Server vs Client component split
- Custom hooks for reusability
- Proper data fetching patterns
- Memoization for performance

## Output Format

Provide:
1. **Summary of Changes**: Brief overview of refactoring
2. **Refactored Code**: Complete improved version
3. **Key Improvements**: List of specific enhancements
4. **Trade-offs**: Any considerations or alternatives
5. **Testing Notes**: How to verify refactored code works

## Instructions

- Preserve all functionality
- Explain why each change improves the code
- Suggest follow-up refactorings if needed
- Note any breaking changes (should be none)
- Provide migration notes if structure changes

## Example Output

```
Summary: Refactored user service to use dependency injection and async patterns

Refactored Code:
[... improved code ...]

Key Improvements:
1. Added type hints for better IDE support
2. Used FastAPI dependency injection
3. Converted to async for database operations
4. Extracted validation logic to Pydantic model
5. Improved error handling with custom exceptions

Trade-offs:
- Slightly more boilerplate but much more maintainable
- Async requires async runtime but enables concurrency

Testing: All existing tests should pass unchanged
```
