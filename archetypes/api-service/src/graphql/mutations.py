"""
GraphQL mutation resolvers.
"""

import strawberry
from typing import Optional
from datetime import datetime

from src.graphql.types import User, Task, UserInput, UserUpdateInput


@strawberry.type
class Mutation:
    """GraphQL mutation root."""

    @strawberry.mutation
    def create_user(self, input: UserInput) -> User:
        """Create a new user."""
        # TODO: Implement database creation
        return User(
            id=1,
            username=input.username,
            email=input.email,
            is_active=True,
            created_at=datetime.utcnow(),
        )

    @strawberry.mutation
    def update_user(self, id: int, input: UserUpdateInput) -> Optional[User]:
        """Update an existing user."""
        # TODO: Implement database update
        return User(
            id=id,
            username=input.username or "updated_user",
            email=input.email or "updated@example.com",
            is_active=input.is_active if input.is_active is not None else True,
            created_at=datetime.utcnow(),
        )

    @strawberry.mutation
    def delete_user(self, id: int) -> bool:
        """Delete a user."""
        # TODO: Implement database deletion
        return True

    @strawberry.mutation
    def submit_task(self, name: str, data: strawberry.scalars.JSON) -> Task:
        """Submit a new background task."""
        # TODO: Implement Celery task submission
        return Task(
            id=f"task-{name}",
            name=name,
            status="pending",
            created_at=datetime.utcnow(),
        )

    @strawberry.mutation
    def cancel_task(self, id: str) -> bool:
        """Cancel a running task."""
        # TODO: Implement Celery task cancellation
        return True
