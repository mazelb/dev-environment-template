# API Service Archetype

Production-ready FastAPI service template with authentication, rate limiting, API versioning, and common middleware patterns.

## Features

### Core Capabilities
- ✅ **JWT Authentication** - Secure token-based authentication
- ✅ **Rate Limiting** - Redis-backed rate limiting with SlowAPI
- ✅ **API Versioning** - URL-based versioning (v1 pattern)
- ✅ **CORS Middleware** - Configurable cross-origin resource sharing
- ✅ **Request Logging** - Structured logging with file and console output
- ✅ **Health Checks** - Basic and detailed health endpoints
- ✅ **Prometheus Metrics** - Built-in metrics instrumentation
- ✅ **Async Patterns** - Async/await throughout the stack
- ✅ **Pydantic Validation** - Request/response validation
- ✅ **Security Headers** - Best practice security headers

### Architecture
```
src/
├── main.py              # Application entry point
├── core/
│   ├── config.py        # Settings management
│   └── security.py      # Password hashing
├── middleware/
│   ├── rate_limiter.py  # Rate limiting setup
│   └── logging.py       # Logging configuration
├── auth/
│   ├── jwt.py           # JWT token handling
│   └── dependencies.py  # Auth dependencies
├── api/
│   └── v1/
│       ├── router.py    # API router aggregation
│       └── health.py    # Health endpoints
└── models/
    ├── user.py          # User models
    └── token.py         # Token models
```

## Quick Start

### 1. Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Generate a secure secret key (32+ characters)
python -c "import secrets; print(secrets.token_urlsafe(32))" > secret.txt

# Update .env with generated secret
# API_SECRET_KEY=<paste-secret-here>
```

### 2. Start Services

```bash
# Start all services (API + Redis)
docker-compose up -d

# View logs
docker-compose logs -f api

# Check health
curl http://localhost:8000/health
```

### 3. Access API

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health
- **Metrics**: http://localhost:8000/metrics

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PROJECT_NAME` | Project name | `my-api` |
| `API_PORT` | API port | `8000` |
| `API_SECRET_KEY` | JWT secret key (required) | - |
| `API_ALGORITHM` | JWT algorithm | `HS256` |
| `API_ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiration | `30` |
| `REDIS_HOST` | Redis hostname | `redis` |
| `REDIS_PORT` | Redis port | `6379` |
| `RATE_LIMIT_PER_MINUTE` | Rate limit | `60` |
| `CORS_ORIGINS` | Allowed origins | `http://localhost:3000` |
| `LOG_LEVEL` | Logging level | `INFO` |

### Rate Limiting

Configure rate limits in `.env`:

```bash
# Requests per minute
RATE_LIMIT_PER_MINUTE=60
```

Apply custom limits to specific endpoints:

```python
from src.middleware.rate_limiter import limiter

@router.get("/expensive-operation")
@limiter.limit("10/minute")
async def expensive_operation():
    pass
```

### CORS Configuration

Update allowed origins in `.env`:

```bash
# Comma-separated list
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,https://myapp.com
```

## Authentication

### JWT Token Flow

1. **Obtain Token** (implement `/api/v1/auth/token` endpoint):
```python
from fastapi.security import OAuth2PasswordRequestForm

@router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Verify credentials
    # Create token
    token = create_access_token({"sub": user.username})
    return {"access_token": token, "token_type": "bearer"}
```

2. **Protected Endpoints**:
```python
from src.auth.dependencies import get_current_user

@router.get("/protected")
async def protected_route(user: User = Depends(get_current_user)):
    return {"user": user.username}
```

3. **Use Token**:
```bash
# Get token
TOKEN=$(curl -X POST http://localhost:8000/api/v1/auth/token \
  -d "username=user&password=pass" | jq -r .access_token)

# Use token
curl http://localhost:8000/api/v1/protected \
  -H "Authorization: Bearer $TOKEN"
```

## API Versioning

### Adding New Versions

Create new version directory:

```bash
mkdir -p src/api/v2
```

Update router in `main.py`:

```python
from src.api.v2.router import api_router as api_router_v2

app.include_router(api_router_v2, prefix="/api/v2")
```

### Version Deprecation

Mark deprecated endpoints:

```python
@router.get("/old-endpoint", deprecated=True)
async def old_endpoint():
    return {"message": "Use /api/v2/new-endpoint instead"}
```

## Health Checks

### Available Endpoints

1. **Basic Health** - `/health`
   ```bash
   curl http://localhost:8000/health
   ```

