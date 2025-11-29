"""Integration tests for OpenSearch operations."""

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestOpenSearchIntegration:
    """Test OpenSearch indexing and search operations."""

    async def test_document_indexing_flow(self, opensearch_client, test_settings):
        """Test complete document indexing flow."""

        # Create test document
        doc = {
            "title": "Test Document",
            "content": "This is a test document for integration testing.",
            "metadata": {"source": "test", "author": "pytest"},
        }

        # Index document
        result = await opensearch_client.index_document(
            index_name=test_settings.opensearch.index_name, document=doc
        )

        assert result is not None
        assert "result" in result or "_id" in result

    async def test_hybrid_search_flow(self, opensearch_client, test_settings):
        """Test hybrid search with BM25 + vector similarity."""

        # Perform hybrid search
        query = "test document"
        results = await opensearch_client.hybrid_search(
            index_name=test_settings.opensearch.index_name,
            query_text=query,
            vector=[0.1] * 384,  # Mock embedding
            size=10,
        )

        assert results is not None
        assert isinstance(results, (list, dict))

    async def test_vector_search(self, opensearch_client, test_settings):
        """Test k-NN vector search."""
        # Create mock embedding
        mock_embedding = [0.1] * 384

        # Search by vector
        results = await opensearch_client.vector_search(
            index_name=test_settings.opensearch.index_name, vector=mock_embedding, k=5
        )

        assert results is not None

    async def test_bm25_keyword_search(self, opensearch_client, test_settings):
        """Test BM25 keyword search."""
        query = "test integration"

        results = await opensearch_client.keyword_search(
            index_name=test_settings.opensearch.index_name, query_text=query, size=10
        )

        assert results is not None
        assert isinstance(results, (list, dict))

    async def test_filtered_search(self, opensearch_client, test_settings):
        """Test search with metadata filters."""
        query = "document"
        filters = {"metadata.source": "test"}

        results = await opensearch_client.search_with_filters(
            index_name=test_settings.opensearch.index_name,
            query_text=query,
            filters=filters,
        )

        assert results is not None


@pytest.mark.integration
@pytest.mark.asyncio
class TestEmbeddingGeneration:
    """Test embedding generation and storage."""

    async def test_generate_embeddings(self, embeddings_service):
        """Test embedding generation for text."""
        texts = [
            "This is the first test document.",
            "This is the second test document.",
        ]

        embeddings = await embeddings_service.generate_embeddings(texts)

        assert embeddings is not None
        assert len(embeddings) == len(texts)
        assert all(isinstance(emb, list) for emb in embeddings)
        assert all(len(emb) > 0 for emb in embeddings)

    async def test_batch_embedding_generation(self, embeddings_service):
        """Test batch embedding generation."""
        texts = [f"Document {i}" for i in range(10)]

        embeddings = await embeddings_service.generate_embeddings_batch(
            texts, batch_size=5
        )

        assert embeddings is not None
        assert len(embeddings) == len(texts)

    async def test_embedding_dimensions(self, embeddings_service):
        """Test embedding dimensions are consistent."""
        text = "Test document for dimension check"

        embedding = await embeddings_service.generate_embedding(text)

        assert len(embedding) == embeddings_service.dimension
