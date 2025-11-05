import 'package:equatable/equatable.dart';

/// Chat session domain entity
class ChatSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  const ChatSessionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
  });

  ChatSessionEntity copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return ChatSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, title, createdAt, updatedAt, messageCount];
}
