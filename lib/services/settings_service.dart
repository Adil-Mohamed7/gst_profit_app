import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:gst_profit_app/services/database_service.dart';

/// Service to handle app settings
class SettingsService {
  static const String _darkModeKey = 'darkMode';

  /// Get dark mode setting
  static bool getDarkMode() {
    final box = DatabaseService.getSettingsBox();
    return box.get(_darkModeKey, defaultValue: false) as bool;
  }

  /// Set dark mode setting
  static Future<void> setDarkMode(bool isDarkMode) async {
    final box = DatabaseService.getSettingsBox();
    await box.put(_darkModeKey, isDarkMode);
  }

  /// Get settings box listenable for reactive updates
  static ValueListenable<Box> getSettingsListenable() {
    return DatabaseService.getSettingsBox().listenable();
  }
}
