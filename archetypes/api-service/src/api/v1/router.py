"""
API v1 router aggregation.
"""

from fastapi import APIRouter

from src.api.v1 import health
from src.api.v1.endpoints import tasks

api_router = APIRouter()

# Include sub-routers
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(tasks.router)

# Add more routers here as needed
# api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
# api_router.include_router(users.router, prefix="/users", tags=["users"])
