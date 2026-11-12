abstract final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String language = 'language';
  static const String isDarkMode = 'is_dark_mode';
  static const String onboardingSeen = 'onboarding_seen';

  /// Guest welcome slides shown once before the public video library.
  static const String introSeen = 'intro_seen';

  /// Per-user: agreed to share Sandy chats with the third-party AI provider.
  static const String sandyAiConsent = 'sandy_ai_consent';
}
