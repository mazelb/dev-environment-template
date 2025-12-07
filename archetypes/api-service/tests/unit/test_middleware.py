"""Unit tests for middleware."""

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient


@pytest.mark.unit
class TestLoggingMiddleware:
    """Test logging middleware."""

    def test_logging_setup_import(self):
        """Test logging setup function can be imported."""
        from src.middleware.logging import setup_logging

        assert setup_logging is not None
        assert callable(setup_logging)

    def test_logging_setup_executes(self):
        """Test logging setup function executes without errors."""
        from src.middleware.logging import setup_logging

        # Should not raise exceptions
        setup_logging()
        assert True


@pytest.mark.unit
class TestRateLimiter:
    """Test rate limiter middleware."""

    def test_limiter_import(self):
        """Test limiter can be imported."""
        from src.middleware.rate_limiter import limiter

        assert limiter is not None

    def test_limiter_has_default_limits(self):
        """Test limiter has default limits configured."""
        from src.middleware.rate_limiter import limiter

        assert hasattr(limiter, "_default_limits")
        assert len(limiter._default_limits) > 0

    def test_limiter_redis_storage(self):
        """Test limiter uses Redis storage."""
        from src.middleware.rate_limiter import limiter

        assert limiter._storage_uri is not None
        assert "redis" in limiter._storage_uri.lower()


@pytest.mark.unit
class TestMiddlewareIntegration:
    """Test middleware integration with FastAPI."""

    def test_limiter_can_be_added_to_app(self):
        """Test limiter can be added to FastAPI app."""
        from src.middleware.rate_limiter import limiter
        from slowapi import _rate_limit_exceeded_handler
        from slowapi.errors import RateLimitExceeded

        app = FastAPI()

        # Should not raise exceptions
        app.state.limiter = limiter
        app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

        assert True
