import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../../../../shared/widgets/sticker_burst.dart';
import '../../../../shared/widgets/waveform_player.dart';

enum CommentType { text, emoji, gif, movieCard, bollywoodCard, voice }

class Comment {
  const Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.type,
    required this.createdAt,
    this.text,
    this.emoji,
    this.gifUrl,
    this.stickerImageUrl,
    this.stickerQuote,
    this.stickerTitle,
    this.audioUrl,
    this.waveformData,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final CommentType type;
  final DateTime createdAt;
  final String? text;
  final String? emoji;
  final String? gifUrl;
  final String? stickerImageUrl;
  final String? stickerQuote;
  final String? stickerTitle;
  final String? audioUrl;
  final List<double>? waveformData;
}

// Sliver version for use in CustomScrollView
class CommentThreadSliver extends ConsumerWidget {
  const CommentThreadSliver({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: load comments via provider
    return const SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('No comments yet. Be the first!',
              style: TextStyle(color: AppColors.textTertiary)),
        ),
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NucleusAvatar(
            imageUrl: comment.authorAvatarUrl,
            name: comment.authorName,
            size: AppSpacing.avatarSm,
          ),
          AppSpacing.hGapMd,
          Expanded(child: _CommentBody(comment: comment)),
        ],
      ),
    );
  }
}

class _CommentBody extends StatelessWidget {
  const _CommentBody({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(comment.authorName, style: AppTextStyles.labelLarge),
        AppSpacing.vGapXs,
        switch (comment.type) {
          CommentType.text => Text(comment.text ?? '', style: AppTextStyles.bodyMedium),
          CommentType.emoji => StickerBurst(
              child: Text(comment.emoji ?? '', style: const TextStyle(fontSize: 40)),
            ),
          CommentType.gif => _GifComment(gifUrl: comment.gifUrl!),
          CommentType.movieCard => _MovieCard(
              quote: comment.stickerQuote ?? '',
              title: comment.stickerTitle ?? '',
              imageUrl: comment.stickerImageUrl,
            ),
          CommentType.bollywoodCard => _BollywoodCard(
              quote: comment.stickerQuote ?? '',
              title: comment.stickerTitle ?? '',
              imageUrl: comment.stickerImageUrl,
            ),
          CommentType.voice => comment.audioUrl != null
              ? WaveformPlayer(
                  audioUrl: comment.audioUrl!,
                  waveformData: comment.waveformData,
                  isCompact: true,
                )
              : const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _GifComment extends StatelessWidget {
  const _GifComment({required this.gifUrl});
  final String gifUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.network(gifUrl, width: 160, fit: BoxFit.cover),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.quote, required this.title, this.imageUrl});
  final String quote;
  final String title;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return StickerBurst(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D0D0D), Color(0xFF2C1654)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"$quote"',
              style: AppTextStyles.quote.copyWith(fontSize: 13, color: AppColors.textPrimary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGapSm,
            Text(
              '— $title',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BollywoodCard extends StatelessWidget {
  const _BollywoodCard({required this.quote, required this.title, this.imageUrl});
  final String quote;
  final String title;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return StickerBurst(
      child: Container(
        width: 200,
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
            Text(
              '"$quote"',
              style: AppTextStyles.quote.copyWith(fontSize: 13, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vGapSm,
            Text(
              '— $title',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
