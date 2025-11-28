"""Pytest configuration and shared fixtures for API service tests."""

import os
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


@pytest.fixture(scope="session")
def test_settings():
    """Create test settings with overrides."""
    os.environ["ENVIRONMENT"] = "test"
    os.environ["DEBUG"] = "false"
    os.environ["DATABASE_URL"] = "sqlite:///./test_api.db"
    os.environ["SECRET_KEY"] = "test_secret_key_for_testing_only"
    os.environ["REDIS_HOST"] = "localhost"
    os.environ["REDIS_PORT"] = "6379"
    os.environ["REDIS_DB"] = "2"

    from src.core.config import settings

    return settings


@pytest.fixture(scope="function")
def client(test_settings):
    """Create a test client for the FastAPI app."""
    from src.main import app

    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture(scope="function")
def auth_headers(client):
    """Create authentication headers for testing."""
    # Create a test user and get token
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "password": "testpassword123",
            "username": "testuser",
        },
    )

    if response.status_code == 201:
        # Login to get token
        login_response = client.post(
            "/api/v1/auth/login",
            data={"username": "test@example.com", "password": "testpassword123"},
        )

        if login_response.status_code == 200:
            token = login_response.json()["access_token"]
            return {"Authorization": f"Bearer {token}"}

    # Return empty headers if auth fails
    return {}


@pytest.fixture(scope="module")
def docker_compose_up():
    """Start Docker Compose services for integration tests."""
    import subprocess

    # Check if docker-compose is available
    try:
        subprocess.run(["docker-compose", "version"], check=True, capture_output=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pytest.skip("Docker Compose not available")

    # Start services
    subprocess.run(
        ["docker-compose", "up", "-d"], check=True, cwd=Path(__file__).parent.parent
    )

    # Wait for services to be healthy
    import time

    time.sleep(20)

    yield

    # Cleanup
    subprocess.run(
        ["docker-compose", "down", "-v"], check=False, cwd=Path(__file__).parent.parent
    )


@pytest.fixture(autouse=True)
def cleanup_db():
    """Clean up test database after each test."""
    yield

    # Remove test database file if it exists
    if os.path.exists("./test_api.db"):
        os.remove("./test_api.db")
