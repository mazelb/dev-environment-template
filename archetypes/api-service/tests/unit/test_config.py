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
        """Test SECRET_KEY is configured."""
        from src.core.config import settings

        assert settings.SECRET_KEY is not None
        assert len(settings.SECRET_KEY) > 0

    def test_algorithm_configured(self):
        """Test JWT algorithm is configured."""
        from src.core.config import settings

        assert settings.ALGORITHM is not None
        assert settings.ALGORITHM in ["HS256", "HS384", "HS512"]

    def test_access_token_expire_minutes(self):
        """Test access token expiry is configured."""
        from src.core.config import settings

        assert settings.ACCESS_TOKEN_EXPIRE_MINUTES > 0

    def test_environment_specific_settings(self, test_settings):
        """Test environment-specific settings."""
        assert test_settings.ENVIRONMENT == "test"
        assert test_settings.DEBUG is False

    def test_database_url_from_env(self, test_settings):
        """Test DATABASE_URL is loaded from environment."""
        assert test_settings.DATABASE_URL is not None
        assert "sqlite" in test_settings.DATABASE_URL.lower()

    def test_redis_configuration(self, test_settings):
        """Test Redis configuration."""
        assert test_settings.REDIS_HOST is not None
        assert test_settings.REDIS_PORT > 0
        assert test_settings.REDIS_DB >= 0

    def test_cors_origins_configured(self):
        """Test CORS origins are configured."""
        from src.core.config import settings

        assert hasattr(settings, "CORS_ORIGINS") or hasattr(settings, "ALLOWED_ORIGINS")
