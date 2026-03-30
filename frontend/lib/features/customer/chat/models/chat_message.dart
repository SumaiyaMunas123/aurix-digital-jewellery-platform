class ChatMessage {
  // Unique identifier for the message
  final String id;
  // The actual text content (can be null if it's just an image)
  final String? text;
  // Local path or network URL of an attached image
  final String? imagePath;
  // True if the current logged-in user sent this message
  final bool isMe;
  // Timestamp when the message was created/sent
  final DateTime time;

  const ChatMessage({
    required this.id,
    this.text,
    this.imagePath,
    required this.isMe,
    required this.time,
  });

  // Helper getters to quickly check message content types
  bool get hasText => (text != null && text!.trim().isNotEmpty);
  bool get hasImage => (imagePath != null && imagePath!.trim().isNotEmpty);
}