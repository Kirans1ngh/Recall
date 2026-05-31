/**
 * App theme and design tokens
 */

export const colors = {
    // Primary palette
    primary: '#6366f1',      // Indigo
    primaryLight: '#818cf8',
    primaryDark: '#4f46e5',

    // Accent
    accent: '#f472b6',       // Pink

    // Background
    background: '#0f0f14',
    surface: '#1a1a24',
    surfaceLight: '#252532',

    // Text
    text: '#ffffff',
    textSecondary: '#a1a1aa',
    textMuted: '#71717a',

    // Status
    success: '#22c55e',
    warning: '#eab308',
    error: '#ef4444',
    info: '#3b82f6',

    // Platform colors
    youtube: '#ff0000',
    twitter: '#1da1f2',
    instagram: '#e4405f',
    spotify: '#1db954',
    webpage: '#6366f1',
};

export const spacing = {
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    xxl: 48,
};

export const borderRadius = {
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    full: 9999,
};

export const typography = {
    h1: {
        fontSize: 32,
        fontWeight: '700' as const,
        letterSpacing: -0.5,
    },
    h2: {
        fontSize: 24,
        fontWeight: '600' as const,
        letterSpacing: -0.3,
    },
    h3: {
        fontSize: 18,
        fontWeight: '600' as const,
    },
    body: {
        fontSize: 16,
        fontWeight: '400' as const,
    },
    caption: {
        fontSize: 14,
        fontWeight: '400' as const,
    },
    small: {
        fontSize: 12,
        fontWeight: '400' as const,
    },
};
