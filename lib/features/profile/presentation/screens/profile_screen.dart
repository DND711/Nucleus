import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.userId});

  /// null = own profile, non-null = other user's profile
  final String? userId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool get _isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 280,
            automaticallyImplyLeading: widget.userId != null,
            leading: widget.userId != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  )
                : null,
            actions: [
              if (_isOwnProfile) ...[
                IconButton(
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.creditGold),
                  onPressed: () => context.push(AppRoutes.credits),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.card_giftcard_rounded, color: AppColors.creditGold),
                  onPressed: () => _showTipSheet(context),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                name: _isOwnProfile ? authUser?.name ?? 'You' : 'Priya',
                username: _isOwnProfile ? authUser?.username : 'priya_creates',
                avatarUrl: _isOwnProfile ? authUser?.avatarUrl : null,
                bio: 'Design × Code × Voice ✨',
                supportersCount: 128,
                isOwnProfile: _isOwnProfile,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Voice Notes'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _PostsGrid(userId: widget.userId),
            _VoiceNotesList(userId: widget.userId),
          ],
        ),
      ),
    );
  }

  void _showTipSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _TipSheet(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    this.username,
    this.avatarUrl,
    this.bio,
    this.supportersCount = 0,
    required this.isOwnProfile,
  });

  final String name;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final int supportersCount;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          NucleusAvatar(
            imageUrl: avatarUrl,
            name: name,
            size: AppSpacing.avatarHero,
            heroTag: 'profile-avatar-$name',
          ),
          AppSpacing.vGapMd,
          Text(name, style: AppTextStyles.headlineLarge),
          if (username != null)
            Text('@$username', style: AppTextStyles.username),
          if (bio != null) ...[
            AppSpacing.vGapSm,
            Text(bio!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
          AppSpacing.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(label: 'Supporters', value: '$supportersCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMedium),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid({this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context) {
    // TODO: load posts by userId
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Container(
        color: AppColors.surfaceElevated,
        child: Center(
          child: Icon(
            index % 3 == 0 ? Icons.mic_rounded : Icons.bolt_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _VoiceNotesList extends StatelessWidget {
  const _VoiceNotesList({this.userId});
  final String? userId;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Voice notes appear here', style: TextStyle(color: AppColors.textTertiary)),
    );
  }
}

class _TipSheet extends StatelessWidget {
  const _TipSheet();

  static const _amounts = [10, 50, 100, 500];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tip this creator', style: AppTextStyles.headlineMedium),
          AppSpacing.vGapLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _amounts.map((amount) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.creditGold, size: 16),
                    Text('₹$amount', style: AppTextStyles.labelLarge),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
