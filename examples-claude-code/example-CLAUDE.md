# Project Memory - Dev Environment Template

**Last Updated**: 2025-12-01
**Repository**: https://github.com/mazelb/dev-environment-template

---

## 🎯 Project Overview

A portable, production-ready development environment template that works seamlessly across macOS, Windows (WSL2), and Linux. Provides consistent tooling, AI assistance, and team collaboration for multi-language development.

**Primary Purpose**: Enable teams to quickly create new projects with best-practice configurations for Python, TypeScript, Node, Go, C++, and Kotlin development.

---

## 👥 Team Information

- **Team Size**: ~8-12 developers
- **Experience Levels**: Junior to Senior
- **Primary Languages**: Python (FastAPI, Django), TypeScript (React, Next.js), Go, C++, Kotlin
- **Deployment**: Docker Compose (dev), AWS ECS (prod)
- **CI/CD**: GitHub Actions
- **Code Review**: Required for all PRs

---

## 🏗️ Project Structure

### Archetypes (7 Project Templates)

1. **base** - Minimal starter with basic Docker setup
   - Location: `archetypes/base/`
   - Use case: Simple utility projects, CLI tools

2. **rag-project** - RAG system with OpenSearch + Ollama
   - Location: `archetypes/rag-project/`
   - Tech: FastAPI, OpenSearch, Ollama, Langfuse, PostgreSQL, Redis
   - Use case: Document search, Q&A systems, semantic search

3. **api-service** - Production-ready FastAPI microservice
   - Location: `archetypes/api-service/`
   - Tech: FastAPI, Celery, GraphQL, PostgreSQL, Redis
   - Use case: REST/GraphQL APIs, background tasks

4. **frontend** - Next.js 14 TypeScript application
   - Location: `archetypes/frontend/`
   - Tech: Next.js, React 18, TypeScript, Tailwind CSS, shadcn/ui
   - Use case: Web frontends, dashboards

5. **agentic-workflows** - AI agent orchestration
   - Location: `archetypes/agentic-workflows/`
   - Tech: LangGraph, LangChain, Ollama
   - Use case: Multi-agent systems, workflows

6. **monitoring** - Prometheus + Grafana stack
   - Location: `archetypes/monitoring/`
   - Tech: Prometheus, Grafana, Alertmanager
   - Use case: System monitoring, metrics

7. **composite-rag-agents** - Combined RAG + Agents
   - Location: `archetypes/composite-rag-agents/`
   - Tech: Combination of rag-project + agentic-workflows
   - Use case: Complex AI systems

### Key Directories

```
dev-environment-template/
├── archetypes/           # 7 project templates
├── .claude/              # Claude Code configuration (NEW)
│   ├── commands/         # Team slash commands
│   ├── skills/           # Auto-invoked skills
│   └── CLAUDE.md         # This file
├── .vscode/              # VS Code configuration
│   ├── extensions.json   # Recommended extensions
│   └── settings.json     # Team settings
├── docs/                 # Documentation
│   ├── SETUP_GUIDE.md
│   ├── ARCHETYPE_GUIDE.md
│   ├── USAGE_GUIDE.md
│   └── CLAUDE_*.md       # Claude Code docs
├── scripts/              # Automation scripts
│   ├── create-project.sh
│   └── manage-template-updates.sh
└── README.md             # Main documentation
```

---

## 💻 Tech Stack

### Languages & Frameworks

**Python 3.11+**
- FastAPI (APIs)
- SQLAlchemy 2.0+ (ORM)
- Alembic (migrations)
- Celery (background tasks)
- pytest (testing)
- Black (formatting)
- Ruff (linting)

**TypeScript/JavaScript**
- Next.js 14 (frontend framework)
- React 18 (UI library)
- Apollo Client (GraphQL)
- Axios (HTTP client)
- Jest/Vitest (testing)
- ESLint + Prettier (code quality)

**Go 1.21+**
- Standard library for services
- gRPC for inter-service communication
- sqlc for type-safe SQL
- testing package

