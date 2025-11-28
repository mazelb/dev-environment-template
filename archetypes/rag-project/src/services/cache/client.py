"""Redis cache client."""

import json
from typing import Any, Optional

import redis
from src.config import Settings


class CacheClient:
    """Redis cache client for caching API responses and data."""

    def __init__(self, settings: Settings):
        """
        Initialize Redis cache client.

        Args:
            settings: Application settings
        """
        self.redis_client = redis.Redis(
            host=settings.REDIS__HOST,
            port=settings.REDIS__PORT,
            db=settings.REDIS__DB,
            password=settings.REDIS__PASSWORD,
            decode_responses=True,
        )
        self.default_ttl = 3600  # 1 hour

    def get(self, key: str) -> Optional[Any]:
        """
        Get value from cache.

        Args:
            key: Cache key

        Returns:
            Cached value or None if not found
        """
        try:
            value = self.redis_client.get(key)
            if value:
                return json.loads(value)
            return None
        except Exception as e:
            print(f"Cache get error: {e}")
            return None

    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> bool:
        """
        Set value in cache.

        Args:
            key: Cache key
            value: Value to cache
            ttl: Time to live in seconds (default: 1 hour)

        Returns:
            True if successful, False otherwise
        """
        try:
            ttl = ttl or self.default_ttl
            serialized = json.dumps(value)
            self.redis_client.setex(key, ttl, serialized)
            return True
        except Exception as e:
            print(f"Cache set error: {e}")
            return False

    def delete(self, key: str) -> bool:
        """
        Delete value from cache.

        Args:
            key: Cache key

        Returns:
            True if successful, False otherwise
        """
        try:
            self.redis_client.delete(key)
            return True
        except Exception as e:
            print(f"Cache delete error: {e}")
            return False

    def exists(self, key: str) -> bool:
        """
        Check if key exists in cache.

        Args:
            key: Cache key

        Returns:
            True if exists, False otherwise
        """
        try:
            return self.redis_client.exists(key) > 0
        except Exception as e:
            print(f"Cache exists error: {e}")
            return False

    def clear(self) -> bool:
        """
        Clear all cache entries.

        Returns:
            True if successful, False otherwise
        """
        try:
            self.redis_client.flushdb()
            return True
        except Exception as e:
            print(f"Cache clear error: {e}")
            return False

    def health_check(self) -> bool:
        """
        Check Redis connection health.

        Returns:
            True if healthy, False otherwise
        """
        try:
            return self.redis_client.ping()
        except Exception:
            return False
            return False
