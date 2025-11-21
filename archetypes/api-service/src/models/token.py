"""
Authentication token models.
"""
from typing import Optional
from pydantic import BaseModel


class Token(BaseModel):
    """Token response model."""
    
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Token payload data."""
    
    username: Optional[str] = None
