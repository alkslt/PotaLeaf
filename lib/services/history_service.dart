import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_result.dart';

/// Manages local persistence of detection history using SharedPreferences.
class HistoryService {
  static const String _historyKey = 'potaleaf_history';

  /// Broadcasts changes to the history list
  static final ValueNotifier<int> historyUpdateNotifier = ValueNotifier<int>(0);

  static void notifyHistoryChanged() {
    historyUpdateNotifier.value++;
  }

  /// Load all saved detection results from local storage.
  Future<List<DetectionResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    return jsonList.map((s) => DetectionResult.fromJsonString(s)).toList();
  }

  /// Save a new detection result to history.
  Future<void> saveResult(DetectionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    jsonList.insert(0, result.toJsonString()); // Newest first
    await prefs.setStringList(_historyKey, jsonList);
    notifyHistoryChanged();
  }

  /// Delete a detection result by ID.
  Future<void> deleteResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    final updatedList = jsonList.where((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map['id'] != id;
    }).toList();

    await prefs.setStringList(_historyKey, updatedList);
    notifyHistoryChanged();
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyHistoryChanged();
  }
}
