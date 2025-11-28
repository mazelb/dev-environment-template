"""Factory for creating embedding service instances."""

from src.config import Settings
from src.services.embeddings.service import EmbeddingService


def make_embedding_service(settings: Settings) -> EmbeddingService:
    """Create an embedding service from settings.

    Args:
        settings: Application settings

    Returns:
        Configured embedding service
    """
    return EmbeddingService(
        model_name=settings.EMBEDDING_MODEL, device=settings.EMBEDDING_DEVICE
    )
