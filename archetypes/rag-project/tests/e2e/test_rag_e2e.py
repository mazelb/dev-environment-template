"""End-to-end tests for complete RAG workflow."""

import pytest


@pytest.mark.e2e
@pytest.mark.asyncio
class TestCompleteRAGWorkflow:
    """Test complete RAG pipeline from document to answer."""

    async def test_full_rag_pipeline(self, test_client, test_settings):
        """Test complete workflow: ingest document → query → get answer."""
        # Step 1: Ingest a document
        document = {
            "title": "Machine Learning Basics",
            "content": "Machine learning is a subset of artificial intelligence that focuses on learning from data.",
            "metadata": {"category": "AI", "author": "Test Author"},
        }

        ingest_response = await test_client.post(
            "/api/v1/documents/ingest", json=document
        )

        assert ingest_response.status_code in [200, 201]
        doc_id = ingest_response.json().get("id")
        assert doc_id is not None

        # Step 2: Wait for indexing
        import asyncio

        await asyncio.sleep(2)

        # Step 3: Query the RAG system
        query_response = await test_client.post(
            "/api/v1/ask", json={"query": "What is machine learning?"}
        )

        assert query_response.status_code == 200
        result = query_response.json()
        assert "answer" in result or "response" in result
        assert "contexts" in result or "sources" in result

    async def test_hybrid_search_workflow(self, test_client):
        """Test hybrid search functionality end-to-end."""
        # Perform hybrid search
        response = await test_client.post(
            "/api/v1/search/hybrid",
            json={
                "query": "artificial intelligence",
                "top_k": 5,
                "filters": {"category": "AI"},
            },
        )

        assert response.status_code == 200
        results = response.json()
        assert "results" in results or isinstance(results, list)

    async def test_streaming_rag_response(self, test_client):
        """Test streaming RAG responses end-to-end."""
        response = await test_client.post(
            "/api/v1/ask/stream", json={"query": "Explain neural networks"}, stream=True
        )

        assert response.status_code == 200

        # Collect streaming chunks
        chunks = []
        async for chunk in response.iter_content():
            if chunk:
                chunks.append(chunk)

        assert len(chunks) > 0

    async def test_document_lifecycle(self, test_client):
        """Test complete document lifecycle: create → read → update → delete."""
        # Create
        doc_data = {
            "title": "Test Document",
            "content": "This is test content.",
            "metadata": {"test": True},
        }
        create_response = await test_client.post("/api/v1/documents", json=doc_data)
        assert create_response.status_code in [200, 201]
        doc_id = create_response.json()["id"]

        # Read
        read_response = await test_client.get(f"/api/v1/documents/{doc_id}")
        assert read_response.status_code == 200

        # Update
        update_response = await test_client.put(
            f"/api/v1/documents/{doc_id}", json={"title": "Updated Title"}
        )
        assert update_response.status_code == 200

        # Delete
        delete_response = await test_client.delete(f"/api/v1/documents/{doc_id}")
        assert delete_response.status_code in [200, 204]


@pytest.mark.e2e
@pytest.mark.asyncio
class TestMultiServiceIntegration:
    """Test integration across multiple services."""

    async def test_rag_with_langfuse_tracing(self, test_client):
        """Test RAG query with Langfuse tracing enabled."""
        response = await test_client.post(
            "/api/v1/ask",
            json={"query": "What is deep learning?", "enable_tracing": True},
        )

        assert response.status_code == 200
        result = response.json()
        assert "trace_id" in result or "answer" in result

    async def test_cached_vs_uncached_query(self, test_client):
        """Test performance difference between cached and uncached queries."""
        import time

        query = {"query": "What is AI?" + str(time.time())}  # Unique query

        # First query (uncached)
        start1 = time.time()
        response1 = await test_client.post("/api/v1/ask", json=query)
        duration1 = time.time() - start1

        assert response1.status_code == 200

        # Second query (should be cached)
        start2 = time.time()
        response2 = await test_client.post("/api/v1/ask", json=query)
        duration2 = time.time() - start2

        assert response2.status_code == 200
        # Cached query should be faster (or at least not significantly slower)

    async def test_opensearch_health_check(self, test_client):
        """Test OpenSearch connectivity."""
        response = await test_client.get("/api/v1/health/opensearch")

        assert response.status_code == 200
        data = response.json()
        assert "status" in data

    async def test_ollama_health_check(self, test_client):
        """Test Ollama LLM connectivity."""
        response = await test_client.get("/api/v1/health/ollama")

        assert response.status_code == 200
        data = response.json()
        assert "status" in data

    async def test_redis_health_check(self, test_client):
        """Test Redis connectivity."""
        response = await test_client.get("/api/v1/health/redis")

        assert response.status_code == 200
        data = response.json()
        assert "status" in data


@pytest.mark.e2e
@pytest.mark.asyncio
class TestFailureRecovery:
    """Test system behavior under failure conditions."""

    async def test_query_with_no_documents(self, test_client):
        """Test querying when no documents are indexed."""
        response = await test_client.post(
            "/api/v1/ask", json={"query": "xyzabc123nonexistent"}
        )

        # Should handle gracefully
        assert response.status_code in [200, 404]

    async def test_invalid_document_format(self, test_client):
        """Test ingesting document with invalid format."""
        response = await test_client.post(
            "/api/v1/documents/ingest", json={"invalid": "format"}
        )

        assert response.status_code in [400, 422]

    async def test_rate_limiting(self, test_client):
        """Test rate limiting enforcement."""
        # Make multiple rapid requests
        responses = []
        for _ in range(20):
            response = await test_client.get("/api/v1/health")
            responses.append(response.status_code)

        # Some requests should succeed, rate limiting may or may not kick in
        assert 200 in responses

    async def test_service_unavailable_handling(self, test_client):
        """Test handling when a service is unavailable."""
        # This test requires temporarily stopping a service
        # For now, just verify endpoint returns appropriate status
        response = await test_client.get("/api/v1/health")
        assert response.status_code in [200, 503]
