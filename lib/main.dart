import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/dubbing/dubbing_orchestrator.dart';
import 'features/upload/upload_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DubbingOrchestrator(
            deepgramKey: '',
            openaiKey: '',
            elevenlabsKey: '',
            synclabsKey: '',
          ),
        ),
      ],
      child: const AIDubApp(),
    ),
  );
}

class AIDubApp extends StatelessWidget {
  const AIDubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Dub Pro (Pure Dart)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const UploadScreen(),
    );
  }
}
