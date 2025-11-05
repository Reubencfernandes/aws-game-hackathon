import '../entities/chat_session_entity.dart';
import '../entities/message_entity.dart';
import '../../../../core/utils/result.dart';

/// Chat repository interface
abstract class ChatRepository {
  /// Get all chat sessions for a user
  Future<Result<List<ChatSessionEntity>>> getChatSessions(String userId);

  /// Get a specific chat session
  Future<Result<ChatSessionEntity>> getChatSession(String sessionId);

  /// Create a new chat session
  Future<Result<ChatSessionEntity>> createChatSession(String userId, String title);

  /// Update a chat session
  Future<Result<ChatSessionEntity>> updateChatSession(ChatSessionEntity session);

  /// Delete a chat session
  Future<Result<void>> deleteChatSession(String sessionId);

  /// Get messages for a chat session
  Future<Result<List<MessageEntity>>> getMessages(String chatId);

  /// Add a message to a chat session
  Future<Result<MessageEntity>> addMessage(MessageEntity message);

  /// Update a message
  Future<Result<MessageEntity>> updateMessage(MessageEntity message);

  /// Delete a message
  Future<Result<void>> deleteMessage(String messageId);

  /// Send a message to LLM and get response (streaming)
  Stream<String> sendMessageToLLM(String message, List<MessageEntity> history);

  /// Sync local data to cloud
  Future<Result<void>> syncToCloud(String userId);
}
