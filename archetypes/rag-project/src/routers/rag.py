"""RAG API endpoints for question answering and search."""

import logging
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from src.config import Settings, get_settings
from src.services.rag import RAGPipeline, make_rag_pipeline

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag", tags=["RAG"])


# Pydantic models
class AskRequest(BaseModel):
    """Request model for ask endpoint."""

    query: str = Field(..., description="Question to ask")
    top_k: int = Field(5, ge=1, le=20, description="Number of documents to retrieve")
    search_type: str = Field("hybrid", pattern="^(keyword|vector|hybrid)$")
    system_message: Optional[str] = Field(None, description="Optional system message")
    temperature: float = Field(0.7, ge=0.0, le=1.0, description="LLM temperature")
    max_tokens: Optional[int] = Field(None, ge=1, description="Maximum tokens to generate")
    stream: bool = Field(False, description="Whether to stream the response")


class SearchRequest(BaseModel):
    """Request model for search endpoint."""

    query: str = Field(..., description="Search query")
    top_k: int = Field(10, ge=1, le=50, description="Number of results")
    search_type: str = Field("hybrid", pattern="^(keyword|vector|hybrid)$")
    filters: Optional[dict] = Field(None, description="Optional filters")


class IndexRequest(BaseModel):
    """Request model for indexing documents."""

    documents: List[dict] = Field(..., description="Documents to index")
    text_field: str = Field("content", description="Field containing text")


class ChatMessage(BaseModel):
    """Chat message model."""

    role: str = Field(..., pattern="^(system|user|assistant)$")
    content: str = Field(..., description="Message content")


class ChatRequest(BaseModel):
    """Request model for chat endpoint."""

    messages: List[ChatMessage] = Field(..., description="Chat messages")
    top_k: int = Field(5, ge=1, le=20, description="Number of documents to retrieve")
    search_type: str = Field("hybrid", pattern="^(keyword|vector|hybrid)$")
    temperature: float = Field(0.7, ge=0.0, le=1.0, description="LLM temperature")
    max_tokens: Optional[int] = Field(None, ge=1, description="Maximum tokens to generate")


# Dependency for RAG pipeline
def get_rag_pipeline(settings: Settings = Depends(get_settings)) -> RAGPipeline:
    """Get RAG pipeline instance."""
    return make_rag_pipeline(settings)


@router.post("/ask")
async def ask(
    request: AskRequest,
    pipeline: RAGPipeline = Depends(get_rag_pipeline),
):
    """Ask a question and get an answer with context.

    This endpoint performs retrieval-augmented generation:
    1. Retrieves relevant documents based on the query
    2. Constructs a prompt with retrieved context
    3. Generates an answer using the LLM
    """
    try:
        if request.stream:
            # Return streaming response
            async def generate():
                async for chunk in pipeline.ask_stream(
                    query=request.query,
                    top_k=request.top_k,
                    search_type=request.search_type,
                    system_message=request.system_message,
                    temperature=request.temperature,
                    max_tokens=request.max_tokens,
                ):
                    import json
                    yield f"data: {json.dumps(chunk)}\n\n"

            return StreamingResponse(generate(), media_type="text/event-stream")
        else:
            # Return complete response
            result = await pipeline.ask(
                query=request.query,
                top_k=request.top_k,
                search_type=request.search_type,
                system_message=request.system_message,
                temperature=request.temperature,
                max_tokens=request.max_tokens,
            )
            return result

    except Exception as e:
        logger.error(f"Error in ask endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/search")
async def search(
    request: SearchRequest,
    pipeline: RAGPipeline = Depends(get_rag_pipeline),
):
    """Search for relevant documents.

    Performs semantic search using keyword, vector, or hybrid search.
    """
    try:
        results = await pipeline.retrieve(
            query=request.query,
            top_k=request.top_k,
            search_type=request.search_type,
            filters=request.filters,
        )

        return {
            "query": request.query,
            "results": results,
            "total": len(results),
            "search_type": request.search_type,
        }

    except Exception as e:
        logger.error(f"Error in search endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/index")
async def index_documents(
    request: IndexRequest,
    pipeline: RAGPipeline = Depends(get_rag_pipeline),
):
    """Index documents for retrieval.

    Chunks documents, generates embeddings, and indexes them in OpenSearch.
    """
    try:
        if not request.documents:
            raise HTTPException(status_code=400, detail="No documents provided")

        result = await pipeline.index_documents(
            documents=request.documents,
            text_field=request.text_field,
        )

        return {
            "message": "Documents indexed successfully",
            "indexed": result.get("success", 0),
            "errors": result.get("errors", 0),
        }

    except Exception as e:
        logger.error(f"Error in index endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/chat")
async def chat(
    request: ChatRequest,
    pipeline: RAGPipeline = Depends(get_rag_pipeline),
):
    """Chat with context retrieval.

    Performs RAG-enhanced chat where the system retrieves relevant
    context based on the conversation.
    """
    try:
        messages = [{"role": msg.role, "content": msg.content} for msg in request.messages]

        result = await pipeline.chat(
            messages=messages,
            top_k=request.top_k,
            search_type=request.search_type,
            temperature=request.temperature,
            max_tokens=request.max_tokens,
        )

        return result

    except Exception as e:
        logger.error(f"Error in chat endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
async def health_check(pipeline: RAGPipeline = Depends(get_rag_pipeline)):
    """Check health of RAG services."""
    try:
        # Check OpenSearch
        opensearch_healthy = pipeline.opensearch.health_check()

        # Check Ollama
        ollama_healthy = await pipeline.ollama.health_check()

        # Get embedding model info
        embedding_info = pipeline.embeddings.get_model_info()

        return {
            "status": "healthy" if (opensearch_healthy and ollama_healthy) else "unhealthy",
            "services": {
                "opensearch": "healthy" if opensearch_healthy else "unhealthy",
                "ollama": "healthy" if ollama_healthy else "unhealthy",
                "embeddings": embedding_info,
            },
        }

    except Exception as e:
        logger.error(f"Error in health check: {e}")
        return {"status": "unhealthy", "error": str(e)}
