# Apache Airflow - Workflow Orchestration

## Overview

Apache Airflow is integrated into the RAG archetype for workflow orchestration, task scheduling, and data pipeline management.

## Architecture

### Services

- **airflow-init**: Initializes database and creates admin user
- **airflow-webserver**: Web UI on port 8080
- **airflow-scheduler**: Schedules and executes DAG tasks
- **Database**: PostgreSQL (shared with RAG application, separate database)

### Configuration

- **Executor**: LocalExecutor (single machine, multiple processes)
- **Database**: `postgresql://airflow:airflow@postgres:5432/airflow`
- **Default Credentials**: admin/admin (change in `.env`)

## Quick Start

### 1. Start Services

```bash
make start
```

This starts all services including Airflow init, scheduler, and webserver.

### 2. Access Web UI

```bash
make airflow-ui
# Opens http://localhost:8080
# Username: admin
# Password: admin (default)
```

### 3. Check Airflow Health

```bash
make health
```

Look for "=== Airflow Health ===" section.

### 4. View Logs

```bash
make airflow-logs
```

## DAG Management

### List All DAGs

```bash
make airflow-dags
```

### Test a DAG

```bash
make airflow-test-dag DAG_ID=hello_world_dag
```

### Trigger a DAG Manually

```bash
make airflow-trigger-dag DAG_ID=document_ingestion_dag
```

### Access Airflow Shell

```bash
make airflow-shell
```

## Available DAGs

### 1. Hello World DAG

- **File**: `airflow/dags/hello_world_dag.py`
- **Purpose**: Simple example DAG for testing
- **Schedule**: Daily
- **Tasks**: Print hello world message

### 2. Document Ingestion DAG

- **File**: `airflow/dags/document_ingestion_dag.py`
- **Purpose**: Template for document ingestion workflows
- **Schedule**: Not scheduled (manual trigger)
- **Tasks**:
  - Extract documents
  - Transform documents
  - Load to OpenSearch

### 3. Health Check DAG

- **File**: `airflow/dags/health_check_dag.py`
- **Purpose**: Monitor service health
- **Schedule**: Every hour
- **Tasks**: Check PostgreSQL, Redis, OpenSearch, Ollama status

## Creating Custom DAGs

### 1. Create DAG File

Create a new Python file in `airflow/dags/`:

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'my_custom_dag',
    default_args=default_args,
    description='My custom DAG',
    schedule_interval=timedelta(days=1),
    catchup=False,
)

def my_task_function():
    print("Hello from my custom task!")

task = PythonOperator(
    task_id='my_task',
    python_callable=my_task_function,
    dag=dag,
)
```

### 2. Reload DAGs

DAGs are automatically reloaded every few seconds. Check the UI or logs.

### 3. Test Your DAG

```bash
make airflow-test-dag DAG_ID=my_custom_dag
```

## Accessing Project Code

The RAG project source code is mounted at `/opt/airflow/src` in Airflow containers.

Example usage in DAG:

```python
import sys
sys.path.insert(0, '/opt/airflow')

from src.services.opensearch import OpenSearchClient
from src.config import get_settings

def ingest_documents():
    settings = get_settings()
    opensearch = OpenSearchClient(settings)
    # Your ingestion logic here
```

## Environment Variables

Configure in `.env` file:

```bash
# Airflow Admin User
AIRFLOW_USERNAME=admin
AIRFLOW_PASSWORD=admin

# Security Keys (generate with: python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
AIRFLOW_FERNET_KEY=your-fernet-key-here
AIRFLOW_WEBSERVER_SECRET_KEY=your-secret-key-here
```

### Generating Keys

```bash
# Fernet Key
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# Webserver Secret Key
python -c "import secrets; print(secrets.token_hex(32))"
```

## Common Operations

### Pause/Unpause DAG

Via Web UI:
1. Go to http://localhost:8080
2. Find your DAG
3. Toggle the switch next to DAG name

Via CLI:
```bash
make airflow-shell
airflow dags pause my_dag_id
airflow dags unpause my_dag_id
```

### View Task Logs

1. Go to Web UI
2. Click on DAG name
3. Click on task instance
4. Click "Log" button

### Clear Task State

```bash
make airflow-shell
airflow tasks clear my_dag_id -t my_task_id
```

### Backfill DAG

```bash
make airflow-shell
airflow dags backfill my_dag_id -s 2025-01-01 -e 2025-01-31
```

## Integration with RAG Services

### Using OpenSearch

```python
from src.services.opensearch import make_opensearch_client
from src.config import get_settings

def index_documents(**context):
    settings = get_settings()
    client = make_opensearch_client(settings)
    # Index documents
```

### Using Ollama

```python
from src.services.ollama import make_ollama_client
from src.config import get_settings

def generate_embeddings(**context):
    settings = get_settings()
    client = make_ollama_client(settings)
    # Generate embeddings
```

### Using Database

```python
from src.db.base import SessionLocal

def process_database_records(**context):
    db = SessionLocal()
    try:
        # Your database operations
        pass
    finally:
        db.close()
```

## Monitoring & Debugging

### Check Scheduler Status

```bash
docker compose exec airflow-scheduler airflow jobs check --job-type SchedulerJob
```

### View Database Connections

```bash
docker compose exec postgres psql -U airflow -d airflow -c "SELECT * FROM connection;"
```

### Clear Logs

```bash
docker compose exec airflow-scheduler airflow tasks clear-logs
```

## Troubleshooting

### DAG Not Appearing

1. Check DAG file syntax: No Python errors
2. Check scheduler logs: `make airflow-logs`
3. Verify DAG is in `airflow/dags/` directory
4. Wait 30 seconds for DAG to be parsed

### Task Failing

1. Check task logs in Web UI
2. Verify environment variables
3. Check service dependencies (PostgreSQL, Redis, etc.)
4. Test task logic independently

### Scheduler Not Running

```bash
# Check scheduler health
docker compose ps airflow-scheduler

# Restart scheduler
docker compose restart airflow-scheduler

# View logs
make airflow-logs
```

### Database Connection Issues

```bash
# Check PostgreSQL health
docker compose exec postgres pg_isready -U airflow -d airflow

# Test connection from Airflow
docker compose exec airflow-scheduler airflow db check
```

## Best Practices

1. **Use XCom for small data**: Don't pass large datasets between tasks
2. **Idempotent tasks**: Tasks should produce same result when re-run
3. **Proper error handling**: Use try/except and retries
4. **Resource limits**: Don't overload scheduler with too many tasks
5. **Testing**: Test DAGs before deploying to production
6. **Monitoring**: Set up alerts for failed tasks
7. **Documentation**: Document each DAG's purpose and dependencies

## Resources

- [Official Airflow Documentation](https://airflow.apache.org/docs/)
- [DAG Writing Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)
- [Airflow Concepts](https://airflow.apache.org/docs/apache-airflow/stable/concepts/index.html)

## Next Steps

1. Customize existing DAGs for your use case
2. Create domain-specific workflows (arxiv paper ingestion, etc.)
3. Set up monitoring and alerting
4. Configure email notifications for failures
5. Optimize task concurrency and resource usage
