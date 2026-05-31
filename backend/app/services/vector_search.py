"""
Vector Search Service
Handles embedding storage and semantic search using Pinecone
"""

from typing import Optional

from app.config import settings
from app.services.ai_processor import AIProcessor


# Global Pinecone index (initialized lazily)
_index = None


def get_pinecone_index():
    """Get or initialize Pinecone index"""
    global _index
    
    if _index is None:
        if not settings.pinecone_api_key:
            return None
        
        try:
            from pinecone import Pinecone
            pc = Pinecone(api_key=settings.pinecone_api_key)
            _index = pc.Index(settings.pinecone_index)
        except Exception as e:
            print(f"Failed to initialize Pinecone: {e}")
            return None
    
    return _index


async def store_embedding(
    bookmark_id: str,
    text: str,
    metadata: dict
) -> bool:
    """
    Store embedding for a bookmark in Pinecone.
    
    Args:
        bookmark_id: Unique bookmark ID
        text: Text to embed (summary + key points + tags)
        metadata: Bookmark metadata for filtering
        
    Returns:
        True if successful, False otherwise
    """
    index = get_pinecone_index()
    if not index:
        print("Pinecone not configured, skipping embedding storage")
        return False
    
    try:
        ai = AIProcessor()
        embedding = await ai.generate_embedding(text)
        
        if not embedding:
            return False
        
        # Upsert to Pinecone
        index.upsert(
            vectors=[{
                "id": bookmark_id,
                "values": embedding,
                "metadata": {
                    "url": metadata.get("url", ""),
                    "title": metadata.get("title", ""),
                    "platform": metadata.get("platform", ""),
                    "summary": metadata.get("summary", "")[:500],  # Limit metadata size
                    "tags": metadata.get("tags", []),
                }
            }]
        )
        
        return True
        
    except Exception as e:
        print(f"Error storing embedding: {e}")
        return False


async def semantic_search(
    query: str,
    limit: int = 10,
    platform_filter: Optional[str] = None
) -> tuple[list[dict], Optional[str]]:
    """
    Perform semantic search across bookmarks.
    
    Args:
        query: Natural language search query
        limit: Maximum number of results
        platform_filter: Optional platform filter
        
    Returns:
        Tuple of (search results, LLM-generated answer)
    """
    index = get_pinecone_index()
    
    # Generate query embedding
    ai = AIProcessor()
    query_embedding = await ai.generate_embedding(query)
    
    if not query_embedding:
        return [], None
    
    # Build filter
    filter_dict = {}
    if platform_filter:
        filter_dict["platform"] = platform_filter
    
    try:
        # Search in Pinecone
        if index:
            results = index.query(
                vector=query_embedding,
                top_k=limit,
                include_metadata=True,
                filter=filter_dict if filter_dict else None
            )
            
            # Format results
            search_results = []
            for match in results.matches:
                search_results.append({
                    "bookmark_id": match.id,
                    "url": match.metadata.get("url", ""),
                    "title": match.metadata.get("title"),
                    "summary": match.metadata.get("summary"),
                    "relevance_score": match.score,
                })
        else:
            # Fallback: return empty results if Pinecone not configured
            search_results = []
        
        # Generate natural language answer
        answer = await ai.generate_search_answer(query, search_results)
        
        return search_results, answer
        
    except Exception as e:
        print(f"Error in semantic search: {e}")
        return [], None
