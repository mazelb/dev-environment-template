"""
Authentication tests.
"""
from src.auth.jwt import create_access_token, verify_token
from src.core.security import get_password_hash, verify_password


def test_password_hashing():
    """Test password hashing and verification."""
    password = "testpassword123"
    hashed = get_password_hash(password)
    
    assert hashed != password
    assert verify_password(password, hashed)
    assert not verify_password("wrongpassword", hashed)


def test_create_access_token():
    """Test JWT token creation."""
    data = {"sub": "testuser"}
    token = create_access_token(data)
    
    assert token is not None
    assert len(token) > 0


def test_verify_token():
    """Test JWT token verification."""
    username = "testuser"
    token = create_access_token({"sub": username})
    
    token_data = verify_token(token)
    
    assert token_data is not None
    assert token_data.username == username


def test_verify_invalid_token():
    """Test invalid token verification."""
    invalid_token = "invalid.token.here"
    token_data = verify_token(invalid_token)
    
    assert token_data is None


def test_token_expiration():
    """Test expired token."""
    from datetime import timedelta
    
    data = {"sub": "testuser"}
    # Create token that expires immediately
    token = create_access_token(data, expires_delta=timedelta(seconds=-1))
    
    token_data = verify_token(token)
    assert token_data is None
