"""Document processor service for chunking text."""

from typing import List

from langchain.text_splitter import RecursiveCharacterTextSplitter

from ..models import DocumentChunk, settings


class DocumentProcessor:
    """Process and chunk documents."""

    def __init__(self, chunk_size: int | None = None, chunk_overlap: int | None = None):
        self.chunk_size = chunk_size or settings.chunk_size
        self.chunk_overlap = chunk_overlap or settings.chunk_overlap
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=self.chunk_size,
            chunk_overlap=self.chunk_overlap,
            length_function=len,
            separators=["\n\n", "\n", " ", ""],
        )

    def chunk_text(self, text: str, document_id: str) -> List[DocumentChunk]:
        """Split text into chunks."""
        chunks = self.text_splitter.split_text(text)
        return [
            DocumentChunk(
                document_id=document_id,
                content=chunk,
                chunk_index=i,
                metadata={"length": len(chunk)},
            )
            for i, chunk in enumerate(chunks)
        ]

    def extract_text_from_file(self, file_path: str, file_type: str) -> str:
        """Extract text from file based on type."""
        if file_type == "txt":
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        elif file_type == "md":
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        elif file_type == "pdf":
            # Placeholder - would use PyPDF2 or pdfplumber
            raise NotImplementedError("PDF extraction not yet implemented")
        else:
            raise ValueError(f"Unsupported file type: {file_type}")
