"""RAG service orchestrating retrieval and generation."""

import httpx

from ..models import RAGQuery, RAGResponse, settings
from .embeddings import EmbeddingService
from .vector_store import VectorStore


class RAGService:
    """RAG orchestration service."""

    def __init__(self):
        self.embeddings = EmbeddingService()
        self.vector_store = VectorStore()
        self.vector_store.init_collection(self.embeddings.get_dimension())

    async def query(self, rag_query: RAGQuery) -> RAGResponse:
        """Process RAG query."""
        # 1. Generate query embedding
        query_embedding = self.embeddings.embed_text(rag_query.query)

        # 2. Retrieve relevant contexts
        contexts = self.vector_store.search(
            query_embedding=query_embedding, k=rag_query.k
        )

        # 3. Build prompt with contexts
        context_text = "\n\n".join(
            [f"Context {i + 1}: {ctx.content}" for i, ctx in enumerate(contexts)]
        )

        prompt = f"""Answer the question based on the following contexts:

{context_text}

Question: {rag_query.query}

Answer:"""

        # 4. Generate response from LLM
        temperature = rag_query.temperature or settings.temperature
        max_tokens = rag_query.max_tokens or settings.max_tokens

        answer = await self._generate_answer(
            prompt=prompt, temperature=temperature, max_tokens=max_tokens
        )

        return RAGResponse(
            answer=answer,
            contexts=contexts,
            query=rag_query.query,
            model=settings.ollama_model,
        )

    async def _generate_answer(
        self, prompt: str, temperature: float, max_tokens: int
    ) -> str:
        """Generate answer using Ollama."""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(
                    f"{settings.ollama_host}/api/generate",
                    json={
                        "model": settings.ollama_model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": temperature,
                            "num_predict": max_tokens,
                        },
                    },
                    timeout=60.0,
                )
                response.raise_for_status()
                result = response.json()
                return result.get("response", "No response generated")
            except Exception as e:
                return f"Error generating response: {str(e)}"
