import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_keys.dart';

class HiveBoxes {
  static Box<dynamic>? _userProfileBox;
  static Box<dynamic>? _feedCacheBox;
  static Box<dynamic>? _stickerCacheBox;
  static Box<dynamic>? _callHistoryBox;
  static Box<dynamic>? _messageBox;
  static Box<dynamic>? _orbitProfileBox;
  static Box<dynamic>? _circleBox;
  static Box<dynamic>? _creditsBox;

  static Box<dynamic> get userProfile => _userProfileBox!;
  static Box<dynamic> get feedCache => _feedCacheBox!;
  static Box<dynamic> get stickerCache => _stickerCacheBox!;
  static Box<dynamic> get callHistory => _callHistoryBox!;
  static Box<dynamic> get messages => _messageBox!;
  static Box<dynamic> get orbitProfile => _orbitProfileBox!;
  static Box<dynamic> get circles => _circleBox!;
  static Box<dynamic> get credits => _creditsBox!;

  static Future<void> openAll() async {
    _userProfileBox = await Hive.openBox(StorageKeys.userProfileBox);
    _feedCacheBox = await Hive.openBox(StorageKeys.feedCacheBox);
    _stickerCacheBox = await Hive.openBox(StorageKeys.stickerCacheBox);
    _callHistoryBox = await Hive.openBox(StorageKeys.callHistoryBox);
    _messageBox = await Hive.openBox(StorageKeys.messageBox);
    _orbitProfileBox = await Hive.openBox(StorageKeys.orbitProfileBox);
    _circleBox = await Hive.openBox(StorageKeys.circleBox);
    _creditsBox = await Hive.openBox(StorageKeys.creditsBox);
  }

  static Future<void> clearAll() async {
    await Future.wait([
      userProfile.clear(),
      feedCache.clear(),
      stickerCache.clear(),
      callHistory.clear(),
      messages.clear(),
      orbitProfile.clear(),
      circles.clear(),
      credits.clear(),
    ]);
  }
}
