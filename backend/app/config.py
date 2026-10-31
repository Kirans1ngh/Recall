"""
Application configuration using Pydantic settings
"""

from functools import lru_cache
from typing import Optional, Literal
from pydantic_settings import BaseSettings, SettingsConfigDict


ProviderType = Literal["openai", "gemini", "nvidia_nim", "auto"]


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""

    # Database
    database_url: str = "postgresql://localhost:5432/bookmark_ai"

    # Redis
    redis_url: str = "redis://localhost:6379"

    # Active Provider Selections ("openai", "gemini", "nvidia_nim", or "auto")
    llm_provider: ProviderType = "auto"
    embedding_provider: ProviderType = "auto"

    # OpenAI Settings
    openai_api_key: str = ""
    openai_base_url: Optional[str] = None
    openai_model: str = "gpt-4o-mini"
    openai_embedding_model: str = "text-embedding-3-small"

    # Google Gemini Settings (OpenAI-compatible endpoint)
    gemini_api_key: str = ""
    gemini_base_url: str = "https://generativelanguage.googleapis.com/v1beta/openai/"
    gemini_model: str = "gemini-1.5-flash"
    gemini_embedding_model: str = "text-embedding-004"

    # NVIDIA NIM Settings (OpenAI-compatible endpoint)
    nvidia_nim_api_key: str = ""
    nvidia_nim_base_url: str = "https://integrate.api.nvidia.com/v1"
    nvidia_nim_model: str = "meta/llama-3.3-70b-instruct"
    nvidia_nim_embedding_model: str = "nvidia/llama-3.2-nv-embedqa-1b-v2"

    # Backwards-compatible aliases
    embedding_model: Optional[str] = None

    # Pinecone
    pinecone_api_key: str = ""
    pinecone_index: str = "bookmarks"
    pinecone_environment: str = "us-east-1"

    # App config
    debug: bool = True

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def effective_llm_provider(self) -> str:
        """Resolve the active LLM provider based on config or available keys"""
        val = (self.llm_provider or "auto").lower()
        if val != "auto":
            return val

        if self.gemini_api_key:
            return "gemini"
        if self.nvidia_nim_api_key:
            return "nvidia_nim"
        if self.openai_api_key:
            return "openai"
        return "openai"

    @property
    def effective_embedding_provider(self) -> str:
        """Resolve the active embedding provider based on config or available keys"""
        val = (self.embedding_provider or "auto").lower()
        if val != "auto":
            return val

        if self.gemini_api_key:
            return "gemini"
        if self.nvidia_nim_api_key:
            return "nvidia_nim"
        if self.openai_api_key:
            return "openai"
        return "openai"

    @property
    def active_llm_model(self) -> str:
        """Return the model name for the effective LLM provider"""
        provider = self.effective_llm_provider
        if provider == "gemini":
            return self.gemini_model
        elif provider == "nvidia_nim":
            return self.nvidia_nim_model
        return self.openai_model

    @property
    def active_embedding_model(self) -> str:
        """Return the model name for the effective embedding provider"""
        provider = self.effective_embedding_provider
        if provider == "gemini":
            return self.gemini_embedding_model
        elif provider == "nvidia_nim":
            return self.nvidia_nim_embedding_model
        return self.embedding_model or self.openai_embedding_model


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
