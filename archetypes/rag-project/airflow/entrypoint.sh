#!/bin/bash
set -e

# Initialize Airflow database if needed
if [ "$1" = "webserver" ] || [ "$1" = "scheduler" ]; then
    # Wait for PostgreSQL to be ready
    echo "Waiting for PostgreSQL..."
    while ! nc -z postgres 5432; do
        sleep 1
    done
    echo "PostgreSQL is ready!"

    # Initialize database (idempotent)
    airflow db migrate

    # Create admin user if doesn't exist
    airflow users create \
        --username airflow \
        --firstname Airflow \
        --lastname Admin \
        --role Admin \
        --email admin@example.com \
        --password airflow \
        2>/dev/null || echo "Admin user already exists"
fi

# Execute the command
exec airflow "$@"
