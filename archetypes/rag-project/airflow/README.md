# Airflow Directory

This directory contains Apache Airflow configuration for workflow orchestration.

## Structure

```
airflow/
├── dags/              # DAG definitions
│   └── examples/      # Example DAGs
├── plugins/           # Custom Airflow plugins
├── logs/             # Airflow logs (generated)
├── Dockerfile        # Airflow container image
├── entrypoint.sh     # Container entrypoint script
└── requirements-airflow.txt  # Airflow dependencies
```

## DAGs (Directed Acyclic Graphs)

DAGs define workflows with tasks and dependencies. Place your DAG files in the `dags/` directory.

### Example DAG Structure

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'example_dag',
    default_args=default_args,
    description='Example DAG',
    schedule_interval=timedelta(days=1),
    catchup=False,
)

def my_task():
    print("Task executed!")

task = PythonOperator(
    task_id='my_task',
    python_callable=my_task,
    dag=dag,
)
```

## Usage

### Start Airflow Services

```bash
# Initialize Airflow database (first time only)
make airflow-init

# Start Airflow scheduler
make airflow-scheduler

# Start Airflow webserver (in another terminal)
make airflow-webserver

# Or use docker-compose
docker-compose up airflow-scheduler airflow-webserver
```

### Access Airflow UI

1. Open browser to: http://localhost:8080
2. Default credentials:
   - Username: `airflow`
   - Password: `airflow`

### Trigger a DAG

```bash
# Via Airflow UI: Click on DAG -> Trigger DAG

# Via CLI
docker-compose exec airflow-webserver airflow dags trigger <dag_id>

# Via Make
make airflow-trigger DAG_ID=<dag_id>
```

## Development

### Creating a New DAG

1. Create Python file in `dags/` directory
2. Define DAG with tasks
3. Wait for Airflow to detect (auto-refresh every 30s)
4. Verify in Airflow UI

### Testing DAGs

```bash
# List DAGs
docker-compose exec airflow-webserver airflow dags list

# Test specific task
docker-compose exec airflow-webserver airflow tasks test <dag_id> <task_id> <execution_date>

# Run DAG without scheduling
docker-compose exec airflow-webserver airflow dags test <dag_id> <execution_date>
```

## Monitoring

- **Logs**: Check `airflow/logs/` directory
- **UI**: Monitor task status in Airflow web interface
- **Database**: Tasks, runs, and metadata in PostgreSQL

## Plugins

Custom operators, sensors, and hooks can be added to the `plugins/` directory.

Example plugin structure:
```
plugins/
├── operators/
│   └── custom_operator.py
├── sensors/
│   └── custom_sensor.py
└── hooks/
    └── custom_hook.py
```

## Environment Variables

Configure Airflow via environment variables in `.env`:

```bash
# Airflow Core
AIRFLOW__CORE__EXECUTOR=LocalExecutor
AIRFLOW__CORE__LOAD_EXAMPLES=False
AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags

# Database
AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://user:pass@postgres:5432/airflow

# Webserver
AIRFLOW__WEBSERVER__SECRET_KEY=your-secret-key
```

## Best Practices

1. **Idempotency**: Tasks should be idempotent (same result on retry)
2. **Error Handling**: Use proper error handling and retries
3. **Dependencies**: Define clear task dependencies
4. **Testing**: Test DAGs before production
5. **Monitoring**: Monitor task execution and logs
6. **Resource Management**: Set appropriate resource limits
7. **Documentation**: Document DAG purpose and tasks

## References

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [DAG Authoring](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html)
- [Operators](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html)
