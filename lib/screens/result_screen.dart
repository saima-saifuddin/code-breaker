
import 'package:flutter/material.dart';
import '../services/result_storage_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<Map<String, dynamic>>> resultsFuture;

  @override
  void initState() {
    super.initState();
    resultsFuture = ResultStorageService.getResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081329),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081329),
        foregroundColor: Colors.white,
        title: const Text('Challenge Results'),
      ),
      // This is the main part responsible for displaying the results.
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: resultsFuture,
        builder: (context, snapshot) {
          // While results are loading, it shows a loading circle.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If retrieving the results fails, it displays an error message.

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load results.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Here, the retrieved results are assigned to the results variable.
          final results = snapshot.data ?? [];
      // If the player has not completed any challenge, it displays that message.
          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No completed challenges yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Completed Challenges: ${results.length}',//counts the number of saved challenge records.
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...results.map((challenge) {
                final levels =
                    (challenge['levels'] as List<dynamic>?) ?? [];

                return Card(
                  color: const Color(0xFF142544),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenge ${challenge['challengeNumber']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${challenge['score']}',
                          style: const TextStyle(
                            color: Color(0xFF7EE8FA),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Correct answers: ${challenge['correctAnswers']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Wrong attempts: ${challenge['wrongAttempts']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        const Text(
                          'Level-wise Performance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        ...levels.map((level) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF20365A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level ${level['level']}: '
                                  '${level['levelName']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Score: ${level['score']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Correct answers: '
                                  '${level['correctAnswers']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Wrong attempts: ${level['wrongAttempts']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
