"""Factory for creating chunking service instances."""

from src.config import Settings
from src.services.chunking.service import ChunkingService


def make_chunking_service(settings: Settings) -> ChunkingService:
    """Create a chunking service from settings.

    Args:
        settings: Application settings

    Returns:
        Configured chunking service
    """
    return ChunkingService(
        chunk_size=settings.CHUNKING_CHUNK_SIZE,
        overlap_size=settings.CHUNKING_OVERLAP_SIZE,
        separator=settings.CHUNKING_SEPARATOR,
    )
