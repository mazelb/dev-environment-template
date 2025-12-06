# API Archetype Full Stack Testing

Complete guide for testing the API archetype with all services, infrastructure validation, and application testing.

**Last Updated:** December 6, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Test Phases](#test-phases)
5. [Running the Tests](#running-the-tests)
6. [Expected Results](#expected-results)
7. [Service Details](#service-details)
8. [Troubleshooting](#troubleshooting)
9. [Common Issues](#common-issues)

---

## Overview

The API archetype full stack test validates a production-ready FastAPI microservice with:
- RESTful and GraphQL API endpoints
- PostgreSQL database with SQLAlchemy ORM
- Redis caching and session storage
- Celery background task processing
- JWT authentication and authorization
- Rate limiting and middleware
- Comprehensive test suite

### What Gets Tested

**Infrastructure (5 tests):**
- ✅ Project creation from archetype
- ✅ Project structure validation
- ✅ Docker Compose configuration
- ✅ Service startup and health
- ✅ Service connectivity

**Application (5 tests):**
- ✅ Unit tests (isolated components)
- ✅ Integration tests (service interaction)
- ✅ API endpoint tests (REST/GraphQL)
- ✅ Authentication tests (JWT)
- ✅ Test coverage reporting

**Total:** 10 comprehensive tests

---

## Architecture

### Docker Services

```yaml
services:
  api:              # FastAPI application (port 8000)
  postgres:         # PostgreSQL database (port 5432)
  redis:            # Redis cache/sessions (port 6379)
  celery-worker:    # Background task worker
  celery-beat:      # Periodic task scheduler
```

### Application Structure

```
archetypes/api-service/
├── src/
│   ├── api/
│   │   ├── v1/           # API v1 endpoints
│   │   │   ├── auth.py   # Authentication endpoints
│   │   │   ├── users.py  # User management
│   │   │   └── items.py  # Example resource
│   │   └── graphql/      # GraphQL schema and resolvers
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Business logic
│   ├── middleware/       # Custom middleware
│   ├── tasks/            # Celery tasks
│   └── config.py         # Configuration
├── tests/
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   └── conftest.py       # Test fixtures
├── alembic/              # Database migrations
├── docker-compose.yml    # Service orchestration
└── requirements.txt      # Python dependencies
```

---

## Prerequisites

### Required Software

- **Docker Desktop 24+** with Docker Compose v2
- **PowerShell 7+** (for test scripts)
- **Python 3.11+** (for local development/testing)
- **Git** (for project creation)

### Required Resources

- **Disk Space:** ~5 GB for Docker images
- **Memory:** 4 GB RAM minimum (8 GB recommended)
- **Time:** 15-20 minutes for full stack test

### Optional Tools

- **HTTPie** or **curl** for API testing
- **pgAdmin** or **psql** for database inspection
- **Redis CLI** for cache inspection

---

## Test Phases

### Phase 1: Project Creation

**What it does:** Creates a new API project from archetype template

**Command:**
```bash
./create-project.sh --name test-api --archetype api-service
```

**Validates:**
- ✅ Project directory created
- ✅ All archetype files copied
- ✅ File permissions correct
- ✅ Git repository initialized (optional)

---

### Phase 2: Project Structure Validation

**What it does:** Verifies all required files and directories exist

**Checks:**
```
✅ src/ directory
✅ src/api/v1/ endpoints
✅ src/models/ database models
✅ src/schemas/ Pydantic schemas
✅ tests/ directory
✅ docker-compose.yml
✅ requirements.txt
✅ .env.example
✅ Dockerfile
✅ alembic/ migrations
```

---

### Phase 3: Docker Compose Validation

**What it does:** Validates Docker Compose configuration syntax

**Command:**
```bash
docker-compose config
```

**Validates:**
- ✅ YAML syntax correct
- ✅ Service definitions valid
- ✅ Volume mappings correct
- ✅ Network configuration valid
- ✅ Environment variables defined

---

### Phase 4: Docker Services Startup

**What it does:** Starts all Docker services

**Command:**
```bash
docker-compose up -d
```

**Services Started:**
1. **postgres** - PostgreSQL database
2. **redis** - Redis cache/sessions
3. **api** - FastAPI application
4. **celery-worker** - Background task worker
5. **celery-beat** - Periodic task scheduler

**Wait Time:** 30-60 seconds for all services to be healthy

---

### Phase 5: Service Health Checks

**What it does:** Validates each service is healthy and accessible

#### 5.1 PostgreSQL Health Check

**Test:**
```bash
docker-compose exec -T postgres pg_isready -U api_user -d api_db
```

**Expected:**
```
/var/run/postgresql:5432 - accepting connections
```

**What it verifies:**
- ✅ PostgreSQL is running
- ✅ Database is accessible
- ✅ User credentials valid
- ✅ Connection pool ready

---

#### 5.2 Redis Health Check

**Test:**
```bash
docker-compose exec -T redis redis-cli ping
```

**Expected:**
```
PONG
```

**What it verifies:**
- ✅ Redis is running
- ✅ Redis is accepting connections
- ✅ Cache is functional

---

#### 5.3 FastAPI Health Check

**Test:**
```bash
curl http://localhost:8000/health
```

**Expected:**
```json
{
  "status": "healthy",
  "app": "API Service",
  "version": "1.0.0",
  "database": "connected",
  "redis": "connected"
}
```

**What it verifies:**
- ✅ FastAPI is running
- ✅ HTTP server responding
- ✅ Database connection active
- ✅ Redis connection active

---

#### 5.4 Celery Worker Health Check

**Test:**
```bash
docker-compose exec -T celery-worker celery -A src.tasks inspect ping
```

**Expected:**
```
-> celery@worker: OK
    pong
```

**What it verifies:**
- ✅ Celery worker is running
- ✅ Worker is connected to broker (Redis)
- ✅ Worker can process tasks

---

#### 5.5 Celery Beat Health Check

**Test:**
```bash
docker-compose logs celery-beat | grep "Scheduler: Sending"
```

**Expected:**
```
Scheduler: Sending due task...
```

**What it verifies:**
- ✅ Celery beat is running
- ✅ Periodic tasks are scheduled
- ✅ Beat is connected to broker

---

### Phase 6: Unit Tests

**What it does:** Runs unit tests inside Docker container

**Command:**
```bash
docker compose exec -T api pytest tests/unit/ -v -m unit --tb=short
```

**Test Coverage:**

**Authentication Tests** (`test_auth.py`):
- Password hashing and verification
- JWT token creation and validation
- Token expiration handling
- Refresh token logic

**Database Tests** (`test_database.py`):
- Model creation and validation
- CRUD operations
- Relationship handling
- Query optimization

**Middleware Tests** (`test_middleware.py`):
- CORS configuration
- Rate limiting
- Request logging
- Error handling

**Schema Tests** (`test_schemas.py`):
- Pydantic validation
- Data serialization
- Type checking
- Custom validators

**Expected Output:**
```
tests/unit/test_auth.py::test_password_hashing PASSED
tests/unit/test_auth.py::test_jwt_creation PASSED
tests/unit/test_auth.py::test_jwt_validation PASSED
tests/unit/test_database.py::test_user_creation PASSED
tests/unit/test_database.py::test_user_crud PASSED
tests/unit/test_middleware.py::test_cors PASSED
tests/unit/test_middleware.py::test_rate_limit PASSED
tests/unit/test_schemas.py::test_user_schema PASSED

============ 25 passed in 3.2s ============
```

---

### Phase 7: Integration Tests

**What it does:** Tests interaction between components with real services

**Command:**
```bash
docker compose exec -T api pytest tests/integration/ -v -m integration --tb=short
```

**Test Coverage:**

**API Endpoint Tests** (`test_api_endpoints.py`):
- REST API endpoints (GET, POST, PUT, DELETE)
- GraphQL queries and mutations
- Request/response validation
- Error handling

**Authentication Flow Tests** (`test_auth_flow.py`):
- User registration
- Login and logout
- Protected endpoint access
- Token refresh

**Database Integration Tests** (`test_database_integration.py`):
- Real database operations
- Transaction handling
- Concurrent access
- Foreign key constraints

**Redis Integration Tests** (`test_redis_integration.py`):
- Caching functionality
- Session storage
- Rate limiting
- Background task queuing

**Expected Output:**
```
tests/integration/test_api_endpoints.py::test_get_users PASSED
tests/integration/test_api_endpoints.py::test_create_user PASSED
tests/integration/test_api_endpoints.py::test_update_user PASSED
tests/integration/test_api_endpoints.py::test_delete_user PASSED
tests/integration/test_auth_flow.py::test_registration PASSED
tests/integration/test_auth_flow.py::test_login PASSED
tests/integration/test_auth_flow.py::test_protected_access PASSED
tests/integration/test_database_integration.py::test_transactions PASSED
tests/integration/test_redis_integration.py::test_caching PASSED

============ 30 passed in 12.5s ============
```

---

### Phase 8: API Endpoint Tests

**What it does:** Tests all REST and GraphQL endpoints

**REST API Tests:**

```bash
# Health check
curl http://localhost:8000/health

# Get all users (requires auth)
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/users

# Create user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"secret123"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"secret123"}'
```

**GraphQL Tests:**

```bash
# GraphQL query
curl -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ users { id email } }"}'

# GraphQL mutation
curl -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { createUser(email:\"test@example.com\") { id } }"}'
```

---

### Phase 9: Background Task Tests

**What it does:** Tests Celery background task processing

**Test Tasks:**

```python
# Send welcome email task
from src.tasks import send_welcome_email
result = send_welcome_email.delay(user_id=1)
print(f"Task ID: {result.id}")
print(f"Task Status: {result.status}")

# Periodic cleanup task
from src.tasks import cleanup_old_sessions
result = cleanup_old_sessions.delay()
```

**Validation:**
```bash
# Check task results
docker-compose exec -T api python -c "
from src.tasks import send_welcome_email
result = send_welcome_email.delay(user_id=1)
print(result.get(timeout=10))
"
```

---

### Phase 10: Test Coverage

**What it does:** Generates code coverage report

**Command:**
```bash
docker compose exec -T api pytest --cov=src --cov-report=term --cov-report=html
```

**Expected Output:**
```
Name                              Stmts   Miss  Cover
-----------------------------------------------------
src/__init__.py                       0      0   100%
src/api/v1/auth.py                   45      2    96%
src/api/v1/users.py                  38      1    97%
src/models/user.py                   25      0   100%
src/schemas/user.py                  18      0   100%
src/services/auth_service.py         52      3    94%
src/middleware/rate_limit.py         28      1    96%
-----------------------------------------------------
TOTAL                               206     7    97%
```

**Coverage Report Location:**
- Terminal: Displayed in console
- HTML: `htmlcov/index.html` (accessible from host)

---

## Running the Tests

### Full Stack Test Script

**Create Test Script:** `tests/Test-ApiArchetypeFull.ps1`

```powershell
# Run full API archetype test
pwsh tests/Test-ApiArchetypeFull.ps1 -Verbose

# Expected duration: 15-20 minutes
# Expected pass rate: 100% (10/10 tests)
```

### Manual Step-by-Step

```bash
# 1. Create project
./create-project.sh --name test-api --archetype api-service
cd test-api

# 2. Configure environment
cp .env.example .env
# Edit .env with required values

# 3. Start services
docker-compose up -d

# 4. Wait for health
sleep 60

# 5. Check service health
docker-compose ps
curl http://localhost:8000/health

# 6. Run tests
docker compose exec -T api pytest tests/unit/ -v
docker compose exec -T api pytest tests/integration/ -v

# 7. Generate coverage
docker compose exec -T api pytest --cov=src --cov-report=html

# 8. Stop services
docker-compose down
```

---

## Expected Results

### Infrastructure Tests (5/5)

| Test | Status | Details |
|------|--------|---------|
| Project Creation | ✅ PASS | Project created successfully |
| Project Structure | ✅ PASS | All required files present |
| Docker Compose Validation | ✅ PASS | Configuration valid |
| Docker Services Startup | ✅ PASS | All 5 services started |
| Service Health Checks | ✅ PASS | All services healthy |

### Application Tests (5/5)

| Test | Status | Details |
|------|--------|---------|
| Unit Tests | ✅ PASS | 25 tests passed |
| Integration Tests | ✅ PASS | 30 tests passed |
| API Endpoint Tests | ✅ PASS | REST & GraphQL working |
| Background Task Tests | ✅ PASS | Celery tasks processing |
| Test Coverage | ✅ PASS | >95% coverage |

### Overall Result

```
✅ PASS: 10/10 tests (100%)
✅ All Docker services healthy
✅ All tests passing
✅ High code coverage
✅ Production ready
```

---

## Service Details

### PostgreSQL Database

**Container:** `api-postgres`
**Port:** 5432
**User:** `api_user` (configurable)
**Database:** `api_db` (configurable)

**Connection String:**
```
postgresql+psycopg2://api_user:api_password@localhost:5432/api_db
```

**Features:**
- SQLAlchemy ORM integration
- Alembic migrations
- Connection pooling
- Health monitoring

---

### Redis Cache

**Container:** `api-redis`
**Port:** 6379

**Usage:**
- Session storage
- API response caching
- Rate limiting counters
- Celery message broker
- Celery result backend

**Configuration:**
```python
REDIS_URL=redis://localhost:6379/0
```

---

### FastAPI Application

**Container:** `api`
**Port:** 8000

**Endpoints:**
- `/` - Root (redirect to docs)
- `/health` - Health check
- `/docs` - Swagger UI
- `/redoc` - ReDoc UI
- `/api/v1/auth/*` - Authentication endpoints
- `/api/v1/users/*` - User management
- `/api/v1/items/*` - Example resource
- `/graphql` - GraphQL endpoint

**Features:**
- JWT authentication
- Role-based authorization
- Rate limiting
- CORS middleware
- Request validation
- Error handling
- Logging

---

### Celery Workers

**Container:** `celery-worker`

**Tasks:**
- Email sending (welcome, notifications)
- Data processing
- Report generation
- Cleanup tasks
- Background jobs

**Monitoring:**
```bash
# Check active tasks
docker-compose exec celery-worker celery -A src.tasks inspect active

# Check registered tasks
docker-compose exec celery-worker celery -A src.tasks inspect registered

# Check worker stats
docker-compose exec celery-worker celery -A src.tasks inspect stats
```

---

### Celery Beat

**Container:** `celery-beat`

**Periodic Tasks:**
- Cleanup old sessions (daily)
- Generate reports (weekly)
- Health checks (hourly)
- Data synchronization (configurable)

**Configuration:**
```python
# src/tasks/celeryconfig.py
beat_schedule = {
    'cleanup-sessions': {
        'task': 'src.tasks.cleanup_old_sessions',
        'schedule': crontab(hour=2, minute=0),
    },
}
```

---

## Troubleshooting

### Issue: PostgreSQL Won't Start

**Symptom:**
```
ERROR: connection to server failed
```

**Solutions:**
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Verify environment variables
cat .env | grep POSTGRES

# Reset database volume
docker-compose down -v
docker-compose up -d postgres
```

---

### Issue: Redis Connection Failed

**Symptom:**
```
ConnectionError: Error connecting to Redis
```

**Solutions:**
```bash
# Check Redis is running
docker-compose ps redis

# Test Redis connection
docker-compose exec redis redis-cli ping

# Check Redis logs
docker-compose logs redis
```

---

### Issue: API Returns 500 Error

**Symptom:**
```
500 Internal Server Error
```

**Solutions:**
```bash
# Check API logs
docker-compose logs api

# Verify database connection
docker-compose exec api python -c "
from src.config import settings
from sqlalchemy import create_engine
engine = create_engine(settings.DATABASE_URL)
print(engine.connect())
"

# Check migrations
docker-compose exec api alembic current
docker-compose exec api alembic upgrade head
```

---

### Issue: Tests Fail with Import Errors

**Symptom:**
```
ModuleNotFoundError: No module named 'src'
```

**Solutions:**
```bash
# Verify PYTHONPATH is set
docker-compose exec api env | grep PYTHONPATH

# Add to docker-compose.yml if missing
environment:
  - PYTHONPATH=/app

# Rebuild container
docker-compose up -d --build api
```

---

### Issue: Celery Worker Not Processing Tasks

**Symptom:**
```
Tasks queued but not processing
```

**Solutions:**
```bash
# Check worker is running
docker-compose ps celery-worker

# Check worker logs
docker-compose logs celery-worker

# Inspect active tasks
docker-compose exec celery-worker celery -A src.tasks inspect active

# Restart worker
docker-compose restart celery-worker
```

---

## Common Issues

### Authentication Issues

**Problem:** JWT token invalid or expired

**Solution:**
```python
# Generate new token
from src.services.auth_service import create_access_token
token = create_access_token(data={"sub": "user@example.com"})
print(f"Token: {token}")
```

---

### Rate Limiting Issues

**Problem:** Too many requests (429 error)

**Solution:**
```bash
# Clear rate limit counters in Redis
docker-compose exec redis redis-cli FLUSHDB

# Or wait for TTL to expire (default: 1 minute)
```

---

### Database Migration Issues

**Problem:** Migration version conflict

**Solution:**
```bash
# Check current migration
docker-compose exec api alembic current

# Downgrade to specific version
docker-compose exec api alembic downgrade <revision>

# Upgrade to latest
docker-compose exec api alembic upgrade head

# Generate new migration
docker-compose exec api alembic revision --autogenerate -m "description"
```

---

## Best Practices

1. **Always run tests in Docker** - Ensures consistent environment
2. **Check service health before testing** - Prevents false failures
3. **Use isolated test database** - Prevent data corruption
4. **Clean up after tests** - Remove test data
5. **Monitor resource usage** - Ensure adequate memory/CPU
6. **Review logs for errors** - Even if tests pass
7. **Keep dependencies updated** - Regular security patches
8. **Run migrations before tests** - Ensure schema is current

---

## Additional Resources

- **API Documentation:** `http://localhost:8000/docs`
- **GraphQL Playground:** `http://localhost:8000/graphql`
- **Database Migrations:** `alembic/versions/`
- **Celery Tasks:** `src/tasks/`
- **Test Fixtures:** `tests/conftest.py`

---

**Last Updated:** December 6, 2025
**Status:** ✅ Complete and validated
**Maintainer:** Dev Environment Template Team
