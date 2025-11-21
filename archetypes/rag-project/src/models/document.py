"""Document models."""

from datetime import datetime
from uuid import uuid4

from pydantic import BaseModel, Field


class DocumentMetadata(BaseModel):
    """Document metadata."""

    filename: str
    file_type: str
    file_size: int
    upload_date: datetime = Field(default_factory=datetime.utcnow)
    num_chunks: int | None = None


class DocumentChunk(BaseModel):
    """Document chunk."""

    chunk_id: str = Field(default_factory=lambda: str(uuid4()))
    document_id: str
    content: str
    chunk_index: int
    metadata: dict = Field(default_factory=dict)


class Document(BaseModel):
    """Document model."""

    id: str = Field(default_factory=lambda: str(uuid4()))
    content: str
    metadata: DocumentMetadata
    chunks: list[DocumentChunk] | None = None


class DocumentUploadResponse(BaseModel):
    """Upload response."""

    document_id: str
    filename: str
    num_chunks: int
    message: str = "Document uploaded successfully"


class DocumentListItem(BaseModel):
    """Document list item."""

    id: str
    filename: str
    file_type: str
    file_size: int
    upload_date: datetime
    num_chunks: int | None = None


class DocumentListResponse(BaseModel):
    """Document list response."""

    documents: list[DocumentListItem]
    total: int
