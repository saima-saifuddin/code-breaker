
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResultStorageService {
  static const String _storageKey = 'completed_challenge_results';

  static Future<List<Map<String, dynamic>>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData == null) return [];

    final decoded = jsonDecode(savedData) as List;

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> saveChallengeResult(
    Map<String, dynamic> result,
  ) async {
    final results = await getResults();

    final challengeNumber = result['challengeNumber'];

    // Replace the old record if this challenge was already completed.
    results.removeWhere(
      (item) => item['challengeNumber'] == challengeNumber,
    );

    results.add(result);

    // Keep challenge history ordered by challenge number.
    results.sort(
      (a, b) => (a['challengeNumber'] as int)
          .compareTo(b['challengeNumber'] as int),
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(results),
    );
  }
}
