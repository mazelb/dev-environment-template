"""Integration tests for database operations."""

import pytest
from sqlalchemy import select


@pytest.mark.integration
@pytest.mark.asyncio
class TestDatabaseOperations:
    """Test database CRUD operations."""

    async def test_database_connection(self, async_db_session):
        """Test database connection is working."""
        result = await async_db_session.execute(select(1))
        value = result.scalar()

        assert value == 1

    async def test_create_record(self, async_db_session, db_models):
        """Test creating a database record."""
        from src.db.base import User

        new_user = User(
            username="testuser", email="test@example.com", hashed_password="hashedpass"
        )

        async_db_session.add(new_user)
        await async_db_session.commit()
        await async_db_session.refresh(new_user)

        assert new_user.id is not None
        assert new_user.username == "testuser"

    async def test_read_record(self, async_db_session, sample_user):
        """Test reading a database record."""
        from src.db.base import User

        result = await async_db_session.execute(
            select(User).where(User.id == sample_user.id)
        )
        user = result.scalar_one()

        assert user is not None
        assert user.id == sample_user.id
        assert user.username == sample_user.username

    async def test_update_record(self, async_db_session, sample_user):
        """Test updating a database record."""
        from src.db.base import User

        # Update user
        sample_user.username = "updated_username"
        await async_db_session.commit()
        await async_db_session.refresh(sample_user)

        # Verify update
        result = await async_db_session.execute(
            select(User).where(User.id == sample_user.id)
        )
        updated_user = result.scalar_one()

        assert updated_user.username == "updated_username"

    async def test_delete_record(self, async_db_session, sample_user):
        """Test deleting a database record."""
        from src.db.base import User

        user_id = sample_user.id

        # Delete user
        await async_db_session.delete(sample_user)
        await async_db_session.commit()

        # Verify deletion
        result = await async_db_session.execute(select(User).where(User.id == user_id))
        deleted_user = result.scalar_one_or_none()

        assert deleted_user is None

    async def test_bulk_insert(self, async_db_session):
        """Test bulk inserting records."""
        from src.db.base import User

        users = [
            User(username=f"user{i}", email=f"user{i}@test.com", hashed_password="pass")
            for i in range(10)
        ]

        async_db_session.add_all(users)
        await async_db_session.commit()

        # Verify all inserted
        result = await async_db_session.execute(select(User))
        all_users = result.scalars().all()

        assert len(all_users) >= 10


@pytest.mark.integration
@pytest.mark.asyncio
class TestRepositoryPattern:
    """Test repository pattern for data access."""

    async def test_repository_create(self, user_repository):
        """Test creating via repository."""
        user_data = {
            "username": "repo_user",
            "email": "repo@test.com",
            "password": "password123",
        }

        user = await user_repository.create(user_data)

        assert user is not None
        assert user.id is not None
        assert user.username == "repo_user"

    async def test_repository_get_by_id(self, user_repository, sample_user):
        """Test getting record by ID via repository."""
        user = await user_repository.get_by_id(sample_user.id)

        assert user is not None
        assert user.id == sample_user.id

    async def test_repository_get_all(self, user_repository):
        """Test getting all records via repository."""
        users = await user_repository.get_all(limit=10, offset=0)

        assert users is not None
        assert isinstance(users, list)

    async def test_repository_update(self, user_repository, sample_user):
        """Test updating via repository."""
        updated_user = await user_repository.update(
            sample_user.id, {"username": "updated_via_repo"}
        )

        assert updated_user is not None
        assert updated_user.username == "updated_via_repo"

    async def test_repository_delete(self, user_repository, sample_user):
        """Test deleting via repository."""
        success = await user_repository.delete(sample_user.id)

        assert success is True

        # Verify deletion
        deleted_user = await user_repository.get_by_id(sample_user.id)
        assert deleted_user is None

    async def test_repository_filter(self, user_repository):
        """Test filtering records via repository."""
        users = await user_repository.filter(filters={"username": "testuser"}, limit=10)

        assert users is not None
        assert isinstance(users, list)


@pytest.mark.integration
class TestDatabaseMigrations:
    """Test Alembic database migrations."""

    def test_migration_current_revision(self, alembic_config):
        """Test checking current migration revision."""
        from alembic.script import ScriptDirectory

        script = ScriptDirectory.from_config(alembic_config)
        head_revision = script.get_current_head()

        assert head_revision is not None

    def test_migration_upgrade(self, alembic_config):
        """Test running migration upgrade."""
        from alembic import command

        # Run upgrade
        command.upgrade(alembic_config, "head")

        # Should complete without errors

    def test_migration_downgrade(self, alembic_config):
        """Test running migration downgrade."""
        from alembic import command

        # Downgrade one revision
        command.downgrade(alembic_config, "-1")

        # Upgrade back
        command.upgrade(alembic_config, "head")

    def test_migration_history(self, alembic_config):
        """Test viewing migration history."""
        from io import StringIO

        from alembic import command

        output = StringIO()
        command.history(alembic_config, verbose=True)

        # Should complete without errors
