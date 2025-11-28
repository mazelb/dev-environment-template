"""Ollama service module."""

from src.services.ollama.client import OllamaClient
from src.services.ollama.factory import make_ollama_client

__all__ = ["OllamaClient", "make_ollama_client"]
