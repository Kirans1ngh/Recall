"""
Webpage Content Extractor
Extracts main content from any webpage
"""

from typing import Optional
from dataclasses import dataclass
import httpx
from bs4 import BeautifulSoup
import re


@dataclass
class WebpageContent:
    """Extracted webpage content"""
    url: str
    title: str
    description: Optional[str] = None
    main_text: str = ""
    author: Optional[str] = None
    published_date: Optional[str] = None


class WebpageExtractor:
    """Extract content from generic webpages"""
    
    # Tags to remove (usually noise)
    NOISE_TAGS = [
        'script', 'style', 'nav', 'footer', 'header', 
        'aside', 'iframe', 'noscript', 'form'
    ]
    
    # Selectors for main content (in order of preference)
    CONTENT_SELECTORS = [
        'article',
        '[role="main"]',
        'main',
        '.post-content',
        '.article-content',
        '.entry-content',
        '.content',
        '#content',
    ]
    
    async def extract(self, url: str) -> Optional[WebpageContent]:
        """
        Extract content from a webpage URL.
        
        Args:
            url: Webpage URL
            
        Returns:
            WebpageContent with extracted text, or None if extraction fails
        """
        try:
            html = await self._fetch_page(url)
            if not html:
                return None
            
            soup = BeautifulSoup(html, 'html.parser')
            
            # Remove noise elements
            for tag in self.NOISE_TAGS:
                for element in soup.find_all(tag):
                    element.decompose()
            
            # Extract metadata
            title = self._extract_title(soup)
            description = self._extract_description(soup)
            author = self._extract_author(soup)
            
            # Extract main content
            main_text = self._extract_main_content(soup)
            
            return WebpageContent(
                url=url,
                title=title,
                description=description,
                main_text=main_text,
                author=author,
            )
            
        except Exception as e:
            print(f"Error extracting webpage content: {e}")
            return None
    
    async def _fetch_page(self, url: str) -> Optional[str]:
        """Fetch webpage HTML"""
        headers = {
            "User-Agent": "Mozilla/5.0 (compatible; BookmarkAI/1.0; +https://bookmarkai.app)"
        }
        
        try:
            async with httpx.AsyncClient(follow_redirects=True) as client:
                response = await client.get(url, headers=headers, timeout=15.0)
                if response.status_code == 200:
                    return response.text
        except Exception as e:
            print(f"Error fetching page: {e}")
        
        return None
    
    def _extract_title(self, soup: BeautifulSoup) -> str:
        """Extract page title"""
        # Try og:title first
        og_title = soup.find('meta', property='og:title')
        if og_title and og_title.get('content'):
            return og_title['content']
        
        # Fall back to title tag
        title_tag = soup.find('title')
        if title_tag:
            return title_tag.get_text(strip=True)
        
        # Fall back to h1
        h1 = soup.find('h1')
        if h1:
            return h1.get_text(strip=True)
        
        return "Untitled"
    
    def _extract_description(self, soup: BeautifulSoup) -> Optional[str]:
        """Extract page description"""
        # Try og:description
        og_desc = soup.find('meta', property='og:description')
        if og_desc and og_desc.get('content'):
            return og_desc['content']
        
        # Try meta description
        meta_desc = soup.find('meta', attrs={'name': 'description'})
        if meta_desc and meta_desc.get('content'):
            return meta_desc['content']
        
        return None
    
    def _extract_author(self, soup: BeautifulSoup) -> Optional[str]:
        """Extract author name"""
        # Try meta author
        meta_author = soup.find('meta', attrs={'name': 'author'})
        if meta_author and meta_author.get('content'):
            return meta_author['content']
        
        # Try article:author
        og_author = soup.find('meta', property='article:author')
        if og_author and og_author.get('content'):
            return og_author['content']
        
        return None
    
    def _extract_main_content(self, soup: BeautifulSoup) -> str:
        """Extract main text content"""
        # Try content selectors
        for selector in self.CONTENT_SELECTORS:
            element = soup.select_one(selector)
            if element:
                text = element.get_text(separator=' ', strip=True)
                if len(text) > 100:  # Reasonable content length
                    return self._clean_text(text)
        
        # Fall back to body
        body = soup.find('body')
        if body:
            text = body.get_text(separator=' ', strip=True)
            return self._clean_text(text)
        
        return ""
    
    def _clean_text(self, text: str) -> str:
        """Clean extracted text"""
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text)
        # Limit length (for very long articles)
        if len(text) > 10000:
            text = text[:10000] + "..."
        return text.strip()
