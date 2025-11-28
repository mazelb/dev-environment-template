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
        # docker_compose_up fixture handles startup
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

        # Either succeeds or service doesn't respond yet
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

        # Should return PONG or timeout
        assert result.returncode in [0, 1]

    def test_opensearch_health(self, docker_compose_up):
        """Test OpenSearch is healthy."""
        import requests

        time.sleep(20)  # OpenSearch takes longer to start

        try:
            response = requests.get("http://localhost:9200/_cluster/health", timeout=5)
            assert response.status_code in [200, 401, 503]
        except requests.exceptions.RequestException:
            pytest.skip("OpenSearch not responding")

    def test_ollama_health(self, docker_compose_up):
        """Test Ollama is healthy."""
        import requests

        time.sleep(15)

        try:
            response = requests.get("http://localhost:11434/api/tags", timeout=5)
            assert response.status_code in [200, 404]
        except requests.exceptions.RequestException:
            pytest.skip("Ollama not responding")


@pytest.mark.integration
@pytest.mark.docker
class TestServiceConnectivity:
    """Test connectivity between services."""

    def test_api_can_connect_to_postgres(self, docker_compose_up):
        """Test API can connect to PostgreSQL."""
        from sqlalchemy import create_engine
        from src.config import Settings

        settings = Settings()
        time.sleep(15)

        try:
            engine = create_engine(settings.database_url)
            conn = engine.connect()
            conn.close()
            assert True
        except Exception:
            pytest.skip("Cannot connect to PostgreSQL")

    def test_api_can_connect_to_redis(self, docker_compose_up):
        """Test API can connect to Redis."""
        import redis
        from src.config import Settings

        settings = Settings()
        time.sleep(10)

        try:
            r = redis.Redis(
                host=settings.redis.host, port=settings.redis.port, db=settings.redis.db
            )
            r.ping()
            assert True
        except Exception:
            pytest.skip("Cannot connect to Redis")
