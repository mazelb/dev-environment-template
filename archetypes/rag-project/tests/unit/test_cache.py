"""Unit tests for cache service."""

import json

import pytest
from src.services.cache.client import RedisCache


@pytest.mark.unit
class TestRedisCache:
    """Test Redis cache client."""

    def test_set_and_get_string(self, mock_redis):
        """Test setting and getting string values."""
        cache = RedisCache(mock_redis)

        # Mock return value
        mock_redis.get.return_value = b'"test_value"'

        # Set value
        cache.set("test_key", "test_value")
        mock_redis.set.assert_called_once()

        # Get value
        value = cache.get("test_key")
        assert value == "test_value"

    def test_set_and_get_dict(self, mock_redis):
        """Test setting and getting dictionary values."""
        cache = RedisCache(mock_redis)
        test_dict = {"key": "value", "number": 42}

        # Mock return value
        mock_redis.get.return_value = json.dumps(test_dict).encode()

        # Set and get
        cache.set("test_key", test_dict)
        value = cache.get("test_key")

        assert value == test_dict

    def test_set_with_ttl(self, mock_redis):
        """Test setting value with TTL."""
        cache = RedisCache(mock_redis)

        cache.set("test_key", "test_value", ttl=300)

        # Verify TTL was set
        call_args = mock_redis.set.call_args
        assert call_args is not None

    def test_delete(self, mock_redis):
        """Test deleting a key."""
        cache = RedisCache(mock_redis)
        mock_redis.delete.return_value = 1

        result = cache.delete("test_key")

        assert result is True
        mock_redis.delete.assert_called_once_with("test_key")

    def test_exists(self, mock_redis):
        """Test checking if key exists."""
        cache = RedisCache(mock_redis)
        mock_redis.exists.return_value = 1

        result = cache.exists("test_key")

        assert result is True
        mock_redis.exists.assert_called_once_with("test_key")

    def test_clear(self, mock_redis):
        """Test clearing all keys."""
        cache = RedisCache(mock_redis)
        mock_redis.flushdb.return_value = True

        cache.clear()

        mock_redis.flushdb.assert_called_once()

    def test_health_check(self, mock_redis):
        """Test health check."""
        cache = RedisCache(mock_redis)
        mock_redis.ping.return_value = True

        result = cache.health_check()

        assert result is True
        mock_redis.ping.assert_called_once()

    def test_get_nonexistent_key(self, mock_redis):
        """Test getting non-existent key returns None."""
        cache = RedisCache(mock_redis)
        mock_redis.get.return_value = None

        result = cache.get("nonexistent_key")

        assert result is None

    def test_json_serialization_error(self, mock_redis):
        """Test handling JSON serialization error."""
        cache = RedisCache(mock_redis)

        # Create an object that can't be serialized
        class NonSerializable:
            pass

        # Should handle error gracefully
        with pytest.raises(TypeError):
            cache.set("test_key", NonSerializable())
