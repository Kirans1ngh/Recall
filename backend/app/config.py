"""
Application configuration using Pydantic settings
"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Database
    database_url: str = "postgresql://localhost:5432/bookmark_ai"
    
    # Redis
    redis_url: str = "redis://localhost:6379"
    
    # OpenAI
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"
    embedding_model: str = "text-embedding-3-small"
    
    # Pinecone
    pinecone_api_key: str = ""
    pinecone_index: str = "bookmarks"
    pinecone_environment: str = "us-east-1"
    
    # App config
    debug: bool = True
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
