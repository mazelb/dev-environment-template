"""
JWT token creation and validation.
"""

from datetime import datetime, timedelta
from typing import Optional

from jose import JWTError, jwt

from src.core.config import settings
from src.models.token import TokenData


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a JWT access token.

    Args:
        data: Data to encode in token
        expires_delta: Token expiration time

    Returns:
        Encoded JWT token
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.API_ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode,
        settings.API_SECRET_KEY,
        algorithm=settings.API_ALGORITHM,
    )

    return encoded_jwt


def verify_token(token: str) -> Optional[TokenData]:
    """
    Verify and decode a JWT token.

    Args:
        token: JWT token to verify

    Returns:
        TokenData if valid, None otherwise
    """
    try:
        payload = jwt.decode(
            token,
            settings.API_SECRET_KEY,
            algorithms=[settings.API_ALGORITHM],
        )
        username: str = payload.get("sub")

        if username is None:
            return None

        return TokenData(username=username)

    except JWTError:
        return None
