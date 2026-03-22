import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/chat_messege.dart';
import '../service/chat_service.dart';
import '../../../core/providers/api_client_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final api = ref.read(apiClientProvider);
  return ChatService(api);
});

final chatProvider =
StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final service = ref.read(chatServiceProvider);
  return ChatNotifier(service);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatService service;

  ChatNotifier(this.service) : super([]);

  Future<void> sendMessage(String text) async {
    state = [...state, ChatMessage(text: text, isUser: true)];

    try {
      final reply = await service.sendMessage(text);

      state = [...state, ChatMessage(text: reply, isUser: false)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(text: "Error: ${e.toString()}", isUser: false)
      ];
    }
  }
}