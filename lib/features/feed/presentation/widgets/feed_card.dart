import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';
import '../../../../shared/widgets/sticker_burst.dart';
import '../../../../shared/widgets/waveform_player.dart';
import '../../domain/entities/post.dart';

class FeedCard extends ConsumerWidget {
  const FeedCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/posts/${post.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(post: post),
            AppSpacing.vGapMd,
            _PostBody(post: post),
            AppSpacing.vGapMd,
            _PostFooter(post: post),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NucleusAvatar(
          imageUrl: post.authorAvatarUrl,
          name: post.authorName,
          size: AppSpacing.avatarMd,
          heroTag: 'avatar-${post.authorId}-${post.id}',
          onTap: () => context.push('/profile/${post.authorId}'),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.authorName, style: AppTextStyles.headlineSmall),
              Row(
                children: [
                  Text(
                    post.authorUsername != null ? '@${post.authorUsername}' : '',
                    style: AppTextStyles.username,
                  ),
                  const Text(' · ', style: TextStyle(color: AppColors.textTertiary)),
                  _CircleChip(circleName: post.circleName),
                ],
              ),
            ],
          ),
        ),
        Text(
          _formatTime(post.createdAt),
          style: AppTextStyles.timestamp,
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(dt);
  }
}

class _PostBody extends StatelessWidget {
  const _PostBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return switch (post.type) {
      PostType.spark => _SparkBody(post: post),
      PostType.voice => _VoiceBody(post: post),
      PostType.moment => _MomentBody(post: post),
      PostType.vibe => _VibeBody(post: post),
      PostType.soundDrop || PostType.moodBoard => _GenericBody(post: post),
    };
  }
}

class _SparkBody extends StatelessWidget {
  const _SparkBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.text != null)
          Text(post.text!, style: AppTextStyles.bodyLarge),
        if (post.imageUrl != null) ...[
          AppSpacing.vGapMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 200,
                color: AppColors.surfaceElevated,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VoiceBody extends StatelessWidget {
  const _VoiceBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.audioUrl == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: WaveformPlayer(
        audioUrl: post.audioUrl!,
        waveformData: post.waveformData,
        duration: post.audioDurationSeconds != null
            ? Duration(seconds: post.audioDurationSeconds!)
            : null,
      ),
    );
  }
}

class _MomentBody extends StatelessWidget {
  const _MomentBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final colors = post.gradientColors?.map((c) {
      final hex = c.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    }).toList();

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: colors != null && colors.length >= 2
            ? LinearGradient(colors: colors)
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: post.momentEmoji != null
          ? Text(post.momentEmoji!, style: const TextStyle(fontSize: 48))
          : null,
    );
  }
}

class _VibeBody extends StatelessWidget {
  const _VibeBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.vibeCreative.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.vibeCreative.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        'Feeling ${post.vibeKey ?? 'something'}',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.vibeCreative),
      ),
    );
  }
}

class _GenericBody extends StatelessWidget {
  const _GenericBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Text(post.text ?? '', style: AppTextStyles.bodyLarge);
  }
}

class _PostFooter extends StatefulWidget {
  const _PostFooter({required this.post});

  final Post post;

  @override
  State<_PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<_PostFooter> {
  bool _showReactions = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Reaction row
        if (widget.post.reactions.isNotEmpty)
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.reactions.entries.length,
                itemBuilder: (context, index) {
                  final entry = widget.post.reactions.entries.elementAt(index);
                  return StickerBurst(
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 3),
                          Text(
                            '${entry.value}',
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        else
          const Expanded(child: SizedBox()),

        // Comment count
        Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: AppSpacing.iconXs, color: AppColors.textTertiary),
            const SizedBox(width: 3),
            Text('${widget.post.commentCount}', style: AppTextStyles.timestamp),
          ],
        ),
      ],
    );
  }
}

class _CircleChip extends StatelessWidget {
  const _CircleChip({required this.circleName});

  final String circleName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        circleName,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryLight),
      ),
    );
  }
}
