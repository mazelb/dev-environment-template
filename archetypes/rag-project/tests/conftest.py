"""Pytest configuration and shared fixtures for RAG project tests."""

import os
import sys
from pathlib import Path
from typing import Generator
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi.testclient import TestClient
from redis import Redis
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

# Defer imports to avoid loading modules with missing dependencies at import time
try:
    from src.config import Settings
    from src.db.base import Base
except ImportError:
    Settings = None
    Base = None


@pytest.fixture(scope="session")
def test_settings():
    """Create test settings with overrides."""
    os.environ["ENVIRONMENT"] = "test"
    os.environ["DEBUG"] = "false"
    os.environ["DATABASE_URL"] = "sqlite:///./test.db"
    os.environ["REDIS__HOST"] = "localhost"
    os.environ["REDIS__PORT"] = "6379"
    os.environ["REDIS__DB"] = "1"  # Use separate DB for tests
    os.environ["OPENSEARCH__HOST"] = "localhost"
    os.environ["OPENSEARCH__PORT"] = "9200"
    os.environ["OPENSEARCH__USE_SSL"] = "false"
    os.environ["OLLAMA__BASE_URL"] = "http://localhost:11434"
    os.environ["EMBEDDING__MODEL_NAME"] = "all-MiniLM-L6-v2"

    try:
        from src.config import Settings

        return Settings()
    except ImportError:
        # Return a mock settings object if imports fail
        class MockSettings:
            database_url = "sqlite:///./test.db"
            redis = type(
                "obj", (object,), {"host": "localhost", "port": 6379, "db": 1}
            )()
            opensearch = type(
                "obj", (object,), {"host": "localhost", "port": 9200, "use_ssl": False}
            )()
            ollama = type("obj", (object,), {"base_url": "http://localhost:11434"})()
            embedding = type("obj", (object,), {"model_name": "all-MiniLM-L6-v2"})()
            chunking = type(
                "obj", (object,), {"chunk_size": 600, "chunk_overlap": 100}
            )()

        return MockSettings()


@pytest.fixture(scope="function")
def test_db_engine():
    """Create a test database engine."""
    engine = create_engine(
        "sqlite:///./test.db", connect_args={"check_same_thread": False}
    )
    Base.metadata.create_all(bind=engine)
    yield engine
    Base.metadata.drop_all(bind=engine)
    # Clean up test database file
    if os.path.exists("./test.db"):
        os.remove("./test.db")


@pytest.fixture(scope="function")
def test_db_session(test_db_engine) -> Generator[Session, None, None]:
    """Create a test database session."""
    TestingSessionLocal = sessionmaker(
        autocommit=False, autoflush=False, bind=test_db_engine
    )
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture(scope="function")
def mock_redis() -> Generator[MagicMock, None, None]:
    """Create a mock Redis client."""
    redis_mock = MagicMock(spec=Redis)
    redis_mock.ping.return_value = True
    redis_mock.get.return_value = None
    redis_mock.set.return_value = True
    redis_mock.delete.return_value = 1
    redis_mock.exists.return_value = 0
    redis_mock.flushdb.return_value = True
    yield redis_mock


@pytest.fixture(scope="function")
def mock_opensearch_client() -> Generator[MagicMock, None, None]:
    """Create a mock OpenSearch client."""
    client_mock = MagicMock()
    client_mock.ping.return_value = True
    client_mock.indices.exists.return_value = False
    client_mock.indices.create.return_value = {"acknowledged": True}
    client_mock.indices.delete.return_value = {"acknowledged": True}
    client_mock.index.return_value = {"_id": "test_id", "result": "created"}
    client_mock.search.return_value = {"hits": {"total": {"value": 0}, "hits": []}}
    client_mock.cluster.health.return_value = {"status": "green"}
    yield client_mock


@pytest.fixture(scope="function")
def mock_ollama_client() -> Generator[AsyncMock, None, None]:
    """Create a mock Ollama client."""
    client_mock = AsyncMock()
    client_mock.health.return_value = True
    client_mock.list_models.return_value = ["llama3.2:1b"]
    client_mock.generate.return_value = "This is a test response."

    async def mock_stream(*args, **kwargs):
        yield "This "
        yield "is "
        yield "a "
        yield "test."

    client_mock.generate_stream.return_value = mock_stream()
    client_mock.embed.return_value = [0.1] * 384
    yield client_mock


@pytest.fixture(scope="function")
def mock_embedding_service() -> Generator[MagicMock, None, None]:
    """Create a mock embedding service."""
    service_mock = MagicMock()
    service_mock.embed_text.return_value = [0.1] * 384
    service_mock.embed_texts.return_value = [[0.1] * 384, [0.2] * 384]
    service_mock.embed_query.return_value = [0.1] * 384
    service_mock.embed_documents.return_value = [[0.1] * 384]
    service_mock.get_dimension.return_value = 384
    service_mock.similarity.return_value = 0.95
    yield service_mock


@pytest.fixture(scope="function")
def sample_documents() -> list[dict]:
    """Sample documents for testing."""
    return [
        {
            "id": "doc1",
            "content": "Artificial intelligence is transforming industries.",
            "metadata": {"source": "test", "category": "AI"},
        },
        {
            "id": "doc2",
            "content": "Machine learning is a subset of AI.",
            "metadata": {"source": "test", "category": "ML"},
        },
        {
            "id": "doc3",
            "content": "Deep learning uses neural networks.",
            "metadata": {"source": "test", "category": "DL"},
        },
    ]


@pytest.fixture(scope="function")
def sample_chunks() -> list[dict]:
    """Sample document chunks for testing."""
    return [
        {
            "text": "Artificial intelligence is transforming industries.",
            "metadata": {"chunk_index": 0, "source": "doc1"},
            "start_char": 0,
            "end_char": 50,
        },
        {
            "text": "Machine learning is a subset of AI.",
            "metadata": {"chunk_index": 0, "source": "doc2"},
            "start_char": 0,
            "end_char": 35,
        },
    ]


@pytest.fixture(scope="module")
def docker_compose_up():
    """Start Docker Compose services for integration tests."""
    import subprocess

    # Check if docker-compose is available
    try:
        subprocess.run(["docker-compose", "version"], check=True, capture_output=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pytest.skip("Docker Compose not available")

    # Start services
    subprocess.run(
        ["docker-compose", "up", "-d"], check=True, cwd=Path(__file__).parent.parent
    )

    # Wait for services to be healthy
    import time

    time.sleep(30)

    yield

    # Cleanup
    subprocess.run(
        ["docker-compose", "down", "-v"], check=False, cwd=Path(__file__).parent.parent
    )


@pytest.fixture(scope="function")
def client(test_settings):
    """Create a test client for the FastAPI app."""
    try:
        from src.api.main import app

        with TestClient(app) as test_client:
            yield test_client
    except ImportError:
        pytest.skip("FastAPI app dependencies not available")
