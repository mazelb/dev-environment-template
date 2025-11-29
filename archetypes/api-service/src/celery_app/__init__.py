"""
Celery application for background task processing.
"""

from src.celery_app.celery import celery_app

__all__ = ["celery_app"]
