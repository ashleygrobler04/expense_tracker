import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataManager {
  static final JsonEncoder _encoder = JsonEncoder.withIndent("  ");
  static final JsonDecoder _decoder = JsonDecoder();

  DataManager._();

  static String encodeData(List<Map<String, dynamic>> json) {
    return _encoder.convert(json);
  }

  static List<Map<String, dynamic>>? decodeData(String text) {
    try {
      return List<Map<String, dynamic>>.from(_decoder.convert(text));
    } catch (e) {
      print("Error decoding data: $e");
      return null;
    }
  }

  static Future<void> saveToFile(List<Map<String, dynamic>> data) async {
    Directory appdata = await getApplicationDocumentsDirectory();
    final file = File("${appdata.path}/expenses.json");
    final encodedData = encodeData(data);
    await file.writeAsString(encodedData);
    print("Data saved to file: ${appdata.path}");
  }

  static Future<List<Map<String, dynamic>>?> loadFromFile() async {
    try {
      Directory appData = await getApplicationDocumentsDirectory();
      final file = File("${appData.path}/expenses.json");
      final text = await file.readAsString();
      return decodeData(text);
    } catch (e) {
      print("Error loading data from file: $e");
      return null;
    }
  }
}
