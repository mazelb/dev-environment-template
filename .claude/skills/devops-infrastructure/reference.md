# DevOps & Infrastructure Reference

## Dockerfile Best Practices

### Base Image Selection
- **Alpine**: Smallest (~5MB) but glibc compatibility issues
- **Slim**: Good balance (~40MB) - Recommended
- **Full**: Largest (~900MB) - Avoid in production

### Multi-Stage Build Template
```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
RUN adduser --system --uid 1001 appuser
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
USER appuser
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

### Security Checklist
- [ ] Non-root user
- [ ] Specific image versions (not `latest`)
- [ ] No secrets in image
- [ ] Health check configured
- [ ] Resource limits set
- [ ] Minimal attack surface

## GitHub Actions Best Practices

### Caching Strategy
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

### Security
```yaml
permissions:
  contents: read  # Least privilege

env:
  API_KEY: ${{ secrets.API_KEY }}  # Never hardcode
```

## Resource Limits (docker-compose)
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 512M
```
