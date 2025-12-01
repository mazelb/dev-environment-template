---
description: Review and optimize GitHub Actions CI/CD pipelines
allowed-tools: ["Read"]
model: claude-sonnet-4-5
---

# CI/CD Pipeline Review

Review and optimize GitHub Actions workflows for efficiency and best practices.

## Review Areas

1. **Workflow Efficiency**: Minimize build time
2. **Caching Strategy**: Optimize dependency caching
3. **Security**: Secure secrets and permissions
4. **Testing**: Comprehensive test coverage
5. **Deployment**: Safe deployment practices

## GitHub Actions Best Practices

### Caching Dependencies
```yaml
# Python
- uses: actions/setup-python@v4
  with:
    python-version: '3.11'
    cache: 'pip'

# Node.js
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# Custom caching
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Matrix Strategy
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    python-version: ['3.10', '3.11', '3.12']
  fail-fast: false
```

### Secrets Management
```yaml
# ❌ Bad: Secrets in code
- run: |
    API_KEY=sk-1234567890

# ✅ Good: Use GitHub Secrets
- run: |
    echo "${{ secrets.API_KEY }}"
  env:
    API_KEY: ${{ secrets.API_KEY }}
```

### Permissions (Least Privilege)
```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
```

### Conditional Execution
```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: ./deploy.sh
```

## Optimization Techniques

### 1. Parallel Jobs
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  build:
    needs: [lint, test]  # Only run if lint & test pass
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
```

### 2. Docker Layer Caching
```yaml
- name: Build Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### 3. Workflow Dispatch
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - staging
          - production
```

## Security Checklist

- [ ] No secrets in code or logs
- [ ] Least privilege permissions
- [ ] Dependabot enabled
- [ ] Security scanning (Trivy, Snyk)
- [ ] Branch protection rules
- [ ] Required status checks
- [ ] Code review requirements

## Archetype-Specific CI/CD

**For rag-project:**
```yaml
jobs:
  test:
    services:
      postgres:
        image: postgres:16
      redis:
        image: redis:7
      opensearch:
        image: opensearchproject/opensearch:2.11
```

**For api-service:**
```yaml
jobs:
  test:
    steps:
      - run: pytest --cov=src --cov-report=xml
      - run: docker-compose up -d
      - run: pytest tests/integration/
```

**For frontend:**
```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - run: npm run test
      - uses: actions/upload-artifact@v3
        with:
          name: build
          path: .next/
```

## Output Format

Provide:
1. **Current Issues**: Problems in workflow
2. **Optimized Workflow**: Improved version
3. **Time Savings**: Build time improvements
4. **Security Improvements**: Security enhancements
5. **Recommendations**: Additional improvements

## Example Output

```
Current Issues:
- No dependency caching (npm install runs every time)
- Sequential jobs (could be parallel)
- Missing permissions declaration
- Secrets logged in output
- No matrix strategy for multi-version testing

Optimized Workflow:
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read
  pull-requests: write

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ['18', '20']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
```

Time Savings:
- Before: 8 minutes (no caching)
- After: 2 minutes (with caching)
- 75% faster

Security Improvements:
- Added least-privilege permissions
- Removed secret exposure
- Added Dependabot configuration

Recommendations:
1. Add security scanning with Trivy
2. Enable branch protection on main
3. Add deployment job with manual approval
4. Configure status checks as required
5. Add code coverage reporting
```
