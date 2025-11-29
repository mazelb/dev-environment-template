"""Shared fixtures for E2E tests."""

import pytest


@pytest.fixture
def test_id():
    """Generate unique test ID."""
    import time

    return int(time.time() * 1000)


@pytest.fixture
def test_client():
    """Create test client for E2E tests."""
    from fastapi.testclient import TestClient
    from src.main import app

    client = TestClient(app)
    yield client
    client.close()


@pytest.fixture
async def async_test_client():
    """Create async test client for E2E tests."""
    from httpx import AsyncClient
    from src.main import app

    async with AsyncClient(app=app, base_url="http://testserver") as client:
        yield client


@pytest.fixture
def auth_token(test_client):
    """Get authentication token for protected endpoints."""
    # Register and login test user
    user_data = {
        "username": "test_user_e2e",
        "email": "testuser_e2e@test.com",
        "password": "TestPass123!",
    }

    # Try to register (may already exist)
    test_client.post("/api/v1/auth/register", json=user_data)

    # Login
    login_response = test_client.post(
        "/api/v1/auth/login",
        json={"username": user_data["username"], "password": user_data["password"]},
    )

    if login_response.status_code == 200:
        return login_response.json()["access_token"]
    return None


@pytest.fixture
def celery_app():
    """Get Celery app instance for testing."""
    from src.celery_app.celery import celery_app

    return celery_app


@pytest.fixture
def flower_client():
    """Create client for Flower monitoring API."""
    import requests

    # Flower typically runs on port 5555
    return requests.Session()


@pytest.fixture
def graphql_client(test_client):
    """Create GraphQL test client."""

    class GraphQLClient:
        def __init__(self, client):
            self.client = client

        def execute(self, query, variables=None):
            response = self.client.post(
                "/graphql", json={"query": query, "variables": variables}
            )
            return response.json()

    return GraphQLClient(test_client)


@pytest.fixture
async def async_graphql_client(async_test_client):
    """Create async GraphQL test client."""

    class AsyncGraphQLClient:
        def __init__(self, client):
            self.client = client

        async def execute(self, query, variables=None):
            response = await self.client.post(
                "/graphql", json={"query": query, "variables": variables}
            )
            return response.json()

    return AsyncGraphQLClient(async_test_client)
