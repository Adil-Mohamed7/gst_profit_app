import 'package:flutter/foundation.dart';
import 'package:gst_profit_app/models/item.dart';
import 'package:gst_profit_app/models/history.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to handle all database operations using Hive
class DatabaseService {
  static const String _itemsBoxName = 'items';
  static const String _customGstBoxName = 'customGstValues';
  static const String _settingsBoxName = 'settings';
  static const String _historyBoxName = 'calculationHistory';

  /// Initialize the database and open required boxes
  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(CalculationHistoryAdapter());

    // Open boxes
    await Hive.openBox<Item>(_itemsBoxName);
    await Hive.openBox<String>(_customGstBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox<CalculationHistory>(_historyBoxName);
  }

  /// Get the items box
  static Box<Item> getItemsBox() => Hive.box<Item>(_itemsBoxName);

  /// Get the custom GST values box
  static Box<String> getCustomGstBox() => Hive.box<String>(_customGstBoxName);

  /// Get the settings box
  static Box getSettingsBox() => Hive.box(_settingsBoxName);

  /// Add a new item to the database
  static Future<void> addItem(Item item) async {
    final box = getItemsBox();
    await box.add(item);
  }

  /// Update an existing item in the database
  static Future<void> updateItem(Item item) async {
    await item.save();
  }

  /// Delete an item from the database
  static Future<void> deleteItem(Item item) async {
    await item.delete();
  }

  /// Get all items
  static List<Item> getAllItems() {
    return getItemsBox().values.toList();
  }

  /// Add custom GST value
  static Future<void> addCustomGst(String gstValue) async {
    final box = getCustomGstBox();
    await box.add(gstValue);
  }

  /// Get all custom GST values
  static List<double> getCustomGstValues() {
    final box = getCustomGstBox();
    return box.values.map((value) => double.parse(value)).toList();
  }

  /// Clear all custom GST values
  static Future<void> clearCustomGstValues() async {
    final box = getCustomGstBox();
    await box.clear();
  }

  /// Clear all data
  static Future<void> clearAllData() async {
    await getItemsBox().clear();
    await getCustomGstBox().clear();
  }

  /// Get the calculation history box
  static Box<CalculationHistory> getHistoryBox() =>
      Hive.box<CalculationHistory>(_historyBoxName);

  /// Save a calculation to history (max 15 records)
  static Future<void> saveCalculationToHistory(CalculationHistory history) async {
    final box = getHistoryBox();

    // Add new history
    await box.add(history);

    // Keep only last 15 records
    if (box.length > 15) {
      // Delete the oldest (first) record
      await box.deleteAt(0);
    }
  }

  /// Get all calculation history
  static List<CalculationHistory> getAllHistory() {
    final box = getHistoryBox();
    // Return in reverse order (newest first)
    return box.values.toList().reversed.toList();
  }

  /// Get calculation history as listenable for reactive updates
  static ValueListenable<Box<CalculationHistory>> getHistoryListenable() {
    return getHistoryBox().listenable();
  }

  /// Delete a history record
  static Future<void> deleteHistoryRecord(CalculationHistory history) async {
    await history.delete();
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    final box = getHistoryBox();
    await box.clear();
  }
}
