"""
AI Processor Service
Handles content summarization and embedding generation using OpenAI
"""

from typing import Optional
from dataclasses import dataclass
from openai import AsyncOpenAI

from app.config import settings


@dataclass
class ProcessedContent:
    """AI-processed content"""
    summary: str
    key_points: list[str]
    tags: list[str]
    entities: list[str]  # People, products, companies mentioned


class AIProcessor:
    """Process content using OpenAI"""
    
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.openai_api_key)
        self.model = settings.openai_model
        self.embedding_model = settings.embedding_model
    
    async def process_content(
        self,
        content: str,
        title: Optional[str] = None,
        platform: str = "webpage"
    ) -> ProcessedContent:
        """
        Process content to extract summary, key points, and tags.
        
        Args:
            content: Raw text content (transcript, article text, etc.)
            title: Optional title for context
            platform: Source platform for context
            
        Returns:
            ProcessedContent with AI-generated summary and metadata
        """
        system_prompt = """You are a content analyzer that extracts structured information from saved bookmarks.
Your job is to help users remember and find content later through semantic search.

Analyze the content and return a JSON object with:
1. "summary": A 2-3 sentence summary capturing the main topic and value
2. "key_points": Array of 3-5 bullet points of the most important/memorable information
3. "tags": Array of 5-10 relevant topic tags (lowercase, single words or short phrases)
4. "entities": Array of specific names mentioned (people, companies, products, tools, etc.)

Be concise but comprehensive. Focus on what makes this content memorable and searchable."""

        user_prompt = f"""Platform: {platform}
Title: {title or 'Unknown'}

Content:
{content[:8000]}"""  # Limit content length for API
        
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                response_format={"type": "json_object"},
                temperature=0.3,
            )
            
            import json
            result = json.loads(response.choices[0].message.content)
            
            return ProcessedContent(
                summary=result.get("summary", ""),
                key_points=result.get("key_points", []),
                tags=result.get("tags", []),
                entities=result.get("entities", []),
            )
            
        except Exception as e:
            print(f"Error processing content with AI: {e}")
            # Return basic fallback
            return ProcessedContent(
                summary=content[:200] + "...",
                key_points=[],
                tags=[],
                entities=[],
            )
    
    async def generate_embedding(self, text: str) -> list[float]:
        """
        Generate embedding vector for text.
        
        Args:
            text: Text to embed
            
        Returns:
            Embedding vector as list of floats
        """
        try:
            response = await self.client.embeddings.create(
                model=self.embedding_model,
                input=text[:8000],  # Limit input length
            )
            return response.data[0].embedding
            
        except Exception as e:
            print(f"Error generating embedding: {e}")
            return []
    
    async def generate_search_answer(
        self,
        query: str,
        context_docs: list[dict]
    ) -> str:
        """
        Generate a natural language answer to a search query.
        
        Args:
            query: User's search query
            context_docs: Relevant bookmarks for context
            
        Returns:
            Natural language answer
        """
        if not context_docs:
            return "I couldn't find any relevant bookmarks for your query."
        
        # Build context from matching documents
        context = "\n\n".join([
            f"**{doc.get('title', 'Untitled')}** ({doc.get('platform', 'unknown')})\n{doc.get('summary', '')}"
            for doc in context_docs[:5]
        ])
        
        system_prompt = """You are a helpful assistant that answers questions about the user's saved bookmarks.
Based on the relevant bookmarks provided, give a concise answer to the user's question.
Mention specific bookmarks when relevant."""

        user_prompt = f"""Question: {query}

Relevant saved bookmarks:
{context}"""
        
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt}
                ],
                temperature=0.5,
                max_tokens=300,
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            print(f"Error generating search answer: {e}")
            return ""
