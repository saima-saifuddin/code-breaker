import 'package:flutter/material.dart';

// Keeping every "magic number" and color in ONE file makes the game easy to
// tune later — e.g. change TIME_PER_PUZZLE once and it updates everywhere.
class GameConstants {
  // ---- Game rules ----
  static const int maxLives = 3;
  static const int timePerPuzzle = 30; // seconds
  static const int hintCost = 10; // coins
  static const int correctAnswerScore = 100;
  static const int correctAnswerCoins = 5;
  static const int fastAnswerBonusScore = 20; // if answered with 15+ seconds left
  static const int fastAnswerThresholdSeconds = 15;
  static const int challengeCompleteBonusScore = 500;
  static const int challengeCompleteBonusCoins = 50;
  static const int totalChallenges = 30;
  static const int levelsPerChallenge = 5;

  static const List<String> levelNames = [
    'Pattern',
    'Programming',
    'Logic',
    'Debugging',
    'Final Code Breaker',
  ];

  static const List<IconData> levelIcons = [
    Icons.pattern,
    Icons.code,
    Icons.psychology,
    Icons.bug_report,
    Icons.lock_open,
  ];
}

// ---- Cyber theme colors ----
class AppColors {
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF141B2D);
  static const Color surfaceLight = Color(0xFF1E2740);
  static const Color primary = Color(0xFF00E5C7); // neon teal
  static const Color secondary = Color(0xFF7B61FF); // neon violet
  static const Color success = Color(0xFF33D17A);
  static const Color error = Color(0xFFFF5C5C);
  static const Color warning = Color(0xFFFFC93C);
  static const Color textPrimary = Color(0xFFEAF0FF);
  static const Color textSecondary = Color(0xFF8B94AD);
  static const Color locked = Color(0xFF3A4258);
}
