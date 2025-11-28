"""Unit tests for authentication module."""

from datetime import timedelta

import pytest
from jose import jwt
from src.auth.jwt import create_access_token, decode_access_token
from src.core.config import settings
from src.core.security import get_password_hash, verify_password


@pytest.mark.unit
class TestPasswordHashing:
    """Test password hashing and verification."""

    def test_password_hashing(self):
        """Test password can be hashed."""
        password = "testpassword123"
        hashed = get_password_hash(password)

        assert hashed != password
        assert len(hashed) > 20

    def test_password_verification(self):
        """Test password verification."""
        password = "testpassword123"
        hashed = get_password_hash(password)

        assert verify_password(password, hashed) is True
        assert verify_password("wrongpassword", hashed) is False

    def test_different_hashes_for_same_password(self):
        """Test same password produces different hashes (salt)."""
        password = "testpassword123"
        hash1 = get_password_hash(password)
        hash2 = get_password_hash(password)

        assert hash1 != hash2
        assert verify_password(password, hash1) is True
        assert verify_password(password, hash2) is True


@pytest.mark.unit
class TestJWT:
    """Test JWT token generation and validation."""

    def test_create_access_token(self):
        """Test creating access token."""
        data = {"sub": "test@example.com"}
        token = create_access_token(data)

        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 20

    def test_create_token_with_expiry(self):
        """Test creating token with custom expiry."""
        data = {"sub": "test@example.com"}
        token = create_access_token(data, expires_delta=timedelta(minutes=30))

        assert token is not None

    def test_decode_valid_token(self):
        """Test decoding valid token."""
        data = {"sub": "test@example.com", "user_id": 123}
        token = create_access_token(data)

        decoded = decode_access_token(token)

        assert decoded is not None
        assert decoded["sub"] == "test@example.com"
        assert decoded["user_id"] == 123

    def test_decode_invalid_token(self):
        """Test decoding invalid token."""
        invalid_token = "invalid.token.here"

        decoded = decode_access_token(invalid_token)

        assert decoded is None

    def test_decode_expired_token(self):
        """Test decoding expired token."""
        data = {"sub": "test@example.com"}
        token = create_access_token(data, expires_delta=timedelta(seconds=-1))

        decoded = decode_access_token(token)

        assert decoded is None

    def test_token_contains_required_claims(self):
        """Test token contains required claims."""
        data = {"sub": "test@example.com"}
        token = create_access_token(data)

        # Decode without verification to check structure
        decoded = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )

        assert "sub" in decoded
        assert "exp" in decoded
        assert decoded["sub"] == "test@example.com"


@pytest.mark.unit
class TestAuthDependencies:
    """Test authentication dependencies."""

    def test_get_current_user_dependency(self):
        """Test get_current_user dependency structure."""
        from src.auth.dependencies import get_current_user

        assert get_current_user is not None
        assert callable(get_current_user)
