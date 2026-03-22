class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  /// Convert to Map
  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "isUser": isUser,
    };
  }

  /// Convert from Map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json["text"],
      isUser: json["isUser"],
    );
  }
}