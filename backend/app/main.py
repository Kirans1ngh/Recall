"""
Bookmark AI - Main FastAPI Application
AI-powered bookmark aggregator with semantic search
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.routes import bookmarks, search
from app.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    print(f"[INFO] Starting Bookmark AI (LLM: {settings.effective_llm_provider}, Embedding: {settings.effective_embedding_provider})...")
    yield
    print("[INFO] Shutting down...")


app = FastAPI(
    title="Bookmark AI",
    description="AI-powered bookmark aggregator with semantic search",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(bookmarks.router, prefix="/api/bookmarks", tags=["bookmarks"])
app.include_router(search.router, prefix="/api/search", tags=["search"])


@app.get("/")
async def root():
    return {
        "message": "Bookmark AI API",
        "status": "running",
        "llm_provider": settings.effective_llm_provider,
        "embedding_provider": settings.effective_embedding_provider,
    }


@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "llm_provider": settings.effective_llm_provider,
        "embedding_provider": settings.effective_embedding_provider,
    }
