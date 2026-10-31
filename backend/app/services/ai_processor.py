"""
AI Processor Service
Handles content summarization, entity extraction, and embedding generation
across multiple providers: OpenAI, Google Gemini, and NVIDIA NIM.
"""

import json
import re
from typing import Optional
from dataclasses import dataclass
from openai import AsyncOpenAI

from app.config import settings


@dataclass
class ProcessedContent:
    """AI-processed content metadata"""
    summary: str
    key_points: list[str]
    tags: list[str]
    entities: list[str]


def parse_json_dict(text: str) -> dict:
    """
    Robustly extract and parse a JSON dictionary from an LLM response string.
    Handles raw JSON, markdown-wrapped JSON (```json ... ```), and surrounding text.
    """
    if not text or not isinstance(text, str):
        return {}

    cleaned = text.strip()

    # 1. Direct parse attempt
    try:
        data = json.loads(cleaned)
        if isinstance(data, dict):
            return data
    except Exception:
        pass

    # 2. Extract content from markdown code fences (```json ... ``` or ``` ... ```)
    code_block_match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", cleaned, re.IGNORECASE)
    if code_block_match:
        try:
            data = json.loads(code_block_match.group(1).strip())
            if isinstance(data, dict):
                return data
        except Exception:
            pass

    # 3. Find outer braces {...}
    first_brace = cleaned.find("{")
    last_brace = cleaned.rfind("}")
    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        candidate = cleaned[first_brace : last_brace + 1]
        try:
            data = json.loads(candidate)
            if isinstance(data, dict):
                return data
        except Exception:
            pass

    return {}


def create_ai_client(provider: str) -> tuple[AsyncOpenAI, str, str]:
    """
    Build AsyncOpenAI client, default chat model, and embedding model for the provider.
    Supported providers: 'openai', 'gemini', 'nvidia_nim'
    """
    provider_name = (provider or "openai").lower()

    if provider_name == "gemini":
        api_key = settings.gemini_api_key or "missing-gemini-key"
        base_url = settings.gemini_base_url
        chat_model = settings.gemini_model
        embedding_model = settings.gemini_embedding_model

    elif provider_name == "nvidia_nim":
        api_key = settings.nvidia_nim_api_key or "missing-nvidia-key"
        base_url = settings.nvidia_nim_base_url
        chat_model = settings.nvidia_nim_model
        embedding_model = settings.nvidia_nim_embedding_model

    else:  # openai
        api_key = settings.openai_api_key or "missing-openai-key"
        base_url = settings.openai_base_url
        chat_model = settings.openai_model
        embedding_model = settings.active_embedding_model

    client = AsyncOpenAI(api_key=api_key, base_url=base_url)
    return client, chat_model, embedding_model


class AIProcessor:
    """Process content using OpenAI, Google Gemini, or NVIDIA NIM"""

    def __init__(
        self,
        llm_provider: Optional[str] = None,
        embedding_provider: Optional[str] = None,
    ):
        self.llm_provider = (llm_provider or settings.effective_llm_provider).lower()
        self.embedding_provider = (embedding_provider or settings.effective_embedding_provider).lower()

        self.llm_client, self.llm_model, _ = create_ai_client(self.llm_provider)
        self.embedding_client, _, self.embedding_model = create_ai_client(self.embedding_provider)

        # Backwards compatibility attributes
        self.client = self.llm_client
        self.model = self.llm_model

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
        system_prompt = (
            "You are a content analyzer that extracts structured information from saved bookmarks.\n"
            "Your job is to help users remember and find content later through semantic search.\n\n"
            "Analyze the content and return a JSON object with exactly these fields:\n"
            "1. \"summary\": A 2-3 sentence summary capturing the main topic and value\n"
            "2. \"key_points\": Array of 3-5 bullet points of the most important/memorable information\n"
            "3. \"tags\": Array of 5-10 relevant topic tags (lowercase, single words or short phrases)\n"
            "4. \"entities\": Array of specific names mentioned (people, companies, products, tools, etc.)\n\n"
            "Return valid JSON only. Do not wrap in conversational commentary."
        )

        user_prompt = f"Platform: {platform}\nTitle: {title or 'Unknown'}\n\nContent:\n{content[:8000]}"

        kwargs = {
            "model": self.llm_model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "temperature": 0.3,
        }

        # Request json_object format where supported natively
        if self.llm_provider in ("openai", "gemini"):
            kwargs["response_format"] = {"type": "json_object"}

        try:
            try:
                response = await self.llm_client.chat.completions.create(**kwargs)
            except Exception as api_err:
                # If provider rejects response_format parameter, retry without it
                if "response_format" in str(api_err).lower() and "response_format" in kwargs:
                    del kwargs["response_format"]
                    response = await self.llm_client.chat.completions.create(**kwargs)
                else:
                    raise api_err

            raw_text = response.choices[0].message.content or ""
            result = parse_json_dict(raw_text)

            summary = str(result.get("summary", "")).strip()
            key_points = [str(p) for p in result.get("key_points", []) if p]
            tags = [str(t).lower() for t in result.get("tags", []) if t]
            entities = [str(e) for e in result.get("entities", []) if e]

            if not summary:
                summary = content[:200] + "..." if len(content) > 200 else content

            return ProcessedContent(
                summary=summary,
                key_points=key_points,
                tags=tags,
                entities=entities,
            )

        except Exception as e:
            print(f"[ERROR] AI processing failed ({self.llm_provider} / {self.llm_model}): {e}")
            return ProcessedContent(
                summary=content[:200] + "..." if len(content) > 200 else content,
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
            response = await self.embedding_client.embeddings.create(
                model=self.embedding_model,
                input=text[:8000],
            )
            return response.data[0].embedding

        except Exception as e:
            print(f"[ERROR] Embedding generation failed ({self.embedding_provider} / {self.embedding_model}): {e}")
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

        context = "\n\n".join([
            f"**{doc.get('title', 'Untitled')}** ({doc.get('platform', 'unknown')})\n{doc.get('summary', '')}"
            for doc in context_docs[:5]
        ])

        system_prompt = (
            "You are a helpful assistant that answers questions about the user's saved bookmarks.\n"
            "Based on the relevant bookmarks provided, give a concise answer to the user's question.\n"
            "Mention specific bookmarks when relevant."
        )

        user_prompt = f"Question: {query}\n\nRelevant saved bookmarks:\n{context}"

        try:
            response = await self.llm_client.chat.completions.create(
                model=self.llm_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                temperature=0.5,
                max_tokens=300,
            )
            return response.choices[0].message.content or ""

        except Exception as e:
            print(f"[ERROR] Search answer generation failed ({self.llm_provider} / {self.llm_model}): {e}")
            return ""
