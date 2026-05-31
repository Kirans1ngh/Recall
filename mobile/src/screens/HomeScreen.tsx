/**
 * Home Screen - Bookmark list with filters
 */

import React, { useEffect, useState, useCallback } from 'react';
import {
    View,
    Text,
    StyleSheet,
    FlatList,
    TouchableOpacity,
    RefreshControl,
    ActivityIndicator,
    Linking,
} from 'react-native';
import { colors, spacing, borderRadius, typography } from '../theme';
import { api, Bookmark } from '../api';

// Platform icon mapping (emoji for simplicity)
const platformIcons: Record<string, string> = {
    youtube: '📺',
    twitter: '🐦',
    instagram: '📷',
    spotify: '🎵',
    tiktok: '🎬',
    reddit: '🔴',
    github: '💻',
    medium: '📝',
    webpage: '🌐',
    unknown: '📎',
};

const platformColors: Record<string, string> = {
    youtube: colors.youtube,
    twitter: colors.twitter,
    instagram: colors.instagram,
    spotify: colors.spotify,
    webpage: colors.primary,
};

const statusColors: Record<string, string> = {
    pending: colors.warning,
    processing: colors.info,
    completed: colors.success,
    failed: colors.error,
};

interface BookmarkCardProps {
    bookmark: Bookmark;
    onPress: () => void;
}

function BookmarkCard({ bookmark, onPress }: BookmarkCardProps) {
    const platformColor = platformColors[bookmark.platform] || colors.primary;
    const statusColor = statusColors[bookmark.status] || colors.textMuted;

    return (
        <TouchableOpacity
            style={styles.card}
            onPress={onPress}
            activeOpacity={0.7}
        >
            {/* Platform indicator */}
            <View style={[styles.platformBadge, { backgroundColor: platformColor + '20' }]}>
                <Text style={styles.platformIcon}>
                    {platformIcons[bookmark.platform] || platformIcons.unknown}
                </Text>
                <Text style={[styles.platformText, { color: platformColor }]}>
                    {bookmark.platform}
                </Text>
            </View>

            {/* Title */}
            <Text style={styles.cardTitle} numberOfLines={2}>
                {bookmark.title || 'Processing...'}
            </Text>

            {/* Summary */}
            {bookmark.summary && (
                <Text style={styles.cardSummary} numberOfLines={3}>
                    {bookmark.summary}
                </Text>
            )}

            {/* Tags */}
            {bookmark.tags && bookmark.tags.length > 0 && (
                <View style={styles.tagsContainer}>
                    {bookmark.tags.slice(0, 4).map((tag, index) => (
                        <View key={index} style={styles.tag}>
                            <Text style={styles.tagText}>{tag}</Text>
                        </View>
                    ))}
                    {bookmark.tags.length > 4 && (
                        <Text style={styles.moreTagsText}>+{bookmark.tags.length - 4}</Text>
                    )}
                </View>
            )}

            {/* Status indicator */}
            <View style={styles.cardFooter}>
                <View style={styles.statusContainer}>
                    <View style={[styles.statusDot, { backgroundColor: statusColor }]} />
                    <Text style={[styles.statusText, { color: statusColor }]}>
                        {bookmark.status}
                    </Text>
                </View>
                <Text style={styles.dateText}>
                    {new Date(bookmark.created_at).toLocaleDateString()}
                </Text>
            </View>
        </TouchableOpacity>
    );
}

