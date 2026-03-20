import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

typedef StickerSelectedCallback = void Function(dynamic sticker);

class StickerPickerSheet extends ConsumerStatefulWidget {
  const StickerPickerSheet({super.key, required this.onStickerSelected});
  final StickerSelectedCallback onStickerSelected;

  @override
  ConsumerState<StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends ConsumerState<StickerPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = ['😄', 'GIF', '🎬', '🎭', '📦', '⭐'];
  static const _tabLabels = ['Emoji', 'GIFs', 'Movies', 'Bollywood', 'Packs', 'Saved'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryLight,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primaryLight,
                unselectedLabelColor: AppColors.textTertiary,
                tabs: List.generate(
                  _tabs.length,
                  (i) => Tab(
                    child: Text('${_tabs[i]} ${_tabLabels[i]}', style: AppTextStyles.labelMedium),
                  ),
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _EmojiTab(onSelected: widget.onStickerSelected),
                    _GifTab(onSelected: widget.onStickerSelected),
                    _MovieCardTab(onSelected: widget.onStickerSelected),
                    _BollywoodTab(onSelected: widget.onStickerSelected),
                    _PacksTab(onSelected: widget.onStickerSelected),
                    _SavedTab(onSelected: widget.onStickerSelected),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmojiTab extends StatelessWidget {
  const _EmojiTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  static const _emojis = [
    '😂', '🥹', '💀', '😍', '🔥', '💯', '🙌', '👀',
    '😭', '🤣', '✨', '💜', '🎉', '💪', '🙏', '😤',
    '😅', '🤯', '😮‍💨', '🫶', '❤️', '😎', '🤔', '😴',
    '🫡', '🤝', '👏', '🥳', '😇', '🤡', '👻', '🎭',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _emojis.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onSelected({'type': 'emoji', 'value': _emojis[index]}),
        child: Center(
          child: Text(_emojis[index], style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

class _GifTab extends StatelessWidget {
  const _GifTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('GIF search coming soon', style: TextStyle(color: AppColors.textTertiary)),
    );
  }
}

class _MovieCardTab extends StatelessWidget {
  const _MovieCardTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  static const _cards = [
    {'title': 'Interstellar', 'quote': 'We used to look up at the sky...', 'emoji': '🌌'},
    {'title': 'The Lion King', 'quote': 'Hakuna Matata!', 'emoji': '🦁'},
    {'title': 'Star Wars', 'quote': 'May the Force be with you.', 'emoji': '⭐'},
    {'title': 'Spider-Man', 'quote': 'With great power comes great responsibility.', 'emoji': '🕷️'},
    {'title': 'Terminator', 'quote': "I'll be back.", 'emoji': '🤖'},
    {'title': 'LOTR', 'quote': 'One Ring to rule them all.', 'emoji': '💍'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return GestureDetector(
          onTap: () => onSelected({'type': 'movie_card', ...card}),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF2C1654)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card['emoji']!, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                Text(
                  '"${card['quote']}"',
                  style: AppTextStyles.quote.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapXs,
                Text(card['title']!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BollywoodTab extends StatelessWidget {
  const _BollywoodTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  static const _cards = [
    {'title': 'DDLJ', 'quote': 'Ja Simran, ja, jee le apni zindagi.', 'emoji': '🌻'},
    {'title': 'RRR', 'quote': 'Naacho Naacho!', 'emoji': '🔥'},
    {'title': 'KGF', 'quote': 'Silence!', 'emoji': '💎'},
    {'title': '3 Idiots', 'quote': 'All is well!', 'emoji': '🎓'},
    {'title': 'Baahubali', 'quote': 'Why did Katappa kill Baahubali?', 'emoji': '⚔️'},
    {'title': 'Sholay', 'quote': 'Kitne aadmi the?', 'emoji': '🤠'},
    {'title': 'Mughal-E-Azam', 'quote': 'Mogambo Khush Hua!', 'emoji': '👑'},
    {'title': 'Pushpa', 'quote': 'Pushpa... I hate tears.', 'emoji': '🌺'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return GestureDetector(
          onTap: () => onSelected({'type': 'bollywood_card', ...card}),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFF7C59F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card['emoji']!, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                Text(
                  '"${card['quote']}"',
                  style: AppTextStyles.quote.copyWith(fontSize: 11, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapXs,
                Text(card['title']!, style: AppTextStyles.labelSmall.copyWith(color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PacksTab extends StatelessWidget {
  const _PacksTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your purchased packs appear here', style: TextStyle(color: AppColors.textTertiary)),
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab({required this.onSelected});
  final StickerSelectedCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your saved stickers appear here', style: TextStyle(color: AppColors.textTertiary)),
    );
  }
}
