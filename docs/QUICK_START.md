# Quick Start Guide

**Get up and running in under 15 minutes**

This guide will help you quickly set up the dev-environment-template and create your first project.

---

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Docker Desktop** installed and running
  - macOS/Windows: [Download here](https://www.docker.com/products/docker-desktop)
  - Linux: `sudo apt-get install docker.io docker-compose`
- [ ] **Git** (2.30+) installed
  - Verify: `git --version`
- [ ] **VS Code** (latest version)
  - [Download here](https://code.visualstudio.com/)
- [ ] **8GB RAM minimum** (16GB recommended)
- [ ] **10GB free disk space**

**Windows Users:** Ensure WSL2 is installed and set as default.

---

## 1. Clone or Create Template (2 minutes)

### Option A: Clone Existing Template

```bash
# Clone the template repository
git clone https://github.com/YOUR-USERNAME/dev-environment-template.git
cd dev-environment-template
```

### Option B: Create From Scratch

```bash
# Create new directory and initialize
mkdir dev-environment-template
cd dev-environment-template
git init

# Run the installation script
./install-template.sh  # macOS/Linux
# OR
.\install-template.ps1  # Windows PowerShell
```

---

## 2. Install VS Code Extension (1 minute)

Install the **Dev Containers** extension:

1. Open VS Code
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on macOS)
3. Search for "Dev Containers"
4. Click **Install** on "Dev Containers" by Microsoft

---

## 3. Start the Dev Container (3-5 minutes)

### Open in Container

1. Open the template folder in VS Code:
   ```bash
   code .
   ```

2. When prompted "Reopen in Container?", click **Reopen in Container**

   *OR manually:*
   - Press `F1`
   - Type and select: `Dev Containers: Reopen in Container`

3. Wait for the container to build (first time: 3-5 minutes)
   - Docker will download base images
   - Extensions will be installed
   - Environment will be configured

### Verify Installation

Once the container is ready, open a terminal in VS Code and run:

```bash
# Check installed tools
python3 --version    # Should show Python 3.11+
node --version       # Should show Node.js 20+
g++ --version        # Should show GCC 11+
docker --version     # Should show Docker CLI

# Verify directory structure
ls -la archetypes/   # Should show: base, rag-project, api-service, frontend, monitoring
```

---

## 4. Create Your First Project (5 minutes)

### Using the Creation Script

The easiest way to create a new project:

```bash
# Run the interactive project creator
./create-project.sh
```

You'll be prompted to:
1. **Enter project name** (e.g., `my-rag-app`)
2. **Choose archetype** (e.g., `rag-project`)
3. **Select location** (default: `../my-rag-app`)

### Manual Creation Example

For a RAG-based AI application:

```bash
# Create project directory
mkdir ../my-rag-app
cd ../my-rag-app

# Copy the RAG archetype
cp -r ../dev-environment-template/archetypes/rag-project/* .

# Copy environment template
cp .env.example .env

# Edit configuration (optional)
nano .env  # or use VS Code: code .env
```

---

## 5. Start Your Project Services (3 minutes)

### For RAG Project

```bash
# Navigate to your project
cd ../my-rag-app

# Start all services with Docker Compose
docker-compose up -d

# Wait for health checks (30-60 seconds)
docker-compose ps

# Check service status
make health  # If Makefile is available
```

### Services Started

For a RAG project, you should see:
- **PostgreSQL** (port 5432) - Database
- **Redis** (port 6379) - Caching
- **OpenSearch** (port 9200) - Vector search
- **Ollama** (port 11434) - LLM inference
- **Langfuse** (port 3000) - Observability
- **Airflow** (port 8080) - Workflow orchestration
- **OpenSearch Dashboards** (port 5601) - Visualization

---

## 6. Verify Everything Works (2 minutes)

### Check Service Health

```bash
# Test OpenSearch
curl http://localhost:9200

# Test Redis
redis-cli ping

# Test PostgreSQL
docker-compose exec postgres psql -U rag_user -d rag_db -c "SELECT version();"

# Test Ollama
curl http://localhost:11434/api/tags
```

### Access Web UIs

Open in your browser:
- **Langfuse:** http://localhost:3000
- **Airflow:** http://localhost:8080
- **OpenSearch Dashboards:** http://localhost:5601

### Run a Test Query

```bash
# If RAG API is running
curl -X POST http://localhost:8000/api/v1/ask \
  -H "Content-Type: application/json" \
  -d '{"query": "What is RAG?"}'
```

---

## 7. Next Steps

### Learn More

- **[Usage Guide](USAGE_GUIDE.md)** - Daily development workflows
- **[Archetype Guide](ARCHETYPE_GUIDE.md)** - All available project templates
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions
- **[API Documentation](TECHNICAL_REFERENCE.md)** - API endpoints and schemas

### Customize Your Project

1. **Environment Variables:** Edit `.env` file
   ```bash
   # Set your OpenAI API key (if using)
   OPENAI_API_KEY=sk-your-key-here

   # Configure Ollama model
   OLLAMA_MODEL=llama2:7b
   ```

2. **Add Dependencies:** Edit `requirements.txt`
   ```bash
   # Add new Python packages
   echo "your-package>=1.0.0" >> requirements.txt
   pip install -r requirements.txt
   ```

3. **Database Migrations:** Use Alembic
   ```bash
   # Create a migration
   alembic revision --autogenerate -m "Add new table"

   # Apply migration
   alembic upgrade head
   ```

### Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Run tests (if available)
pytest tests/ -v

# Format code (if Makefile exists)
make format

# Lint code
make lint
```

---

## Troubleshooting Quick Fixes

### Container won't build?
```bash
# Rebuild without cache
docker-compose build --no-cache
```

### Port already in use?
```bash
# Find process using port (example: 5432)
lsof -i :5432          # macOS/Linux
netstat -ano | findstr :5432  # Windows

# Edit docker-compose.yml to use different ports
```

### Permission denied on Linux?
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Services not healthy?
```bash
# Check individual service logs
docker-compose logs postgres
docker-compose logs redis
docker-compose logs opensearch

# Increase Docker memory allocation in Docker Desktop settings
```

### Can't connect to services?
```bash
# Verify services are running
docker-compose ps

# Check network connectivity
docker network inspect rag-project_rag-network

# Restart all services
docker-compose restart
```

---

## Getting Help

- **FAQ:** [docs/FAQ.md](FAQ.md)
- **Full Setup Guide:** [docs/SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Issues:** Check [GitHub Issues](https://github.com/YOUR-USERNAME/dev-environment-template/issues)
- **Discussions:** Join [GitHub Discussions](https://github.com/YOUR-USERNAME/dev-environment-template/discussions)

---

## What You've Accomplished ✅

- ✅ Installed and configured dev environment template
- ✅ Created your first project from an archetype
- ✅ Started all required services (database, cache, search, LLM)
- ✅ Verified service health and connectivity
- ✅ Ready to start developing!

**Total Time:** ~15 minutes

**Next:** Explore the [Usage Guide](USAGE_GUIDE.md) to learn daily development workflows and best practices.