**C++ 17+**
- CMake (build system)
- Google Test (testing)
- clang-format (formatting)

**Kotlin**
- Spring Boot (backends)
- JUnit + Kotest (testing)
- Gradle (build)

### Infrastructure

**Database**
- PostgreSQL 16 (primary)
- Redis 7 (cache, queues)
- OpenSearch 2.19 (search, vectors)

**Container Runtime**
- Docker 24+
- Docker Compose v2
- Dev Containers (VS Code)

**CI/CD**
- GitHub Actions
- Docker multi-stage builds
- Automated testing

**Monitoring**
- Prometheus (metrics)
- Grafana (visualization)
- Langfuse (LLM observability)

---

## 📝 Code Conventions

### Python

**Style**:
- Black formatter (88 char line length)
- Ruff for linting
- PEP 8 compliance
- Type hints required for all functions

**Example**:
```python
from typing import Optional
from pydantic import BaseModel

class UserInput(BaseModel):
    email: str
    name: str
    age: Optional[int] = None

def create_user(data: UserInput) -> User:
    """Create a new user with validated data.

    Args:
        data: User input data validated by Pydantic

    Returns:
        Created user instance

    Raises:
        ValueError: If email already exists
    """
    if user_exists(data.email):
        raise ValueError(f"User with email {data.email} already exists")
    return User.create(**data.dict())
```

**FastAPI Endpoints**:
- RESTful URLs (`/api/v1/users`, `/api/v1/users/{id}`)
- Pydantic models for request/response
- Dependency injection for database sessions
- OpenAPI documentation enabled

**Testing**:
- pytest with fixtures
- Minimum 80% code coverage
- Test files: `tests/test_*.py`
- Integration tests in `tests/integration/`

### TypeScript/JavaScript

**Style**:
- Prettier for formatting
- ESLint for linting
- Strict mode TypeScript
- Functional components with hooks (React)

**Example**:
```typescript
interface User {
  id: string;
  email: string;
  name: string;
}

interface UserServiceProps {
  apiClient: ApiClient;
}

export const useUserService = ({ apiClient }: UserServiceProps) => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchUsers = async (): Promise<User[]> => {
    setLoading(true);
    try {
      const response = await apiClient.get<User[]>('/api/v1/users');
      setUsers(response.data);
      return response.data;
    } catch (error) {
      console.error('Failed to fetch users:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  return { users, loading, fetchUsers };
};
```

**Next.js Patterns**:
- App Router (not Pages Router)
- Server Components by default
- Client Components with `'use client'` directive
- API routes in `app/api/`

**Testing**:
- Jest or Vitest
- React Testing Library
- Minimum 70% coverage
- E2E tests with Playwright (optional)

### Go

**Style**:
- gofmt standard
- golangci-lint for linting
- Effective Go guidelines
- Table-driven tests

**Example**:
```go
package user

import (
    "context"
    "errors"
)

var ErrUserNotFound = errors.New("user not found")

type Service struct {
    repo Repository
}

func NewService(repo Repository) *Service {
    return &Service{repo: repo}
}

func (s *Service) GetUser(ctx context.Context, id string) (*User, error) {
    user, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }
    if user == nil {
        return nil, ErrUserNotFound
    }
    return user, nil
}
```

### C++

**Style**:
- Google C++ Style Guide
- clang-format for formatting
- Modern C++17 features
- RAII and smart pointers

**Example**:
```cpp
#include <memory>
#include <string>
#include <vector>

class UserService {
public:
    explicit UserService(std::unique_ptr<UserRepository> repo)
        : repo_(std::move(repo)) {}

    std::unique_ptr<User> GetUser(const std::string& id) const {
        auto user = repo_->FindById(id);
        if (!user) {
            throw UserNotFoundException("User not found: " + id);
        }
        return user;
    }

private:
    std::unique_ptr<UserRepository> repo_;
};
```

### Kotlin

