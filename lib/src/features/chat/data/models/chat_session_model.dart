import 'package:hive/hive.dart';
import '../../domain/entities/chat_session_entity.dart';

part 'chat_session_model.g.dart';

/// Chat session data model
@HiveType(typeId: 0)
class ChatSessionModel extends ChatSessionEntity {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final String userId;

  @HiveField(2)
  @override
  final String title;

  @HiveField(3)
  @override
  final DateTime createdAt;

  @HiveField(4)
  @override
  final DateTime updatedAt;

  @HiveField(5)
  @override
  final int messageCount;

  const ChatSessionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
  }) : super(
          id: id,
          userId: userId,
          title: title,
          createdAt: createdAt,
          updatedAt: updatedAt,
          messageCount: messageCount,
        );

  /// Create from entity
  factory ChatSessionModel.fromEntity(ChatSessionEntity entity) {
    return ChatSessionModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      messageCount: entity.messageCount,
    );
  }

  /// Create from JSON
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  /// Convert to entity
  ChatSessionEntity toEntity() {
    return ChatSessionEntity(
      id: id,
      userId: userId,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageCount: messageCount,
    );
  }

  @override
  ChatSessionModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
