import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/hive_service.dart';
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

  ChatNotifier(this.service) : super([]) {
    _loadChats(); // Load previous chats when provider is initialized
  }

  void _loadChats() {
    final previousChats = HiveService.getMessages();
    state = previousChats;
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(text: text, isUser: true);

    state = [...state, userMsg];
    await HiveService.saveMessage(userMsg);

    try {
      final reply = await service.sendMessage(text);

      final botMsg = ChatMessage(text: reply, isUser: false);

      state = [...state, botMsg];
      await HiveService.saveMessage(botMsg);
    } catch (e) {
      final errorMsg =
      ChatMessage(text: "Error: ${e.toString()}", isUser: false);

      state = [...state, errorMsg];
      await HiveService.saveMessage(errorMsg);
    }
  }

  Future<void> clearChats() async {
    await HiveService.clearChat();
    state = [];
  }
}