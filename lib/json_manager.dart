import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  // A cross-platform data manager
  static final JsonEncoder _encoder = JsonEncoder.withIndent("  ");
  static final JsonDecoder _decoder = JsonDecoder();

  // Private constructor to prevent instantiation
  DataManager._();

  /// Load data from shared preferences
  static Future<List<Map<String, dynamic>>?> loadFromFile() async {
    try {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      String? expenses = await prefs.getString("Expenses");
      if (expenses == null) {
        return null; // No data found
      }
      // Decode the JSON string into a list of maps
      return List<Map<String, dynamic>>.from(_decoder.convert(expenses));
    } catch (e) {
      //print("Error loading data: $e");
      return null;
    }
  }

  /// Save data to shared preferences
  static Future<void> saveToFile(List<Map<String, dynamic>> data) async {
    try {
      SharedPreferencesAsync prefs = SharedPreferencesAsync();
      String jsonData = _encoder.convert(data); // Serialize the data
      await prefs.setString("Expenses", jsonData);
    } catch (e) {
      //print("Error saving data: $e");
    }
  }
}
