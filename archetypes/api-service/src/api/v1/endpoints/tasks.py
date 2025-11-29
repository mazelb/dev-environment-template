"""
API endpoints for task management.
"""

from typing import Any, Dict

from celery.result import AsyncResult
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from src.celery_app.tasks import (
    cleanup_old_data,
    generate_report,
    process_data,
    send_email,
)

router = APIRouter(prefix="/tasks", tags=["tasks"])


class EmailRequest(BaseModel):
    """Email sending request."""

    to: str = Field(..., description="Recipient email address")
    subject: str = Field(..., description="Email subject")
    body: str = Field(..., description="Email body")


class DataProcessRequest(BaseModel):
    """Data processing request."""

    data: Dict[str, Any] = Field(..., description="Data to process")


class ReportRequest(BaseModel):
    """Report generation request."""

    report_type: str = Field(..., description="Type of report")
    filters: Dict[str, Any] = Field(default_factory=dict, description="Report filters")


class CleanupRequest(BaseModel):
    """Cleanup request."""

    days: int = Field(default=30, description="Days to retain")


class TaskResponse(BaseModel):
    """Task submission response."""

    task_id: str = Field(..., description="Task ID")
    status: str = Field(..., description="Task status")
    message: str = Field(..., description="Status message")


@router.post("/send-email", response_model=TaskResponse)
async def send_email_task(request: EmailRequest):
    """Submit an email sending task."""
    task = send_email.delay(request.to, request.subject, request.body)
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message="Email task submitted successfully",
    )


@router.post("/process-data", response_model=TaskResponse)
async def process_data_task(request: DataProcessRequest):
    """Submit a data processing task."""
    task = process_data.delay(request.data)
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message="Data processing task submitted successfully",
    )


@router.post("/generate-report", response_model=TaskResponse)
async def generate_report_task(request: ReportRequest):
    """Submit a report generation task."""
    task = generate_report.delay(request.report_type, request.filters)
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message="Report generation task submitted successfully",
    )


@router.post("/cleanup", response_model=TaskResponse)
async def cleanup_task(request: CleanupRequest):
    """Submit a cleanup task."""
    task = cleanup_old_data.delay(request.days)
    return TaskResponse(
        task_id=task.id,
        status="pending",
        message="Cleanup task submitted successfully",
    )


@router.get("/status/{task_id}")
async def get_task_status(task_id: str) -> Dict[str, Any]:
    """
    Get task status by ID.

    Args:
        task_id: Task ID

    Returns:
        Task status information
    """
    task_result = AsyncResult(task_id)

    if task_result.state == "PENDING":
        return {
            "task_id": task_id,
            "state": task_result.state,
            "status": "Task is waiting to be processed",
        }
    elif task_result.state == "PROGRESS":
        return {
            "task_id": task_id,
            "state": task_result.state,
            "progress": task_result.info,
        }
    elif task_result.state == "SUCCESS":
        return {
            "task_id": task_id,
            "state": task_result.state,
            "result": task_result.result,
        }
    elif task_result.state == "FAILURE":
        return {
            "task_id": task_id,
            "state": task_result.state,
            "error": str(task_result.info),
        }
    else:
        return {
            "task_id": task_id,
            "state": task_result.state,
            "status": "Unknown task state",
        }


@router.delete("/{task_id}")
async def cancel_task(task_id: str) -> Dict[str, str]:
    """
    Cancel a running task.

    Args:
        task_id: Task ID

    Returns:
        Cancellation status
    """
    task_result = AsyncResult(task_id)

    if task_result.state in ["PENDING", "PROGRESS"]:
        task_result.revoke(terminate=True)
        return {
            "task_id": task_id,
            "status": "cancelled",
            "message": "Task cancelled successfully",
        }
    else:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel task in state: {task_result.state}",
        )
