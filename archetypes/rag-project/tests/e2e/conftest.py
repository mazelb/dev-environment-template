"""Shared fixtures for E2E tests."""

import pytest


@pytest.fixture
def test_id():
    """Generate unique test ID."""
    import time

    return int(time.time() * 1000)


@pytest.fixture
async def test_client():
    """Create test client for E2E tests."""
    from httpx import AsyncClient
    from src.main import app

    async with AsyncClient(app=app, base_url="http://testserver") as client:
        yield client


@pytest.fixture
async def auth_token(test_client):
    """Get authentication token for protected endpoints."""
    # Register and login test user
    user_data = {
        "username": "test_user_e2e",
        "email": "testuser_e2e@test.com",
        "password": "TestPass123!",
    }

    # Try to register (may already exist)
    await test_client.post("/api/v1/auth/register", json=user_data)

    # Login
    login_response = await test_client.post(
        "/api/v1/auth/login",
        json={"username": user_data["username"], "password": user_data["password"]},
    )

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None
