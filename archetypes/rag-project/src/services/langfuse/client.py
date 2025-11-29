"""Langfuse client for LLM observability and tracing."""

import logging
from contextlib import contextmanager
from typing import Any, Dict, List, Optional

from langfuse import Langfuse
from langfuse.decorators import langfuse_context, observe

logger = logging.getLogger(__name__)


class LangfuseClient:
    """Client for Langfuse LLM observability."""

    def __init__(
        self,
        public_key: str,
        secret_key: str,
        host: str = "http://langfuse:3000",
        enabled: bool = True,
    ):
        """
        Initialize Langfuse client.

        Args:
            public_key: Langfuse public key
            secret_key: Langfuse secret key
            host: Langfuse server URL
            enabled: Whether tracing is enabled
        """
        self.enabled = enabled
        self.client: Optional[Langfuse] = None

        if enabled:
            try:
                self.client = Langfuse(
                    public_key=public_key,
                    secret_key=secret_key,
                    host=host,
                )
                logger.info(f"Langfuse client initialized for {host}")
            except Exception as e:
                logger.error(f"Failed to initialize Langfuse: {e}")
                self.enabled = False

    def health_check(self) -> bool:
        """
        Check if Langfuse is enabled and responsive.

        Returns:
            True if healthy, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            # Try to flush (send any pending traces)
            self.client.flush()
            return True
        except Exception as e:
            logger.error(f"Langfuse health check failed: {e}")
            return False

    def create_trace(
        self,
        name: str,
        user_id: Optional[str] = None,
        session_id: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
        tags: Optional[List[str]] = None,
    ) -> Optional[Any]:
        """
        Create a new trace.

        Args:
            name: Name of the trace
            user_id: Optional user ID
            session_id: Optional session ID
            metadata: Optional metadata dictionary
            tags: Optional list of tags

        Returns:
            Trace object or None if disabled
        """
        if not self.enabled or not self.client:
            return None

        try:
            trace = self.client.trace(
                name=name,
                user_id=user_id,
                session_id=session_id,
                metadata=metadata or {},
                tags=tags or [],
            )
            return trace
        except Exception as e:
            logger.error(f"Failed to create trace: {e}")
            return None

    def score_trace(
        self,
        trace_id: str,
        name: str,
        value: float,
        comment: Optional[str] = None,
    ) -> bool:
        """
        Add a score to a trace.

        Args:
            trace_id: ID of the trace
            name: Name of the score (e.g., "accuracy", "relevance")
            value: Score value
            comment: Optional comment

        Returns:
            True if successful, False otherwise
        """
        if not self.enabled or not self.client:
            return False

        try:
            self.client.score(
                trace_id=trace_id,
                name=name,
                value=value,
                comment=comment,
            )
            return True
        except Exception as e:
            logger.error(f"Failed to score trace: {e}")
            return False

    def flush(self):
        """Flush all pending traces to Langfuse."""
        if self.enabled and self.client:
            try:
                self.client.flush()
                logger.debug("Langfuse traces flushed")
            except Exception as e:
                logger.error(f"Failed to flush Langfuse traces: {e}")

    def shutdown(self):
        """Shutdown Langfuse client and flush pending traces."""
        if self.enabled and self.client:
            try:
                self.client.flush()
                logger.info("Langfuse client shutdown")
            except Exception as e:
                logger.error(f"Error during Langfuse shutdown: {e}")


# Decorator for automatic tracing
def trace_operation(name: Optional[str] = None):
    """
    Decorator for tracing operations with Langfuse.

    Usage:
        @trace_operation("search_documents")
        async def search(query: str):
            # Function code
            pass
    """

    def decorator(func):
        # Use Langfuse observe decorator
        return observe(name=name or func.__name__)(func)

    return decorator


@contextmanager
def trace_context(
    name: str,
    metadata: Optional[Dict[str, Any]] = None,
    tags: Optional[List[str]] = None,
):
    """
    Context manager for tracing a block of code.

    Usage:
        with trace_context("document_processing"):
            # Code to trace
            process_documents()
    """
    try:
        # Start trace
        langfuse_context.update_current_trace(
            name=name,
            metadata=metadata or {},
            tags=tags or [],
        )
        yield
    finally:
        # Trace automatically ends when context exits
        pass
