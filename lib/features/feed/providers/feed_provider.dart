import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/entities/post.dart';

class FeedResult {
  const FeedResult({required this.posts, this.nextCursor});
  final List<Post> posts;
  final String? nextCursor;
}

abstract class FeedRepository {
  Future<FeedResult> getFeed({String? cursor, String? circleId});
}

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl({required this.dioClient});
  final DioClient dioClient;

  @override
  Future<FeedResult> getFeed({String? cursor, String? circleId}) async {
    final response = await dioClient.dio.get(
      '/feed',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (circleId != null) 'circleId': circleId,
        'limit': 20,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['posts'] as List<dynamic>).map((p) => _parse(p as Map<String, dynamic>)).toList();

    return FeedResult(
      posts: items,
      nextCursor: data['nextCursor'] as String?,
    );
  }

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

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(dioClient: ref.watch(dioClientProvider));
});
