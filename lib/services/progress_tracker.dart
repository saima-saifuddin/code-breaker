import 'package:flutter/foundation.dart';
import 'result_storage_service.dart';

/// Holds the highest challenge the player has completed.
///
/// Why it exists: the "Next Challenge" button on the Challenge Complete
/// screen opens the next game WITHOUT going back to the challenge list, so
/// the list could not otherwise learn that more challenges were completed.
/// The challenge list listens to [completedChallenges] and unlocks tiles.
///
/// The saved challenge results ([ResultStorageService], written to the device
/// the moment a challenge is completed) are the single source of truth. The
/// Home screen reads them directly, and [load] rebuilds this value from the
/// very same data, so the Challenge Selection screen can never fall behind
/// the Home screen after the app is closed and reopened.
class ProgressTracker {
  ProgressTracker._();

  /// Highest completed challenge number (0 = none completed yet).
  static final ValueNotifier<int> completedChallenges = ValueNotifier<int>(0);

  /// Rebuilds the progress from the challenge results saved on the device.
  /// Never lowers the value, so it is always safe to call again.
  static Future<void> load() async {
    try {
      final results = await ResultStorageService.getResults();
      for (final result in results) {
        if (result['completed'] != true) continue;
        final number = result['challengeNumber'];
        if (number is num) {
          markChallengeCompleted(number.toInt());
        }
      }
    } catch (_) {
      // If saved data cannot be read, keep the current value rather than
      // crashing the app. Nothing saved is modified or deleted here.
    }
  }

  /// Records that [challengeNumber] was completed. Never lowers the value.
  static void markChallengeCompleted(int challengeNumber) {
    if (challengeNumber > completedChallenges.value) {
      completedChallenges.value = challengeNumber;
    }
  }
}
