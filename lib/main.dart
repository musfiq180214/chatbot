import 'package:chatbot/core/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/hive_service.dart';
import 'features/chat/presentation/chat_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/env");
    debugPrint("OpenAI API Key Loaded: ${dotenv.env['OPENAI_API_KEY']}");
  } catch (e) {
    debugPrint("Error loading env file: $e");
  }
  await HiveService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ChatScreen(),
    );
  }
}
/*
*  We are ignoring secret keys from github
* */