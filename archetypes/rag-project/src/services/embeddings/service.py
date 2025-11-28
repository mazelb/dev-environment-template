"""Embedding service using sentence-transformers."""

import logging
from typing import List, Optional

import numpy as np
from sentence_transformers import SentenceTransformer

logger = logging.getLogger(__name__)


class EmbeddingService:
    """Service for generating text embeddings."""

    def __init__(self, model_name: str = "all-MiniLM-L6-v2", device: Optional[str] = None):
        """Initialize the embedding service.

        Args:
            model_name: Name of the sentence-transformer model
            device: Device to run on ('cpu', 'cuda', or None for auto)
        """
        self.model_name = model_name
        self.device = device
        self.model: Optional[SentenceTransformer] = None
        self._load_model()

    def _load_model(self) -> None:
        """Load the embedding model."""
        try:
            self.model = SentenceTransformer(self.model_name, device=self.device)
            logger.info(f"Loaded embedding model: {self.model_name}")
        except Exception as e:
            logger.error(f"Failed to load embedding model: {e}")
            raise

    def embed_text(self, text: str, normalize: bool = True) -> Optional[List[float]]:
        """Generate embedding for a single text.

        Args:
            text: Text to embed
            normalize: Whether to normalize the embedding vector

        Returns:
            Embedding vector or None if failed
        """
        if not self.model:
            logger.error("Embedding model not loaded")
            return None

        try:
            embedding = self.model.encode(
                text, normalize_embeddings=normalize, show_progress_bar=False
            )
            return embedding.tolist()
        except Exception as e:
            logger.error(f"Failed to generate embedding: {e}")
            return None

    def embed_batch(
        self, texts: List[str], normalize: bool = True, batch_size: int = 32
    ) -> List[List[float]]:
        """Generate embeddings for multiple texts.

        Args:
            texts: List of texts to embed
            normalize: Whether to normalize the embedding vectors
            batch_size: Batch size for processing

        Returns:
            List of embedding vectors
        """
        if not self.model:
            logger.error("Embedding model not loaded")
            return []

        try:
            embeddings = self.model.encode(
                texts,
                normalize_embeddings=normalize,
                batch_size=batch_size,
                show_progress_bar=len(texts) > 100,
            )
            return embeddings.tolist()
        except Exception as e:
            logger.error(f"Failed to generate batch embeddings: {e}")
            return []

    def embed_documents(
        self, documents: List[str], normalize: bool = True, batch_size: int = 32
    ) -> List[List[float]]:
        """Generate embeddings for documents (optimized for longer text).

        Args:
            documents: List of documents to embed
            normalize: Whether to normalize the embedding vectors
            batch_size: Batch size for processing

        Returns:
            List of embedding vectors
        """
        return self.embed_batch(documents, normalize=normalize, batch_size=batch_size)

    def embed_query(self, query: str, normalize: bool = True) -> Optional[List[float]]:
        """Generate embedding for a search query.

        Args:
            query: Query text to embed
            normalize: Whether to normalize the embedding vector

        Returns:
            Embedding vector or None if failed
        """
        return self.embed_text(query, normalize=normalize)

    def similarity(self, embedding1: List[float], embedding2: List[float]) -> float:
        """Calculate cosine similarity between two embeddings.

        Args:
            embedding1: First embedding vector
            embedding2: Second embedding vector

        Returns:
            Cosine similarity score (-1 to 1)
        """
        try:
            vec1 = np.array(embedding1)
            vec2 = np.array(embedding2)
            return float(np.dot(vec1, vec2) / (np.linalg.norm(vec1) * np.linalg.norm(vec2)))
        except Exception as e:
            logger.error(f"Failed to calculate similarity: {e}")
            return 0.0

    def get_embedding_dimension(self) -> int:
        """Get the dimension of the embedding vectors.

        Returns:
            Embedding dimension
        """
        if not self.model:
            return 0
        return self.model.get_sentence_embedding_dimension()

    def get_model_info(self) -> dict:
        """Get information about the loaded model.

        Returns:
            Dictionary with model information
        """
        return {
            "model_name": self.model_name,
            "device": str(self.device) if self.device else "auto",
            "embedding_dimension": self.get_embedding_dimension(),
            "max_seq_length": self.model.max_seq_length if self.model else 0,
        }
