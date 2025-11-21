"""FastAPI main application."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .models import settings
from .services import RAGService


# Lifespan context manager
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize services on startup."""
    # Initialize RAG service
    app.state.rag_service = RAGService()
    yield
    # Cleanup on shutdown
    pass


# Create FastAPI app
app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="RAG system with vector search and LLM integration",
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)


# Health check
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "app": settings.app_name,
        "version": settings.app_version,
    }


@app.get("/")
async def root():
    """Root endpoint."""
    return {"message": "RAG API", "docs": "/docs", "health": "/health"}
