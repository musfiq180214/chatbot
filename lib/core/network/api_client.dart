import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/urls.dart';
import '../logger/app_logger.dart';

class ApiClient {
  final http.Client client;

  ApiClient(this.client);

  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse("${ApiUrls.baseUrl}$endpoint?key=${ApiUrls.apiKey}");

    try {
      AppLogger.logRequest(url.toString(), body);

      final response = await client.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppLogger.logResponse(url.toString(), decoded);
        return decoded;
      } else {
        AppLogger.logError(url.toString(), decoded);
        throw Exception(decoded.toString());
      }
    } catch (e) {
      AppLogger.logError(url.toString(), e);
      rethrow;
    }
  }
}