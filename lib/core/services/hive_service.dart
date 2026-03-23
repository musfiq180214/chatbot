import 'package:hive_flutter/hive_flutter.dart';
import '../../features/chat/model/chat_messege.dart';

class HiveService {
  static const String chatBox = "chat_box";
  static const String settingsBox = "settings_box";
  static const String selectedModelKey = "selected_model";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(chatBox);
    await Hive.openBox(settingsBox);
  }

  static Box getBox() => Hive.box(chatBox);

  /// Save a chat message
  static Future<void> saveMessage(ChatMessage message) async {
    final box = getBox();
    await box.add(message.toJson());
  }

  static List<ChatMessage> getMessages() {
    final box = getBox();

    return box.values.map((e) {
      if (e is Map) {
        return ChatMessage.fromJson(Map<String, dynamic>.from(e));
      } else {
        print("Invalid Hive data skipped: $e");
        return null;
      }
    }).whereType<ChatMessage>().toList();
  }

  /// Clear all messages
  static Future<void> clearChat() async => await getBox().clear();

  /// Save selected model
  static Future<void> saveSelectedModel(String model) async {
    final box = Hive.box(settingsBox); // ✅ separate box
    await box.put(selectedModelKey, model);
  }

  static String? getSelectedModel() {
    final box = Hive.box(settingsBox);
    return box.get(selectedModelKey) as String?;
  }
}