**Style**:
- Kotlin coding conventions
- ktlint for formatting
- Data classes for DTOs
- Extension functions when appropriate

**Example**:
```kotlin
data class UserInput(
    val email: String,
    val name: String,
    val age: Int? = null
)

class UserService(private val repository: UserRepository) {
    fun createUser(input: UserInput): User {
        if (repository.existsByEmail(input.email)) {
            throw IllegalArgumentException("User with email ${input.email} already exists")
        }
        return repository.save(input.toEntity())
    }
}

private fun UserInput.toEntity() = User(
    email = this.email,
    name = this.name,
    age = this.age
)
```

---

## 🗄️ Database Conventions

### Schema Naming
- Tables: `snake_case` (e.g., `user_profiles`, `api_keys`)
- Columns: `snake_case` (e.g., `created_at`, `user_id`)
- Indexes: `idx_{table}_{columns}` (e.g., `idx_users_email`)
- Foreign keys: `fk_{table}_{ref_table}` (e.g., `fk_profiles_users`)

### Migrations
- Alembic for Python projects
- Flyway for Java/Kotlin projects
- Naming: `YYYYMMDD_HHmmss_description.sql` or autogenerated by tool
- Always reversible (up/down migrations)
- Test migrations on staging before production

### Queries
- **Always use parameterized queries** (prevents SQL injection)
- Use ORMs when possible (SQLAlchemy, Prisma)
- Add indexes on frequently queried fields
- Use connection pooling (configured in all archetypes)

---

## 🔐 Security Standards

### Secrets Management
- **Never commit secrets to git**
- Use `.env.local` for development (git-ignored)
- Use GitHub Secrets for CI/CD
- Use AWS Secrets Manager for production
- Environment variables for all secrets

### API Security
- JWT for authentication
- Rate limiting (Redis-backed)
- Input validation (Pydantic, Zod)
- CORS configuration
- HTTPS in production
- Security headers (Helmet, FastAPI middleware)

### Dependencies
- Regular updates (weekly check)
- Dependabot enabled
- npm audit / pip audit on CI
- Pin major versions in production

### OWASP Top 10 Compliance
All code must be checked against:
1. A01: Broken Access Control
2. A02: Cryptographic Failures
3. A03: Injection
4. A04: Insecure Design
5. A07: Identification and Authentication Failures

---

## ⚡ Performance Targets

### API Response Times
- GET endpoints: < 200ms (p95)
- POST endpoints: < 500ms (p95)
- Complex queries: < 1s (p95)

### Database Queries
- Single queries: < 100ms (p95)
- With JOINs: < 200ms (p95)
- Bulk operations: < 500ms (p95)

### Frontend
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s
- Lighthouse score: > 90

### Docker
- Build time: < 5 minutes
- Container startup: < 30 seconds
- Image size: < 500MB (compressed)

---

## 🤖 AI Assistance

### Claude Code (Primary AI Assistant)
- Location: `.claude/` directory
- **8 Slash Commands**: `/explain`, `/refactor`, `/test`, `/document`, `/optimize`, `/debug`, `/architecture`, `/security`
- **3 Skills**: code-quality, devops-infrastructure, data-engineering
- **Usage**: `claude code` in terminal

### GitHub Copilot (Autocomplete)
- Real-time code completion
- Inline suggestions
- Enabled for all languages except YAML/config files

**Division of Labor**:
- **Copilot**: Fast autocomplete while typing
- **Claude Code**: Complex reasoning, refactoring, architecture, debugging

---

## 🔄 Common Workflows

### Creating a New Project
```bash
./create-project.sh --name myapp --archetype rag-project --github
cd myapp
cp .env.example .env.local
# Add API keys to .env.local
docker-compose up -d
code .
```

### Starting Development
```bash
# In VS Code terminal (Ctrl+`)
claude code

# Claude helps with:
# - Code review
# - Bug fixing
# - Test generation
# - Performance optimization
```

### Running Tests
```bash
# Python
pytest -v --cov=src

# TypeScript
npm test

# Go
go test ./... -v

