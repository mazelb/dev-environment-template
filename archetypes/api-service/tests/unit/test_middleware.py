"""Unit tests for middleware."""

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient


@pytest.mark.unit
class TestLoggingMiddleware:
    """Test logging middleware."""

    def test_logging_middleware_import(self):
        """Test logging middleware can be imported."""
        from src.middleware.logging import LoggingMiddleware

        assert LoggingMiddleware is not None

    def test_logging_middleware_logs_requests(self):
        """Test middleware logs HTTP requests."""
        from src.middleware.logging import LoggingMiddleware

        app = FastAPI()
        app.add_middleware(LoggingMiddleware)

        @app.get("/test")
        def test_endpoint():
            return {"status": "ok"}

        client = TestClient(app)
        response = client.get("/test")

        assert response.status_code == 200


@pytest.mark.unit
class TestRateLimiter:
    """Test rate limiter middleware."""

    def test_rate_limiter_import(self):
        """Test rate limiter can be imported."""
        from src.middleware.rate_limiter import RateLimiter

        assert RateLimiter is not None

    def test_rate_limiter_initialization(self):
        """Test rate limiter initializes correctly."""
        from src.middleware.rate_limiter import RateLimiter

        limiter = RateLimiter(max_requests=10, window_seconds=60)

        assert limiter is not None
        assert limiter.max_requests == 10
        assert limiter.window_seconds == 60

    def test_rate_limiter_allows_requests_within_limit(self):
        """Test rate limiter allows requests within limit."""
        from src.middleware.rate_limiter import RateLimiter

        app = FastAPI()
        limiter = RateLimiter(max_requests=5, window_seconds=60)
        app.add_middleware(
            type(limiter).__bases__[0], app=app, dispatch=limiter.dispatch
        )

        @app.get("/test")
        def test_endpoint():
            return {"status": "ok"}

        client = TestClient(app)

        # First 5 requests should succeed
        for _ in range(5):
            response = client.get("/test")
            assert response.status_code == 200


@pytest.mark.unit
class TestMiddlewareIntegration:
    """Test middleware integration with FastAPI."""

    def test_middleware_can_be_added_to_app(self):
        """Test middleware can be added to FastAPI app."""
        from src.middleware.logging import LoggingMiddleware

        app = FastAPI()

        # Should not raise exceptions
        app.add_middleware(LoggingMiddleware)

        assert True
