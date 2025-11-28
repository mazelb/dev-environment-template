"""Factory for creating OpenSearch client instances."""

from src.config import Settings
from src.services.opensearch.client import OpenSearchClient


def make_opensearch_client(settings: Settings) -> OpenSearchClient:
    """Create an OpenSearch client from settings.

    Args:
        settings: Application settings

    Returns:
        Configured OpenSearch client
    """
    return OpenSearchClient(
        host=settings.OPENSEARCH_HOST,
        port=settings.OPENSEARCH_PORT,
        use_ssl=settings.OPENSEARCH_USE_SSL,
        verify_certs=settings.OPENSEARCH_VERIFY_CERTS,
        http_auth=(
            (settings.OPENSEARCH_USER, settings.OPENSEARCH_PASSWORD)
            if settings.OPENSEARCH_USER and settings.OPENSEARCH_PASSWORD
            else None
        ),
    )
