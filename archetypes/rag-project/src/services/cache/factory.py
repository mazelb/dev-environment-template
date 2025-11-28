"""Cache service factory."""

from src.config import Settings
from src.services.cache.client import CacheClient


def make_cache_client(settings: Settings) -> CacheClient:
    """
    Factory function to create cache client.

    Args:
        settings: Application settings

    Returns:
        CacheClient: Redis cache client instance
    """
    return CacheClient(settings)
