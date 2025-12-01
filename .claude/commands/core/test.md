# Example: Migrated /test Command

---
description: Generate, fix, and improve test coverage for Python, TypeScript/JavaScript, Kotlin
allowed-tools: ["Read", "Write", "Edit", "Bash(npm test)", "Bash(pytest .*)", "Bash(./gradlew test)"]
model: claude-sonnet-4-5
argument-hint: "[file or directory to test]"
---

# Test Generation & Fixing

Generate comprehensive tests for: $ARGUMENTS

## Assessment

First, analyze the current test coverage:
1. What tests exist?
2. What scenarios lack coverage?
3. What edge cases are missing?
4. Are there integration tests?

## Test Generation

Based on the code provided, generate tests covering:
- Happy path scenarios
- Edge cases and boundary conditions
- Error handling and exceptions
- Mock/stub external dependencies
- Async/concurrent scenarios (if applicable)

## Test Frameworks by Language

### TypeScript/JavaScript
- **Framework**: Jest (React, Node), Vitest (Vite projects)
- **Structure**: `describe` blocks, `it`/`test` functions
- **Mocking**: `jest.mock()`, `vi.mock()`
- **Example**:
```typescript
describe('UserService', () => {
  it('should create user with valid data', async () => {
    const user = await userService.create({ email: 'test@example.com' });
    expect(user.id).toBeDefined();
    expect(user.email).toBe('test@example.com');
  });

  it('should throw error for invalid email', async () => {
    await expect(userService.create({ email: 'invalid' }))
      .rejects.toThrow('Invalid email');
  });
});
```

### Python
- **Framework**: pytest (modern), unittest (standard library)
- **Structure**: `test_` prefixed functions, classes
- **Fixtures**: `@pytest.fixture` for setup
- **Example**:
```python
import pytest
from src.services.user import UserService

@pytest.fixture
def user_service():
    return UserService()

def test_create_user_with_valid_data(user_service):
    user = user_service.create(email='test@example.com')
    assert user.id is not None
    assert user.email == 'test@example.com'

def test_create_user_with_invalid_email_raises_error(user_service):
    with pytest.raises(ValueError, match='Invalid email'):
        user_service.create(email='invalid')
```

### Kotlin
- **Framework**: JUnit 5, Kotest
- **Structure**: `@Test` annotations, descriptive names
- **Example**:
```kotlin
class UserServiceTest {
    private lateinit var userService: UserService

    @BeforeEach
    fun setup() {
        userService = UserService()
    }

    @Test
    fun `should create user with valid data`() {
        val user = userService.create("test@example.com")

        assertNotNull(user.id)
        assertEquals("test@example.com", user.email)
    }

    @Test
    fun `should throw exception for invalid email`() {
        assertThrows<IllegalArgumentException> {
            userService.create("invalid")
        }
    }
}
```

## Archetype-Specific Context

### For rag-project archetype:
- Test OpenSearch document indexing
- Test embedding generation
- Test retrieval accuracy
- Test RAG pipeline end-to-end

### For api-service archetype:
- Test FastAPI endpoints with TestClient
- Test Celery task execution
- Test database operations with fixtures
- Test GraphQL queries/mutations

### For frontend archetype:
- Test React components with Testing Library
- Test user interactions and events
- Test API integration with mock server
- Test routing and navigation

## Execution & Validation

After generating tests:

1. **Run the test suite**:
```bash
# TypeScript/JavaScript
!npm test 2>&1

# Python
!pytest -v 2>&1

# Kotlin
!./gradlew test 2>&1
```

2. **Analyze failures**: If tests fail, explain why and suggest fixes

3. **Coverage report**: Check if coverage improved
```bash
# TypeScript
!npm run test:coverage 2>&1

# Python
!pytest --cov=src --cov-report=term-missing 2>&1
```

4. **Iterate**: Fix failing tests and verify they pass

## Best Practices

- ✅ One assertion per test (or closely related assertions)
- ✅ Clear, descriptive test names
- ✅ Arrange-Act-Assert pattern
- ✅ Independent tests (no shared state)
- ✅ Fast execution (mock slow dependencies)
- ✅ Deterministic (no flaky tests)
- ✅ Cover edge cases and error paths

## Example Usage

**User provides code:**
```python
# src/services/calculator.py
def divide(a: float, b: float) -> float:
    return a / b
```

**Claude generates:**
```python
# tests/test_calculator.py
import pytest
from src.services.calculator import divide

def test_divide_positive_numbers():
    assert divide(10, 2) == 5.0

def test_divide_negative_numbers():
    assert divide(-10, 2) == -5.0

def test_divide_by_zero_raises_error():
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)

def test_divide_floating_point():
    result = divide(1, 3)
    assert abs(result - 0.333333) < 0.00001
```

---

**This command will be saved as:** `.claude/commands/core/test.md`

**Usage:**
```bash
claude code
/test @src/services/user.py
```
