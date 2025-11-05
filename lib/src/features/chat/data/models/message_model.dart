import 'package:hive/hive.dart';
import '../../domain/entities/message_entity.dart';

part 'message_model.g.dart';

/// Message data model
@HiveType(typeId: 1)
class MessageModel extends MessageEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String chatId;

  @HiveField(2)
  @override
  final String content;

  @HiveField(3)
  final String roleString;

  @HiveField(4)
  @override
  final DateTime timestamp;

  @HiveField(5)
  @override
  final bool isStreaming;

  @HiveField(6)
  @override
  final bool isError;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.roleString,
    required this.timestamp,
    this.isStreaming = false,
    this.isError = false,
  }) : super(
          id: id,
          chatId: chatId,
          content: content,
          role: MessageRole.user, // This will be overridden by the getter
          timestamp: timestamp,
          isStreaming: isStreaming,
          isError: isError,
        );

  @override
  MessageRole get role => MessageRole.values.firstWhere(
        (e) => e.name == roleString,
        orElse: () => MessageRole.user,
      );

  /// Create from entity
  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      chatId: entity.chatId,
      content: entity.content,
      roleString: entity.role.name,
      timestamp: entity.timestamp,
      isStreaming: entity.isStreaming,
      isError: entity.isError,
    );
  }

  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      content: json['content'] as String,
      roleString: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isStreaming: json['isStreaming'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'content': content,
      'role': roleString,
      'timestamp': timestamp.toIso8601String(),
      'isStreaming': isStreaming,
      'isError': isError,
    };
  }

  /// Convert to entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatId: chatId,
      content: content,
      role: role,
      timestamp: timestamp,
      isStreaming: isStreaming,
      isError: isError,
    );
  }

  @override
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isStreaming,
    bool? isError,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      roleString: role?.name ?? roleString,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
    );
  }
}
