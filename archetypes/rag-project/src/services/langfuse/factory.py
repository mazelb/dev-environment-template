"""Factory for creating Langfuse client instances."""

import logging
from typing import Optional

from src.config import Settings
from .client import LangfuseClient

logger = logging.getLogger(__name__)


def make_langfuse_client(settings: Settings) -> Optional[LangfuseClient]:
    """
    Create a Langfuse client instance from settings.

    Args:
        settings: Application settings

    Returns:
        LangfuseClient instance or None if creation fails
    """
    try:
        # Check if Langfuse is enabled
        enabled = getattr(settings, "langfuse_enabled", True)

        if not enabled:
            logger.info("Langfuse tracing is disabled")
            return LangfuseClient(
                public_key="",
                secret_key="",
                enabled=False,
            )

        # Get Langfuse credentials
        public_key = getattr(settings, "langfuse_public_key", "")
        secret_key = getattr(settings, "langfuse_secret_key", "")
        host = getattr(settings, "langfuse_host", "http://langfuse:3000")

        if not public_key or not secret_key:
            logger.warning("Langfuse credentials not provided, tracing disabled")
            return LangfuseClient(
                public_key="",
                secret_key="",
                enabled=False,
            )

        client = LangfuseClient(
            public_key=public_key,
            secret_key=secret_key,
            host=host,
            enabled=True,
        )

        # Verify connection
        if not client.health_check():
            logger.warning("Langfuse health check failed, continuing without tracing")

        logger.info("Langfuse client created successfully")
        return client
    except Exception as e:
        logger.error(f"Failed to create Langfuse client: {e}")
        # Return disabled client to allow application to continue
        return LangfuseClient(
            public_key="",
            secret_key="",
            enabled=False,
        )
