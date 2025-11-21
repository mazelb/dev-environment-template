"""
Rate limiting middleware using SlowAPI and Redis.
"""
from slowapi import Limiter
from slowapi.util import get_remote_address

from src.core.config import settings

# Create limiter instance
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[f"{settings.RATE_LIMIT_PER_MINUTE}/minute"],
    storage_uri=f"redis://{settings.REDIS_HOST}:{settings.REDIS_PORT}",
)
