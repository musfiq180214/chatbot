import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/urls.dart';
import '../../../core/network/api_client.dart';

abstract class IChatRepository {
  Future<String> sendMessage(List<Map<String, String>> messages);
}

class ChatRepository implements IChatRepository {
  final ApiClient _apiClient;
  final String model; // 🔥 dynamic model

  ChatRepository(this._apiClient, {this.model = "openai/gpt-4o-mini"});

  @override
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final response = await _apiClient.post(
        endpoint: ApiUrls.chatEndpoint,
        body: {"model": model, "messages": messages},
      );

      final choices = response["choices"] as List?;
      if (choices != null && choices.isNotEmpty) {
        return choices[0]["message"]["content"] ??
            "I couldn't generate a response.";
      }

      return "No response found.";
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}

final chatRepositoryProvider = Provider.family<IChatRepository, String>((
  ref,
  model,
) {
  final api = ref.watch(apiClientProvider);
  return ChatRepository(api, model: model);
});
