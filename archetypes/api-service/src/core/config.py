"""
Application configuration using Pydantic settings.
"""

from typing import List

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""

    # Project
    PROJECT_NAME: str = "API Service"

    # API
    API_SECRET_KEY: str
    API_ALGORITHM: str = "HS256"
    API_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Redis
    REDIS_HOST: str = "redis"
    REDIS_PORT: int = 6379

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60

    # CORS
    CORS_ORIGINS: List[str] = ["http://localhost:3000"]

    # Logging
    LOG_LEVEL: str = "INFO"

    # Database (PostgreSQL)
    POSTGRES_DB: str = "api_db"
    POSTGRES_USER: str = "api_user"
    POSTGRES_PASSWORD: str = "api_password"
    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    DATABASE_URL: str = (
        "postgresql+psycopg2://api_user:api_password@postgres:5432/api_db"
    )

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
