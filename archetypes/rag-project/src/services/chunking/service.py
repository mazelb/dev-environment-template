"""Document chunking service."""

import logging
from dataclasses import dataclass
from typing import List, Optional

logger = logging.getLogger(__name__)


@dataclass
class Chunk:
    """Represents a text chunk with metadata."""

    text: str
    chunk_index: int
    total_chunks: int
    start_char: int
    end_char: int
    metadata: dict


class ChunkingService:
    """Service for chunking documents into smaller pieces."""

    def __init__(
        self,
        chunk_size: int = 600,
        overlap_size: int = 100,
        separator: str = "\n\n",
    ):
        """Initialize the chunking service.

        Args:
            chunk_size: Target size of each chunk in characters
            overlap_size: Number of overlapping characters between chunks
            separator: Preferred separator for splitting text
        """
        self.chunk_size = chunk_size
        self.overlap_size = overlap_size
        self.separator = separator

        if overlap_size >= chunk_size:
            raise ValueError("Overlap size must be smaller than chunk size")

    def chunk_text(
        self, text: str, metadata: Optional[dict] = None
    ) -> List[Chunk]:
        """Chunk a single text document.

        Args:
            text: Text to chunk
            metadata: Optional metadata to attach to each chunk

        Returns:
            List of Chunk objects
        """
        if not text or not text.strip():
            return []

        metadata = metadata or {}
        chunks = []

        # Split by preferred separator first
        paragraphs = text.split(self.separator)
        current_chunk = ""
        current_start = 0

        for para in paragraphs:
            para = para.strip()
            if not para:
                continue

            # If adding this paragraph exceeds chunk size, save current chunk
            if len(current_chunk) + len(para) + len(self.separator) > self.chunk_size:
                if current_chunk:
                    chunks.append(current_chunk)
                    current_start += len(current_chunk) - self.overlap_size
                current_chunk = para
            else:
                if current_chunk:
                    current_chunk += self.separator + para
                else:
                    current_chunk = para

        # Don't forget the last chunk
        if current_chunk:
            chunks.append(current_chunk)

        # Create Chunk objects with metadata
        chunk_objects = []
        for i, chunk_text in enumerate(chunks):
            chunk_obj = Chunk(
                text=chunk_text,
                chunk_index=i,
                total_chunks=len(chunks),
                start_char=text.find(chunk_text),
                end_char=text.find(chunk_text) + len(chunk_text),
                metadata={**metadata, "chunk_index": i, "total_chunks": len(chunks)},
            )
            chunk_objects.append(chunk_obj)

        logger.info(f"Chunked text into {len(chunk_objects)} chunks")
        return chunk_objects

    def chunk_with_overlap(self, text: str, metadata: Optional[dict] = None) -> List[Chunk]:
        """Chunk text with sliding window overlap.

        Args:
            text: Text to chunk
            metadata: Optional metadata to attach to each chunk

        Returns:
            List of Chunk objects with overlap
        """
        if not text or not text.strip():
            return []

        metadata = metadata or {}
        chunks = []
        start = 0
        text_length = len(text)

        while start < text_length:
            # Calculate end position
            end = min(start + self.chunk_size, text_length)

            # Try to break at sentence boundary
            if end < text_length:
                # Look for sentence ending punctuation
                for punct in [". ", "! ", "? ", "\n"]:
                    last_punct = text.rfind(punct, start, end)
                    if last_punct != -1:
                        end = last_punct + len(punct)
                        break

            chunk_text = text[start:end].strip()
            if chunk_text:
                chunks.append(
                    Chunk(
                        text=chunk_text,
                        chunk_index=len(chunks),
                        total_chunks=0,  # Will update after
                        start_char=start,
                        end_char=end,
                        metadata={**metadata, "chunk_index": len(chunks)},
                    )
                )

            # Move start position with overlap
            start = end - self.overlap_size if end < text_length else text_length

        # Update total_chunks
        for chunk in chunks:
            chunk.total_chunks = len(chunks)
            chunk.metadata["total_chunks"] = len(chunks)

        logger.info(f"Chunked text with overlap into {len(chunks)} chunks")
        return chunks

    def chunk_by_sentences(
        self, text: str, sentences_per_chunk: int = 5, metadata: Optional[dict] = None
    ) -> List[Chunk]:
        """Chunk text by sentences.

        Args:
            text: Text to chunk
            sentences_per_chunk: Number of sentences per chunk
            metadata: Optional metadata to attach to each chunk

        Returns:
            List of Chunk objects
        """
        if not text or not text.strip():
            return []

        metadata = metadata or {}

        # Simple sentence splitting (can be improved with spaCy or NLTK)
        sentences = []
        current_sentence = ""

        for char in text:
            current_sentence += char
            if char in ".!?" and len(current_sentence.strip()) > 5:
                sentences.append(current_sentence.strip())
                current_sentence = ""

        if current_sentence.strip():
            sentences.append(current_sentence.strip())

        # Group sentences into chunks
        chunks = []
        for i in range(0, len(sentences), sentences_per_chunk):
            chunk_sentences = sentences[i : i + sentences_per_chunk]
            chunk_text = " ".join(chunk_sentences)

            chunks.append(
                Chunk(
                    text=chunk_text,
                    chunk_index=len(chunks),
                    total_chunks=0,  # Will update after
                    start_char=text.find(chunk_sentences[0]),
                    end_char=text.find(chunk_sentences[-1]) + len(chunk_sentences[-1]),
                    metadata={**metadata, "chunk_index": len(chunks)},
                )
            )

        # Update total_chunks
        for chunk in chunks:
            chunk.total_chunks = len(chunks)
            chunk.metadata["total_chunks"] = len(chunks)

        logger.info(f"Chunked text by sentences into {len(chunks)} chunks")
        return chunks

    def chunk_documents(
        self, documents: List[dict], text_field: str = "content"
    ) -> List[dict]:
        """Chunk multiple documents and prepare for indexing.

        Args:
            documents: List of document dictionaries
            text_field: Field name containing the text to chunk

        Returns:
            List of chunked documents ready for indexing
        """
        chunked_docs = []

        for doc in documents:
            text = doc.get(text_field, "")
            if not text:
                continue

            # Create metadata from document fields
            metadata = {k: v for k, v in doc.items() if k != text_field}

            # Chunk the document
            chunks = self.chunk_with_overlap(text, metadata)

            # Convert to indexable format
            for chunk in chunks:
                chunked_doc = {
                    "text": chunk.text,
                    "chunk_index": chunk.chunk_index,
                    "total_chunks": chunk.total_chunks,
                    "start_char": chunk.start_char,
                    "end_char": chunk.end_char,
                    **chunk.metadata,
                }
                chunked_docs.append(chunked_doc)

        logger.info(f"Chunked {len(documents)} documents into {len(chunked_docs)} chunks")
        return chunked_docs
