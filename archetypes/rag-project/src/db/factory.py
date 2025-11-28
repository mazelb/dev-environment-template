"""Database factory for creating database instances."""

from src.db.base import SessionLocal, get_db, init_db, teardown

__all__ = ["SessionLocal", "init_db", "teardown", "get_db"]


class Database:
    """Database manager class."""

    def __init__(self):
        """Initialize database."""
        self.session_local = SessionLocal

    def get_session(self):
        """Get database session."""
        return self.session_local()

    def init(self):
        """Initialize database tables."""
        init_db()

    def teardown(self):
        """Close database connections."""
        teardown()


def make_database() -> Database:
    """
    Factory function to create database instance.

    Returns:
        Database: Database instance
    """
    return Database()
