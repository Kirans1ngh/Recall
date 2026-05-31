"""
Search API routes - Semantic search across bookmarks
"""

from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import Optional

from app.services.vector_search import semantic_search

router = APIRouter()


class SearchResult(BaseModel):
    """A single search result"""
    bookmark_id: str
    url: str
    title: Optional[str]
    summary: Optional[str]
    relevance_score: float
    matched_content: Optional[str] = None


class SearchResponse(BaseModel):
    """Search response with results and metadata"""
    query: str
    results: list[SearchResult]
    total: int
    answer: Optional[str] = None  # LLM-generated answer to the query


@router.get("", response_model=SearchResponse)
async def search_bookmarks(
    q: str = Query(..., description="Natural language search query", min_length=2),
    limit: int = Query(10, ge=1, le=50),
    platform: Optional[str] = Query(None, description="Filter by platform")
):
    """
    Search bookmarks using natural language.
    
    Examples:
    - "What was that video about AI tools?"
    - "Song recommendations from last week"
    - "Articles about Python async"
    """
    results, answer = await semantic_search(
        query=q,
        limit=limit,
        platform_filter=platform
    )
    
    return SearchResponse(
        query=q,
        results=results,
        total=len(results),
        answer=answer
    )
