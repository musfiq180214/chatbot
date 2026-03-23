import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static const String baseUrl = "https://openrouter.ai/api/v1";

  static const String chatEndpoint = "/chat/completions";

  static final String? apiKey = dotenv.env['OPENROUTER_API_KEY'];
}