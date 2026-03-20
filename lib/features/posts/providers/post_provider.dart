import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../feed/domain/entities/post.dart';
import '../../feed/providers/feed_provider.dart';

final postDetailProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/posts/$postId');
  final repo = ref.read(feedRepositoryProvider) as FeedRepositoryImpl;
  return repo.parsePost(response.data as Map<String, dynamic>);
});

// Extension to expose parse publicly
extension FeedRepoExt on FeedRepositoryImpl {
  Post parsePost(Map<String, dynamic> d) => _parse(d);

  Post _parse(Map<String, dynamic> d) {
    return Post(
      id: d['_id'] as String,
      authorId: d['authorId'] as String,
      authorName: d['authorName'] as String,
      authorUsername: d['authorUsername'] as String?,
      authorAvatarUrl: d['authorAvatarUrl'] as String?,
      circleId: d['circleId'] as String,
      circleName: d['circleName'] as String,
      type: _parseType(d['type'] as String),
      createdAt: DateTime.parse(d['createdAt'] as String),
      text: d['text'] as String?,
      imageUrl: d['imageUrl'] as String?,
      audioUrl: d['audioUrl'] as String?,
      waveformData: (d['waveformData'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      audioDurationSeconds: d['audioDurationSeconds'] as int?,
      gradientColors: (d['gradientColors'] as List<dynamic>?)?.cast<String>(),
      momentEmoji: d['momentEmoji'] as String?,
      vibeKey: d['vibeKey'] as String?,
      reactions: Map<String, int>.from(d['reactions'] as Map<dynamic, dynamic>? ?? {}),
      commentCount: d['commentCount'] as int? ?? 0,
      isReacted: d['isReacted'] as bool? ?? false,
      myReaction: d['myReaction'] as String?,
    );
  }

  PostType _parseType(String t) => switch (t) {
        'voice' => PostType.voice,
        'moment' => PostType.moment,
        'vibe' => PostType.vibe,
        'sound_drop' => PostType.soundDrop,
        'mood_board' => PostType.moodBoard,
        _ => PostType.spark,
      };
}
