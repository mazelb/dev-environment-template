"""Unit tests for embedding service."""

from unittest.mock import MagicMock, patch

import numpy as np
import pytest
from src.services.embeddings.service import EmbeddingService


@pytest.mark.unit
class TestEmbeddingService:
    """Test embedding service."""

    def test_service_initialization(self, test_settings):
        """Test service initializes correctly."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)

            assert service is not None
            assert service.model_name == test_settings.embedding.model_name

    def test_embed_text(self, test_settings):
        """Test embedding a single text."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.encode.return_value = np.array([0.1, 0.2, 0.3])
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)
            embedding = service.embed_text("Test text")

            assert len(embedding) == 3
            assert embedding[0] == 0.1

    def test_embed_texts_batch(self, test_settings):
        """Test embedding multiple texts."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.encode.return_value = np.array(
                [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]]
            )
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)
            embeddings = service.embed_texts(["Text 1", "Text 2"])

            assert len(embeddings) == 2
            assert len(embeddings[0]) == 3

    def test_embed_query(self, test_settings):
        """Test embedding a query."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.encode.return_value = np.array([0.1, 0.2, 0.3])
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)
            embedding = service.embed_query("Test query")

            assert len(embedding) == 3

    def test_embed_documents(self, test_settings):
        """Test embedding documents."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.encode.return_value = np.array([[0.1, 0.2, 0.3]])
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)
            embeddings = service.embed_documents(["Document text"])

            assert len(embeddings) == 1

    def test_similarity(self, test_settings):
        """Test similarity calculation."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)

            # Same vectors should have similarity of 1.0
            vec = [1.0, 0.0, 0.0]
            similarity = service.similarity(vec, vec)

            assert abs(similarity - 1.0) < 0.01

    def test_get_dimension(self, test_settings):
        """Test getting embedding dimension."""
        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            service = EmbeddingService(test_settings)
            dim = service.get_dimension()

            assert dim == 384
