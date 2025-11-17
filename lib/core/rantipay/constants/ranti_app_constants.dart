class RantiAppConstants {
  // App Info
  static const String appName = 'RantiPAY';
  static const String appVersion = '1.0.0';
  
  // Device Dimensions (iPhone X reference)
  static const double phoneWidth = 375.0;
  static const double phoneHeight = 812.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Haptic Feedback
  static const bool enableHapticFeedback = true;
  
  // Grid Settings
  static const int defaultGridColumns = 2;
  static const double defaultGridAspectRatio = 0.75;
  
  // Scroll Physics
  static const bool useBouncingScrollPhysics = true;
  
  // Image Cache Settings
  static const Duration imageCacheDuration = Duration(days: 7);
  static const int maxImageCacheSize = 100;
  
  // Network Settings
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}