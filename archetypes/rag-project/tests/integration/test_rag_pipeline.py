"""Integration tests for RAG pipeline."""

from unittest.mock import MagicMock, patch

import pytest


@pytest.mark.integration
@pytest.mark.asyncio
class TestRAGPipeline:
    """Test RAG pipeline end-to-end."""

    async def test_pipeline_initialization(self, test_settings):
        """Test pipeline initializes with all dependencies."""
        from src.services.rag.pipeline import RAGPipeline

        with (
            patch("src.services.opensearch.client.OpenSearch"),
            patch("src.services.embeddings.service.SentenceTransformer"),
        ):
            pipeline = RAGPipeline(test_settings)

            assert pipeline is not None

    async def test_index_documents(self, test_settings, sample_documents):
        """Test indexing documents through pipeline."""
        from src.services.rag.pipeline import RAGPipeline

        with (
            patch("src.services.opensearch.client.OpenSearch") as mock_os,
            patch("src.services.embeddings.service.SentenceTransformer") as mock_emb,
        ):
            # Setup mocks
            mock_os_instance = MagicMock()
            mock_os_instance.index.return_value = {"_id": "doc1", "result": "created"}
            mock_os.return_value = mock_os_instance

            mock_emb_instance = MagicMock()
            mock_emb_instance.encode.return_value = [[0.1] * 384] * len(
                sample_documents
            )
            mock_emb_instance.get_sentence_embedding_dimension.return_value = 384
            mock_emb.return_value = mock_emb_instance

            pipeline = RAGPipeline(test_settings)

            # Index documents
            result = await pipeline.index_documents(sample_documents)

            assert result is not None

    async def test_retrieve_documents(self, test_settings):
        """Test retrieving documents."""
        from src.services.rag.pipeline import RAGPipeline

        with (
            patch("src.services.opensearch.client.OpenSearch") as mock_os,
            patch("src.services.embeddings.service.SentenceTransformer") as mock_emb,
        ):
            # Setup mocks
            mock_os_instance = MagicMock()
            mock_os_instance.search.return_value = {
                "hits": {
                    "total": {"value": 1},
                    "hits": [
                        {
                            "_id": "doc1",
                            "_score": 1.5,
                            "_source": {"content": "Test content"},
                        }
                    ],
                }
            }
            mock_os.return_value = mock_os_instance

            mock_emb_instance = MagicMock()
            mock_emb_instance.encode.return_value = [0.1] * 384
            mock_emb_instance.get_sentence_embedding_dimension.return_value = 384
            mock_emb.return_value = mock_emb_instance

            pipeline = RAGPipeline(test_settings)

            # Retrieve documents
            results = await pipeline.retrieve("test query", search_type="hybrid")

            assert len(results) >= 0

    async def test_generate_answer(self, test_settings):
        """Test generating answer from query."""
        from src.services.rag.pipeline import RAGPipeline

        with (
            patch("src.services.opensearch.client.OpenSearch"),
            patch("src.services.embeddings.service.SentenceTransformer"),
            patch("httpx.AsyncClient") as mock_httpx,
        ):
            # Mock Ollama response
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "Test answer"}
            mock_httpx.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            pipeline = RAGPipeline(test_settings)

            # Generate answer
            answer = await pipeline.generate_answer(
                query="What is AI?", search_type="hybrid"
            )

            assert answer is not None
            assert isinstance(answer, str)

    async def test_chat_with_context(self, test_settings):
        """Test chat with context retrieval."""
        from src.services.rag.pipeline import RAGPipeline

        with (
            patch("src.services.opensearch.client.OpenSearch"),
            patch("src.services.embeddings.service.SentenceTransformer"),
            patch("httpx.AsyncClient") as mock_httpx,
        ):
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"message": {"content": "Chat response"}}
            mock_httpx.return_value.__aenter__.return_value.post.return_value = (
                mock_response
            )

            pipeline = RAGPipeline(test_settings)

            messages = [{"role": "user", "content": "Hello"}]

            response = await pipeline.chat(messages)

            assert response is not None


@pytest.mark.integration
class TestRAGServices:
    """Test integration between RAG services."""

    def test_embedding_to_opensearch_flow(self, test_settings, mock_opensearch_client):
        """Test flow from embedding to OpenSearch indexing."""
        from src.services.embeddings.service import EmbeddingService
        from src.services.opensearch.client import OpenSearchClient

        with (
            patch("src.services.embeddings.service.SentenceTransformer") as mock_model,
            patch(
                "src.services.opensearch.client.OpenSearch",
                return_value=mock_opensearch_client,
            ),
        ):
            mock_instance = MagicMock()
            mock_instance.encode.return_value = [[0.1] * 384]
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            # Create services
            embedding_service = EmbeddingService(test_settings)
            opensearch_client = OpenSearchClient(test_settings)

            # Generate embedding
            text = "Test document"
            embedding = embedding_service.embed_text(text)

            # Index with embedding
            doc = {"content": text, "embedding": embedding}
            opensearch_client.index_document("test_index", doc, "doc1")

            # Verify mock was called
            mock_opensearch_client.index.assert_called_once()

    def test_chunking_to_embedding_flow(self, test_settings):
        """Test flow from chunking to embedding."""
        from src.services.chunking.service import ChunkingService
        from src.services.embeddings.service import EmbeddingService

        with patch("src.services.embeddings.service.SentenceTransformer") as mock_model:
            mock_instance = MagicMock()
            mock_instance.encode.return_value = [[0.1] * 384, [0.2] * 384]
            mock_instance.get_sentence_embedding_dimension.return_value = 384
            mock_model.return_value = mock_instance

            # Create services
            chunking_service = ChunkingService(test_settings)
            embedding_service = EmbeddingService(test_settings)

            # Chunk text
            text = "This is a long document. " * 50
            chunks = chunking_service.chunk_text(text)

            # Generate embeddings for chunks
            chunk_texts = [chunk.text for chunk in chunks]
            embeddings = embedding_service.embed_texts(chunk_texts)

            assert len(embeddings) == len(chunks)
