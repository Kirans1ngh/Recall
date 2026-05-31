/**
 * Bookmark AI - Main App Entry
 * Dark themed mobile app for AI-powered bookmarking
 */

import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';

import HomeScreen from './src/screens/HomeScreen';
import SearchScreen from './src/screens/SearchScreen';
import AddScreen from './src/screens/AddScreen';
import { colors } from './src/theme';

const Tab = createBottomTabNavigator();

// Custom dark theme for navigation
const DarkTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: colors.background,
    card: colors.surface,
    text: colors.text,
    border: colors.surfaceLight,
    primary: colors.primary,
  },
};

// Tab bar icons
function TabIcon({ name, focused }: { name: string; focused: boolean }) {
  const icons: Record<string, string> = {
    Home: '📚',
    Search: '🔍',
    Add: '➕',
  };

  return (
    <View style={[styles.tabIcon, focused && styles.tabIconFocused]}>
      <Text style={styles.tabIconText}>{icons[name]}</Text>
    </View>
  );
}

export default function App() {
  return (
    <NavigationContainer theme={DarkTheme}>
      <StatusBar style="light" />
      <Tab.Navigator
        screenOptions={({ route }) => ({
          headerShown: false,
          tabBarIcon: ({ focused }) => (
            <TabIcon name={route.name} focused={focused} />
          ),
          tabBarActiveTintColor: colors.primary,
          tabBarInactiveTintColor: colors.textMuted,
          tabBarStyle: styles.tabBar,
          tabBarLabelStyle: styles.tabBarLabel,
        })}
      >
        <Tab.Screen
          name="Home"
          component={HomeScreen}
          options={{ tabBarLabel: 'Bookmarks' }}
        />
        <Tab.Screen
          name="Search"
          component={SearchScreen}
          options={{ tabBarLabel: 'Search' }}
        />
        <Tab.Screen
          name="Add"
          component={AddScreen}
          options={{ tabBarLabel: 'Add' }}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: colors.surface,
    borderTopColor: colors.surfaceLight,
    borderTopWidth: 1,
    height: 85,
    paddingTop: 8,
    paddingBottom: 25,
  },
  tabBarLabel: {
    fontSize: 12,
    fontWeight: '500',
  },
  tabIcon: {
    padding: 4,
  },
  tabIconFocused: {
    transform: [{ scale: 1.1 }],
  },
  tabIconText: {
    fontSize: 24,
  },
});
