import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/glass_container.dart';
import '../core/widgets/scale_tap.dart';
import 'add/add_bookmark_screen.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const SearchScreen(),
      AddBookmarkScreen(
        onBookmarkAdded: () {
          setState(() {
            _currentIndex = 0; // Return to Bookmarks tab
          });
        },
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
          child: GlassContainer(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            backgroundColor: AppColors.surface.withValues(alpha: 0.88),
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.collections_bookmark_outlined,
                    activeIcon: Icons.collections_bookmark,
                    label: 'Bookmarks',
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                    label: 'Search',
                  ),
                  _buildTabItem(
                    index: 2,
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    label: 'Add',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: ScaleTap(
        onTap: () => _onTabTapped(index),
        scaleDown: 0.92,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: isSelected
                ? Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 19,
                  color: isSelected ? AppColors.cyanLight : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.text : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
