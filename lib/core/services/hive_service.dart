import 'package:hive_flutter/hive_flutter.dart';
import '../../features/chat/model/chat_messege.dart';

class HiveService {
  static const String chatBox = "chat_box";
  static const String selectedModelKey = "selected_model";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(chatBox);
  }

  static Box getBox() => Hive.box(chatBox);

  /// Save a chat message
  static Future<void> saveMessage(ChatMessage message) async {
    final box = getBox();
    await box.add(message.toJson());
  }

  /// Get all messages
  static List<ChatMessage> getMessages() {
    final box = getBox();
    return box.values
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Clear all messages
  static Future<void> clearChat() async => await getBox().clear();

  /// Save selected model
  static Future<void> saveSelectedModel(String model) async {
    final box = getBox();
    await box.put(selectedModelKey, model);
  }

  /// Load selected model
  static String? getSelectedModel() {
    final box = getBox();
    return box.get(selectedModelKey) as String?;
  }
}
