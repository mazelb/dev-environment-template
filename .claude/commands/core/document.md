---
description: Generate comprehensive documentation for Python, TypeScript, Kotlin code
allowed-tools: ["Read", "Write", "Edit"]
model: claude-sonnet-4-5
argument-hint: "[file or directory to document]"
---

# Documentation Generator

Generate comprehensive inline documentation for: $ARGUMENTS

## Documentation Styles

### Python (Google/NumPy style docstrings)
```python
def create_user(email: str, name: str, age: Optional[int] = None) -> User:
    """Create a new user with validated data.

    Args:
        email: User's email address (must be valid format)
        name: User's full name
        age: Optional age (must be >= 0 if provided)

    Returns:
        User: Created user instance with generated ID

    Raises:
        ValueError: If email is invalid or already exists
        TypeError: If age is negative

    Example:
        >>> user = create_user("test@example.com", "John Doe", 25)
        >>> user.id
        '550e8400-e29b-41d4-a716-446655440000'
    """
```

### TypeScript/JavaScript (JSDoc format)
```typescript
/**
 * Creates a new user with validated data
 *
 * @param email - User's email address (must be valid format)
 * @param name - User's full name
 * @param age - Optional age (must be >= 0 if provided)
 * @returns Promise resolving to created user instance
 * @throws {ValidationError} If email is invalid
 * @throws {ConflictError} If email already exists
 *
 * @example
 * ```typescript
 * const user = await createUser("test@example.com", "John Doe", 25);
 * console.log(user.id); // "550e8400-e29b-41d4-a716-446655440000"
 * ```
 */
export async function createUser(
  email: string,
  name: string,
  age?: number
): Promise<User> {
  // ...
}
```

### Kotlin (KDoc format)
```kotlin
/**
 * Creates a new user with validated data
 *
 * @param email User's email address (must be valid format)
 * @param name User's full name
 * @param age Optional age (must be >= 0 if provided)
 * @return Created user instance with generated ID
 * @throws IllegalArgumentException if email is invalid or already exists
 * @throws IllegalStateException if database connection fails
 *
 * @sample
 * ```kotlin
 * val user = createUser("test@example.com", "John Doe", 25)
 * println(user.id) // "550e8400-e29b-41d4-a716-446655440000"
 * ```
 */
fun createUser(email: String, name: String, age: Int? = null): User {
  // ...
}
```

## Documentation Requirements

1. **Function/Method Documentation**:
   - Purpose and behavior
   - All parameters with types and descriptions
   - Return value with type and meaning
   - Exceptions/errors that may be thrown
   - Usage examples for public APIs

2. **Class Documentation**:
   - Purpose and responsibilities
   - Key attributes/properties
   - Usage examples
   - Related classes

3. **Module/File Documentation**:
   - Overall purpose
   - Key exports
   - Dependencies
   - Usage overview

## Archetype-Specific Documentation

**For rag-project:**
- Document embedding dimensions
- Explain search parameters (top_k, similarity threshold)
- Document LLM parameters (temperature, max_tokens)
- Explain chunking strategy

**For api-service:**
- Document API endpoints (path, method, body, response)
- Explain authentication requirements
- Document rate limiting
- Explain background task behavior

**For frontend:**
- Document component props and state
- Explain data fetching patterns
- Document event handlers
- Explain routing behavior

## Instructions

Generate documentation that:
- Follows language-specific conventions
- Includes type information
- Provides clear parameter descriptions
- Includes usage examples for public APIs
- Explains complex logic
- Notes important behavior or constraints
- Is suitable for auto-generated API docs

## Output Format

Provide:
1. **Documented Code**: Code with inline documentation added
2. **Coverage Summary**: What was documented
3. **Usage Examples**: How to use the documented code
4. **Notes**: Any important information about the code

## Example Usage

```
User: "/document @src/services/user.py"
Claude: [Adds docstrings to all functions and classes]

Documented Code:
[... code with Google-style docstrings ...]

Coverage Summary:
- 5 functions documented
- 2 classes documented
- Added module-level docstring
- Included 3 usage examples

Usage Examples:
```python
# Creating a user
user = create_user("test@example.com", "John Doe")

# Finding users
users = find_users(email="test@example.com")
```

Notes:
- All functions now have type hints
- Added examples for complex validation logic
- Module docstring explains the user service architecture
```
