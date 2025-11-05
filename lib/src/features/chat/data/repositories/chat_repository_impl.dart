import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../datasources/chat_remote_datasource.dart';
import '../datasources/llm_service.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;
  final ChatRemoteDataSource remoteDataSource;
  final LLMService llmService;
  final Uuid _uuid = const Uuid();

  ChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.llmService,
  });

  @override
  Future<Result<List<ChatSessionEntity>>> getChatSessions(String userId) async {
    try {
      // Try to get from local first
      final localSessions = await localDataSource.getChatSessions(userId);

      // Sync with remote in background (fire and forget)
      _syncFromRemote(userId);

      return Success(localSessions.map((s) => s.toEntity()).toList());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get chat sessions', e, stackTrace);
      return Failure('Failed to load chat sessions',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<ChatSessionEntity>> getChatSession(String sessionId) async {
    try {
      final session = await localDataSource.getChatSession(sessionId);
      if (session == null) {
        return const Failure('Chat session not found');
      }
      return Success(session.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get chat session', e, stackTrace);
      return Failure('Failed to load chat session',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<ChatSessionEntity>> createChatSession(
    String userId,
    String title,
  ) async {
    try {
      final now = DateTime.now();
      final session = ChatSessionModel(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        createdAt: now,
        updatedAt: now,
        messageCount: 0,
      );

      await localDataSource.saveChatSession(session);

      // Sync to remote in background
      _syncSessionToRemote(session);

      return Success(session.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create chat session', e, stackTrace);
      return Failure('Failed to create chat session',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<ChatSessionEntity>> updateChatSession(
    ChatSessionEntity session,
  ) async {
    try {
      final model = ChatSessionModel.fromEntity(session);
      await localDataSource.saveChatSession(model);

      // Sync to remote in background
      _syncSessionToRemote(model);

      return Success(session);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update chat session', e, stackTrace);
      return Failure('Failed to update chat session',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteChatSession(String sessionId) async {
    try {
      await localDataSource.deleteChatSession(sessionId);

      // Delete from remote in background
      remoteDataSource.deleteChatSession(sessionId).catchError((e) {
        AppLogger.warning('Failed to delete from remote: $e');
      });

      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete chat session', e, stackTrace);
      return Failure('Failed to delete chat session',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages(String chatId) async {
    try {
      final messages = await localDataSource.getMessages(chatId);
      return Success(messages.map((m) => m.toEntity()).toList());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get messages', e, stackTrace);
      return Failure('Failed to load messages',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> addMessage(MessageEntity message) async {
    try {
      final model = MessageModel.fromEntity(message);
      await localDataSource.saveMessage(model);

      // Update session's message count and updatedAt
      final session = await localDataSource.getChatSession(message.chatId);
      if (session != null) {
        final updatedSession = session.copyWith(
          messageCount: session.messageCount + 1,
          updatedAt: DateTime.now(),
        );
        await localDataSource.saveChatSession(updatedSession);
        _syncSessionToRemote(updatedSession);
      }

      // Sync to remote in background
      _syncMessageToRemote(model);

      return Success(message);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add message', e, stackTrace);
      return Failure('Failed to add message',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> updateMessage(MessageEntity message) async {
    try {
      final model = MessageModel.fromEntity(message);
      await localDataSource.updateMessage(model);

      // Sync to remote in background
      remoteDataSource.updateMessage(model).catchError((e) {
        AppLogger.warning('Failed to update message on remote: $e');
      });

      return Success(message);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update message', e, stackTrace);
      return Failure('Failed to update message',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      await localDataSource.deleteMessage(messageId);

      // Delete from remote in background
      remoteDataSource.deleteMessage(messageId).catchError((e) {
        AppLogger.warning('Failed to delete message from remote: $e');
      });

      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete message', e, stackTrace);
      return Failure('Failed to delete message',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Stream<String> sendMessageToLLM(
    String message,
    List<MessageEntity> history,
  ) {
    return llmService.sendMessage(message, history);
  }

  @override
  Future<Result<void>> syncToCloud(String userId) async {
    try {
      AppLogger.info('Syncing to cloud for user: $userId');

      final sessions = await localDataSource.getChatSessions(userId);
      final allMessages = <MessageModel>[];

      for (final session in sessions) {
        final messages = await localDataSource.getMessages(session.id);
        allMessages.addAll(messages);
      }

      await remoteDataSource.syncToCloud(sessions, allMessages);

      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to sync to cloud', e, stackTrace);
      return Failure('Failed to sync to cloud',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  // Helper methods for background syncing

  void _syncFromRemote(String userId) {
    remoteDataSource.getChatSessions(userId).then((remoteSessions) async {
      for (final session in remoteSessions) {
        await localDataSource.saveChatSession(session);
      }
      AppLogger.info('Synced ${remoteSessions.length} sessions from remote');
    }).catchError((e) {
      AppLogger.warning('Background sync from remote failed: $e');
    });
  }

  void _syncSessionToRemote(ChatSessionModel session) {
    remoteDataSource.saveChatSession(session).catchError((e) {
      AppLogger.warning('Failed to sync session to remote: $e');
    });
  }

  void _syncMessageToRemote(MessageModel message) {
    remoteDataSource.saveMessage(message).catchError((e) {
      AppLogger.warning('Failed to sync message to remote: $e');
    });
  }
}
