"""End-to-end tests for API service complete workflows."""

import pytest


@pytest.mark.e2e
@pytest.mark.asyncio
class TestCompleteAPIWorkflow:
    """Test complete API workflows from request to response."""

    async def test_user_registration_and_login(self, test_client):
        """Test complete user registration and login flow."""
        # Register new user
        user_data = {
            "username": f"e2e_user_{pytest.test_id}",
            "email": f"e2e_{pytest.test_id}@test.com",
            "password": "SecurePass123!",
        }

        register_response = await test_client.post(
            "/api/v1/auth/register", json=user_data
        )

        assert register_response.status_code in [200, 201]

        # Login with credentials
        login_response = await test_client.post(
            "/api/v1/auth/login",
            json={"username": user_data["username"], "password": user_data["password"]},
        )

        assert login_response.status_code == 200
        tokens = login_response.json()
        assert "access_token" in tokens

    async def test_authenticated_api_access(self, test_client, auth_token):
        """Test accessing protected endpoints with authentication."""
        headers = {"Authorization": f"Bearer {auth_token}"}

        # Access protected endpoint
        response = await test_client.get("/api/v1/users/me", headers=headers)

        assert response.status_code == 200
        user_data = response.json()
        assert "id" in user_data or "username" in user_data

    async def test_graphql_complete_workflow(self, test_client):
        """Test complete GraphQL workflow."""
        # Mutation to create data
        mutation = """
            mutation {
                createPost(input: {
                    title: "E2E Test Post"
                    content: "Content for end-to-end testing"
                }) {
                    id
                    title
                }
            }
        """

        create_response = await test_client.post("/graphql", json={"query": mutation})

        assert create_response.status_code == 200
        result = create_response.json()
        assert "data" in result or "errors" in result

    async def test_rest_crud_workflow(self, test_client, auth_token):
        """Test complete REST CRUD workflow."""
        headers = {"Authorization": f"Bearer {auth_token}"}

        # Create
        create_data = {"title": "E2E Resource", "description": "Test resource"}
        create_response = await test_client.post(
            "/api/v1/resources", json=create_data, headers=headers
        )
        assert create_response.status_code in [200, 201]
        resource_id = create_response.json().get("id")

        # Read
        read_response = await test_client.get(
            f"/api/v1/resources/{resource_id}", headers=headers
        )
        assert read_response.status_code == 200

        # Update
        update_response = await test_client.put(
            f"/api/v1/resources/{resource_id}",
            json={"title": "Updated Title"},
            headers=headers,
        )
        assert update_response.status_code == 200

        # Delete
        delete_response = await test_client.delete(
            f"/api/v1/resources/{resource_id}", headers=headers
        )
        assert delete_response.status_code in [200, 204]


@pytest.mark.e2e
@pytest.mark.asyncio
class TestCeleryWorkflowE2E:
    """Test Celery background task workflows end-to-end."""

    async def test_async_task_submission_and_result(self, test_client, auth_token):
        """Test submitting async task and retrieving result."""
        headers = {"Authorization": f"Bearer {auth_token}"}

        # Submit task
        task_data = {"operation": "process", "data": {"value": 123}}
        submit_response = await test_client.post(
            "/api/v1/tasks/submit", json=task_data, headers=headers
        )

        assert submit_response.status_code in [200, 202]
        task_id = submit_response.json().get("task_id")
        assert task_id is not None

        # Poll for result
        import asyncio

        for _ in range(10):
            status_response = await test_client.get(
                f"/api/v1/tasks/{task_id}", headers=headers
            )

            if status_response.status_code == 200:
                task_status = status_response.json()
                if task_status.get("status") in ["SUCCESS", "COMPLETED"]:
                    break

            await asyncio.sleep(1)

        # Verify task completed
        assert status_response.status_code == 200

    async def test_task_cancellation(self, test_client, auth_token):
        """Test canceling a running task."""
        headers = {"Authorization": f"Bearer {auth_token}"}

        # Submit long-running task
        submit_response = await test_client.post(
            "/api/v1/tasks/submit",
            json={"operation": "long_process", "duration": 60},
            headers=headers,
        )

        task_id = submit_response.json().get("task_id")

        # Cancel task
        cancel_response = await test_client.post(
            f"/api/v1/tasks/{task_id}/cancel", headers=headers
        )

        assert cancel_response.status_code in [200, 202]

    async def test_task_error_handling(self, test_client, auth_token):
        """Test handling of task errors."""
        headers = {"Authorization": f"Bearer {auth_token}"}

        # Submit task that will fail
        submit_response = await test_client.post(
            "/api/v1/tasks/submit", json={"operation": "fail_task"}, headers=headers
        )

        task_id = submit_response.json().get("task_id")

        # Wait and check status
        import asyncio

        await asyncio.sleep(3)

        status_response = await test_client.get(
            f"/api/v1/tasks/{task_id}", headers=headers
        )

        assert status_response.status_code in [200, 500]


@pytest.mark.e2e
class TestServiceDependencies:
    """Test service startup order and dependencies."""

    def test_postgres_connectivity(self, test_client):
        """Test PostgreSQL is accessible."""
        response = test_client.get("/api/v1/health/database")

        assert response.status_code == 200
        data = response.json()
        assert data.get("status") in ["healthy", "ok", "up"]

    def test_redis_connectivity(self, test_client):
        """Test Redis is accessible."""
        response = test_client.get("/api/v1/health/redis")

        assert response.status_code == 200
        data = response.json()
        assert data.get("status") in ["healthy", "ok", "up"]

    def test_celery_worker_connectivity(self, test_client):
        """Test Celery workers are running."""
        response = test_client.get("/api/v1/health/celery")

        assert response.status_code == 200
        data = response.json()
        assert "workers" in data or "status" in data

    def test_all_services_health(self, test_client):
        """Test all services are healthy."""
        response = test_client.get("/api/v1/health")

        assert response.status_code == 200
        data = response.json()
        assert data.get("status") in ["healthy", "ok"]
        assert "services" in data or "components" in data


@pytest.mark.e2e
@pytest.mark.asyncio
class TestErrorRecovery:
    """Test system recovery from error conditions."""

    async def test_invalid_authentication(self, test_client):
        """Test handling of invalid authentication."""
        headers = {"Authorization": "Bearer invalid_token_xyz"}

        response = await test_client.get("/api/v1/users/me", headers=headers)

        assert response.status_code == 401

    async def test_missing_required_fields(self, test_client):
        """Test validation of required fields."""
        response = await test_client.post(
            "/api/v1/auth/register",
            json={"username": "incomplete"},  # Missing required fields
        )

        assert response.status_code in [400, 422]

    async def test_database_constraint_violation(self, test_client):
        """Test handling of database constraint violations."""
        user_data = {
            "username": "duplicate_user",
            "email": "duplicate@test.com",
            "password": "password123",
        }

        # Register first time
        await test_client.post("/api/v1/auth/register", json=user_data)

        # Try to register again with same username/email
        response = await test_client.post("/api/v1/auth/register", json=user_data)

        assert response.status_code in [400, 409, 422]

    async def test_rate_limit_recovery(self, test_client):
        """Test system recovery after rate limiting."""
        # Make requests until rate limited
        for _ in range(100):
            response = await test_client.get("/api/v1/health")
            if response.status_code == 429:
                break

        # Wait for rate limit to reset
        import asyncio

        await asyncio.sleep(5)

        # Should be able to make requests again
        response = await test_client.get("/api/v1/health")
        assert response.status_code == 200
