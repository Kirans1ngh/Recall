/**
 * Add Screen - Manually add a bookmark URL
 */

import React, { useState } from 'react';
import {
    View,
    Text,
    StyleSheet,
    TextInput,
    TouchableOpacity,
    ActivityIndicator,
    Keyboard,
    Alert,
} from 'react-native';
import { colors, spacing, borderRadius, typography } from '../theme';
import { api } from '../api';

export default function AddScreen() {
    const [url, setUrl] = useState('');
    const [notes, setNotes] = useState('');
    const [loading, setLoading] = useState(false);
    const [success, setSuccess] = useState(false);

    const handleSubmit = async () => {
        if (!url.trim()) {
            Alert.alert('Error', 'Please enter a URL');
            return;
        }

        // Basic URL validation
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
            Alert.alert('Error', 'Please enter a valid URL starting with http:// or https://');
            return;
        }

        Keyboard.dismiss();
        setLoading(true);
        setSuccess(false);

        try {
            await api.createBookmark(url.trim(), notes.trim() || undefined);
            setSuccess(true);
            setUrl('');
            setNotes('');

            // Reset success after 3 seconds
            setTimeout(() => setSuccess(false), 3000);
        } catch (err) {
            console.error('Error creating bookmark:', err);
            Alert.alert('Error', 'Failed to save bookmark. Is the server running?');
        } finally {
            setLoading(false);
        }
    };

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Add Bookmark</Text>
                <Text style={styles.headerSubtitle}>
                    Paste a URL to save and analyze
                </Text>
            </View>

            {/* Form */}
            <View style={styles.form}>
                {/* URL Input */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>URL</Text>
                    <TextInput
                        style={styles.input}
                        placeholder="https://youtube.com/watch?v=..."
                        placeholderTextColor={colors.textMuted}
                        value={url}
                        onChangeText={setUrl}
                        autoCapitalize="none"
                        autoCorrect={false}
                        keyboardType="url"
                    />
                </View>

                {/* Notes Input */}
                <View style={styles.inputGroup}>
                    <Text style={styles.label}>Notes (optional)</Text>
                    <TextInput
                        style={[styles.input, styles.textArea]}
                        placeholder="Add personal notes..."
                        placeholderTextColor={colors.textMuted}
                        value={notes}
                        onChangeText={setNotes}
                        multiline
                        numberOfLines={3}
                        textAlignVertical="top"
                    />
                </View>

                {/* Submit Button */}
                <TouchableOpacity
                    style={[
                        styles.submitButton,
                        (!url.trim() || loading) && styles.submitButtonDisabled,
                        success && styles.submitButtonSuccess,
                    ]}
                    onPress={handleSubmit}
                    disabled={!url.trim() || loading}
                >
                    {loading ? (
                        <ActivityIndicator size="small" color={colors.text} />
                    ) : success ? (
                        <>
                            <Text style={styles.submitButtonIcon}>✓</Text>
                            <Text style={styles.submitButtonText}>Saved!</Text>
                        </>
                    ) : (
                        <>
                            <Text style={styles.submitButtonIcon}>📎</Text>
                            <Text style={styles.submitButtonText}>Save Bookmark</Text>
                        </>
                    )}
                </TouchableOpacity>
            </View>

            {/* Instructions */}
            <View style={styles.instructions}>
                <Text style={styles.instructionsTitle}>💡 Tip</Text>
                <Text style={styles.instructionsText}>
                    You can also share links directly from other apps using the share button!
                </Text>
            </View>

            {/* Supported Platforms */}
            <View style={styles.platforms}>
                <Text style={styles.platformsTitle}>Supported platforms</Text>
                <View style={styles.platformIcons}>
                    <Text style={styles.platformIcon}>📺 YouTube</Text>
                    <Text style={styles.platformIcon}>🐦 Twitter</Text>
                    <Text style={styles.platformIcon}>📷 Instagram</Text>
                    <Text style={styles.platformIcon}>🎵 Spotify</Text>
                    <Text style={styles.platformIcon}>🌐 Websites</Text>
                </View>
            </View>
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
    form: {
        padding: spacing.lg,
    },
    inputGroup: {
        marginBottom: spacing.lg,
    },
    label: {
        ...typography.caption,
        color: colors.textSecondary,
        marginBottom: spacing.sm,
        fontWeight: '600',
    },
    input: {
        backgroundColor: colors.surface,
        borderRadius: borderRadius.md,
        paddingHorizontal: spacing.md,
        paddingVertical: spacing.md,
        ...typography.body,
        color: colors.text,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    textArea: {
        minHeight: 100,
        paddingTop: spacing.md,
    },
    submitButton: {
        backgroundColor: colors.primary,
        borderRadius: borderRadius.lg,
        paddingVertical: spacing.md,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: spacing.md,
    },
    submitButtonDisabled: {
        backgroundColor: colors.surfaceLight,
    },
    submitButtonSuccess: {
        backgroundColor: colors.success,
    },
    submitButtonIcon: {
        fontSize: 18,
        marginRight: spacing.sm,
    },
    submitButtonText: {
        ...typography.body,
        color: colors.text,
        fontWeight: '600',
    },
    instructions: {
        margin: spacing.lg,
        backgroundColor: colors.surface,
        borderRadius: borderRadius.md,
        padding: spacing.md,
        borderWidth: 1,
        borderColor: colors.surfaceLight,
    },
    instructionsTitle: {
        ...typography.caption,
        color: colors.text,
        fontWeight: '600',
        marginBottom: spacing.xs,
    },
    instructionsText: {
        ...typography.body,
        color: colors.textSecondary,
    },
    platforms: {
        paddingHorizontal: spacing.lg,
    },
    platformsTitle: {
        ...typography.caption,
        color: colors.textMuted,
        marginBottom: spacing.sm,
    },
    platformIcons: {
        flexDirection: 'row',
        flexWrap: 'wrap',
    },
    platformIcon: {
        ...typography.small,
        color: colors.textSecondary,
        backgroundColor: colors.surface,
        paddingHorizontal: spacing.sm,
        paddingVertical: spacing.xs,
        borderRadius: borderRadius.sm,
        marginRight: spacing.sm,
        marginBottom: spacing.sm,
    },
});
