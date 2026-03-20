import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../../../shared/widgets/skeleton_loader.dart';

class StickerPack {
  const StickerPack({
    required this.id,
    required this.name,
    required this.creatorName,
    required this.previewEmojis,
    required this.priceInr,
    required this.stickerCount,
    this.isPurchased = false,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final String creatorName;
  final List<String> previewEmojis;
  final int priceInr;
  final int stickerCount;
  final bool isPurchased;
  final String? thumbnailUrl;
}

class StickerStoreScreen extends ConsumerStatefulWidget {
  const StickerStoreScreen({super.key});

  @override
  ConsumerState<StickerStoreScreen> createState() => _StickerStoreScreenState();
}

class _StickerStoreScreenState extends ConsumerState<StickerStoreScreen> {
  String _filter = 'all';

  static const _filters = ['all', 'popular', 'new', 'movies', 'bollywood', 'anime'];

  // Demo packs
  static const _demoPacks = [
    StickerPack(
      id: 'bollywood-classics',
      name: 'Bollywood Classics',
      creatorName: 'Nucleus',
      previewEmojis: ['🎬', '🎭', '💃', '🕺'],
      priceInr: 49,
      stickerCount: 25,
    ),
    StickerPack(
      id: 'hollywood-icons',
      name: 'Hollywood Icons',
      creatorName: 'Nucleus',
      previewEmojis: ['🌌', '🦁', '⭐', '🕷️'],
      priceInr: 49,
      stickerCount: 30,
    ),
    StickerPack(
      id: 'rr-pack',
      name: 'RRR Special Edition',
      creatorName: 'NaattuKoottam',
      previewEmojis: ['🔥', '💪', '⚔️', '🦅'],
      priceInr: 29,
      stickerCount: 15,
    ),
    StickerPack(
      id: 'pushpa-pack',
      name: 'Pushpa Universe',
      creatorName: 'FireFlower',
      previewEmojis: ['🌺', '💎', '🚛', '🔥'],
      priceInr: 29,
      stickerCount: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sticker Store'),
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isSelected = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
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
                        f[0].toUpperCase() + f.substring(1),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 0),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemCount: _demoPacks.length,
              itemBuilder: (context, index) {
                return _StickerPackCard(
                  pack: _demoPacks[index],
                  onTap: () => _showPackPreview(_demoPacks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPackPreview(StickerPack pack) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PackPreviewSheet(pack: pack),
    );
  }
}

class _StickerPackCard extends StatelessWidget {
  const _StickerPackCard({required this.pack, required this.onTap});
  final StickerPack pack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: pack.previewEmojis
                      .map((e) => Text(e, style: const TextStyle(fontSize: 28)))
                      .toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pack.name, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    'by ${pack.creatorName}',
                    style: AppTextStyles.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${pack.priceInr}', style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      )),
                      Text('${pack.stickerCount} stickers', style: AppTextStyles.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackPreviewSheet extends StatelessWidget {
  const _PackPreviewSheet({required this.pack});
  final StickerPack pack;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              Text(pack.name, style: AppTextStyles.headlineMedium),
              Text('by ${pack.creatorName} · ${pack.stickerCount} stickers', style: AppTextStyles.bodySmall),
              AppSpacing.vGapLg,
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                  ),
                  itemCount: pack.previewEmojis.length * 3,
                  itemBuilder: (context, index) {
                    final emoji = pack.previewEmojis[index % pack.previewEmojis.length];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                ),
                child: NucleusButton(
                  label: pack.isPurchased ? 'Already Owned' : 'Buy for ₹${pack.priceInr}',
                  onPressed: pack.isPurchased ? null : () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
