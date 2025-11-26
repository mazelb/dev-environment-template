"""Vector store service using ChromaDB."""

from typing import Any, Dict, List

import chromadb
from chromadb.config import Settings as ChromaSettings
from src.models import DocumentChunk, SearchResult, settings


class VectorStore:
    """Vector database operations."""

    def __init__(self):
        self.client = chromadb.HttpClient(
            host=settings.vector_db_host,
            port=settings.vector_db_port,
            settings=ChromaSettings(anonymized_telemetry=False),
        )
        self.collection_name = settings.collection_name
        self.collection = None

    def init_collection(self, embedding_dim: int = 384):
        """Initialize or get collection."""
        try:
            self.collection = self.client.get_collection(self.collection_name)
        except:
            self.collection = self.client.create_collection(
                name=self.collection_name, metadata={"embedding_dim": embedding_dim}
            )
        return self.collection

    def add_chunks(self, chunks: List[DocumentChunk], embeddings: List[List[float]]):
        """Add document chunks with embeddings."""
        if not self.collection:
            self.init_collection()

        self.collection.add(
            ids=[chunk.chunk_id for chunk in chunks],
            embeddings=embeddings,
            documents=[chunk.content for chunk in chunks],
            metadatas=[
                {
                    "document_id": chunk.document_id,
                    "chunk_index": chunk.chunk_index,
                    **chunk.metadata,
                }
                for chunk in chunks
            ],
        )

    def search(
        self,
        query_embedding: List[float],
        k: int = 3,
        filter: Dict[str, Any] | None = None,
    ) -> List[SearchResult]:
        """Search for similar chunks."""
        if not self.collection:
            self.init_collection()

        results = self.collection.query(
            query_embeddings=[query_embedding], n_results=k, where=filter
        )

        search_results = []
        if results["ids"] and len(results["ids"][0]) > 0:
            for i, chunk_id in enumerate(results["ids"][0]):
                search_results.append(
                    SearchResult(
                        document_id=results["metadatas"][0][i].get("document_id", ""),
                        chunk_id=chunk_id,
                        content=results["documents"][0][i],
                        score=1.0
                        - results["distances"][0][i],  # Convert distance to similarity
                        metadata=results["metadatas"][0][i],
                    )
                )

        return search_results

    def delete_document(self, document_id: str):
        """Delete all chunks for a document."""
        if not self.collection:
            self.init_collection()

        self.collection.delete(where={"document_id": document_id})
