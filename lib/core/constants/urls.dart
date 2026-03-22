import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static const String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta";

  static const String geminiEndpoint =
      "/models/gemini-3-flash-preview:generateContent";

  static final String? apiKey = dotenv.env['OPENAI_API_KEY'];

}