---
description: Optimize Dockerfiles and docker-compose.yml configurations
allowed-tools: ["Read", "Edit", "Bash(docker images)", "Bash(docker ps)"]
model: claude-sonnet-4-5
---

# Docker Optimization

Optimize Dockerfile and docker-compose configurations for production readiness.

## Optimization Goals

1. **Image Size**: Reduce final image size
2. **Build Speed**: Optimize layer caching
3. **Security**: Harden container security
4. **Performance**: Improve runtime performance
5. **Best Practices**: Follow Docker guidelines

## Dockerfile Optimization Techniques

### Multi-Stage Builds
```dockerfile
# Bad: Single stage (large image)
FROM python:3.11
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]

# Good: Multi-stage build (smaller image)
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

### Layer Caching
```dockerfile
# Bad: Dependencies reinstalled on any code change
COPY . /app
RUN pip install -r requirements.txt

# Good: Cache dependencies separately
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY . /app/
```

### Base Image Selection
- **Alpine**: Smallest (but glibc compatibility issues)
- **Slim**: Good balance (recommended for Python/Node)
- **Full**: Largest (avoid in production)

### Security Hardening
```dockerfile
# Run as non-root user
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001
USER appuser

# Use specific versions (not latest)
FROM python:3.11.6-slim

# Scan for vulnerabilities
# Add to CI: docker scan myimage:latest
```

## docker-compose.yml Optimization

### Resource Limits
```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Logging Configuration
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Archetype-Specific Optimizations

**For rag-project:**
- Multi-stage build for Python dependencies
- Separate build stage for model downloads
- Volume mount for Ollama models
- Optimize OpenSearch JVM settings

**For api-service:**
- Multi-stage build with poetry/pip
- Separate worker and API images
- Connection pooling configuration
- Celery worker resource limits

**For frontend:**
- Multi-stage with Next.js standalone output
- Static asset optimization
- Node_modules caching
- Production environment variables

## Analysis Checklist

Review:
- [ ] Using multi-stage builds?
- [ ] Minimal base image (slim/alpine)?
- [ ] Layer caching optimized?
- [ ] Running as non-root user?
- [ ] Health checks configured?
- [ ] Resource limits set?
- [ ] Logging configured?
- [ ] Secrets externalized?
- [ ] .dockerignore present?
- [ ] Image size acceptable?

## Output Format

Provide:
1. **Current Issues**: Problems with existing Dockerfile
2. **Optimized Dockerfile**: Improved version
3. **Size Comparison**: Before/after image sizes
4. **Build Time**: Expected improvements
5. **Security Improvements**: Security enhancements
6. **docker-compose Updates**: If applicable

## Example Output

```
Current Issues:
- Using full Python image (995MB)
- Dependencies reinstalled on every code change
- Running as root user
- No health check
- Missing resource limits

Optimized Dockerfile:
[... multi-stage optimized Dockerfile ...]

Size Comparison:
- Before: 995MB
- After: 145MB (85% reduction)

Build Time:
- Cold build: Similar (3min)
- Cached build: 10s → 2s (5x faster)

Security Improvements:
- Non-root user (appuser:1001)
- Specific Python version (3.11.6-slim)
- No unnecessary packages
- .dockerignore excludes sensitive files

docker-compose Updates:
```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
    logging:
      driver: json-file
      options:
        max-size: "10m"
```

Next Steps:
1. Test optimized Dockerfile locally
2. Update CI/CD pipeline
3. Run security scan: docker scan image:latest
4. Monitor production performance
```
