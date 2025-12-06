---
name: devops-infrastructure
description: |
  Automatically reviews and optimizes Dockerfiles, CI/CD pipelines, and Infrastructure-as-Code.

  Activates when you mention: Docker optimization, Dockerfile review, CI/CD pipeline,
  GitHub Actions, infrastructure code, Terraform, container security, deployment strategy.

  Provides: Dockerfile multi-stage optimizations, CI/CD efficiency improvements,
  IaC best practices, security hardening, resource optimization.

  Supports: Docker, docker-compose, GitHub Actions, Terraform, Kubernetes
allowed-tools: ["Read", "Bash(docker images)", "Bash(docker ps)"]
---

# DevOps & Infrastructure Skill

Automatically optimizes Docker configurations, CI/CD pipelines, and infrastructure code.

## When This Skill Activates

Claude invokes this skill when you:
1. Show a Dockerfile or docker-compose.yml
2. Ask about CI/CD optimization
3. Mention container security
4. Discuss deployment strategies
5. Work with infrastructure code

## What This Skill Does

### 1. Dockerfile Optimization

**Checks for**:
- Multi-stage builds
- Minimal base images (alpine/slim)
- Layer caching optimization
- Security (non-root user, specific versions)
- Image size reduction
- Build speed improvements

**Example Optimization**:
```dockerfile
# Before: 995MB
FROM python:3.11
COPY . /app
RUN pip install -r requirements.txt

# After: 145MB (85% reduction)
FROM python:3.11-slim AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
COPY --from=builder /root/.local /root/.local
COPY . /app
USER appuser:1001
```

### 2. CI/CD Pipeline Optimization

**Checks for**:
- Dependency caching
- Parallel job execution
- Matrix strategies
- Secrets management
- Permissions (least privilege)
- Security scanning integration

### 3. Container Security

**Checks for**:
- Running as root
- Exposed secrets
- Vulnerable base images
- Missing health checks
- Resource limits
- Network security

### 4. Infrastructure-as-Code Review

**Supports**:
- Terraform
- CloudFormation
- Kubernetes manifests
- docker-compose files

## Archetype-Specific Optimizations

**For rag-project**:
- Optimize OpenSearch JVM settings
- Ollama model caching
- Redis connection pooling
- Multi-stage build for Python dependencies

**For api-service**:
- Separate worker and API images
- Celery resource optimization
- Database connection pooling
- Health check configuration

**For frontend**:
- Next.js standalone output
- Static asset optimization
- Build caching strategies
- Environment variable handling

## Output Format

Provides:
1. **Current Issues**: Problems identified
2. **Optimized Configuration**: Improved version
3. **Improvements**: Size/speed/security gains
4. **Migration Steps**: How to apply changes
5. **Testing**: Verification steps

## Example Usage

```
User: "Review my Dockerfile for production"
Claude: [Activates devops-infrastructure skill]
- Identifies single-stage build (large image)
- Suggests multi-stage optimization
- Adds security hardening
- Provides optimized Dockerfile

Result: 995MB → 145MB (85% reduction)
```
