import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(route: AppRoutes.home, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _TabItem(route: AppRoutes.circles, icon: Icons.bubble_chart_outlined, activeIcon: Icons.bubble_chart_rounded, label: 'Circles'),
    _TabItem(route: AppRoutes.orbit, icon: Icons.radar_outlined, activeIcon: Icons.radar_rounded, label: 'Orbit'),
    _TabItem(route: AppRoutes.notifications, icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Updates'),
    _TabItem(route: AppRoutes.profile, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.2),
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            context.go(_tabs[index].route);
          },
          height: AppSpacing.bottomNavHeight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _tabs.map((tab) {
            final isSelected = _tabs.indexOf(tab) == currentIndex;
            return NavigationDestination(
              icon: Icon(tab.icon, size: AppSpacing.iconMd),
              selectedIcon: Icon(tab.activeIcon, size: AppSpacing.iconMd, color: AppColors.primaryLight),
              label: tab.label,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.postComposer),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, color: AppColors.textPrimary),
            )
          : null,
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
