"""
Health check endpoints.
"""

from fastapi import APIRouter, Depends
from redis import Redis

from src.auth.dependencies import get_current_user
from src.core.config import settings
from src.models.user import User

router = APIRouter()


@router.get("/")
async def health_check():
    """Basic health check."""
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
    }


@router.get("/detailed")
async def detailed_health_check():
    """Detailed health check with dependency status."""

    # Check Redis connection
    redis_status = "healthy"
    try:
        r = Redis(host=settings.REDIS_HOST, port=settings.REDIS_PORT, socket_timeout=2)
        r.ping()
    except Exception:
        redis_status = "unhealthy"

    return {
        "status": "healthy" if redis_status == "healthy" else "degraded",
        "service": settings.PROJECT_NAME,
        "dependencies": {
            "redis": redis_status,
        },
    }


@router.get("/protected")
async def protected_health_check(current_user: User = Depends(get_current_user)):
    """Protected health check requiring authentication."""
    return {
        "status": "healthy",
        "user": current_user.username,
        "message": "Authentication working correctly",
    }
