import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.extension,
      'text': 'Solve each puzzle to move to the next level.',
    },
    {
      'icon': Icons.favorite,
      'text': 'You have 3 lives. A wrong answer costs one life.',
    },
    {
      'icon': Icons.timer,
      'text': 'Watch the timer — running out also costs a life.',
    },
    {
      'icon': Icons.monetization_on,
      'text': 'Correct answers earn coins as you play.',
    },
    {
      'icon': Icons.lightbulb,
      'text': 'Spend coins on the Hint button if you get stuck.',
    },
    {
      'icon': Icons.key,
      'text': 'Levels 1-4 each reveal a clue for the challenge.',
    },
    {
      'icon': Icons.lock_open,
      'text': 'Level 5 asks you to combine the clues into the final code.',
    },
    {
      'icon': Icons.flag,
      'text': 'Finish all 5 levels to unlock the next challenge.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),

      appBar: AppBar(
        backgroundColor: const Color(0xFF101820),
        title: const Text('How to Play'),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _steps.length,

        itemBuilder: (context, index) {
          final step = _steps[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color(0xFF1E2933),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFF00E5FF).withOpacity(0.15),

                  child: Icon(
                    step['icon'] as IconData,
                    color: const Color(0xFF00E5FF),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    step['text'] as String,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}