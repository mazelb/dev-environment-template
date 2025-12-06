"""
Data Quality Validation Framework
"""
from pydantic import BaseModel, Field, validator
from typing import Optional

class DataQualityCheck:
    """Base class for data quality checks"""

    @staticmethod
    def check_nulls(df, columns):
        """Check for unexpected NULL values"""
        null_counts = df[columns].isnull().sum()
        return null_counts[null_counts > 0]

    @staticmethod
    def check_duplicates(df, key_columns):
        """Check for duplicate records"""
        return df[df.duplicated(subset=key_columns, keep=False)]

    @staticmethod
    def check_referential_integrity(df, fk_column, reference_df, pk_column):
        """Check foreign key integrity"""
        return df[~df[fk_column].isin(reference_df[pk_column])]

class UserRecord(BaseModel):
    """Example validated user record"""
    email: str
    age: int = Field(ge=0, le=150)
    name: str = Field(min_length=1, max_length=100)

    @validator('email')
    def validate_email(cls, v):
        if '@' not in v:
            raise ValueError('Invalid email')
        return v.lower()
