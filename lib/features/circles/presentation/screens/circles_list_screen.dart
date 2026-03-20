import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class CirclesListScreen extends ConsumerWidget {
  const CirclesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/circles/create'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: const [
          _CircleCard(
            id: '1',
            name: 'Close Friends',
            memberCount: 12,
            unreadCount: 3,
            icon: Icons.favorite_rounded,
            color: AppColors.accent,
          ),
          _CircleCard(
            id: '2',
            name: 'Builders',
            memberCount: 28,
            unreadCount: 0,
            icon: Icons.code_rounded,
            color: AppColors.primary,
          ),
          _CircleCard(
            id: '3',
            name: 'Hyderabad Crew',
            memberCount: 45,
            unreadCount: 7,
            icon: Icons.location_city_rounded,
            color: AppColors.vibeChill,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/circles/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Circle', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  const _CircleCard({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.unreadCount,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final int memberCount;
  final int unreadCount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: AppSpacing.avatarMd,
        height: AppSpacing.avatarMd,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: AppSpacing.iconMd),
      ),
      title: Text(name, style: AppTextStyles.headlineSmall),
      subtitle: Text('$memberCount members', style: AppTextStyles.bodySmall),
      trailing: unreadCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '$unreadCount',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
              ),
            )
          : null,
      onTap: () => context.push('/circles/$id'),
    );
  }
}
