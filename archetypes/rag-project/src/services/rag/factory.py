"""Factory for creating RAG pipeline instances."""

from src.config import Settings
from src.services.chunking import make_chunking_service
from src.services.embeddings import make_embedding_service
from src.services.ollama import make_ollama_client
from src.services.opensearch import make_opensearch_client
from src.services.rag.pipeline import RAGPipeline


def make_rag_pipeline(settings: Settings) -> RAGPipeline:
    """Create a RAG pipeline from settings.

    Args:
        settings: Application settings

    Returns:
        Configured RAG pipeline
    """
    return RAGPipeline(
        opensearch_client=make_opensearch_client(settings),
        ollama_client=make_ollama_client(settings),
        embedding_service=make_embedding_service(settings),
        chunking_service=make_chunking_service(settings),
        index_name=settings.OPENSEARCH_INDEX_NAME,
        model_name=settings.OLLAMA_MODEL,
    )
