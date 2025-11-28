"""Unit tests for OpenSearch client."""

from unittest.mock import patch

import pytest
from src.services.opensearch.client import OpenSearchClient


@pytest.mark.unit
class TestOpenSearchClient:
    """Test OpenSearch client."""

    def test_client_initialization(self, test_settings, mock_opensearch_client):
        """Test client initializes correctly."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)

            assert client is not None
            assert client.settings == test_settings

    def test_health_check(self, test_settings, mock_opensearch_client):
        """Test health check."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            mock_opensearch_client.cluster.health.return_value = {"status": "green"}

            result = client.health_check()

            assert result is True

    def test_create_index(self, test_settings, mock_opensearch_client):
        """Test creating an index."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            mock_opensearch_client.indices.exists.return_value = False
            mock_opensearch_client.indices.create.return_value = {"acknowledged": True}

            result = client.create_index("test_index")

            assert result is True
            mock_opensearch_client.indices.create.assert_called_once()

    def test_delete_index(self, test_settings, mock_opensearch_client):
        """Test deleting an index."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            mock_opensearch_client.indices.delete.return_value = {"acknowledged": True}

            result = client.delete_index("test_index")

            assert result is True

    def test_index_document(self, test_settings, mock_opensearch_client):
        """Test indexing a document."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            doc = {"content": "test content", "embedding": [0.1] * 384}

            result = client.index_document("test_index", doc, "doc_id")

            assert result == "test_id"

    def test_search_keyword(
        self, test_settings, mock_opensearch_client, sample_documents
    ):
        """Test keyword search."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            mock_opensearch_client.search.return_value = {
                "hits": {
                    "total": {"value": 1},
                    "hits": [
                        {"_id": "doc1", "_score": 1.5, "_source": sample_documents[0]}
                    ],
                }
            }

            results = client.search_keyword("test_index", "AI", size=10)

            assert len(results) == 1
            assert results[0]["_id"] == "doc1"

    def test_search_vector(self, test_settings, mock_opensearch_client):
        """Test vector search."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            query_vector = [0.1] * 384

            mock_opensearch_client.search.return_value = {
                "hits": {"total": {"value": 0}, "hits": []}
            }

            results = client.search_vector("test_index", query_vector, k=5)

            assert isinstance(results, list)

    def test_hybrid_search(self, test_settings, mock_opensearch_client):
        """Test hybrid search."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            query_vector = [0.1] * 384

            mock_opensearch_client.search.return_value = {
                "hits": {"total": {"value": 0}, "hits": []}
            }

            results = client.hybrid_search("test_index", "AI", query_vector, size=10)

            assert isinstance(results, list)

    def test_count_documents(self, test_settings, mock_opensearch_client):
        """Test counting documents."""
        with patch(
            "src.services.opensearch.client.OpenSearch",
            return_value=mock_opensearch_client,
        ):
            client = OpenSearchClient(test_settings)
            mock_opensearch_client.count.return_value = {"count": 42}

            count = client.count_documents("test_index")

            assert count == 42
