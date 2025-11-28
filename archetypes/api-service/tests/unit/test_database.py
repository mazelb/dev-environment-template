"""Unit tests for database configuration."""

import pytest
from sqlalchemy.orm import Session


@pytest.mark.unit
class TestDatabaseConfig:
    """Test database configuration."""

    def test_database_url_configuration(self, test_settings):
        """Test database URL is configured."""
        assert test_settings.DATABASE_URL is not None
        assert len(test_settings.DATABASE_URL) > 0

    def test_database_engine_creation(self):
        """Test database engine can be created."""
        from src.db.base import engine

        assert engine is not None

    def test_session_creation(self):
        """Test database session can be created."""
        from src.db.base import SessionLocal

        session = SessionLocal()
        assert session is not None
        assert isinstance(session, Session)
        session.close()

    def test_get_db_dependency(self):
        """Test get_db dependency function."""
        from src.db.base import get_db

        db_gen = get_db()
        db = next(db_gen)

        assert db is not None
        assert isinstance(db, Session)

        # Cleanup
        try:
            db_gen.send(None)
        except StopIteration:
            pass


@pytest.mark.unit
class TestDatabaseModels:
    """Test database models."""

    def test_user_model_exists(self):
        """Test User model is defined."""
        from src.models.user import User

        assert User is not None
        assert hasattr(User, "__tablename__")

    def test_user_model_fields(self):
        """Test User model has required fields."""
        from src.models.user import User

        assert hasattr(User, "id")
        assert hasattr(User, "email")
        assert hasattr(User, "username")
        assert hasattr(User, "hashed_password")

    def test_token_model_exists(self):
        """Test Token model is defined."""
        from src.models.token import Token

        assert Token is not None
