FROM apache/airflow:2.10.3-python3.11

# Switch to root to install system dependencies
USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Switch back to airflow user
USER airflow

# Copy requirements
COPY requirements-airflow.txt /tmp/requirements-airflow.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r /tmp/requirements-airflow.txt

# Copy source code (for importing in DAGs)
COPY --chown=airflow:airflow ../src /opt/airflow/src

# Copy DAGs and plugins
COPY --chown=airflow:airflow dags /opt/airflow/dags
COPY --chown=airflow:airflow plugins /opt/airflow/plugins

# Set environment variables
ENV PYTHONPATH="/opt/airflow:/opt/airflow/src:${PYTHONPATH}"
ENV AIRFLOW_HOME=/opt/airflow

# Copy entrypoint script
COPY --chown=airflow:airflow entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
