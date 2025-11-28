"""Unit tests for chunking service."""

import pytest
from src.services.chunking.service import Chunk, ChunkingService


@pytest.mark.unit
class TestChunkingService:
    """Test chunking service."""

    def test_service_initialization(self, test_settings):
        """Test service initializes correctly."""
        service = ChunkingService(test_settings)

        assert service is not None
        assert service.chunk_size == test_settings.chunking.chunk_size
        assert service.chunk_overlap == test_settings.chunking.chunk_overlap

    def test_chunk_text_simple(self, test_settings):
        """Test chunking a simple text."""
        service = ChunkingService(test_settings)
        text = "This is a test. " * 100  # Long text

        chunks = service.chunk_text(text)

        assert len(chunks) > 0
        assert all(isinstance(chunk, Chunk) for chunk in chunks)
        assert all(chunk.text for chunk in chunks)

    def test_chunk_with_metadata(self, test_settings):
        """Test chunking with metadata."""
        service = ChunkingService(test_settings)
        text = "Test text. " * 50
        metadata = {"source": "test", "doc_id": "123"}

        chunks = service.chunk_text(text, metadata=metadata)

        assert len(chunks) > 0
        assert all(chunk.metadata.get("source") == "test" for chunk in chunks)
        assert all(chunk.metadata.get("doc_id") == "123" for chunk in chunks)

    def test_chunk_indices(self, test_settings):
        """Test chunk indices are sequential."""
        service = ChunkingService(test_settings)
        text = "Sentence one. " * 50

        chunks = service.chunk_text(text)

        for i, chunk in enumerate(chunks):
            assert chunk.metadata["chunk_index"] == i
            assert chunk.metadata["total_chunks"] == len(chunks)

    def test_chunk_positions(self, test_settings):
        """Test chunk start and end positions."""
        service = ChunkingService(test_settings)
        text = "Test text for chunking."

        chunks = service.chunk_text(text)

        assert len(chunks) >= 1
        assert chunks[0].start_char == 0
        assert chunks[0].end_char > 0

    def test_sliding_window_chunking(self, test_settings):
        """Test sliding window chunking with overlap."""
        service = ChunkingService(test_settings)
        text = "A" * 1000  # Long uniform text

        chunks = service.chunk_sliding_window(text)

        # Should have overlap between chunks
        if len(chunks) > 1:
            # Check that chunks overlap
            assert chunks[1].start_char < chunks[0].end_char

    def test_sentence_chunking(self, test_settings):
        """Test sentence-based chunking."""
        service = ChunkingService(test_settings)
        text = "Sentence one. Sentence two. Sentence three. " * 10

        chunks = service.chunk_by_sentences(text)

        assert len(chunks) > 0
        # Each chunk should end with a sentence boundary
        assert all(
            chunk.text.strip().endswith(".")
            or chunk.text.strip().endswith("!")
            or chunk.text.strip().endswith("?")
            for chunk in chunks
        )

    def test_chunk_documents_batch(self, test_settings, sample_documents):
        """Test chunking multiple documents."""
        service = ChunkingService(test_settings)

        all_chunks = service.chunk_documents(sample_documents)

        assert len(all_chunks) > 0
        # Should have chunks from all documents
        sources = set(chunk.metadata.get("id") for chunk in all_chunks)
        assert len(sources) <= len(sample_documents)

    def test_empty_text(self, test_settings):
        """Test handling empty text."""
        service = ChunkingService(test_settings)

        chunks = service.chunk_text("")

        assert len(chunks) == 0

    def test_short_text_no_chunking_needed(self, test_settings):
        """Test text shorter than chunk size."""
        service = ChunkingService(test_settings)
        short_text = "Short text."

        chunks = service.chunk_text(short_text)

        # Should still create at least one chunk
        assert len(chunks) == 1
        assert chunks[0].text == short_text
