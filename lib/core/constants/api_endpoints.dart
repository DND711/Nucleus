class ApiEndpoints {
  const ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String logout = '/auth/logout';

  // Profile
  static const String profileMe = '/profile/me';
  static const String profileUpdate = '/profile/me';
  static const String profileById = '/profile/:id';
  static const String usernameCheck = '/profile/username/check';
  static const String avatarUpload = '/profile/avatar/upload-url';

  // Feed
  static const String feed = '/feed';
  static const String feedByCircle = '/feed/circle/:circleId';

  // Posts
  static const String posts = '/posts';
  static const String postById = '/posts/:id';
  static const String postReact = '/posts/:id/react';
  static const String postComment = '/posts/:id/comments';
  static const String postMediaUpload = '/posts/media/upload-url';

  // Circles
  static const String circles = '/circles';
  static const String circleById = '/circles/:id';
  static const String circleInvite = '/circles/:id/invite';
  static const String circleMembers = '/circles/:id/members';
  static const String circleJoin = '/circles/:id/join';
  static const String circleLeave = '/circles/:id/leave';
  static const String circleSubscribe = '/circles/:id/subscribe';

  // Stickers
  static const String stickerPacks = '/stickers/packs';
  static const String stickerPackById = '/stickers/packs/:id';
  static const String stickerPackPurchase = '/stickers/packs/:id/purchase';
  static const String stickerPackOwned = '/stickers/packs/owned';

  // Orbit
  static const String orbitSetup = '/orbit/setup';
  static const String orbitProfile = '/orbit/profile/:userId';
  static const String orbitDiscover = '/orbit/discover';
  static const String orbitPull = '/orbit/pull/:userId';
  static const String orbitConnections = '/orbit/connections';
  static const String orbitBlock = '/orbit/block/:userId';
  static const String orbitReport = '/orbit/report/:userId';
  static const String orbitPhotoUpload = '/orbit/photos/upload-url';
  static const String orbitVerify = '/orbit/verify';

  // Messages
  static const String messages = '/messages/:connectionId';
  static const String messagesSend = '/messages/:connectionId/send';

  // Calls
  static const String callInitiate = '/calls/initiate';
  static const String callEnd = '/calls/:callId/end';
  static const String callHistory = '/calls/history';
  static const String callSignal = '/calls/:callId/signal';

  // Credits
  static const String creditsBalance = '/credits/balance';
  static const String creditsClaim = '/credits/claim/daily';
  static const String creditsPurchase = '/credits/purchase';
  static const String creditsLedger = '/credits/ledger';
  static const String creditsGift = '/credits/gift/:userId';

  // Payments / Tips
  static const String tipSend = '/tips/send';
  static const String tipHistory = '/tips/history';
  static const String paymentVerify = '/payments/verify';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsMarkRead = '/notifications/read';
  static const String fcmTokenUpdate = '/notifications/fcm-token';

  // Search
  static const String search = '/search';
  static const String searchUsers = '/search/users';
  static const String searchPosts = '/search/posts';
  static const String searchCircles = '/search/circles';

  // Vibes
  static const String vibeSave = '/vibes';
  static const String vibeHistory = '/vibes/history';

  // Signal Questions
  static const String signalQuestions = '/profile/signal-questions';
}
