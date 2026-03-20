import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _Section(title: 'Account', tiles: [
            _Tile(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () {}),
            _Tile(icon: Icons.phone_outlined, label: 'Phone Number', onTap: () {}),
            _Tile(icon: Icons.lock_outline_rounded, label: 'Privacy', onTap: () {}),
          ]),
          _Section(title: 'Orbit', tiles: [
            _Tile(icon: Icons.radar_rounded, label: 'Orbit Settings', onTap: () {}),
            _Tile(icon: Icons.verified_outlined, label: 'Verification Status', onTap: () => context.push(AppRoutes.verificationStatus)),
            _Tile(icon: Icons.block_rounded, label: 'Blocked Users', onTap: () {}),
          ]),
          _Section(title: 'Notifications', tiles: [
            _Tile(icon: Icons.notifications_outlined, label: 'Push Notifications', onTap: () {}),
            _Tile(icon: Icons.do_not_disturb_outlined, label: 'Do Not Disturb', onTap: () {}),
          ]),
          _Section(title: 'Credits & Payments', tiles: [
            _Tile(icon: Icons.bolt_rounded, label: 'Credits', onTap: () => context.push(AppRoutes.credits), trailing: const Icon(Icons.bolt_rounded, color: AppColors.creditGold, size: 16)),
            _Tile(icon: Icons.receipt_outlined, label: 'Transaction History', onTap: () {}),
          ]),
          _Section(title: 'Support', tiles: [
            _Tile(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
            _Tile(icon: Icons.bug_report_outlined, label: 'Report a Bug', onTap: () {}),
            _Tile(icon: Icons.info_outline_rounded, label: 'About Nucleus', onTap: () {}),
          ]),
          _Section(title: 'Account Actions', tiles: [
            _Tile(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: AppColors.error,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Log out?'),
                    content: const Text('You will need to verify your phone number to log back in.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authStateProvider.notifier).logout();
                }
              },
            ),
          ]),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.tiles});
  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.xl,
            AppSpacing.screenPadding,
            AppSpacing.sm,
          ),
          child: Text(title, style: AppTextStyles.labelMedium),
        ),
        ...tiles,
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap, this.color, this.trailing});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: AppSpacing.iconMd),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
