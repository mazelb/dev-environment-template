"""Hello World DAG - Simple example for testing Airflow setup."""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

# Default arguments for all tasks
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2024, 1, 1),
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# Create DAG
dag = DAG(
    "hello_world",
    default_args=default_args,
    description="Simple hello world DAG",
    schedule_interval=None,  # Manual trigger only
    catchup=False,
    tags=["example", "hello-world"],
)


def print_hello():
    """Print hello message."""
    print("Hello from Airflow!")
    print(f"Execution date: {datetime.now()}")
    return "Hello task completed"


def print_world():
    """Print world message."""
    print("World from Airflow!")
    return "World task completed"


# Define tasks
task_hello = PythonOperator(
    task_id="print_hello",
    python_callable=print_hello,
    dag=dag,
)

task_date = BashOperator(
    task_id="print_date",
    bash_command="date",
    dag=dag,
)

task_world = PythonOperator(
    task_id="print_world",
    python_callable=print_world,
    dag=dag,
)

# Set task dependencies
task_hello >> task_date >> task_world
