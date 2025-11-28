"""OpenSearch service module."""

from src.services.opensearch.client import OpenSearchClient
from src.services.opensearch.factory import make_opensearch_client

__all__ = ["OpenSearchClient", "make_opensearch_client"]
