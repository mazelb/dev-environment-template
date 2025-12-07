"""Unit tests for configuration."""

import pytest


@pytest.mark.unit
class TestConfiguration:
    """Test application configuration."""

    def test_settings_loads(self):
        """Test settings can be loaded."""
        from src.core.config import settings

        assert settings is not None

    def test_secret_key_configured(self):
        """Test API_SECRET_KEY is configured."""
        from src.core.config import settings

        assert settings.API_SECRET_KEY is not None
        assert len(settings.API_SECRET_KEY) > 0

    def test_algorithm_configured(self):
        """Test JWT algorithm is configured."""
        from src.core.config import settings

        assert settings.API_ALGORITHM is not None
        assert settings.API_ALGORITHM in ["HS256", "HS384", "HS512"]

    def test_access_token_expire_minutes(self):
        """Test access token expiry is configured."""
        from src.core.config import settings

        assert settings.API_ACCESS_TOKEN_EXPIRE_MINUTES > 0

    def test_environment_specific_settings(self):
        """Test project name is configured."""
        from src.core.config import settings

        assert settings.PROJECT_NAME is not None
        assert len(settings.PROJECT_NAME) > 0

    def test_database_url_from_env(self):
        """Test DATABASE_URL is loaded from environment."""
        from src.core.config import settings

        assert settings.DATABASE_URL is not None
        assert "postgresql" in settings.DATABASE_URL.lower()

    def test_redis_configuration(self):
        """Test Redis configuration."""
        from src.core.config import settings

        assert settings.REDIS_HOST is not None
        assert settings.REDIS_PORT > 0

    def test_cors_origins_configured(self):
        """Test CORS origins are configured."""
        from src.core.config import settings

        assert hasattr(settings, "CORS_ORIGINS") or hasattr(settings, "ALLOWED_ORIGINS")