# All archetypes have Makefile
make test
```

### Database Migrations
```bash
# Create migration
make db-migrate MESSAGE="add user profile"

# Apply migrations
make db-upgrade

# Rollback
make db-downgrade
```

### Docker Operations
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Rebuild
docker-compose build --no-cache

# Stop all
docker-compose down
```

---

## 📊 Monitoring & Observability

### Logs
- Structured logging (JSON format)
- Log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Correlation IDs for request tracing

### Metrics (Prometheus)
- Request rate, error rate, duration
- Database connection pool stats
- Cache hit/miss rates
- Custom business metrics

### Tracing (Langfuse)
- LLM calls and costs
- RAG pipeline performance
- Embedding generation time
- Model selection tracking

---

## 🚀 Deployment

### Development
- Docker Compose on local machine
- Hot reload enabled
- Debug ports exposed

### Staging
- AWS ECS (Fargate)
- RDS for PostgreSQL
- ElastiCache for Redis
- Application Load Balancer

### Production
- AWS ECS (Fargate)
- Multi-AZ RDS
- ElastiCache Redis Cluster
- CloudWatch monitoring
- Auto-scaling enabled

### CI/CD Pipeline
```yaml
# .github/workflows/ci.yml
1. Lint & Format Check
2. Run Tests
3. Build Docker Image
4. Security Scan (Trivy)
5. Push to ECR
6. Deploy to Staging (auto)
7. Deploy to Production (manual approval)
```

---

## 📚 Documentation

### For Developers
- `docs/SETUP_GUIDE.md` - Complete setup (70-90 min)
- `docs/ARCHETYPE_GUIDE.md` - Using archetypes
- `docs/USAGE_GUIDE.md` - Daily workflows
- `docs/CLAUDE_CODE_MIGRATION.md` - AI assistant transition
- `docs/TROUBLESHOOTING.md` - Common issues

### For Each Archetype
- `archetypes/{name}/README.md` - Archetype-specific docs
- `archetypes/{name}/Makefile` - Common commands
- `archetypes/{name}/.env.example` - Environment variables

---

## 🐛 Known Issues & Workarounds

### WSL2 File Watching
- **Issue**: Hot reload slow on Windows WSL2
- **Workaround**: Use `docker-compose.override.yml` with polling

### Docker Build Cache
- **Issue**: Cache not invalidating on dependency changes
- **Workaround**: Use `--no-cache` flag or update Dockerfile `COPY` order

### M1/M2 Mac Compatibility
- **Issue**: Some images don't have ARM builds
- **Workaround**: Use `platform: linux/amd64` in docker-compose.yml

---

## 🔮 Roadmap

**Q1 2025**
- [ ] Add Kubernetes archetype
- [ ] Improve test coverage across all archetypes
- [ ] Add GitHub Codespaces support

**Q2 2025**
- [ ] Add ML training archetype
- [ ] Improve documentation with video tutorials
- [ ] Add Terraform modules for AWS

**Q3 2025**
- [ ] Multi-cloud support (Azure, GCP)
- [ ] Add monitoring dashboards
- [ ] Improve archetype composition

---

## 🤝 Team Collaboration

### Git Workflow
- **Main branch**: Production-ready code
- **Feature branches**: `feature/description`
- **Bug fixes**: `fix/description`
- **Pull requests**: Required, minimum 1 approval
- **Commit messages**: Conventional Commits format

### Code Review Guidelines
- Review within 24 hours
- Check for tests and documentation
- Verify security and performance
- Use GitHub PR templates

### Communication
- GitHub Issues for bugs and features
- GitHub Discussions for architecture decisions
- Slack #dev for daily updates
- Weekly team sync meetings

---

**This file helps Claude understand:**
- Your project structure and conventions
- Technologies and frameworks used
- Common workflows and commands
- Team practices and standards
- Known issues and solutions

**Update this file when:**
- Adding new archetypes
- Changing conventions
- Adding new tools or frameworks
- Documenting new patterns
