"""
YouTube Content Extractor
Extracts video metadata and transcripts from YouTube URLs
"""

import re
from typing import Optional
from dataclasses import dataclass
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import TranscriptsDisabled, NoTranscriptFound
import httpx


@dataclass
class YouTubeContent:
    """Extracted YouTube content"""
    video_id: str
    title: str
    description: str
    channel: str
    transcript: Optional[str] = None
    duration: Optional[int] = None  # seconds
    thumbnail_url: Optional[str] = None


class YouTubeExtractor:
    """Extract content from YouTube videos"""
    
    @staticmethod
    def extract_video_id(url: str) -> Optional[str]:
        """Extract video ID from various YouTube URL formats"""
        patterns = [
            r"(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})",
            r"youtube\.com/embed/([a-zA-Z0-9_-]{11})",
            r"youtube\.com/v/([a-zA-Z0-9_-]{11})",
            r"youtube\.com/shorts/([a-zA-Z0-9_-]{11})",
        ]
        
        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)
        return None
    
    async def extract(self, url: str) -> Optional[YouTubeContent]:
        """
        Extract content from a YouTube URL.
        
        Args:
            url: YouTube video URL
            
        Returns:
            YouTubeContent with metadata and transcript, or None if extraction fails
        """
        video_id = self.extract_video_id(url)
        if not video_id:
            return None
        
        # Fetch video metadata using oEmbed (no API key required)
        metadata = await self._fetch_metadata(video_id)
        if not metadata:
            return None
        
        # Fetch transcript
        transcript = self._fetch_transcript(video_id)
        
        return YouTubeContent(
            video_id=video_id,
            title=metadata.get("title", ""),
            description="",  # oEmbed doesn't provide description
            channel=metadata.get("author_name", ""),
            transcript=transcript,
            thumbnail_url=metadata.get("thumbnail_url"),
        )
    
    async def _fetch_metadata(self, video_id: str) -> Optional[dict]:
        """Fetch video metadata using YouTube oEmbed"""
        oembed_url = f"https://www.youtube.com/oembed?url=https://youtube.com/watch?v={video_id}&format=json"
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(oembed_url, timeout=10.0)
                if response.status_code == 200:
                    return response.json()
        except Exception as e:
            print(f"Error fetching YouTube metadata: {e}")
        
        return None
    
    def _fetch_transcript(self, video_id: str) -> Optional[str]:
        """Fetch video transcript using youtube-transcript-api"""
        try:
            # Use the newer API method
            transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
            
            # Try to get English transcript
            try:
                transcript = transcript_list.find_transcript(['en', 'en-US', 'en-GB'])
            except:
                # Fall back to first available transcript
                transcript = transcript_list.find_generated_transcript(['en', 'en-US', 'en-GB'])
            
            # Fetch the transcript data
            transcript_data = transcript.fetch()
            
            # Combine transcript segments into single text
            full_transcript = " ".join([
                segment['text'] for segment in transcript_data
            ])
            
            return full_transcript
            
        except TranscriptsDisabled:
            print(f"Transcripts disabled for video {video_id}")
            return None
        except NoTranscriptFound:
            print(f"No transcript found for video {video_id}")
            return None
        except Exception as e:
            print(f"Error fetching transcript: {e}")
            return None
