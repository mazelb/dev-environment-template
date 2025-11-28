"""Unit tests for Ollama client."""

from unittest.mock import MagicMock, patch

import pytest
from src.services.ollama.client import OllamaClient


@pytest.mark.unit
@pytest.mark.asyncio
class TestOllamaClient:
    """Test Ollama client."""

    async def test_client_initialization(self, test_settings):
        """Test client initializes correctly."""
        client = OllamaClient(test_settings)

        assert client is not None
        assert client.base_url == test_settings.ollama.base_url

    async def test_health_check(self, test_settings):
        """Test health check."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_client.return_value.__aenter__.return_value.get.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            result = await client.health()

            assert result is True

    async def test_list_models(self, test_settings):
        """Test listing available models."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {
                "models": [{"name": "llama3.2:1b"}, {"name": "llama3.2:3b"}]
            }
            mock_client.return_value.__aenter__.return_value.get.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            models = await client.list_models()

            assert len(models) == 2
            assert "llama3.2:1b" in models

    async def test_generate(self, test_settings):
        """Test text generation."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "This is a test response."}
            mock_client.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            response = await client.generate("Test prompt")

            assert response == "This is a test response."

    async def test_generate_with_parameters(self, test_settings):
        """Test generation with custom parameters."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "Test"}
            mock_client.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            response = await client.generate(
                "Test prompt",
                temperature=0.5,
                max_tokens=100,
                system="You are a helpful assistant.",
            )

            assert response == "Test"

    async def test_embed(self, test_settings):
        """Test embedding generation."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"embedding": [0.1, 0.2, 0.3]}
            mock_client.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            embedding = await client.embed("Test text")

            assert len(embedding) == 3
            assert embedding[0] == 0.1

    async def test_chat(self, test_settings):
        """Test chat completion."""
        with patch("httpx.AsyncClient") as mock_client:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"message": {"content": "Chat response"}}
            mock_client.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            client = OllamaClient(test_settings)
            messages = [{"role": "user", "content": "Hello"}]
            response = await client.chat(messages)

            assert response == "Chat response"
