import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/progress_tracker.dart';
import 'services/sound_service.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SoundService.instance.init();
  // Restore the saved challenge progress before the first screen is built.
  await ProgressTracker.load();
  runApp(const CodeBreakerApp());
}

class CodeBreakerApp extends StatelessWidget {
  const CodeBreakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code_Breaker',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
     
    );
  }
}