"""Search and query models."""

from pydantic import BaseModel, Field


class SearchQuery(BaseModel):
    """Search query."""

    query: str = Field(..., description="Search query text")
    k: int = Field(default=3, description="Number of results")
    filter: dict | None = None


class SearchResult(BaseModel):
    """Search result."""

    document_id: str
    chunk_id: str
    content: str
    score: float
    metadata: dict = Field(default_factory=dict)


class SearchResponse(BaseModel):
    """Search response."""

    results: list[SearchResult]
    query: str
    total: int


class RAGQuery(BaseModel):
    """RAG query."""

    query: str
    k: int = Field(default=3, description="Number of contexts to retrieve")
    temperature: float | None = None
    max_tokens: int | None = None


class RAGResponse(BaseModel):
    """RAG response."""

    answer: str
    contexts: list[SearchResult]
    query: str
    model: str
