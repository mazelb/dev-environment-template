"""Unit tests for database configuration."""

import pytest
from sqlalchemy.orm import Session


@pytest.mark.unit
class TestDatabaseConfig:
    """Test database configuration."""

    def test_database_url_configuration(self):
        """Test database URL is configured."""
        from src.core.config import settings

        assert settings.DATABASE_URL is not None
        assert len(settings.DATABASE_URL) > 0

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
        from pydantic import BaseModel

        assert User is not None
        assert issubclass(User, BaseModel)

    def test_user_model_fields(self):
        """Test User model has required fields."""
        from src.models.user import User

        assert "username" in User.model_fields
        assert "email" in User.model_fields
        assert "full_name" in User.model_fields
        assert "is_active" in User.model_fields

    def test_token_model_exists(self):
        """Test Token model is defined."""
        from src.models.token import Token

        assert Token is not None
