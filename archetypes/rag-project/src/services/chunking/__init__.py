"""Chunking service module."""

from src.services.chunking.factory import make_chunking_service
from src.services.chunking.service import Chunk, ChunkingService

__all__ = ["ChunkingService", "Chunk", "make_chunking_service"]
