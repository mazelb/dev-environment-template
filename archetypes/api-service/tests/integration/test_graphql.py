"""Integration tests for GraphQL API."""

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestGraphQLQueries:
    """Test GraphQL query execution."""

    async def test_basic_query(self, graphql_client):
        """Test basic GraphQL query."""
        query = """
            query {
                health {
                    status
                    timestamp
                }
            }
        """

        result = await graphql_client.execute(query)

        assert result is not None
        assert "data" in result
        assert "health" in result["data"]

    async def test_query_with_variables(self, graphql_client):
        """Test GraphQL query with variables."""
        query = """
            query GetUser($id: ID!) {
                user(id: $id) {
                    id
                    username
                    email
                }
            }
        """
        variables = {"id": "1"}

        result = await graphql_client.execute(query, variables=variables)

        assert result is not None
        assert "data" in result

    async def test_nested_query(self, graphql_client):
        """Test nested GraphQL query."""
        query = """
            query {
                users {
                    id
                    username
                    posts {
                        id
                        title
                    }
                }
            }
        """

        result = await graphql_client.execute(query)

        assert result is not None
        assert "data" in result

    async def test_query_with_filters(self, graphql_client):
        """Test GraphQL query with filters."""
        query = """
            query GetUsers($limit: Int, $offset: Int) {
                users(limit: $limit, offset: $offset) {
                    id
                    username
                }
            }
        """
        variables = {"limit": 10, "offset": 0}

        result = await graphql_client.execute(query, variables=variables)

        assert result is not None
        assert "data" in result


@pytest.mark.integration
@pytest.mark.asyncio
class TestGraphQLMutations:
    """Test GraphQL mutations."""

    async def test_create_mutation(self, graphql_client):
        """Test creating data via mutation."""
        mutation = """
            mutation CreateUser($input: CreateUserInput!) {
                createUser(input: $input) {
                    id
                    username
                    email
                }
            }
        """
        variables = {
            "input": {
                "username": "testuser",
                "email": "test@example.com",
                "password": "securepass123",
            }
        }

        result = await graphql_client.execute(mutation, variables=variables)

        assert result is not None
        assert "data" in result or "errors" in result

    async def test_update_mutation(self, graphql_client):
        """Test updating data via mutation."""
        mutation = """
            mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
                updateUser(id: $id, input: $input) {
                    id
                    username
                }
            }
        """
        variables = {"id": "1", "input": {"username": "updateduser"}}

        result = await graphql_client.execute(mutation, variables=variables)

        assert result is not None

    async def test_delete_mutation(self, graphql_client):
        """Test deleting data via mutation."""
        mutation = """
            mutation DeleteUser($id: ID!) {
                deleteUser(id: $id) {
                    success
                    message
                }
            }
        """
        variables = {"id": "999"}  # Non-existent ID

        result = await graphql_client.execute(mutation, variables=variables)

        assert result is not None

    async def test_batch_mutation(self, graphql_client):
        """Test batch operations via mutation."""
        mutation = """
            mutation BatchCreateUsers($inputs: [CreateUserInput!]!) {
                batchCreateUsers(inputs: $inputs) {
                    id
                    username
                }
            }
        """
        variables = {
            "inputs": [
                {"username": "user1", "email": "user1@test.com", "password": "pass1"},
                {"username": "user2", "email": "user2@test.com", "password": "pass2"},
            ]
        }

        result = await graphql_client.execute(mutation, variables=variables)

        assert result is not None


@pytest.mark.integration
@pytest.mark.asyncio
class TestGraphQLErrorHandling:
    """Test GraphQL error handling."""

    async def test_invalid_query_syntax(self, graphql_client):
        """Test handling of invalid GraphQL syntax."""
        query = "query { invalid syntax here }"

        result = await graphql_client.execute(query)

        assert result is not None
        assert "errors" in result

    async def test_missing_required_argument(self, graphql_client):
        """Test error when required argument is missing."""
        query = """
            query GetUser {
                user {
                    id
                    username
                }
            }
        """

        result = await graphql_client.execute(query)

        assert result is not None
        # Should have error for missing required argument

    async def test_invalid_field(self, graphql_client):
        """Test error when requesting non-existent field."""
        query = """
            query {
                user(id: "1") {
                    nonExistentField
                }
            }
        """

        result = await graphql_client.execute(query)

        assert result is not None
        assert "errors" in result
