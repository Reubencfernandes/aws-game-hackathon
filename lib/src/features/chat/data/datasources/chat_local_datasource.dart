import 'package:hive/hive.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/logger.dart';

/// Local data source for chat using Hive
class ChatLocalDataSource {
  Box<ChatSessionModel>? _chatBox;
  Box<MessageModel>? _messageBox;

  /// Initialize Hive boxes
  Future<void> initialize() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ChatSessionModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(MessageModelAdapter());
      }

      _chatBox = await Hive.openBox<ChatSessionModel>(
        AppConfig.hiveChatBoxName,
      );
      _messageBox = await Hive.openBox<MessageModel>(
        AppConfig.hiveMessagesBoxName,
      );

      AppLogger.info('Local database initialized');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize local database', e, stackTrace);
      rethrow;
    }
  }

  /// Get all chat sessions for a user
  Future<List<ChatSessionModel>> getChatSessions(String userId) async {
    await _ensureInitialized();
    final sessions = _chatBox!.values
        .where((session) => session.userId == userId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  /// Get a specific chat session
  Future<ChatSessionModel?> getChatSession(String sessionId) async {
    await _ensureInitialized();
    return _chatBox!.get(sessionId);
  }

  /// Save a chat session
  Future<void> saveChatSession(ChatSessionModel session) async {
    await _ensureInitialized();
    await _chatBox!.put(session.id, session);
    AppLogger.debug('Chat session saved: ${session.id}');
  }

  /// Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    await _ensureInitialized();
    await _chatBox!.delete(sessionId);
    // Also delete associated messages
    final messages = _messageBox!.values
        .where((msg) => msg.chatId == sessionId)
        .map((msg) => msg.id)
        .toList();
    for (final messageId in messages) {
      await _messageBox!.delete(messageId);
    }
    AppLogger.debug('Chat session deleted: $sessionId');
  }

  /// Get messages for a chat session
  Future<List<MessageModel>> getMessages(String chatId) async {
    await _ensureInitialized();
    final messages = _messageBox!.values
        .where((message) => message.chatId == chatId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Save a message
  Future<void> saveMessage(MessageModel message) async {
    await _ensureInitialized();
    await _messageBox!.put(message.id, message);
    AppLogger.debug('Message saved: ${message.id}');
  }

  /// Update a message
  Future<void> updateMessage(MessageModel message) async {
    await _ensureInitialized();
    await _messageBox!.put(message.id, message);
    AppLogger.debug('Message updated: ${message.id}');
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _ensureInitialized();
    await _messageBox!.delete(messageId);
    AppLogger.debug('Message deleted: $messageId');
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _chatBox!.clear();
    await _messageBox!.clear();
    AppLogger.info('All local data cleared');
  }

  Future<void> _ensureInitialized() async {
    if (_chatBox == null || _messageBox == null) {
      await initialize();
    }
  }
}
