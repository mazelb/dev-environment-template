"""Embedding service using sentence transformers."""

from typing import List

from sentence_transformers import SentenceTransformer

from ..models import settings


class EmbeddingService:
    """Generate embeddings for text."""

    def __init__(self, model_name: str | None = None):
        self.model_name = model_name or settings.embedding_model
        self.model = SentenceTransformer(self.model_name)

    def embed_text(self, text: str) -> List[float]:
        """Generate embedding for a single text."""
        embedding = self.model.encode(text, convert_to_tensor=False)
        return embedding.tolist()

    def embed_texts(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for multiple texts."""
        embeddings = self.model.encode(texts, convert_to_tensor=False)
        return [emb.tolist() for emb in embeddings]

    def get_dimension(self) -> int:
        """Get embedding dimension."""
        return self.model.get_sentence_embedding_dimension()
