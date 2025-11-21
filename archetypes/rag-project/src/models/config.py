"""Configuration settings using Pydantic Settings."""
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False
    )
    
    # API Settings
    app_name: str = "RAG API"
    app_version: str = "1.0.0"
    debug: bool = False
    
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Vector DB
    vector_db_host: str = "vector-db"
    vector_db_port: int = 8001
    collection_name: str = "documents"
    
    # Ollama
    ollama_host: str = "http://ollama:11434"
    ollama_model: str = "llama2"
    
    # Embeddings
    embedding_model: str = "all-MiniLM-L6-v2"
    
    # Document Processing
    chunk_size: int = 500
    chunk_overlap: int = 50
    max_upload_size: int = 10 * 1024 * 1024
    
    # RAG
    retrieval_k: int = 3
    temperature: float = 0.7
    max_tokens: int = 512
    
    # Optional
    openai_api_key: str | None = None
    
    @property
    def vector_db_url(self) -> str:
        return f"http://{self.vector_db_host}:{self.vector_db_port}"


settings = Settings()
