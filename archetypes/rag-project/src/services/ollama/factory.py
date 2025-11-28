"""Factory for creating Ollama client instances."""

from src.config import Settings
from src.services.ollama.client import OllamaClient


def make_ollama_client(settings: Settings) -> OllamaClient:
    """Create an Ollama client from settings.

    Args:
        settings: Application settings

    Returns:
        Configured Ollama client
    """
    return OllamaClient(
        base_url=settings.OLLAMA_BASE_URL, timeout=settings.OLLAMA_TIMEOUT
    )
