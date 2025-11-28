"""Unit tests for database layer."""

import pytest
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import Session
from src.db.base import Base, get_engine


@pytest.mark.unit
class TestDatabaseBase:
    """Test database base configuration."""

    def test_engine_creation(self, test_settings):
        """Test creating database engine."""
        engine = get_engine(test_settings)

        assert engine is not None
        assert str(engine.url).startswith("sqlite")

    def test_session_creation(self, test_db_engine):
        """Test creating database session."""
        from sqlalchemy.orm import sessionmaker

        SessionLocal = sessionmaker(bind=test_db_engine)
        session = SessionLocal()

        assert session is not None
        assert isinstance(session, Session)
        session.close()

    def test_base_model(self):
        """Test Base model can be used for table creation."""

        # Create a test model
        class TestModel(Base):
            __tablename__ = "test_table"
            id = Column(Integer, primary_key=True)
            name = Column(String(100))

        assert hasattr(TestModel, "__tablename__")
        assert TestModel.__tablename__ == "test_table"

    def test_session_dependency(self, test_db_session):
        """Test session dependency provides session."""
        assert test_db_session is not None
        assert isinstance(test_db_session, Session)


@pytest.mark.unit
class TestDatabaseFactory:
    """Test database factory."""

    def test_factory_creates_engine(self, test_settings):
        """Test factory creates engine with settings."""
        from src.db.factory import make_engine

        engine = make_engine(test_settings)

        assert engine is not None

    def test_factory_creates_session(self, test_settings):
        """Test factory creates session maker."""
        from src.db.factory import make_session_factory

        session_factory = make_session_factory(test_settings)

        assert session_factory is not None
        session = session_factory()
        assert isinstance(session, Session)
        session.close()
