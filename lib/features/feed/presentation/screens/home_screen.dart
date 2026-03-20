import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/post.dart';
import '../../providers/feed_provider.dart';
import '../widgets/feed_card.dart';
import '../widgets/moment_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pagingController = PagingController<String?, Post>(firstPageKey: null);
  int _selectedCircleIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(String? cursor) async {
    try {
      final result = await ref.read(feedRepositoryProvider).getFeed(cursor: cursor);
      if (result.nextCursor == null) {
        _pagingController.appendLastPage(result.posts);
      } else {
        _pagingController.appendPage(result.posts, result.nextCursor);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            title: Text(
              'Nucleus',
              style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primaryLight),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push(AppRoutes.search),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _CircleTabBar(
                selectedIndex: _selectedCircleIndex,
                onChanged: (index) {
                  setState(() => _selectedCircleIndex = index);
                  _pagingController.refresh();
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: MomentStrip()),
        ],
        body: RefreshIndicator(
          onRefresh: () async => _pagingController.refresh(),
          color: AppColors.primaryLight,
          backgroundColor: AppColors.surface,
          child: PagedListView<String?, Post>(
            pagingController: _pagingController,
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.massive,
            ),
            builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, post, index) {
                return RepaintBoundary(
                  child: FeedCard(
                    post: post,
                    key: ValueKey(post.id),
                  ),
                );
              },
              firstPageProgressIndicatorBuilder: (_) => const _FeedSkeletons(),
              newPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              noItemsFoundIndicatorBuilder: (_) => const _EmptyFeed(),
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textTertiary),
                    AppSpacing.vGapMd,
                    Text('Could not load feed', style: AppTextStyles.bodyMedium),
                    AppSpacing.vGapSm,
                    TextButton(
                      onPressed: _pagingController.refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleTabBar extends ConsumerWidget {
  const _CircleTabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load real circles from provider
    final circles = ['All', 'Close Friends', 'Builders', 'City'];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
        itemCount: circles.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryLight : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  circles[index],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.spatial_audio_rounded, size: 56, color: AppColors.textTertiary),
            AppSpacing.vGapLg,
            const Text('Nothing here yet.', style: AppTextStyles.headlineSmall),
            AppSpacing.vGapSm,
            Text(
              'Share something with your circle.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedSkeletons extends StatelessWidget {
  const _FeedSkeletons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const FeedCardSkeleton()),
    );
  }
}
