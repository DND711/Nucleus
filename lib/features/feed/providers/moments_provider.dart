import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

class Moment {
  const Moment({
    required this.id,
    required this.authorId,
    required this.circleId,
    required this.createdAt,
    this.imageUrl,
    this.emoji,
    this.gradientColors,
  });

  final String id;
  final String authorId;
  final String circleId;
  final DateTime createdAt;
  final String? imageUrl;
  final String? emoji;
  final List<String>? gradientColors;
}

final momentsProvider = FutureProvider<List<Moment>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get('/feed/moments');
  final list = response.data as List<dynamic>;
  return list.map((m) {
    final d = m as Map<String, dynamic>;
    return Moment(
      id: d['_id'] as String,
      authorId: d['authorId'] as String,
      circleId: d['circleId'] as String,
      createdAt: DateTime.parse(d['createdAt'] as String),
      imageUrl: d['imageUrl'] as String?,
      emoji: d['emoji'] as String?,
      gradientColors: (d['gradientColors'] as List<dynamic>?)?.cast<String>(),
    );
  }).toList();
});
