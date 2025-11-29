"""Integration tests for Redis cache operations."""

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestCacheIntegration:
    """Test Redis caching functionality."""

    async def test_cache_set_and_get(self, redis_client):
        """Test setting and retrieving cache values."""
        key = "test:key:1"
        value = {"data": "test value", "count": 42}

        # Set cache
        await redis_client.set(key, value, ttl=300)

        # Get cache
        cached_value = await redis_client.get(key)

        assert cached_value is not None
        assert cached_value == value

    async def test_cache_expiration(self, redis_client):
        """Test cache TTL expiration."""
        key = "test:expiring:key"
        value = "temporary data"

        # Set with short TTL
        await redis_client.set(key, value, ttl=1)

        # Verify exists
        assert await redis_client.exists(key)

        # Wait for expiration
        import asyncio

        await asyncio.sleep(2)

        # Should be expired
        cached = await redis_client.get(key)
        assert cached is None

    async def test_cache_deletion(self, redis_client):
        """Test cache deletion."""
        key = "test:delete:key"
        value = "to be deleted"

        await redis_client.set(key, value)
        assert await redis_client.exists(key)

        # Delete
        await redis_client.delete(key)
        assert not await redis_client.exists(key)

    async def test_cache_pattern_delete(self, redis_client):
        """Test deleting multiple keys by pattern."""
        # Set multiple keys
        for i in range(5):
            await redis_client.set(f"test:pattern:{i}", f"value{i}")

        # Delete by pattern
        deleted = await redis_client.delete_pattern("test:pattern:*")

        assert deleted >= 5

    async def test_cache_hit_miss_scenario(self, redis_client):
        """Test cache hit and miss scenarios."""
        key = "test:hit:miss"

        # Cache miss
        result = await redis_client.get(key)
        assert result is None

        # Set value
        await redis_client.set(key, "cached data")

        # Cache hit
        result = await redis_client.get(key)
        assert result == "cached data"


@pytest.mark.integration
@pytest.mark.asyncio
class TestRateLimiting:
    """Test rate limiting with Redis."""

    async def test_rate_limit_enforcement(self, redis_client):
        """Test rate limiting for API calls."""
        key = "rate:limit:test:user"
        max_requests = 5
        window = 10  # seconds

        # Make requests up to limit
        for i in range(max_requests):
            allowed = await redis_client.check_rate_limit(key, max_requests, window)
            assert allowed is True

        # Next request should be rate limited
        allowed = await redis_client.check_rate_limit(key, max_requests, window)
        assert allowed is False

    async def test_rate_limit_reset(self, redis_client):
        """Test rate limit reset after window expires."""
        key = "rate:limit:reset:test"
        max_requests = 3
        window = 2  # seconds

        # Exhaust limit
        for _ in range(max_requests):
            await redis_client.check_rate_limit(key, max_requests, window)

        # Should be limited
        assert not await redis_client.check_rate_limit(key, max_requests, window)

        # Wait for window to expire
        import asyncio

        await asyncio.sleep(3)

        # Should be allowed again
        assert await redis_client.check_rate_limit(key, max_requests, window)