export default function HomeScreen() {
    const [bookmarks, setBookmarks] = useState<Bookmark[]>([]);
    const [loading, setLoading] = useState(true);
    const [refreshing, setRefreshing] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const fetchBookmarks = useCallback(async () => {
        try {
            setError(null);
            const data = await api.getBookmarks();
            setBookmarks(data);
        } catch (err) {
            setError('Failed to load bookmarks. Is the server running?');
            console.error(err);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    }, []);

    useEffect(() => {
        fetchBookmarks();
    }, [fetchBookmarks]);

    const onRefresh = useCallback(() => {
        setRefreshing(true);
        fetchBookmarks();
    }, [fetchBookmarks]);

    const openBookmark = (bookmark: Bookmark) => {
        Linking.openURL(bookmark.url);
    };

    if (loading) {
        return (
            <View style={styles.centerContainer}>
                <ActivityIndicator size="large" color={colors.primary} />
                <Text style={styles.loadingText}>Loading bookmarks...</Text>
            </View>
        );
    }

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Bookmarks</Text>
                <Text style={styles.headerSubtitle}>
                    {bookmarks.length} saved
                </Text>
            </View>

            {error ? (
                <View style={styles.errorContainer}>
                    <Text style={styles.errorText}>{error}</Text>
                    <TouchableOpacity style={styles.retryButton} onPress={fetchBookmarks}>
                        <Text style={styles.retryButtonText}>Retry</Text>
                    </TouchableOpacity>
                </View>
            ) : bookmarks.length === 0 ? (
                <View style={styles.emptyContainer}>
                    <Text style={styles.emptyIcon}>📎</Text>
                    <Text style={styles.emptyTitle}>No bookmarks yet</Text>
                    <Text style={styles.emptySubtitle}>
                        Share a link from any app to save it here
                    </Text>
                </View>
            ) : (
                <FlatList
                    data={bookmarks}
                    keyExtractor={(item) => item.id}
                    renderItem={({ item }) => (
                        <BookmarkCard
                            bookmark={item}
                            onPress={() => openBookmark(item)}
                        />
                    )}
                    contentContainerStyle={styles.listContent}
                    refreshControl={
                        <RefreshControl
                            refreshing={refreshing}
                            onRefresh={onRefresh}
                            tintColor={colors.primary}
                            colors={[colors.primary]}
                        />
                    }
                    showsVerticalScrollIndicator={false}
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
    },
    centerContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: colors.background,
    },
    header: {
        paddingTop: 60,
        paddingHorizontal: spacing.lg,
        paddingBottom: spacing.md,
    },
    headerTitle: {
        ...typography.h1,
        color: colors.text,
    },
    headerSubtitle: {
        ...typography.caption,
        color: colors.textSecondary,
        marginTop: spacing.xs,
    },
    listContent: {
        padding: spacing.md,
        paddingBottom: 100,
    },
    card: {
        backgroundColor: colors.surface,
        borderRadius: borderRadius.lg,
        padding: spacing.md,
        marginBottom: spacing.md,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    platformBadge: {
        flexDirection: 'row',
        alignItems: 'center',
        alignSelf: 'flex-start',
        paddingHorizontal: spacing.sm,
        paddingVertical: spacing.xs,
        borderRadius: borderRadius.full,
        marginBottom: spacing.sm,
    },
    platformIcon: {
        fontSize: 14,
        marginRight: spacing.xs,
    },
    platformText: {
        ...typography.small,
        fontWeight: '600',
        textTransform: 'capitalize',
    },
    cardTitle: {
        ...typography.h3,
        color: colors.text,
        marginBottom: spacing.xs,
    },
    cardSummary: {
        ...typography.body,
        color: colors.textSecondary,
        marginBottom: spacing.sm,
        lineHeight: 22,
    },
    tagsContainer: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        marginBottom: spacing.sm,
    },
    tag: {
        backgroundColor: colors.surfaceLight,
        paddingHorizontal: spacing.sm,
        paddingVertical: spacing.xs - 2,
        borderRadius: borderRadius.sm,
        marginRight: spacing.xs,
        marginBottom: spacing.xs,
    },
    tagText: {
        ...typography.small,
        color: colors.textSecondary,
    },
    moreTagsText: {
        ...typography.small,
        color: colors.textMuted,
        alignSelf: 'center',
    },
    cardFooter: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginTop: spacing.xs,
    },
    statusContainer: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    statusDot: {
        width: 8,
        height: 8,
        borderRadius: 4,
        marginRight: spacing.xs,
    },
    statusText: {
        ...typography.small,
        textTransform: 'capitalize',
    },
    dateText: {
        ...typography.small,
        color: colors.textMuted,
    },
    loadingText: {
        ...typography.body,
        color: colors.textSecondary,
        marginTop: spacing.md,
    },
    errorContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: spacing.xl,
    },
    errorText: {
        ...typography.body,
        color: colors.error,
        textAlign: 'center',
        marginBottom: spacing.md,
    },
    retryButton: {
        backgroundColor: colors.primary,
        paddingHorizontal: spacing.lg,
        paddingVertical: spacing.sm,
        borderRadius: borderRadius.md,
    },
    retryButtonText: {
        ...typography.body,
        color: colors.text,
        fontWeight: '600',
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: spacing.xl,
    },
    emptyIcon: {
        fontSize: 64,
        marginBottom: spacing.md,
    },
    emptyTitle: {
        ...typography.h2,
        color: colors.text,
        marginBottom: spacing.sm,
    },
    emptySubtitle: {
        ...typography.body,
        color: colors.textSecondary,
        textAlign: 'center',
    },
});
