"""
Unit tests for AI Processor and Multi-Provider Configurations
"""

import asyncio
import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from app.config import Settings
from app.services.ai_processor import (
    AIProcessor,
    ProcessedContent,
    create_ai_client,
    parse_json_dict,
)


def test_parse_json_dict_direct():
    """Test parsing clean direct JSON"""
    raw = '{"summary": "A clean summary", "tags": ["tag1", "tag2"]}'
    res = parse_json_dict(raw)
    assert res["summary"] == "A clean summary"
    assert res["tags"] == ["tag1", "tag2"]


def test_parse_json_dict_markdown_fence():
    """Test parsing JSON wrapped in markdown fences"""
    raw = """```json
{
  "summary": "Fenced summary",
  "key_points": ["point 1", "point 2"],
  "tags": ["ai", "search"],
  "entities": ["OpenAI", "Google"]
}
```"""
    res = parse_json_dict(raw)
    assert res["summary"] == "Fenced summary"
    assert len(res["key_points"]) == 2
    assert "OpenAI" in res["entities"]


def test_parse_json_dict_with_conversational_preamble():
    """Test parsing JSON surrounded by introductory and trailing commentary"""
    raw = """Here is the extracted information:
```
{
  "summary": "Conversational wrapper",
  "key_points": ["point a"],
  "tags": ["tech"],
  "entities": []
}
```
Let me know if you need more details!"""
    res = parse_json_dict(raw)
    assert res["summary"] == "Conversational wrapper"
    assert res["tags"] == ["tech"]


def test_parse_json_dict_raw_unfenced_with_text():
    """Test parsing JSON without fences but with surrounding text"""
    raw = 'Sure, here is your json: {"summary": "Embedded JSON", "tags": ["python"]} Thank you.'
    res = parse_json_dict(raw)
    assert res["summary"] == "Embedded JSON"
    assert res["tags"] == ["python"]


def test_parse_json_dict_invalid_fallback():
    """Test that malformed string returns empty dict without throwing exceptions"""
    raw = "Not a json at all {broken"
    res = parse_json_dict(raw)
    assert res == {}


def test_provider_auto_detection():
    """Test provider auto detection priority based on keys"""
    # 1. Only Gemini key present
    s1 = Settings(gemini_api_key="test-gemini", openai_api_key="", nvidia_nim_api_key="")
    assert s1.effective_llm_provider == "gemini"
    assert s1.active_llm_model == "gemini-1.5-flash"
    assert s1.active_embedding_model == "text-embedding-004"

    # 2. Only NVIDIA NIM key present
    s2 = Settings(gemini_api_key="", openai_api_key="", nvidia_nim_api_key="test-nv")
    assert s2.effective_llm_provider == "nvidia_nim"
    assert s2.active_llm_model == "meta/llama-3.3-70b-instruct"
    assert s2.active_embedding_model == "nvidia/llama-3.2-nv-embedqa-1b-v2"

    # 3. Explicit provider overrides
    s3 = Settings(
        llm_provider="gemini",
        embedding_provider="openai",
        openai_api_key="sk-openai",
        gemini_api_key="gemini-key",
    )
    assert s3.effective_llm_provider == "gemini"
    assert s3.effective_embedding_provider == "openai"
    assert s3.active_llm_model == "gemini-1.5-flash"
    assert s3.active_embedding_model == "text-embedding-3-small"


def test_create_ai_client_gemini():
    """Verify Gemini client initialization configures custom base_url"""
    with patch("app.services.ai_processor.settings") as mock_settings:
        mock_settings.gemini_api_key = "gemini-test-key"
        mock_settings.gemini_base_url = "https://generativelanguage.googleapis.com/v1beta/openai/"
        mock_settings.gemini_model = "gemini-1.5-flash"
        mock_settings.gemini_embedding_model = "text-embedding-004"

        client, model, emb_model = create_ai_client("gemini")
        assert model == "gemini-1.5-flash"
        assert emb_model == "text-embedding-004"
        assert "generativelanguage.googleapis.com" in str(client.base_url)


def test_create_ai_client_nvidia_nim():
    """Verify NVIDIA NIM client initialization configures NIM base_url"""
    with patch("app.services.ai_processor.settings") as mock_settings:
        mock_settings.nvidia_nim_api_key = "nv-test-key"
        mock_settings.nvidia_nim_base_url = "https://integrate.api.nvidia.com/v1"
        mock_settings.nvidia_nim_model = "meta/llama-3.3-70b-instruct"
        mock_settings.nvidia_nim_embedding_model = "nvidia/llama-3.2-nv-embedqa-1b-v2"

        client, model, emb_model = create_ai_client("nvidia_nim")
        assert model == "meta/llama-3.3-70b-instruct"
        assert emb_model == "nvidia/llama-3.2-nv-embedqa-1b-v2"
        assert "integrate.api.nvidia.com" in str(client.base_url)


def test_process_content_mock():
    """Test process_content parses mock response correctly"""
    async def run_test():
        ai = AIProcessor(llm_provider="gemini", embedding_provider="gemini")
        mock_completion = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = '{"summary": "Test Summary", "key_points": ["P1", "P2"], "tags": ["AI"], "entities": ["Recall"]}'
        mock_completion.choices = [mock_choice]

        ai.llm_client.chat.completions.create = AsyncMock(return_value=mock_completion)

        result = await ai.process_content("Full document text content", title="Demo Title")
        assert isinstance(result, ProcessedContent)
        assert result.summary == "Test Summary"
        assert result.key_points == ["P1", "P2"]
        assert result.tags == ["ai"]
        assert result.entities == ["Recall"]

    asyncio.run(run_test())


def test_generate_search_answer_mock():
    """Test natural language search answer generation"""
    async def run_test():
        ai = AIProcessor(llm_provider="nvidia_nim")
        mock_completion = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = "Here is what your bookmarks show about this topic."
        mock_completion.choices = [mock_choice]

        ai.llm_client.chat.completions.create = AsyncMock(return_value=mock_completion)

        docs = [{"title": "Doc 1", "platform": "webpage", "summary": "Sample bookmark"}]
        answer = await ai.generate_search_answer("How does this work?", docs)
        assert answer == "Here is what your bookmarks show about this topic."

    asyncio.run(run_test())


def test_generate_embedding_mock():
    """Test embedding generation parsing mock float vector"""
    async def run_test():
        ai = AIProcessor(embedding_provider="openai")
        mock_response = MagicMock()
        mock_data = MagicMock()
        mock_data.embedding = [0.012, -0.045, 0.789]
        mock_response.data = [mock_data]

        ai.embedding_client.embeddings.create = AsyncMock(return_value=mock_response)

        vec = await ai.generate_embedding("search query")
        assert vec == [0.012, -0.045, 0.789]

    asyncio.run(run_test())
