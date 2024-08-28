import 'dart:convert';

class ChatMessage {
  final String message;
  final DateTime timestamp;

  ChatMessage({required this.message, required this.timestamp});

  factory ChatMessage.fromJson(String jsonString) {
    final jsonData = json.decode(jsonString);
    return ChatMessage(
      message: jsonData['message'],
      timestamp: DateTime.parse(jsonData['timestamp']),
    );
  }

  String toJson() {
    final jsonData = {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
    return json.encode(jsonData);
  }
}
