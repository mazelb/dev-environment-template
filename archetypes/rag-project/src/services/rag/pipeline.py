"""RAG (Retrieval-Augmented Generation) pipeline."""

import logging
from typing import AsyncGenerator, Dict, List, Optional

from src.services.chunking import ChunkingService
from src.services.embeddings import EmbeddingService
from src.services.ollama import OllamaClient
from src.services.opensearch import OpenSearchClient

logger = logging.getLogger(__name__)


class RAGPipeline:
    """End-to-end RAG pipeline for question answering."""

    def __init__(
        self,
        opensearch_client: OpenSearchClient,
        ollama_client: OllamaClient,
        embedding_service: EmbeddingService,
        chunking_service: ChunkingService,
        index_name: str = "documents",
        model_name: str = "llama3.2:1b",
    ):
        """Initialize the RAG pipeline.

        Args:
            opensearch_client: OpenSearch client for retrieval
            ollama_client: Ollama client for generation
            embedding_service: Service for generating embeddings
            chunking_service: Service for chunking documents
            index_name: Name of the OpenSearch index
            model_name: Name of the Ollama model to use
        """
        self.opensearch = opensearch_client
        self.ollama = ollama_client
        self.embeddings = embedding_service
        self.chunking = chunking_service
        self.index_name = index_name
        self.model_name = model_name

    async def index_documents(
        self, documents: List[Dict], text_field: str = "content"
    ) -> Dict[str, int]:
        """Index documents for retrieval.

        Args:
            documents: List of documents to index
            text_field: Field containing the text content

        Returns:
            Dictionary with indexing statistics
        """
        # Chunk documents
        chunked_docs = self.chunking.chunk_documents(documents, text_field)

        # Generate embeddings for chunks
        texts = [chunk["text"] for chunk in chunked_docs]
        embeddings = self.embeddings.embed_batch(texts)

        # Add embeddings to chunks
        for chunk, embedding in zip(chunked_docs, embeddings):
            chunk["embedding"] = embedding

        # Bulk index
        result = self.opensearch.bulk_index(self.index_name, chunked_docs)

        logger.info(
            f"Indexed {result['success']} chunks with {result['errors']} errors"
        )
        return result

    async def retrieve(
        self,
        query: str,
        top_k: int = 5,
        search_type: str = "hybrid",
        filters: Optional[Dict] = None,
    ) -> List[Dict]:
        """Retrieve relevant documents for a query.

        Args:
            query: Search query
            top_k: Number of results to retrieve
            search_type: Type of search ('keyword', 'vector', or 'hybrid')
            filters: Optional filters to apply

        Returns:
            List of retrieved documents with scores
        """
        # Generate query embedding for vector/hybrid search
        query_embedding = None
        if search_type in ["vector", "hybrid"]:
            query_embedding = self.embeddings.embed_query(query)

        # Perform search based on type
        if search_type == "keyword":
            results = self.opensearch.keyword_search(
                self.index_name,
                query,
                fields=["text", "title", "content"],
                size=top_k,
                filters=filters,
            )
        elif search_type == "vector" and query_embedding:
            results = self.opensearch.vector_search(
                self.index_name,
                query_embedding,
                vector_field="embedding",
                size=top_k,
                filters=filters,
            )
        elif search_type == "hybrid" and query_embedding:
            results = self.opensearch.hybrid_search(
                self.index_name,
                query,
                query_embedding,
                text_fields=["text", "title", "content"],
                vector_field="embedding",
                size=top_k,
                filters=filters,
            )
        else:
            logger.warning(
                f"Invalid search type: {search_type}, falling back to keyword"
            )
            results = self.opensearch.keyword_search(
                self.index_name,
                query,
                fields=["text", "title", "content"],
                size=top_k,
                filters=filters,
            )

        logger.info(f"Retrieved {len(results)} documents for query")
        return results

    def _build_context(self, retrieved_docs: List[Dict]) -> str:
        """Build context string from retrieved documents.

        Args:
            retrieved_docs: List of retrieved documents

        Returns:
            Formatted context string
        """
        context_parts = []

        for i, doc in enumerate(retrieved_docs, 1):
            source = doc.get("source", {})
            text = source.get("text", "")
            title = source.get("title", "Document")

            context_parts.append(f"[{i}] {title}\n{text}")

        return "\n\n".join(context_parts)

    def _build_prompt(
        self, query: str, context: str, system_message: Optional[str] = None
    ) -> str:
        """Build the prompt for the LLM.

        Args:
            query: User's question
            context: Retrieved context
            system_message: Optional system message

        Returns:
            Formatted prompt
        """
        if system_message:
            prompt = f"{system_message}\n\n"
        else:
            prompt = "You are a helpful assistant. Answer the question based on the provided context. If the answer is not in the context, say so.\n\n"

        prompt += f"Context:\n{context}\n\n"
        prompt += f"Question: {query}\n\n"
        prompt += "Answer:"

        return prompt

    async def ask(
        self,
        query: str,
        top_k: int = 5,
        search_type: str = "hybrid",
        system_message: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> Dict:
        """Ask a question and get an answer with retrieved context.

        Args:
            query: User's question
            top_k: Number of documents to retrieve
            search_type: Type of search to use
            system_message: Optional system message
            temperature: LLM temperature
            max_tokens: Maximum tokens to generate

        Returns:
            Dictionary with answer and retrieved documents
        """
        # Retrieve relevant documents
        retrieved_docs = await self.retrieve(query, top_k, search_type)

        if not retrieved_docs:
            return {
                "answer": "I couldn't find any relevant information to answer your question.",
                "sources": [],
                "context": "",
            }

        # Build context and prompt
        context = self._build_context(retrieved_docs)
        prompt = self._build_prompt(query, context, system_message)

        # Generate answer
        answer = await self.ollama.generate(
            model=self.model_name,
            prompt=prompt,
            temperature=temperature,
            max_tokens=max_tokens,
        )

        return {
            "answer": answer or "Failed to generate answer.",
            "sources": retrieved_docs,
            "context": context,
            "query": query,
        }

    async def ask_stream(
        self,
        query: str,
        top_k: int = 5,
        search_type: str = "hybrid",
        system_message: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> AsyncGenerator[Dict, None]:
        """Ask a question and stream the answer.

        Args:
            query: User's question
            top_k: Number of documents to retrieve
            search_type: Type of search to use
            system_message: Optional system message
            temperature: LLM temperature
            max_tokens: Maximum tokens to generate

        Yields:
            Dictionaries with answer chunks and metadata
        """
        # Retrieve relevant documents
        retrieved_docs = await self.retrieve(query, top_k, search_type)

        # Send sources first
        yield {
            "type": "sources",
            "sources": retrieved_docs,
            "query": query,
        }

        if not retrieved_docs:
            yield {
                "type": "answer",
                "content": "I couldn't find any relevant information to answer your question.",
                "done": True,
            }
            return

        # Build context and prompt
        context = self._build_context(retrieved_docs)
        prompt = self._build_prompt(query, context, system_message)

        # Stream answer
        async for chunk in self.ollama.generate_stream(
            model=self.model_name,
            prompt=prompt,
            temperature=temperature,
            max_tokens=max_tokens,
        ):
            yield {"type": "answer", "content": chunk, "done": False}

        yield {"type": "answer", "content": "", "done": True}

    async def chat(
        self,
        messages: List[Dict[str, str]],
        top_k: int = 5,
        search_type: str = "hybrid",
        temperature: float = 0.7,
        max_tokens: Optional[int] = None,
    ) -> Dict:
        """Chat with context retrieval.

        Args:
            messages: List of chat messages
            top_k: Number of documents to retrieve
            search_type: Type of search to use
            temperature: LLM temperature
            max_tokens: Maximum tokens to generate

        Returns:
            Dictionary with answer and retrieved documents
        """
        # Get the last user message as query
        query = None
        for msg in reversed(messages):
            if msg.get("role") == "user":
                query = msg.get("content")
                break

        if not query:
            return {"answer": "No user message found.", "sources": []}

        # Retrieve relevant documents
        retrieved_docs = await self.retrieve(query, top_k, search_type)

        # Build context
        context = ""
        if retrieved_docs:
            context = self._build_context(retrieved_docs)

        # Add context to messages
        enhanced_messages = messages.copy()
        if context:
            # Insert context before last user message
            context_msg = {
                "role": "system",
                "content": f"Use the following context to answer the user's question:\n\n{context}",
            }
            enhanced_messages.insert(-1, context_msg)

        # Generate answer
        answer = await self.ollama.chat(
            model=self.model_name,
            messages=enhanced_messages,
            temperature=temperature,
            max_tokens=max_tokens,
        )

        return {
            "answer": answer or "Failed to generate answer.",
            "sources": retrieved_docs,
            "messages": enhanced_messages,
        }