2. **API v1 Health** - `/api/v1/health/`
   ```bash
   curl http://localhost:8000/api/v1/health/
   ```

3. **Detailed Health** - `/api/v1/health/detailed`
   ```bash
   curl http://localhost:8000/api/v1/health/detailed
   ```

4. **Protected Health** - `/api/v1/health/protected` (requires auth)
   ```bash
   curl http://localhost:8000/api/v1/health/protected \
     -H "Authorization: Bearer $TOKEN"
   ```

## Monitoring

### Prometheus Metrics

Metrics automatically exposed at `/metrics`:

```bash
curl http://localhost:8000/metrics
```

**Available Metrics:**
- `http_requests_total` - Total HTTP requests
- `http_request_duration_seconds` - Request duration
- `http_requests_in_progress` - Current requests

### Integration with Monitoring Stack

Compose with monitoring archetype:

```bash
# In your project
docker-compose -f docker-compose.yml \
  -f ../monitoring/docker-compose.yml up -d
```

Update Prometheus config to scrape API:

```yaml
scrape_configs:
  - job_name: 'api'
    static_configs:
      - targets: ['api:8000']
```

## Testing

### Run Tests

```bash
# Install dev dependencies
pip install -r requirements.txt

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=src --cov-report=html

# Run specific test file
pytest tests/test_auth.py -v
```

### Test Categories

- `test_api.py` - Endpoint tests
- `test_auth.py` - Authentication tests

### Add New Tests

```python
# tests/test_users.py
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_create_user():
    response = client.post("/api/v1/users/", json={
        "username": "testuser",
        "email": "test@example.com",
        "password": "secure123"
    })
    assert response.status_code == 201
```

## Development

### Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run with auto-reload
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

# Format code
black src/

# Lint code
pylint src/
```

### Adding New Endpoints

1. **Create router file**:
```python
# src/api/v1/users.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def list_users():
    return {"users": []}
```

2. **Register router**:
```python
# src/api/v1/router.py
from src.api.v1 import users

api_router.include_router(users.router, prefix="/users", tags=["users"])
```

## Composition with Other Archetypes

### With RAG Project

```bash
# Combine API service with RAG backend
docker-compose -f docker-compose.yml \
  -f ../rag-project/docker-compose.yml up -d
```

Update API to use RAG service:

```python
# src/api/v1/search.py
import httpx

@router.post("/search")
async def search(query: str):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://rag-api:8001/search",
            json={"query": query}
        )
    return response.json()
```

### With Monitoring

```bash
# API + Monitoring stack
docker-compose -f docker-compose.yml \
  -f ../monitoring/docker-compose.yml up -d
```

Access Grafana at http://localhost:3000 to view API metrics.

### With Agentic Workflows

Integrate agent workflows:

```python
# src/api/v1/agents.py
from src.workflows.research_agent import research_workflow

@router.post("/research")
async def trigger_research(query: str):
    result = await research_workflow(query)
    return {"result": result}
```

## Security Best Practices

### 1. Secret Key Management

```bash
# Generate secure key
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Store in secure location (e.g., AWS Secrets Manager, HashiCorp Vault)
# Never commit to version control
```

### 2. HTTPS in Production

Update docker-compose for production:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
```

### 3. Rate Limiting

Protect endpoints from abuse:

```python
@limiter.limit("5/minute")
@router.post("/expensive")
async def expensive_operation():
    pass
```

### 4. Input Validation

Use Pydantic models:

```python
class SearchQuery(BaseModel):
    query: str = Field(..., min_length=1, max_length=500)
    limit: int = Field(10, ge=1, le=100)
```

## Troubleshooting

### Redis Connection Issues

```bash
# Check Redis is running
docker-compose ps redis

# Test connection
docker-compose exec redis redis-cli ping

# Check logs
docker-compose logs redis
```

### Authentication Not Working

```bash
# Verify secret key is set
docker-compose exec api printenv | grep API_SECRET_KEY

# Check token expiration
# Ensure system time is synchronized
```

### Rate Limiting Not Applied

```bash
# Verify Redis connection
docker-compose exec api python -c "from redis import Redis; r = Redis(host='redis'); print(r.ping())"

# Check rate limit configuration
docker-compose exec api printenv | grep RATE_LIMIT
```

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review [FastAPI documentation](https://fastapi.tiangolo.com/)
- See [SlowAPI documentation](https://slowapi.readthedocs.io/)
