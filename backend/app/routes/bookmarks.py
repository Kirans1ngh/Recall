"""
Bookmark API routes
"""

from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel, HttpUrl
from typing import Optional
from datetime import datetime
from uuid import uuid4

from app.services.url_detector import detect_platform
from app.services.processor import process_bookmark

router = APIRouter()


class BookmarkCreate(BaseModel):
    """Request model for creating a bookmark"""
    url: HttpUrl
    notes: Optional[str] = None


class BookmarkResponse(BaseModel):
    """Response model for a bookmark"""
    id: str
    url: str
    platform: str
    title: Optional[str] = None
    summary: Optional[str] = None
    key_points: Optional[list[str]] = None
    tags: Optional[list[str]] = None
    status: str  # pending, processing, completed, failed
    created_at: datetime
    processed_at: Optional[datetime] = None


# In-memory storage for MVP (replace with Supabase later)
bookmarks_db: dict[str, dict] = {}


@router.post("", response_model=BookmarkResponse)
async def create_bookmark(
    bookmark: BookmarkCreate,
    background_tasks: BackgroundTasks
):
    """
    Create a new bookmark from a shared URL.
    Processing happens asynchronously in the background.
    """
    url_str = str(bookmark.url)
    platform = detect_platform(url_str)
    
    bookmark_id = str(uuid4())
    now = datetime.utcnow()
    
    bookmark_data = {
        "id": bookmark_id,
        "url": url_str,
        "platform": platform,
        "title": None,
        "summary": None,
        "key_points": None,
        "tags": None,
        "notes": bookmark.notes,
        "status": "pending",
        "created_at": now,
        "processed_at": None,
    }
    
    bookmarks_db[bookmark_id] = bookmark_data
    
    # Queue background processing
    background_tasks.add_task(process_bookmark, bookmark_id, bookmarks_db)
    
    return BookmarkResponse(**bookmark_data)


@router.get("", response_model=list[BookmarkResponse])
async def list_bookmarks(
    status: Optional[str] = None,
    platform: Optional[str] = None,
    limit: int = 50,
    offset: int = 0
):
    """List all bookmarks with optional filters"""
    results = list(bookmarks_db.values())
    
    # Apply filters
    if status:
        results = [b for b in results if b["status"] == status]
    if platform:
        results = [b for b in results if b["platform"] == platform]
    
    # Sort by created_at descending
    results.sort(key=lambda x: x["created_at"], reverse=True)
    
    # Paginate
    results = results[offset:offset + limit]
    
    return [BookmarkResponse(**b) for b in results]


@router.get("/{bookmark_id}", response_model=BookmarkResponse)
async def get_bookmark(bookmark_id: str):
    """Get a specific bookmark by ID"""
    if bookmark_id not in bookmarks_db:
        raise HTTPException(status_code=404, detail="Bookmark not found")
    
    return BookmarkResponse(**bookmarks_db[bookmark_id])


@router.delete("/{bookmark_id}")
async def delete_bookmark(bookmark_id: str):
    """Delete a bookmark"""
    if bookmark_id not in bookmarks_db:
        raise HTTPException(status_code=404, detail="Bookmark not found")
    
    del bookmarks_db[bookmark_id]
    return {"message": "Bookmark deleted"}
