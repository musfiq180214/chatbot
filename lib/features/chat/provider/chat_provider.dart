import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/services/hive_service.dart';
import '../model/chat_messege.dart';
import '../repository/chat_repository.dart';

final selectedModelProvider =
    StateNotifierProvider<SelectedModelNotifier, String>(
      (ref) => SelectedModelNotifier(),
    );

class SelectedModelNotifier extends StateNotifier<String> {
  SelectedModelNotifier() : super("") {
    _loadModel();
  }

  Future<void> _loadModel() async {
    await HiveService.init();
    final savedModel = HiveService.getSelectedModel();
    if (savedModel != null) {
      state = savedModel;
    } else {
      // Pick a random default if none saved
      final availableModels = [
        "openai/gpt-4o-mini",
        "openai/gpt-4o",
        "openai/gpt-3.5-turbo",
      ];
      final mutableList = [...availableModels];
      mutableList.shuffle();
      state = mutableList.first;
    }
  }

  Future<void> setModel(String model) async {
    state = model;
    await HiveService.saveSelectedModel(model);
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final model = ref.watch(selectedModelProvider);
  final repository = ref.watch(chatRepositoryProvider(model));
  return ChatNotifier(repository);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final IChatRepository _repository;
  final List<Map<String, String>> _messages = [];

  ChatNotifier(this._repository) : super([]) {
    _loadPreviousChats();
  }

  void _loadPreviousChats() {
    final previousChats = HiveService.getMessages();
    state = previousChats;

    for (var msg in previousChats) {
      _messages.add({
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.text,
      });
    }
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(text: text, isUser: true);
    state = [...state, userMsg];
    await HiveService.saveMessage(userMsg);

    _messages.add({"role": "user", "content": text});

    try {
      final reply = await _repository.sendMessage(_messages);
      _messages.add({"role": "assistant", "content": reply});

      final botMsg = ChatMessage(text: reply, isUser: false);
      state = [...state, botMsg];
      await HiveService.saveMessage(botMsg);
    } catch (e) {
      final errorMsg = ChatMessage(
        text: "Error: ${e.toString()}",
        isUser: false,
      );
      state = [...state, errorMsg];
      await HiveService.saveMessage(errorMsg);
    }
  }

  Future<void> clearChats() async {
    await HiveService.clearChat();
    state = [];
    _messages.clear();
  }
}
