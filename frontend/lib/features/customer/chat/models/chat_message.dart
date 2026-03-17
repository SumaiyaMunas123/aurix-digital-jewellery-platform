class ChatMessage {
  final String id;
  final String? text;
  final String? imagePath;
  final bool isMe;
  final DateTime time;

  const ChatMessage({
    required this.id,
    this.text,
    this.imagePath,
    required this.isMe,
    required this.time,
  });

  bool get hasText => (text != null && text!.trim().isNotEmpty);
  bool get hasImage => (imagePath != null && imagePath!.trim().isNotEmpty);
}