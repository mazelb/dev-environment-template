"""FastAPI main application."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.config import get_settings
from src.routers import rag

settings = get_settings()


# Lifespan context manager
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize services on startup."""
    yield
    # Cleanup on shutdown
    pass


# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
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

# Include routers
app.include_router(rag.router)


# Health check
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "RAG API",
        "docs": "/docs",
        "redoc": "/redoc",
        "health": "/health",
        "rag_endpoints": {
            "ask": "/rag/ask",
            "search": "/rag/search",
            "index": "/rag/index",
            "chat": "/rag/chat",
        },
    }
