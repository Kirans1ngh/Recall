# Bookmark AI 🔖🤖

AI-powered bookmark aggregator with semantic search. Save content from any platform (YouTube, articles, tweets) and find it later using natural language queries.

## Features

- 📎 **Universal Bookmarking** - Save links from YouTube, Twitter, articles, and more
- 🤖 **AI Summarization** - Automatic content extraction and summarization
- 🔍 **Semantic Search** - Find bookmarks using natural language ("What was that video about AI tools?")
- 🏷️ **Smart Tagging** - Auto-generated tags and key points

## Quick Start

### 1. Setup Backend

```bash
cd backend

# Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Mac/Linux

# Install dependencies
pip install -r requirements.txt

# Setup environment
copy .env.example .env
# Edit .env with your API keys
```

### 2. Get API Keys

- **OpenAI**: https://platform.openai.com/api-keys
- **Pinecone**: https://www.pinecone.io/ (free tier available)

### 3. Run the Server

```bash
uvicorn app.main:app --reload --port 8000
```

---

## 📱 Mobile App

The mobile app is built with Expo (React Native) and provides:
- **Bookmark list** with status indicators and tags
- **Semantic search** with AI-powered answers  
- **Add bookmarks** manually or via share intent

### Setup Mobile App

```bash
cd mobile
npm install
npx expo start
```

Then:
- Press `a` for Android emulator
- Press `w` for web browser
- Scan QR code with Expo Go app on your phone

### Configure API URL

Edit `mobile/src/api.ts` and set your backend URL:
```typescript
const API_BASE_URL = 'http://YOUR_IP:8000';
```

---

### 4. Test the API

```bash
# Create a bookmark
curl -X POST http://localhost:8000/api/bookmarks \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"}'

# List bookmarks
curl http://localhost:8000/api/bookmarks

# Search bookmarks
curl "http://localhost:8000/api/search?q=music+video"
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/bookmarks` | Create a new bookmark |
| GET | `/api/bookmarks` | List all bookmarks |
| GET | `/api/bookmarks/{id}` | Get specific bookmark |
| DELETE | `/api/bookmarks/{id}` | Delete bookmark |
| GET | `/api/search?q=query` | Semantic search |

## Project Structure

```
bookmark-ai/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app
│   │   ├── config.py            # Settings
│   │   ├── routes/              # API endpoints
│   │   │   ├── bookmarks.py
│   │   │   └── search.py
│   │   └── services/            # Business logic
│   │       ├── url_detector.py  # Platform detection
│   │       ├── processor.py     # Orchestration
│   │       ├── ai_processor.py  # OpenAI integration
│   │       ├── vector_search.py # Pinecone integration
│   │       └── extractors/      # Content extractors
│   │           ├── youtube.py
│   │           └── webpage.py
│   ├── requirements.txt
│   └── .env.example
└── README.md
```

## Roadmap

- [x] Core API structure
- [x] YouTube extraction
- [x] Webpage extraction
- [x] AI summarization
- [x] Vector search
- [ ] Supabase database
- [ ] User authentication
- [ ] Twitter/X extraction
- [ ] Mobile app (React Native)
- [ ] Browser extension

## License

MIT
