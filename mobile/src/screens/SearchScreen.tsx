/**
 * Search Screen - Semantic search with AI-powered answers
 */

import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TextInput,
    FlatList,
    TouchableOpacity,
    ActivityIndicator,
    Keyboard,
    Linking,
} from 'react-native';
import { colors, spacing, borderRadius, typography } from '../theme';
import { api, SearchResult, SearchResponse } from '../api';

export default function SearchScreen() {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState<SearchResult[]>([]);
    const [answer, setAnswer] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [searched, setSearched] = useState(false);

    const handleSearch = async () => {
        if (!query.trim()) return;

        Keyboard.dismiss();
        setLoading(true);
        setSearched(true);

        try {
            const response: SearchResponse = await api.search(query.trim());
            setResults(response.results);
            setAnswer(response.answer);
        } catch (err) {
            console.error('Search error:', err);
            setResults([]);
            setAnswer(null);
        } finally {
            setLoading(false);
        }
    };

    const openResult = (result: SearchResult) => {
        Linking.openURL(result.url);
    };

    const renderResult = ({ item }: { item: SearchResult }) => (
        <TouchableOpacity
            style={styles.resultCard}
            onPress={() => openResult(item)}
            activeOpacity={0.7}
        >
            <View style={styles.resultHeader}>
                <Text style={styles.resultTitle} numberOfLines={2}>
                    {item.title || 'Untitled'}
                </Text>
                <View style={styles.scoreContainer}>
                    <Text style={styles.scoreText}>
                        {Math.round(item.relevance_score * 100)}%
                    </Text>
                </View>
            </View>

            {item.summary && (
                <Text style={styles.resultSummary} numberOfLines={3}>
                    {item.summary}
                </Text>
            )}

            <Text style={styles.resultUrl} numberOfLines={1}>
                {item.url}
            </Text>
        </TouchableOpacity>
    );

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Search</Text>
                <Text style={styles.headerSubtitle}>
                    Ask anything about your bookmarks
                </Text>
            </View>

            {/* Search Input */}
            <View style={styles.searchContainer}>
                <TextInput
                    style={styles.searchInput}
                    placeholder="What was that video about AI tools?"
                    placeholderTextColor={colors.textMuted}
                    value={query}
                    onChangeText={setQuery}
                    onSubmitEditing={handleSearch}
                    returnKeyType="search"
                />
                <TouchableOpacity
                    style={[
                        styles.searchButton,
                        !query.trim() && styles.searchButtonDisabled
                    ]}
                    onPress={handleSearch}
                    disabled={!query.trim() || loading}
                >
                    {loading ? (
                        <ActivityIndicator size="small" color={colors.text} />
                    ) : (
                        <Text style={styles.searchButtonText}>🔍</Text>
                    )}
                </TouchableOpacity>
            </View>

            {/* Example queries */}
            {!searched && (
                <View style={styles.examplesContainer}>
                    <Text style={styles.examplesTitle}>Try asking:</Text>
                    {[
                        'What was that video about AI tools?',
                        'Articles about machine learning',
                        'Song recommendations from Spotify',
                        'Tweets about programming',
                    ].map((example, index) => (
                        <TouchableOpacity
                            key={index}
                            style={styles.exampleButton}
                            onPress={() => {
                                setQuery(example);
                            }}
                        >
                            <Text style={styles.exampleText}>{example}</Text>
                        </TouchableOpacity>
                    ))}
                </View>
            )}

            {/* Results */}
            {searched && (
                <FlatList
                    data={results}
                    keyExtractor={(item) => item.bookmark_id}
                    renderItem={renderResult}
                    contentContainerStyle={styles.resultsContent}
                    showsVerticalScrollIndicator={false}
                    ListHeaderComponent={
                        answer ? (
                            <View style={styles.answerCard}>
                                <Text style={styles.answerLabel}>✨ AI Answer</Text>
                                <Text style={styles.answerText}>{answer}</Text>
                            </View>
                        ) : null
                    }
                    ListEmptyComponent={
                        !loading ? (
                            <View style={styles.emptyContainer}>
                                <Text style={styles.emptyIcon}>🔍</Text>
                                <Text style={styles.emptyTitle}>No results found</Text>
                                <Text style={styles.emptySubtitle}>
                                    Try a different query or save more bookmarks
                                </Text>
                            </View>
                        ) : null
                    }
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
    searchContainer: {
        flexDirection: 'row',
        paddingHorizontal: spacing.md,
        marginBottom: spacing.md,
    },
    searchInput: {
        flex: 1,
        backgroundColor: colors.surface,
        borderRadius: borderRadius.lg,
        paddingHorizontal: spacing.md,
        paddingVertical: spacing.md,
        ...typography.body,
        color: colors.text,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    searchButton: {
        backgroundColor: colors.primary,
        width: 52,
        height: 52,
        borderRadius: borderRadius.lg,
        justifyContent: 'center',
        alignItems: 'center',
        marginLeft: spacing.sm,
    },
    searchButtonDisabled: {
        backgroundColor: colors.surfaceLight,
    },
    searchButtonText: {
        fontSize: 20,
    },
    examplesContainer: {
        padding: spacing.lg,
    },
    examplesTitle: {
        ...typography.caption,
        color: colors.textSecondary,
        marginBottom: spacing.sm,
    },
    exampleButton: {
        backgroundColor: colors.surface,
        padding: spacing.md,
        borderRadius: borderRadius.md,
        marginBottom: spacing.sm,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    exampleText: {
        ...typography.body,
        color: colors.textSecondary,
    },
    resultsContent: {
        padding: spacing.md,
        paddingBottom: 100,
    },
    answerCard: {
        backgroundColor: colors.primaryDark + '30',
        borderRadius: borderRadius.lg,
        padding: spacing.md,
        marginBottom: spacing.md,
        borderWidth: 1,
        borderColor: colors.primary + '50',
    },
    answerLabel: {
        ...typography.caption,
        color: colors.primary,
        fontWeight: '600',
        marginBottom: spacing.sm,
    },
    answerText: {
        ...typography.body,
        color: colors.text,
        lineHeight: 24,
    },
    resultCard: {
        backgroundColor: colors.surface,
        borderRadius: borderRadius.lg,
        padding: spacing.md,
        marginBottom: spacing.md,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    resultHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        marginBottom: spacing.xs,
    },
    resultTitle: {
        ...typography.h3,
        color: colors.text,
        flex: 1,
        marginRight: spacing.sm,
    },
    scoreContainer: {
        backgroundColor: colors.success + '20',
        paddingHorizontal: spacing.sm,
        paddingVertical: spacing.xs - 2,
        borderRadius: borderRadius.sm,
    },
    scoreText: {
        ...typography.small,
        color: colors.success,
        fontWeight: '600',
    },
    resultSummary: {
        ...typography.body,
        color: colors.textSecondary,
        marginBottom: spacing.sm,
        lineHeight: 22,
    },
    resultUrl: {
        ...typography.small,
        color: colors.textMuted,
    },
    emptyContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        padding: spacing.xl,
        marginTop: spacing.xxl,
    },
    emptyIcon: {
        fontSize: 48,
        marginBottom: spacing.md,
    },
    emptyTitle: {
        ...typography.h3,
        color: colors.text,
        marginBottom: spacing.sm,
    },
    emptySubtitle: {
        ...typography.body,
        color: colors.textSecondary,
        textAlign: 'center',
    },
});
