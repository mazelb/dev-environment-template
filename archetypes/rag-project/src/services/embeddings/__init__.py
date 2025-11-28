"""Embeddings service module."""

from src.services.embeddings.factory import make_embedding_service
from src.services.embeddings.service import EmbeddingService

__all__ = ["EmbeddingService", "make_embedding_service"]
