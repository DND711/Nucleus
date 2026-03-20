enum PostType { spark, voice, moment, vibe, soundDrop, moodBoard }

class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    required this.circleId,
    required this.circleName,
    required this.type,
    required this.createdAt,
    this.text,
    this.imageUrl,
    this.audioUrl,
    this.waveformData,
    this.audioDurationSeconds,
    this.gradientColors,
    this.momentEmoji,
    this.vibeKey,
    this.reactions = const {},
    this.commentCount = 0,
    this.isReacted = false,
    this.myReaction,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String circleId;
  final String circleName;
  final PostType type;
  final DateTime createdAt;

  // Spark
  final String? text;
  final String? imageUrl;

  // Voice
  final String? audioUrl;
  final List<double>? waveformData;
  final int? audioDurationSeconds;

  // Moment
  final List<String>? gradientColors;
  final String? momentEmoji;

  // Vibe
  final String? vibeKey;

  // Reactions
  final Map<String, int> reactions; // emoji -> count
  final int commentCount;
  final bool isReacted;
  final String? myReaction;

  Post copyWith({
    Map<String, int>? reactions,
    int? commentCount,
    bool? isReacted,
    String? myReaction,
  }) {
    return Post(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      circleId: circleId,
      circleName: circleName,
      type: type,
      createdAt: createdAt,
      text: text,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      waveformData: waveformData,
      audioDurationSeconds: audioDurationSeconds,
      gradientColors: gradientColors,
      momentEmoji: momentEmoji,
      vibeKey: vibeKey,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      isReacted: isReacted ?? this.isReacted,
      myReaction: myReaction ?? this.myReaction,
    );
  }
}
