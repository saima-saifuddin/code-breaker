
import 'package:flutter/material.dart';
import 'challenge_selection_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';
import '../services/result_storage_service.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalScore = 0;
  int totalCoins = 0;
  int completedChallenges = 0;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  // Load saved challenge results.
  Future<void> loadStatistics() async {
    final results = await ResultStorageService.getResults();

    // Only count completed challenges.
    final completedResults = results
        .where((result) => result['completed'] == true)
        .toList();

    // Calculate total score.
    final score = completedResults.fold<int>(
      0,
      (total, result) =>
          total + (result['score'] as int? ?? 0),
    );

    // Calculate total coins.
    final coins = completedResults.fold<int>(
      0,
      (total, result) =>
          total + (result['coins'] as int? ?? 0),
    );

    if (!mounted) return;

    setState(() {
      totalScore = score;
      totalCoins = coins;
      completedChallenges = completedResults.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final horizontalPadding = screenWidth * 0.06;
    final titleSize = (screenWidth * 0.075).clamp(22.0, 36.0);
    final iconSize = (screenWidth * 0.16).clamp(48.0, 80.0);

    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Statistics
              _buildStatsRow(),

              const Spacer(),

              // Game Icon
              Icon(
                Icons.lock_open,
                color: Color(0xFF00E5FF),
                size: iconSize,
              ),

              const SizedBox(height: 12),

              // App Title
              Text(
                '🔐 CODE BREAKER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              const Text(
                'Break the code.\nSolve the puzzle.\nBecome the master.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // PLAY
              _MenuButton(
                label: 'PLAY',
                icon: Icons.play_arrow,
                filled: true,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ChallengeSelectionScreen(),
                    ),
                  );

                  // Reload statistics when returning to Home Screen.
                  loadStatistics();
                },
                
              ),

              const SizedBox(height: 14),

              // HOW TO PLAY
              _MenuButton(
                label: 'HOW TO PLAY',
                icon: Icons.info_outline,
                filled: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HowToPlayScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.035),

              // SETTINGS
              _MenuButton(
                label: 'Settings',
                icon: Icons.info_outline,
                filled: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen(),
                    ),
                  );
                },
              ),

              SizedBox(height: screenHeight * 0.035),
            ],
          ),
        ),
      ),
    );
  }

  // Display saved statistics.
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2933),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.star,
            value: totalScore.toString(),
            label: 'Score',
          ),
          _StatItem(
            icon: Icons.monetization_on,
            value: totalCoins.toString(),
            label: 'Coins',
          ),
          _StatItem(
            icon: Icons.emoji_events,
            value: '$completedChallenges/30',
            label: 'Challenges',
          ),
        ],
      ),
    );
  }
}

// Statistics item widget.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF00E5FF),
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// Menu button widget.
class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(
                  letterSpacing: 1.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: const Color(0xFF101820),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF334155),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}


