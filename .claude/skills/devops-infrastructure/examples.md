# DevOps Examples

## Example: Dockerfile Optimization

**Before**:
```dockerfile
FROM python:3.11
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```
**Size**: 995MB

**After**:
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
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "app.py"]
```
**Size**: 145MB (85% reduction)

## Example: CI/CD Optimization

**Before**: 8 minutes, no caching
**After**: 2 minutes with dependency caching (75% faster)
