import '../../../core/constants/urls.dart';
import '../../../core/network/api_client.dart';

class ChatService {
  final ApiClient apiClient;

  ChatService(this.apiClient);

  Future<String> sendMessage(String message) async {
    final response = await apiClient.post(
      endpoint: ApiUrls.geminiEndpoint,
      body: {
        "contents": [
          {
            "parts": [
              {"text": message}
            ]
          }
        ]
      },
    );

    return response["candidates"][0]["content"]["parts"][0]["text"];
  }
}