"""Ollama client for LLM inference."""

import json
import logging
from typing import AsyncGenerator, Dict, List, Optional

import httpx

logger = logging.getLogger(__name__)


class OllamaClient:
    """Client for Ollama LLM inference."""

    def __init__(self, base_url: str, timeout: float = 120.0):
        """Initialize Ollama client.

        Args:
            base_url: Base URL of Ollama server (e.g., http://ollama:11434)
            timeout: Request timeout in seconds
        """
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.client = httpx.AsyncClient(timeout=timeout)

    async def health_check(self) -> bool:
        """Check if Ollama server is healthy."""
        try:
            response = await self.client.get(f"{self.base_url}/api/tags")
            return response.status_code == 200
        except Exception as e:
            logger.error(f"Ollama health check failed: {e}")
            return False

    async def list_models(self) -> List[Dict[str, str]]:
        """List available models.

        Returns:
            List of model information dictionaries
        """
        try:
            response = await self.client.get(f"{self.base_url}/api/tags")
            response.raise_for_status()
            data = response.json()
            return data.get("models", [])
        except Exception as e:
            logger.error(f"Failed to list models: {e}")
            return []

    async def pull_model(self, model_name: str) -> bool:
        """Pull a model from Ollama registry.

        Args:
            model_name: Name of the model to pull

        Returns:
            True if successful, False otherwise
        """
        try:
            response = await self.client.post(
                f"{self.base_url}/api/pull", json={"name": model_name}, timeout=600.0
            )
            response.raise_for_status()
            logger.info(f"Successfully pulled model: {model_name}")
            return True
        except Exception as e:
            logger.error(f"Failed to pull model {model_name}: {e}")
            return False

    async def generate(
        self,
        model: str,
        prompt: str,
        system: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
        stop: Optional[List[str]] = None,
    ) -> Optional[str]:
        """Generate text completion.

        Args:
            model: Model name to use
            prompt: Input prompt
            system: System message
            temperature: Sampling temperature (0.0 to 1.0)
            max_tokens: Maximum tokens to generate
            stop: Stop sequences

        Returns:
            Generated text or None if failed
        """
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {"temperature": temperature},
        }

        if system:
            payload["system"] = system

        if max_tokens:
            payload["options"]["num_predict"] = max_tokens

        if stop:
            payload["options"]["stop"] = stop

        try:
            response = await self.client.post(
                f"{self.base_url}/api/generate", json=payload
            )
            response.raise_for_status()
            data = response.json()
            return data.get("response", "")
        except Exception as e:
            logger.error(f"Generation failed: {e}")
            return None

    async def generate_stream(
        self,
        model: str,
        prompt: str,
        system: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
        stop: Optional[List[str]] = None,
    ) -> AsyncGenerator[str, None]:
        """Generate text completion with streaming.

        Args:
            model: Model name to use
            prompt: Input prompt
            system: System message
            temperature: Sampling temperature (0.0 to 1.0)
            max_tokens: Maximum tokens to generate
            stop: Stop sequences

        Yields:
            Text chunks as they are generated
        """
        payload = {
            "model": model,
            "prompt": prompt,
            "stream": True,
            "options": {"temperature": temperature},
        }

        if system:
            payload["system"] = system

        if max_tokens:
            payload["options"]["num_predict"] = max_tokens

        if stop:
            payload["options"]["stop"] = stop

        try:
            async with self.client.stream(
                "POST", f"{self.base_url}/api/generate", json=payload
            ) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line:
                        try:
                            data = json.loads(line)
                            if "response" in data:
                                yield data["response"]
                            if data.get("done", False):
                                break
                        except json.JSONDecodeError:
                            continue
        except Exception as e:
            logger.error(f"Streaming generation failed: {e}")
            yield ""

    async def chat(
        self,
        model: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> Optional[str]:
        """Chat completion using messages format.

        Args:
            model: Model name to use
            messages: List of message dictionaries with 'role' and 'content'
            temperature: Sampling temperature (0.0 to 1.0)
            max_tokens: Maximum tokens to generate

        Returns:
            Assistant response or None if failed
        """
        payload = {
            "model": model,
            "messages": messages,
            "stream": False,
            "options": {"temperature": temperature},
        }

        if max_tokens:
            payload["options"]["num_predict"] = max_tokens

        try:
            response = await self.client.post(
                f"{self.base_url}/api/chat", json=payload
            )
            response.raise_for_status()
            data = response.json()
            message = data.get("message", {})
            return message.get("content", "")
        except Exception as e:
            logger.error(f"Chat completion failed: {e}")
            return None

    async def chat_stream(
        self,
        model: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> AsyncGenerator[str, None]:
        """Chat completion with streaming.

        Args:
            model: Model name to use
            messages: List of message dictionaries with 'role' and 'content'
            temperature: Sampling temperature (0.0 to 1.0)
            max_tokens: Maximum tokens to generate

        Yields:
            Text chunks as they are generated
        """
        payload = {
            "model": model,
            "messages": messages,
            "stream": True,
            "options": {"temperature": temperature},
        }

        if max_tokens:
            payload["options"]["num_predict"] = max_tokens

        try:
            async with self.client.stream(
                "POST", f"{self.base_url}/api/chat", json=payload
            ) as response:
                response.raise_for_status()
                async for line in response.aiter_lines():
                    if line:
                        try:
                            data = json.loads(line)
                            message = data.get("message", {})
                            if "content" in message:
                                yield message["content"]
                            if data.get("done", False):
                                break
                        except json.JSONDecodeError:
                            continue
        except Exception as e:
            logger.error(f"Streaming chat failed: {e}")
            yield ""

    async def embed(self, model: str, text: str) -> Optional[List[float]]:
        """Generate embeddings for text.

        Args:
            model: Model name to use (should support embeddings)
            text: Text to embed

        Returns:
            Embedding vector or None if failed
        """
        payload = {"model": model, "prompt": text}

        try:
            response = await self.client.post(
                f"{self.base_url}/api/embeddings", json=payload
            )
            response.raise_for_status()
            data = response.json()
            return data.get("embedding")
        except Exception as e:
            logger.error(f"Embedding generation failed: {e}")
            return None

    async def close(self) -> None:
        """Close the HTTP client."""
        await self.client.aclose()
