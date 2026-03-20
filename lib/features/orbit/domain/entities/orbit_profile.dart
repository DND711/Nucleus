class OrbitProfile {
  const OrbitProfile({
    required this.userId,
    required this.photos,
    required this.isVerified,
    this.verifiedAt,
    this.verificationExpiresAt,
    required this.signalQuestions,
    required this.compatibilityScore,
    required this.signals,
    this.voiceExcerptUrl,
    this.vibeHistory = const [],
    this.pullState = OrbitPullState.none,
  });

  final String userId;
  final List<OrbitPhoto> photos;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime? verificationExpiresAt;
  final List<SignalQuestion> signalQuestions;
  final double compatibilityScore;
  final CompatibilitySignals signals;
  final String? voiceExcerptUrl;
  final List<String> vibeHistory;
  final OrbitPullState pullState;

  bool get isVerificationExpiringSoon {
    if (verificationExpiresAt == null) return false;
    return verificationExpiresAt!.difference(DateTime.now()).inDays <= 14;
  }

  bool get isVerificationExpired {
    if (verificationExpiresAt == null) return true;
    return verificationExpiresAt!.isBefore(DateTime.now());
  }
}

class OrbitPhoto {
  const OrbitPhoto({
    required this.url,
    required this.isVerified,
    required this.order,
  });

  final String url;
  final bool isVerified;
  final int order;
}

class SignalQuestion {
  const SignalQuestion({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class CompatibilitySignals {
  const CompatibilitySignals({
    required this.voiceEnergy,
    required this.stickerLanguage,
    required this.vibePatterns,
    required this.circles,
    required this.signalQuestions,
    required this.moments,
    required this.tipBehaviour,
  });

  final double voiceEnergy;
  final double stickerLanguage;
  final double vibePatterns;
  final double circles;
  final double signalQuestions;
  final double moments;
  final double tipBehaviour;

  double get overall {
    const weights = [0.2, 0.15, 0.2, 0.1, 0.2, 0.1, 0.05];
    final scores = [voiceEnergy, stickerLanguage, vibePatterns, circles, signalQuestions, moments, tipBehaviour];
    return List.generate(7, (i) => scores[i] * weights[i]).reduce((a, b) => a + b) * 100;
  }
}

enum OrbitPullState { none, pendingOutgoing, pendingIncoming, confirmed }
