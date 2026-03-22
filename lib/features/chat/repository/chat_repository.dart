import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/urls.dart';
import '../../../core/network/api_client.dart';

abstract class IChatRepository {
  Future<String> sendMessage(String message);
}

class ChatRepository implements IChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  @override
  Future<String> sendMessage(String message) async {
    final response = await _apiClient.post(
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

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ChatRepository(api);
});