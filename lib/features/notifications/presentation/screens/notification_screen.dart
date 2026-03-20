import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';

enum NotifType { reaction, tip, circleInvite, orbit, newPost, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actorName,
    this.actorAvatarUrl,
    this.deepLink,
  });

  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actorName;
  final String? actorAvatarUrl;
  final String? deepLink;
}

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Demo notifications
    final notifications = [
      AppNotification(
        id: '1',
        type: NotifType.reaction,
        title: 'Priya reacted',
        body: 'Priya reacted 🥹 to your voice note',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        actorName: 'Priya',
        deepLink: '/posts/123',
      ),
      AppNotification(
        id: '2',
        type: NotifType.tip,
        title: 'You received ₹50',
        body: 'Arjun tipped you ₹50 for your last post',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        actorName: 'Arjun',
        deepLink: '/posts/456',
      ),
      AppNotification(
        id: '3',
        type: NotifType.orbit,
        title: 'Ananya pulled you into orbit!',
        body: 'You have a new orbit connection. Say hi!',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        actorName: 'Ananya',
        deepLink: '/orbit/connections',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          TextButton(
            onPressed: () {/* mark all read */},
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('All caught up!', style: TextStyle(color: AppColors.textTertiary)))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
                onTap: () {
                  final link = notifications[index].deepLink;
                  if (link != null) context.push(link);
                },
              ),
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.type) {
        NotifType.reaction => Icons.emoji_emotions_rounded,
        NotifType.tip => Icons.bolt_rounded,
        NotifType.circleInvite => Icons.bubble_chart_rounded,
        NotifType.orbit => Icons.radar_rounded,
        NotifType.newPost => Icons.mic_rounded,
        NotifType.system => Icons.info_rounded,
      };

  Color get _iconColor => switch (notification.type) {
        NotifType.reaction => AppColors.accent,
        NotifType.tip => AppColors.creditGold,
        NotifType.circleInvite => AppColors.primaryLight,
        NotifType.orbit => AppColors.orbitGlow,
        NotifType.newPost => AppColors.primaryLight,
        NotifType.system => AppColors.textSecondary,
      };

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        color: notification.isRead ? null : AppColors.primary.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NucleusAvatar(
                  name: notification.actorName,
                  size: AppSpacing.avatarMd,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
                    child: Icon(_icon, size: 12, color: _iconColor),
                  ),
                ),
              ],
            ),
            AppSpacing.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.body, style: AppTextStyles.bodyMedium),
                  AppSpacing.vGapXs,
                  Text(_formatTime(notification.createdAt), style: AppTextStyles.timestamp),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
              ),
          ],
        ),
      ),
    );
  }
}
