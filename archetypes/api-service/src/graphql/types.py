"""
GraphQL type definitions.
"""

from datetime import datetime
from typing import Optional

import strawberry


@strawberry.type
class User:
    """User type."""

    id: int
    username: str
    email: str
    is_active: bool = True
    created_at: datetime


@strawberry.type
class Task:
    """Task type."""

    id: str
    name: str
    status: str
    created_at: datetime
    completed_at: Optional[datetime] = None
    result: Optional[str] = None


@strawberry.type
class HealthStatus:
    """Health status type."""

    status: str
    version: str
    timestamp: datetime
    services: strawberry.scalars.JSON


@strawberry.input
class UserInput:
    """User input type."""

    username: str
    email: str
    password: str


@strawberry.input
class UserUpdateInput:
    """User update input type."""

    username: Optional[str] = None
    email: Optional[str] = None
    is_active: Optional[bool] = None
