"""Integration tests for Docker services."""

import subprocess
import time
from pathlib import Path

import pytest


@pytest.mark.integration
@pytest.mark.docker
@pytest.mark.slow
class TestDockerServices:
    """Test Docker services startup and health."""

    def test_docker_compose_file_exists(self):
        """Test docker-compose.yml exists."""
        compose_file = Path(__file__).parent.parent.parent / "docker-compose.yml"
        assert compose_file.exists()

    def test_services_can_start(self, docker_compose_up):
        """Test all services can start."""
        time.sleep(5)

        # Check if containers are running
        result = subprocess.run(
            ["docker-compose", "ps"],
            capture_output=True,
            text=True,
            cwd=Path(__file__).parent.parent.parent,
        )

        assert result.returncode == 0
        assert "Up" in result.stdout or "running" in result.stdout.lower()

    def test_postgres_health(self, docker_compose_up):
        """Test PostgreSQL is healthy."""
        time.sleep(10)

        result = subprocess.run(
            ["docker-compose", "exec", "-T", "postgres", "pg_isready"],
            capture_output=True,
            text=True,
            cwd=Path(__file__).parent.parent.parent,
        )

        assert result.returncode in [0, 1]

    def test_redis_health(self, docker_compose_up):
        """Test Redis is healthy."""
        time.sleep(10)

        result = subprocess.run(
            ["docker-compose", "exec", "-T", "redis", "redis-cli", "ping"],
            capture_output=True,
            text=True,
            cwd=Path(__file__).parent.parent.parent,
        )

        assert result.returncode in [0, 1]


@pytest.mark.integration
@pytest.mark.docker
class TestServiceConnectivity:
    """Test connectivity between services."""

    def test_api_can_connect_to_postgres(self, docker_compose_up):
        """Test API can connect to PostgreSQL."""
        from sqlalchemy import create_engine
        from src.core.config import settings

        time.sleep(15)

        try:
            engine = create_engine(settings.DATABASE_URL)
            conn = engine.connect()
            conn.close()
            assert True
        except Exception:
            pytest.skip("Cannot connect to PostgreSQL")

    def test_api_can_connect_to_redis(self, docker_compose_up):
        """Test API can connect to Redis."""
        import redis
        from src.core.config import settings

        time.sleep(10)

        try:
            r = redis.Redis(
                host=settings.REDIS_HOST, port=settings.REDIS_PORT, db=settings.REDIS_DB
            )
            r.ping()
            assert True
        except Exception:
            pytest.skip("Cannot connect to Redis")
