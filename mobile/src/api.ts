/**
 * API configuration and client
 */

// Change this to your backend URL
const API_BASE_URL = 'http://10.0.2.2:8000'; // Android emulator localhost
// const API_BASE_URL = 'http://localhost:8000'; // iOS/Web

export interface Bookmark {
    id: string;
    url: string;
    platform: string;
    title: string | null;
    summary: string | null;
    key_points: string[] | null;
    tags: string[] | null;
    status: 'pending' | 'processing' | 'completed' | 'failed';
    created_at: string;
    processed_at: string | null;
}

export interface SearchResult {
    bookmark_id: string;
    url: string;
    title: string | null;
    summary: string | null;
    relevance_score: number;
}

export interface SearchResponse {
    query: string;
    results: SearchResult[];
    total: number;
    answer: string | null;
}

class ApiClient {
    private baseUrl: string;

    constructor(baseUrl: string = API_BASE_URL) {
        this.baseUrl = baseUrl;
    }

    async createBookmark(url: string, notes?: string): Promise<Bookmark> {
        const response = await fetch(`${this.baseUrl}/api/bookmarks`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ url, notes }),
        });

        if (!response.ok) {
            throw new Error(`Failed to create bookmark: ${response.statusText}`);
        }

        return response.json();
    }

    async getBookmarks(status?: string, platform?: string): Promise<Bookmark[]> {
        const params = new URLSearchParams();
        if (status) params.append('status', status);
        if (platform) params.append('platform', platform);

        const url = `${this.baseUrl}/api/bookmarks${params.toString() ? '?' + params.toString() : ''}`;
        const response = await fetch(url);

        if (!response.ok) {
            throw new Error(`Failed to fetch bookmarks: ${response.statusText}`);
        }

        return response.json();
    }

    async getBookmark(id: string): Promise<Bookmark> {
        const response = await fetch(`${this.baseUrl}/api/bookmarks/${id}`);

        if (!response.ok) {
            throw new Error(`Failed to fetch bookmark: ${response.statusText}`);
        }

        return response.json();
    }

    async deleteBookmark(id: string): Promise<void> {
        const response = await fetch(`${this.baseUrl}/api/bookmarks/${id}`, {
            method: 'DELETE',
        });

        if (!response.ok) {
            throw new Error(`Failed to delete bookmark: ${response.statusText}`);
        }
    }

    async search(query: string, limit: number = 10): Promise<SearchResponse> {
        const params = new URLSearchParams({ q: query, limit: limit.toString() });
        const response = await fetch(`${this.baseUrl}/api/search?${params.toString()}`);

        if (!response.ok) {
            throw new Error(`Search failed: ${response.statusText}`);
        }

        return response.json();
    }
}

export const api = new ApiClient();
