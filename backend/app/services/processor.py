"""
Bookmark Processing Service
Orchestrates content extraction, AI processing, and embedding storage
"""

from datetime import datetime

from app.services.url_detector import detect_platform
from app.services.extractors.youtube import YouTubeExtractor
from app.services.extractors.webpage import WebpageExtractor
from app.services.ai_processor import AIProcessor
from app.services.vector_search import store_embedding


async def process_bookmark(bookmark_id: str, bookmarks_db: dict):
    """
    Process a bookmark: extract content, summarize with AI, store embeddings.
    
    This runs as a background task after bookmark creation.
    
    Args:
        bookmark_id: ID of the bookmark to process
        bookmarks_db: Reference to the bookmarks database
    """
    if bookmark_id not in bookmarks_db:
        return
    
    bookmark = bookmarks_db[bookmark_id]
    bookmark["status"] = "processing"
    
    try:
        url = bookmark["url"]
        platform = bookmark["platform"]
        
        # 1. Extract content based on platform
        content = None
        title = None
        
        if platform == "youtube":
            extractor = YouTubeExtractor()
            result = await extractor.extract(url)
            if result:
                title = result.title
                content = f"Title: {result.title}\nChannel: {result.channel}\n\n"
                if result.transcript:
                    content += f"Transcript:\n{result.transcript}"
                else:
                    content += "No transcript available."
                    
        else:
            # Default to webpage extraction
            extractor = WebpageExtractor()
            result = await extractor.extract(url)
            if result:
                title = result.title
                content = f"Title: {result.title}\n"
                if result.description:
                    content += f"Description: {result.description}\n"
                content += f"\nContent:\n{result.main_text}"
        
        if not content:
            bookmark["status"] = "failed"
            return
        
        bookmark["title"] = title
        
        # 2. Process with AI
        ai = AIProcessor()
        processed = await ai.process_content(
            content=content,
            title=title,
            platform=platform
        )
        
        bookmark["summary"] = processed.summary
        bookmark["key_points"] = processed.key_points
        bookmark["tags"] = processed.tags
        
        # 3. Generate and store embedding
        # Combine summary + key points + tags for rich embedding
        embedding_text = f"{title or ''} {processed.summary} {' '.join(processed.key_points)} {' '.join(processed.tags)}"
        
        await store_embedding(
            bookmark_id=bookmark_id,
            text=embedding_text,
            metadata={
                "url": url,
                "title": title,
                "platform": platform,
                "summary": processed.summary,
                "tags": processed.tags,
            }
        )
        
        # 4. Mark as complete
        bookmark["status"] = "completed"
        bookmark["processed_at"] = datetime.utcnow()
        
    except Exception as e:
        print(f"Error processing bookmark {bookmark_id}: {e}")
        bookmark["status"] = "failed"
