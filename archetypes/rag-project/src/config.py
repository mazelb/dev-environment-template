"""Application configuration using Pydantic settings."""

from functools import lru_cache
from typing import Optional

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Application Settings
    APP_NAME: str = "RAG API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "INFO"

    # Server Settings
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # PostgreSQL Database
    POSTGRES_DB: str = "rag_db"
    POSTGRES_USER: str = "rag_user"
    POSTGRES_PASSWORD: str = "rag_password"
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DATABASE_URL: str = Field(
        default="postgresql+psycopg2://rag_user:rag_password@postgres:5432/rag_db"
    )

    # Redis Cache
    REDIS__HOST: str = "redis"
    REDIS__PORT: int = 6379
    REDIS__DB: int = 0
    REDIS__PASSWORD: Optional[str] = None

    # OpenSearch Configuration
    OPENSEARCH_HOST: str = "opensearch"
    OPENSEARCH_PORT: int = 9200
    OPENSEARCH_USE_SSL: bool = False
    OPENSEARCH_VERIFY_CERTS: bool = False
    OPENSEARCH_USER: Optional[str] = None
    OPENSEARCH_PASSWORD: Optional[str] = None
    OPENSEARCH_INDEX_NAME: str = "documents"
    OPENSEARCH__HOST: str = "http://opensearch:9200"
    OPENSEARCH__INDEX_NAME: str = "documents"
    OPENSEARCH__CHUNK_INDEX_SUFFIX: str = "chunks"
    OPENSEARCH__MAX_TEXT_SIZE: int = 1000000

    # Vector Search Settings
    OPENSEARCH__VECTOR_DIMENSION: int = 1024
    OPENSEARCH__VECTOR_SPACE_TYPE: str = "cosinesimil"

    # Hybrid Search Settings
    OPENSEARCH__RRF_PIPELINE_NAME: str = "hybrid-rrf-pipeline"
    OPENSEARCH__HYBRID_SEARCH_SIZE_MULTIPLIER: int = 2

    # Ollama LLM
    OLLAMA_BASE_URL: str = "http://ollama:11434"
    OLLAMA_TIMEOUT: float = 120.0
    OLLAMA_MODEL: str = "llama3.2:1b"
    OLLAMA_HOST: str = "http://ollama:11434"
    OLLAMA_PORT: int = 11434

    # Embeddings
    EMBEDDING_MODEL: str = "all-MiniLM-L6-v2"
    EMBEDDING_DEVICE: Optional[str] = None

    # Text Chunking Configuration
    CHUNKING_CHUNK_SIZE: int = 600
    CHUNKING_OVERLAP_SIZE: int = 100
    CHUNKING_SEPARATOR: str = "\n\n"
    CHUNKING__CHUNK_SIZE: int = 600
    CHUNKING__OVERLAP_SIZE: int = 100
    CHUNKING__MIN_CHUNK_SIZE: int = 100
    CHUNK_SIZE: int = 600
    CHUNK_OVERLAP: int = 100

    # Document Processing
    MAX_UPLOAD_SIZE: int = 10485760

    # PDF Parser Configuration
    PDF_PARSER__MAX_PAGES: int = 30
    PDF_PARSER__MAX_FILE_SIZE_MB: int = 20
    PDF_PARSER__DO_OCR: bool = False
    PDF_PARSER__DO_TABLE_STRUCTURE: bool = True

    # RAG Settings
    RETRIEVAL_K: int = 5
    TEMPERATURE: float = 0.7
    MAX_TOKENS: int = 2048

    # Langfuse Observability
    LANGFUSE__HOST: str = "http://langfuse:3000"
    LANGFUSE__PUBLIC_KEY: Optional[str] = None
    LANGFUSE__SECRET_KEY: Optional[str] = None
    LANGFUSE_NEXTAUTH_SECRET: str = "changeThisToASecureRandomString32CharsMin"
    LANGFUSE_SALT: str = "changeThisToAnotherSecureRandomString"

    # Optional API Keys
    OPENAI_API_KEY: Optional[str] = None
    ANTHROPIC_API_KEY: Optional[str] = None

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False, extra="allow"
    )


@lru_cache()
def get_settings() -> Settings:
    """
    Get cached settings instance.

    Returns:
        Settings: Application settings
    """
    return Settings()
