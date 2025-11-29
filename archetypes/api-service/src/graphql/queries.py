"""
GraphQL query resolvers.
"""

from datetime import datetime
from typing import List, Optional

import strawberry

from src.graphql.types import HealthStatus, Task, User


@strawberry.type
class Query:
    """GraphQL query root."""

    @strawberry.field
    def hello(self) -> str:
        """Simple hello query."""
        return "Hello from GraphQL!"

    @strawberry.field
    def health(self) -> HealthStatus:
        """Health check query."""
        return HealthStatus(
            status="healthy",
            version="1.0.0",
            timestamp=datetime.utcnow(),
            services={
                "api": "up",
                "database": "up",
                "redis": "up",
                "celery": "up",
            },
        )

    @strawberry.field
    def users(self) -> List[User]:
        """Get all users."""
        # TODO: Implement database query
        return [
            User(
                id=1,
                username="admin",
                email="admin@example.com",
                is_active=True,
                created_at=datetime.utcnow(),
            ),
            User(
                id=2,
                username="user",
                email="user@example.com",
                is_active=True,
                created_at=datetime.utcnow(),
            ),
        ]

    @strawberry.field
    def user(self, id: int) -> Optional[User]:
        """Get user by ID."""
        # TODO: Implement database query
        if id == 1:
            return User(
                id=1,
                username="admin",
                email="admin@example.com",
                is_active=True,
                created_at=datetime.utcnow(),
            )
        return None

    @strawberry.field
    def tasks(self) -> List[Task]:
        """Get all tasks."""
        # TODO: Implement Celery task query
        return [
            Task(
                id="task-1",
                name="send_email",
                status="completed",
                created_at=datetime.utcnow(),
                completed_at=datetime.utcnow(),
                result="Email sent successfully",
            ),
        ]

    @strawberry.field
    def task(self, id: str) -> Optional[Task]:
        """Get task by ID."""
        # TODO: Implement Celery task query
        return Task(
            id=id,
            name="process_data",
            status="running",
            created_at=datetime.utcnow(),
        )
