import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/services/hive_service.dart';
import '../model/chat_messege.dart';
import '../repository/chat_repository.dart';

final chatProvider =
StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final IChatRepository _repository;

  ChatNotifier(this._repository) : super([]) {
    _loadPreviousChats();
  }

  void _loadPreviousChats() {
    final previousChats = HiveService.getMessages();
    state = previousChats;
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(text: text, isUser: true);
    state = [...state, userMsg];
    await HiveService.saveMessage(userMsg);

    try {
      final reply = await _repository.sendMessage(text);
      final botMsg = ChatMessage(text: reply, isUser: false);
      state = [...state, botMsg];
      await HiveService.saveMessage(botMsg);
    } catch (e) {
      final errorMsg = ChatMessage(text: "Error: ${e.toString()}", isUser: false);
      state = [...state, errorMsg];
      await HiveService.saveMessage(errorMsg);
    }
  }

  Future<void> clearChats() async {
    await HiveService.clearChat();
    state = [];
  }
}