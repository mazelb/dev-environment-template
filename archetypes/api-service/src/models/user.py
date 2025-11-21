"""
User data models.
"""
from typing import Optional
from pydantic import BaseModel, EmailStr


class User(BaseModel):
    """User model."""
    
    username: str
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool = True
    is_admin: bool = False


class UserCreate(BaseModel):
    """User creation model."""
    
    username: str
    email: EmailStr
    password: str
    full_name: Optional[str] = None


class UserInDB(User):
    """User model with hashed password."""
    
    hashed_password: str
