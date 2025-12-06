# API Archetype Quick Reference

Quick commands and common operations for testing the API archetype.

**Last Updated:** December 6, 2025

---

## 🚀 Quick Start

```bash
# 1. Create project
./create-project.sh --name my-api --archetype api-service
cd my-api

# 2. Configure environment
cp .env.example .env

# 3. Start services
docker-compose up -d

# 4. Check health
curl http://localhost:8000/health

# 5. Run tests
docker compose exec -T api pytest
```

---

## 📦 Docker Commands

### Start Services

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d api
docker-compose up -d postgres
docker-compose up -d redis

# Start with logs
docker-compose up

# Rebuild and start
docker-compose up -d --build
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v

# Stop specific service
docker-compose stop api
```

### Service Status

```bash
# Check all services
docker-compose ps

# Check specific service logs
docker-compose logs api
docker-compose logs postgres
docker-compose logs redis
docker-compose logs celery-worker

# Follow logs
docker-compose logs -f api

# Check last 100 lines
docker-compose logs --tail=100 api
```

---

## 🔍 Health Checks

### API Health

```bash
# Basic health check
curl http://localhost:8000/health

# Expected response
{
  "status": "healthy",
  "app": "API Service",
  "version": "1.0.0",
  "database": "connected",
  "redis": "connected"
}

# Health check from inside container
docker-compose exec api curl http://localhost:8000/health
```

### PostgreSQL Health

```bash
# Check PostgreSQL is ready
docker-compose exec postgres pg_isready -U api_user -d api_db

# Connect to PostgreSQL
docker-compose exec postgres psql -U api_user -d api_db

# List databases
docker-compose exec postgres psql -U api_user -c "\l"

# List tables
docker-compose exec postgres psql -U api_user -d api_db -c "\dt"
```

### Redis Health

```bash
# Ping Redis
docker-compose exec redis redis-cli ping
# Expected: PONG

# Check Redis info
docker-compose exec redis redis-cli info

# Monitor Redis commands
docker-compose exec redis redis-cli monitor

# Check keys
docker-compose exec redis redis-cli keys "*"
```

### Celery Health

```bash
# Check worker status
docker-compose exec celery-worker celery -A src.tasks inspect ping

# Check active tasks
docker-compose exec celery-worker celery -A src.tasks inspect active

# Check registered tasks
docker-compose exec celery-worker celery -A src.tasks inspect registered

# Check worker stats
docker-compose exec celery-worker celery -A src.tasks inspect stats
```

---

## 🧪 Testing Commands

### Run All Tests

```bash
# Run all tests inside Docker
docker compose exec -T api pytest

# Run all tests with verbose output
docker compose exec -T api pytest -v

# Run all tests with output capture disabled
docker compose exec -T api pytest -s
```

### Run Specific Test Types

```bash
# Unit tests only
docker compose exec -T api pytest -m unit

# Integration tests only
docker compose exec -T api pytest -m integration

# E2E tests only
docker compose exec -T api pytest -m e2e

# Skip slow tests
docker compose exec -T api pytest -m "not slow"

# Skip Docker tests
docker compose exec -T api pytest -m "not docker"
```

### Run Specific Test Files

```bash
# Run specific test file
docker compose exec -T api pytest tests/unit/test_auth.py

# Run specific test function
docker compose exec -T api pytest tests/unit/test_auth.py::test_password_hashing

# Run tests matching pattern
docker compose exec -T api pytest -k "test_auth"
```

### Test Coverage

```bash
# Generate coverage report
docker compose exec -T api pytest --cov=src --cov-report=term

# Generate HTML coverage report
docker compose exec -T api pytest --cov=src --cov-report=html

# Generate coverage with missing lines
docker compose exec -T api pytest --cov=src --cov-report=term-missing

# Copy HTML report from container to host
docker compose cp api:/app/htmlcov ./htmlcov
```

---

## 🔐 Authentication Commands

### Register User

```bash
# Register new user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "full_name": "Test User"
  }'
```

### Login

```bash
# Login and get token
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test@example.com",
    "password": "SecurePass123!"
  }'

# Save token to variable
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"SecurePass123!"}' \
  | jq -r '.access_token')
```

### Access Protected Endpoint

```bash
# Use token to access protected endpoint
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users/me

# Get all users (admin only)
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users
```

---

## 📡 API Endpoint Commands

### REST API

```bash
# Get all users
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users

# Get specific user
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/v1/users/123

# Create user
curl -X POST http://localhost:8000/api/v1/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"new@example.com","password":"Pass123!"}'

# Update user
curl -X PUT http://localhost:8000/api/v1/users/123 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Updated Name"}'

# Delete user
curl -X DELETE http://localhost:8000/api/v1/users/123 \
  -H "Authorization: Bearer $TOKEN"
```

### GraphQL API

```bash
# GraphQL query (get all users)
curl -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query":"{ users { id email fullName } }"}'

# GraphQL mutation (create user)
curl -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"query":"mutation { createUser(email:\"new@example.com\", password:\"Pass123!\") { id email } }"}'
```

---

## 🗄️ Database Commands

### Migrations

```bash
# Check current migration version
docker-compose exec api alembic current

# Generate new migration
docker-compose exec api alembic revision --autogenerate -m "Add user table"

