"""
URL Platform Detection Service
Identifies the source platform from a URL
"""

from urllib.parse import urlparse
import re


# Platform detection patterns
PLATFORM_PATTERNS = {
    "youtube": [
        r"youtube\.com",
        r"youtu\.be",
    ],
    "instagram": [
        r"instagram\.com",
        r"instagr\.am",
    ],
    "twitter": [
        r"twitter\.com",
        r"x\.com",
    ],
    "spotify": [
        r"spotify\.com",
        r"open\.spotify\.com",
    ],
    "tiktok": [
        r"tiktok\.com",
        r"vm\.tiktok\.com",
    ],
    "reddit": [
        r"reddit\.com",
        r"redd\.it",
    ],
    "linkedin": [
        r"linkedin\.com",
    ],
    "github": [
        r"github\.com",
    ],
    "medium": [
        r"medium\.com",
    ],
    "substack": [
        r"substack\.com",
    ],
}


def detect_platform(url: str) -> str:
    """
    Detect the platform from a URL.
    
    Args:
        url: The URL to analyze
        
    Returns:
        Platform name (e.g., 'youtube', 'instagram') or 'webpage' for generic sites
    """
    try:
        parsed = urlparse(url)
        domain = parsed.netloc.lower()
        
        # Remove www. prefix
        if domain.startswith("www."):
            domain = domain[4:]
        
        # Check against known patterns
        for platform, patterns in PLATFORM_PATTERNS.items():
            for pattern in patterns:
                if re.search(pattern, domain):
                    return platform
        
        return "webpage"
        
    except Exception:
        return "unknown"


def get_content_type(platform: str) -> str:
    """Get the expected content type for a platform"""
    content_types = {
        "youtube": "video",
        "instagram": "media",
        "twitter": "post",
        "spotify": "audio",
        "tiktok": "video",
        "reddit": "post",
        "linkedin": "post",
        "github": "code",
        "medium": "article",
        "substack": "article",
        "webpage": "article",
    }
    return content_types.get(platform, "unknown")
