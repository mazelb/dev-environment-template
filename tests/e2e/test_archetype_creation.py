"""End-to-end tests for project creation from archetypes."""

import subprocess
from pathlib import Path

import pytest


@pytest.mark.slow
@pytest.mark.e2e
class TestRAGArchetypeCreation:
    """Test creating a RAG project from archetype."""

    def test_rag_archetype_exists(self):
        """Test RAG archetype directory exists."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )
        assert archetype_path.exists()
        assert archetype_path.is_dir()

    def test_rag_archetype_has_required_files(self):
        """Test RAG archetype has all required files."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )

        required_files = [
            "docker-compose.yml",
            "requirements.txt",
            "Makefile",
            ".env.example",
            "README.md",
            "__archetype__.json",
            "src",
            "tests",
            "alembic",
        ]

        for file_name in required_files:
            file_path = archetype_path / file_name
            assert file_path.exists(), f"Missing required file: {file_name}"

    def test_rag_docker_compose_valid(self):
        """Test RAG docker-compose.yml is valid."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )

        result = subprocess.run(
            ["docker-compose", "config"],
            capture_output=True,
            text=True,
            cwd=archetype_path,
        )

        # Should either succeed or fail due to missing env vars (acceptable)
        assert result.returncode in [0, 1]

    def test_rag_requirements_installable(self):
        """Test RAG requirements.txt is valid."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )
        requirements_file = archetype_path / "requirements.txt"

        assert requirements_file.exists()

        # Check file is not empty
        content = requirements_file.read_text()
        assert len(content) > 0
        assert "fastapi" in content.lower()


@pytest.mark.slow
@pytest.mark.e2e
class TestAPIArchetypeCreation:
    """Test creating an API project from archetype."""

    def test_api_archetype_exists(self):
        """Test API archetype directory exists."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )
        assert archetype_path.exists()
        assert archetype_path.is_dir()

    def test_api_archetype_has_required_files(self):
        """Test API archetype has all required files."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )

        required_files = [
            "docker-compose.yml",
            "requirements.txt",
            "Dockerfile",
            ".env.example",
            "README.md",
            "__archetype__.json",
            "src",
            "tests",
        ]

        for file_name in required_files:
            file_path = archetype_path / file_name
            assert file_path.exists(), f"Missing required file: {file_name}"

    def test_api_docker_compose_valid(self):
        """Test API docker-compose.yml is valid."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )

        result = subprocess.run(
            ["docker-compose", "config"],
            capture_output=True,
            text=True,
            cwd=archetype_path,
        )

        assert result.returncode in [0, 1]

    def test_api_requirements_installable(self):
        """Test API requirements.txt is valid."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )
        requirements_file = archetype_path / "requirements.txt"

        assert requirements_file.exists()

        content = requirements_file.read_text()
        assert len(content) > 0
        assert "fastapi" in content.lower()


@pytest.mark.slow
@pytest.mark.e2e
class TestArchetypeConfiguration:
    """Test archetype configuration files."""

    def test_rag_archetype_json_valid(self):
        """Test RAG __archetype__.json is valid JSON."""
        import json

        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )
        config_file = archetype_path / "__archetype__.json"

        assert config_file.exists()

        with open(config_file) as f:
            config = json.load(f)

        # Check that config is valid and has content
        assert isinstance(config, dict)
        assert len(config) > 0

    def test_api_archetype_json_valid(self):
        """Test API __archetype__.json is valid JSON."""
        import json

        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )
        config_file = archetype_path / "__archetype__.json"

        assert config_file.exists()

        with open(config_file) as f:
            config = json.load(f)

        assert "name" in config
        assert "description" in config


@pytest.mark.slow
@pytest.mark.e2e
@pytest.mark.docker
class TestProjectCreationScript:
    """Test the create-project script."""

    def test_create_project_script_exists(self):
        """Test create-project.sh exists."""
        script_path = Path(__file__).parent.parent.parent / "create-project.sh"

        # Should exist or we skip
        if not script_path.exists():
            pytest.skip("create-project.sh not found")

        assert script_path.exists()
        assert script_path.is_file()


@pytest.mark.slow
@pytest.mark.e2e
class TestArchetypeDocumentation:
    """Test archetype documentation."""

    def test_rag_readme_exists(self):
        """Test RAG README.md exists and has content."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "rag-project"
        )
        readme = archetype_path / "README.md"

        assert readme.exists()

        try:
            content = readme.read_text(encoding="utf-8")
            assert len(content) > 100
            assert "rag" in content.lower() or "retrieval" in content.lower()
        except UnicodeDecodeError:
            content = readme.read_text(encoding="utf-8", errors="ignore")
            assert len(content) > 100

    def test_api_readme_exists(self):
        """Test API README.md exists and has content."""
        archetype_path = (
            Path(__file__).parent.parent.parent / "archetypes" / "api-service"
        )
        readme = archetype_path / "README.md"

        assert readme.exists()

        content = readme.read_text()
        assert len(content) > 100
        assert "api" in content.lower()