# Apply migrations
docker-compose exec api alembic upgrade head

# Downgrade one revision
docker-compose exec api alembic downgrade -1

# Downgrade to specific revision
docker-compose exec api alembic downgrade <revision_id>

# Show migration history
docker-compose exec api alembic history
```

### Direct Database Access

```bash
# Connect to database
docker-compose exec postgres psql -U api_user -d api_db

# Run SQL query
docker-compose exec postgres psql -U api_user -d api_db \
  -c "SELECT * FROM users LIMIT 5;"

# Dump database
docker-compose exec postgres pg_dump -U api_user api_db > backup.sql

# Restore database
cat backup.sql | docker-compose exec -T postgres psql -U api_user -d api_db
```

---

## 🔄 Celery Commands

### Execute Tasks

```bash
# Execute task from Python shell
docker-compose exec api python << EOF
from src.tasks import send_welcome_email
result = send_welcome_email.delay(user_id=1)
print(f"Task ID: {result.id}")
print(f"Task Status: {result.status}")
EOF

# Check task result
docker-compose exec api python << EOF
from celery.result import AsyncResult
result = AsyncResult('<task_id>')
print(result.get(timeout=10))
EOF
```

### Monitor Tasks

```bash
# Watch worker logs
docker-compose logs -f celery-worker

# Watch beat logs
docker-compose logs -f celery-beat

# Inspect active tasks
docker-compose exec celery-worker celery -A src.tasks inspect active

# Inspect scheduled tasks
docker-compose exec celery-worker celery -A src.tasks inspect scheduled

# Inspect reserved tasks
docker-compose exec celery-worker celery -A src.tasks inspect reserved
```

### Celery Management

```bash
# Restart worker
docker-compose restart celery-worker

# Scale workers (add more workers)
docker-compose up -d --scale celery-worker=3

# Stop specific worker
docker-compose exec celery-worker celery -A src.tasks control shutdown

# Purge all tasks from queue
docker-compose exec celery-worker celery -A src.tasks purge
```

---

## 🔧 Development Commands

### Code Quality

```bash
# Run linter
docker-compose exec api ruff check src/

# Run formatter
docker-compose exec api black src/

# Run type checker
docker-compose exec api mypy src/

# Run all quality checks
docker-compose exec api bash -c "ruff check src/ && black --check src/ && mypy src/"
```

### Interactive Shell

```bash
# Python shell with app context
docker-compose exec api python

# IPython shell (if installed)
docker-compose exec api ipython

# Django-style shell with app loaded
docker-compose exec api python -c "from src.config import settings; print(settings)"
```

### Logs and Debugging

```bash
# Show recent API logs
docker-compose logs --tail=100 api

# Follow API logs
docker-compose logs -f api

# Show all container logs
docker-compose logs

# Export logs to file
docker-compose logs > logs.txt
```

---

## 📊 Monitoring Commands

### Resource Usage

```bash
# Check container resource usage
docker stats

# Check specific container
docker stats api-api

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

### Performance

```bash
# Check API response time
time curl http://localhost:8000/health

# Load test with Apache Bench (if installed)
ab -n 1000 -c 10 http://localhost:8000/health

# Monitor PostgreSQL connections
docker-compose exec postgres psql -U api_user -d api_db \
  -c "SELECT count(*) FROM pg_stat_activity;"
```

---

## 🐛 Debugging Commands

### Debug API Issues

```bash
# Check API logs
docker-compose logs api | grep ERROR

# Check API environment variables
docker-compose exec api env | grep -i api

# Test database connection
docker-compose exec api python -c "
from sqlalchemy import create_engine
from src.config import settings
engine = create_engine(settings.DATABASE_URL)
print('Connected:', engine.connect())
"

# Test Redis connection
docker-compose exec api python -c "
import redis
from src.config import settings
r = redis.from_url(settings.REDIS_URL)
print('Connected:', r.ping())
"
```

### Debug Celery Issues

```bash
# Check celery configuration
docker-compose exec celery-worker celery -A src.tasks inspect conf

# Check broker connection
docker-compose exec celery-worker python -c "
from src.tasks import celery_app
print('Broker:', celery_app.connection().as_uri())
"

# List active queues
docker-compose exec redis redis-cli keys "celery*"
```

---

## 🔄 Common Workflows

### Fresh Start

```bash
# Complete reset
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
sleep 30
docker-compose exec api alembic upgrade head
curl http://localhost:8000/health
```

### Update Dependencies

```bash
# Update requirements.txt
# Edit requirements.txt

# Rebuild containers
docker-compose build --no-cache api celery-worker

# Restart services
docker-compose up -d
```

### Run Full Test Suite

```bash
# Full test workflow
docker-compose up -d
sleep 30
docker-compose ps
docker compose exec -T api pytest -v --cov=src
docker-compose down
```

---

## 📚 Documentation Links

- **API Docs:** http://localhost:8000/docs (Swagger UI)
- **ReDoc:** http://localhost:8000/redoc (Alternative API docs)
- **GraphQL Playground:** http://localhost:8000/graphql
- **Full Stack Testing:** [FULL_STACK_TESTING.md](./FULL_STACK_TESTING.md)
- **Main README:** [README.md](./README.md)

---

**Last Updated:** December 6, 2025
**Maintainer:** Dev Environment Template Team
