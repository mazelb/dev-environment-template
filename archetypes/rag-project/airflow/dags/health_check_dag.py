"""Health check DAG for monitoring service health.

This DAG checks the health of all services:
- PostgreSQL
- Redis
- OpenSearch
- Ollama
- Langfuse
"""

import logging
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook

logger = logging.getLogger(__name__)

# Default arguments
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2024, 1, 1),
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

# Create DAG - runs every 15 minutes
dag = DAG(
    "health_check",
    default_args=default_args,
    description="Monitor service health",
    schedule_interval=timedelta(minutes=15),
    catchup=False,
    tags=["monitoring", "health-check"],
)


def check_postgres(**context):
    """Check PostgreSQL health."""
    try:
        hook = PostgresHook(postgres_conn_id="postgres_default")
        connection = hook.get_conn()
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        connection.close()

        logger.info("PostgreSQL health check: PASS")
        return {"service": "postgres", "status": "healthy", "result": result}
    except Exception as e:
        logger.error(f"PostgreSQL health check: FAIL - {e}")
        return {"service": "postgres", "status": "unhealthy", "error": str(e)}


def check_redis(**context):
    """Check Redis health."""
    try:
        import redis

        client = redis.Redis(host="redis", port=6379, decode_responses=True)
        pong = client.ping()

        logger.info(f"Redis health check: PASS (ping={pong})")
        return {"service": "redis", "status": "healthy", "ping": pong}
    except Exception as e:
        logger.error(f"Redis health check: FAIL - {e}")
        return {"service": "redis", "status": "unhealthy", "error": str(e)}


def check_opensearch(**context):
    """Check OpenSearch health."""
    try:
        from opensearchpy import OpenSearch

        client = OpenSearch(
            hosts=[{"host": "opensearch", "port": 9200}],
            http_auth=("admin", "Admin@123"),
            use_ssl=False,
            verify_certs=False,
        )

        health = client.cluster.health()
        status = health["status"]

        logger.info(f"OpenSearch health check: PASS (status={status})")
        return {"service": "opensearch", "status": "healthy", "cluster_status": status}
    except Exception as e:
        logger.error(f"OpenSearch health check: FAIL - {e}")
        return {"service": "opensearch", "status": "unhealthy", "error": str(e)}


def check_ollama(**context):
    """Check Ollama health."""
    try:
        import httpx

        response = httpx.get("http://ollama:11434/api/tags", timeout=10.0)
        response.raise_for_status()

        models = response.json().get("models", [])
        model_count = len(models)

        logger.info(f"Ollama health check: PASS ({model_count} models)")
        return {"service": "ollama", "status": "healthy", "model_count": model_count}
    except Exception as e:
        logger.error(f"Ollama health check: FAIL - {e}")
        return {"service": "ollama", "status": "unhealthy", "error": str(e)}


def aggregate_health(**context):
    """Aggregate health check results."""
    task_instance = context["task_instance"]

    results = {
        "postgres": task_instance.xcom_pull(task_ids="check_postgres"),
        "redis": task_instance.xcom_pull(task_ids="check_redis"),
        "opensearch": task_instance.xcom_pull(task_ids="check_opensearch"),
        "ollama": task_instance.xcom_pull(task_ids="check_ollama"),
    }

    # Count healthy and unhealthy services
    healthy = sum(1 for r in results.values() if r and r.get("status") == "healthy")
    total = len(results)

    logger.info(f"Health check summary: {healthy}/{total} services healthy")

    for service, result in results.items():
        status = result.get("status", "unknown") if result else "unknown"
        logger.info(f"  {service}: {status}")

    return {
        "timestamp": datetime.now().isoformat(),
        "healthy_count": healthy,
        "total_count": total,
        "all_healthy": healthy == total,
        "results": results,
    }


# Define tasks
task_check_postgres = PythonOperator(
    task_id="check_postgres",
    python_callable=check_postgres,
    provide_context=True,
    dag=dag,
)

task_check_redis = PythonOperator(
    task_id="check_redis",
    python_callable=check_redis,
    provide_context=True,
    dag=dag,
)

task_check_opensearch = PythonOperator(
    task_id="check_opensearch",
    python_callable=check_opensearch,
    provide_context=True,
    dag=dag,
)

task_check_ollama = PythonOperator(
    task_id="check_ollama",
    python_callable=check_ollama,
    provide_context=True,
    dag=dag,
)

task_aggregate = PythonOperator(
    task_id="aggregate_health",
    python_callable=aggregate_health,
    provide_context=True,
    dag=dag,
)

# Run health checks in parallel, then aggregate
[
    task_check_postgres,
    task_check_redis,
    task_check_opensearch,
    task_check_ollama,
] >> task_aggregate
