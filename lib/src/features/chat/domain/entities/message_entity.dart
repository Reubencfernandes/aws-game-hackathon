import 'package:equatable/equatable.dart';

/// Message role
enum MessageRole {
  user,
  assistant,
  system,
}

/// Message domain entity
class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isStreaming;
  final bool isError;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isStreaming = false,
    this.isError = false,
  });

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isStreaming,
    bool? isError,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props =>
      [id, chatId, content, role, timestamp, isStreaming, isError];
}
