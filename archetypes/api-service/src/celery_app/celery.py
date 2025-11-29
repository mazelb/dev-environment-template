"""
Celery application configuration and initialization.
"""

from celery import Celery

from src.core.config import settings

# Create Celery instance
celery_app = Celery(
    "api_service",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["src.celery_app.tasks"],
)

# Configure Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    task_soft_time_limit=25 * 60,  # 25 minutes
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=1000,
)

# Optional: Result expiration
celery_app.conf.result_expires = 3600  # 1 hour

if __name__ == "__main__":
    celery_app.start()
