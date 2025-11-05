import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/logger.dart';

/// Remote data source for chat using Cloud Firestore
class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _chatsCollection =>
      _firestore.collection(AppConfig.firestoreChatsCollection);

  CollectionReference get _messagesCollection =>
      _firestore.collection(AppConfig.firestoreMessagesCollection);

  /// Get all chat sessions for a user
  Future<List<ChatSessionModel>> getChatSessions(String userId) async {
    try {
      final querySnapshot = await _chatsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatSessionModel.fromJson(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id},
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch chat sessions from cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Get a specific chat session
  Future<ChatSessionModel?> getChatSession(String sessionId) async {
    try {
      final doc = await _chatsCollection.doc(sessionId).get();
      if (!doc.exists) return null;

      return ChatSessionModel.fromJson(
        {...doc.data() as Map<String, dynamic>, 'id': doc.id},
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch chat session from cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Save a chat session
  Future<void> saveChatSession(ChatSessionModel session) async {
    try {
      await _chatsCollection.doc(session.id).set(session.toJson());
      AppLogger.debug('Chat session synced to cloud: ${session.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save chat session to cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a chat session
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _chatsCollection.doc(sessionId).delete();
      // Also delete associated messages
      final messagesSnapshot = await _messagesCollection
          .where('chatId', isEqualTo: sessionId)
          .get();
      for (final doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
      AppLogger.debug('Chat session deleted from cloud: $sessionId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete chat session from cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Get messages for a chat session
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final querySnapshot = await _messagesCollection
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromJson(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id},
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch messages from cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Save a message
  Future<void> saveMessage(MessageModel message) async {
    try {
      await _messagesCollection.doc(message.id).set(message.toJson());
      AppLogger.debug('Message synced to cloud: ${message.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save message to cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Update a message
  Future<void> updateMessage(MessageModel message) async {
    try {
      await _messagesCollection.doc(message.id).update(message.toJson());
      AppLogger.debug('Message updated in cloud: ${message.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update message in cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesCollection.doc(messageId).delete();
      AppLogger.debug('Message deleted from cloud: $messageId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete message from cloud', e, stackTrace);
      rethrow;
    }
  }

  /// Sync local data to cloud
  Future<void> syncToCloud(
    List<ChatSessionModel> sessions,
    List<MessageModel> messages,
  ) async {
    try {
      AppLogger.info('Starting cloud sync...');

      // Batch write for better performance
      final batch = _firestore.batch();

      for (final session in sessions) {
        batch.set(_chatsCollection.doc(session.id), session.toJson());
      }

      for (final message in messages) {
        batch.set(_messagesCollection.doc(message.id), message.toJson());
      }

      await batch.commit();
      AppLogger.info('Cloud sync completed');
    } catch (e, stackTrace) {
      AppLogger.error('Cloud sync failed', e, stackTrace);
      rethrow;
    }
  }
}
