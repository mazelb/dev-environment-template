"""
Celery tasks for background processing.
"""

import time
from typing import Any, Dict

from celery import Task

from src.celery_app.celery import celery_app


class CallbackTask(Task):
    """Base task class with callbacks."""

    def on_success(self, retval, task_id, args, kwargs):
        """Success callback."""
        print(f"Task {task_id} succeeded with result: {retval}")

    def on_failure(self, exc, task_id, args, kwargs, einfo):
        """Failure callback."""
        print(f"Task {task_id} failed with exception: {exc}")


@celery_app.task(name="send_email", base=CallbackTask)
def send_email(to: str, subject: str, body: str) -> Dict[str, Any]:
    """
    Send an email asynchronously.

    Args:
        to: Recipient email address
        subject: Email subject
        body: Email body

    Returns:
        Dict with status and message
    """
    # Simulate email sending
    time.sleep(2)
    print(f"Sending email to {to}: {subject}")

    return {
        "status": "sent",
        "to": to,
        "subject": subject,
        "timestamp": time.time(),
    }


@celery_app.task(name="process_data", base=CallbackTask, bind=True)
def process_data(self, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process data asynchronously with progress tracking.

    Args:
        self: Task instance (bound)
        data: Data to process

    Returns:
        Processed data
    """
    total = 100
    for i in range(total):
        time.sleep(0.01)  # Simulate processing
        self.update_state(
            state="PROGRESS",
            meta={"current": i, "total": total, "percent": (i / total) * 100},
        )

    return {"status": "completed", "result": data, "processed_items": total}


@celery_app.task(name="generate_report", base=CallbackTask)
def generate_report(report_type: str, filters: Dict[str, Any]) -> Dict[str, Any]:
    """
    Generate a report asynchronously.

    Args:
        report_type: Type of report to generate
        filters: Report filters

    Returns:
        Report metadata
    """
    time.sleep(5)  # Simulate report generation

    return {
        "status": "completed",
        "report_type": report_type,
        "filters": filters,
        "rows": 1000,
        "file_path": f"/reports/{report_type}_{time.time()}.pdf",
    }


@celery_app.task(name="cleanup_old_data", base=CallbackTask)
def cleanup_old_data(days: int = 30) -> Dict[str, Any]:
    """
    Clean up old data from the database.

    Args:
        days: Number of days to retain

    Returns:
        Cleanup statistics
    """
    time.sleep(3)  # Simulate cleanup

    return {
        "status": "completed",
        "days_retained": days,
        "deleted_records": 150,
        "freed_space_mb": 25.5,
    }


@celery_app.task(name="scheduled_health_check", base=CallbackTask)
def scheduled_health_check() -> Dict[str, Any]:
    """
    Perform scheduled health check of external services.

    Returns:
        Health check results
    """
    # Simulate health checks
    return {
        "status": "healthy",
        "services": {
            "database": "up",
            "redis": "up",
            "api": "up",
        },
        "timestamp": time.time(),
    }
