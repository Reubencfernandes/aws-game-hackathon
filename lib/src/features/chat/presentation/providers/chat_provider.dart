import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_llm_response.dart';
import '../../data/datasources/chat_local_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/llm_service.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';

// Data Source Providers
final chatLocalDataSourceProvider = Provider<ChatLocalDataSource>((ref) {
  final dataSource = ChatLocalDataSource();
  dataSource.initialize();
  return dataSource;
});

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource();
});

final llmServiceProvider = Provider<LLMService>((ref) {
  return LLMService();
});

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final localDataSource = ref.watch(chatLocalDataSourceProvider);
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  final llmService = ref.watch(llmServiceProvider);

  return ChatRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    llmService: llmService,
  );
});

// Use Case Providers
final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessage(repository);
});

final getLLMResponseUseCaseProvider = Provider<GetLLMResponse>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetLLMResponse(repository);
});

// Current Chat Session Provider
final currentChatSessionProvider =
    StateProvider<ChatSessionEntity?>((ref) => null);

// Chat Sessions Provider
final chatSessionsProvider = FutureProvider<List<ChatSessionEntity>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];

  final result = await repository.getChatSessions(user.id);
  return result.fold(
    onSuccess: (sessions) => sessions,
    onFailure: (_, __) => [],
  );
});

// Messages Provider for current chat
final messagesProvider = FutureProvider<List<MessageEntity>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final currentSession = ref.watch(currentChatSessionProvider);

  if (currentSession == null) return [];

  final result = await repository.getMessages(currentSession.id);
  return result.fold(
    onSuccess: (messages) => messages,
    onFailure: (_, __) => [],
  );
});

// Chat Controller Provider
final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final getLLMResponse = ref.watch(getLLMResponseUseCaseProvider);

  return ChatController(
    repository: repository,
    userId: user?.id ?? '',
    getLLMResponse: getLLMResponse,
  );
});

/// Chat state
class ChatState {
  final List<MessageEntity> messages;
  final bool isLoading;
  final bool isStreamingResponse;
  final String? errorMessage;
  final MessageEntity? streamingMessage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreamingResponse = false,
    this.errorMessage,
    this.streamingMessage,
  });

  ChatState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? isStreamingResponse,
    String? errorMessage,
    MessageEntity? streamingMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreamingResponse: isStreamingResponse ?? this.isStreamingResponse,
      errorMessage: errorMessage,
      streamingMessage: streamingMessage,
    );
  }
}

/// Chat controller
class ChatController extends StateNotifier<ChatState> {
  final ChatRepository repository;
  final String userId;
  final GetLLMResponse getLLMResponse;
  final Uuid _uuid = const Uuid();

  ChatController({
    required this.repository,
    required this.userId,
    required this.getLLMResponse,
  }) : super(const ChatState());

  /// Load messages for a chat session
  Future<void> loadMessages(String chatId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await repository.getMessages(chatId);

    result.fold(
      onSuccess: (messages) {
        state = state.copyWith(messages: messages, isLoading: false);
      },
      onFailure: (message, _) {
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }

  /// Send a message and get LLM response
  Future<void> sendMessage(String chatId, String content) async {
    if (content.trim().isEmpty) return;

    try {
      // Create user message
      final userMessage = MessageEntity(
        id: _uuid.v4(),
        chatId: chatId,
        content: content.trim(),
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      // Add user message to local state
      state = state.copyWith(
        messages: [...state.messages, userMessage],
      );

      // Save user message
      await repository.addMessage(userMessage);

      // Create streaming assistant message
      final assistantMessageId = _uuid.v4();
      final assistantMessage = MessageEntity(
        id: assistantMessageId,
        chatId: chatId,
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isStreaming: true,
      );

      state = state.copyWith(
        isStreamingResponse: true,
        streamingMessage: assistantMessage,
        messages: [...state.messages, assistantMessage],
      );

      // Get LLM response stream
      final responseStream = getLLMResponse(content, state.messages);
      String fullResponse = '';

      await for (final chunk in responseStream) {
        fullResponse += chunk;

        // Update streaming message
        final updatedMessage = assistantMessage.copyWith(
          content: fullResponse,
        );

        // Update in state
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == assistantMessageId) {
            return updatedMessage;
          }
          return msg;
        }).toList();

        state = state.copyWith(
          messages: updatedMessages,
          streamingMessage: updatedMessage,
        );
      }

      // Finalize assistant message
      final finalMessage = assistantMessage.copyWith(
        content: fullResponse,
        isStreaming: false,
      );

      await repository.addMessage(finalMessage);

      // Update final state
      final finalMessages = state.messages.map((msg) {
        if (msg.id == assistantMessageId) {
          return finalMessage;
        }
        return msg;
      }).toList();

      state = state.copyWith(
        messages: finalMessages,
        isStreamingResponse: false,
        streamingMessage: null,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send message', e, stackTrace);
      state = state.copyWith(
        isStreamingResponse: false,
        streamingMessage: null,
        errorMessage: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  /// Edit and regenerate a message
  Future<void> editAndRegenerate(String messageId, String newContent) async {
    try {
      // Find the message to edit
      final messageIndex =
          state.messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex == -1) return;

      final originalMessage = state.messages[messageIndex];
      if (originalMessage.role != MessageRole.user) return;

      // Update the user message
      final updatedMessage = originalMessage.copyWith(content: newContent);
      await repository.updateMessage(updatedMessage);

      // Remove all messages after this one
      final remainingMessages = state.messages.sublist(0, messageIndex + 1);
      final messagesToDelete = state.messages.sublist(messageIndex + 1);

      for (final msg in messagesToDelete) {
        await repository.deleteMessage(msg.id);
      }

      // Update state
      state = state.copyWith(
        messages: [
          ...remainingMessages.take(messageIndex).toList(),
          updatedMessage,
        ],
      );

      // Regenerate response
      await sendMessage(originalMessage.chatId, newContent);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to edit and regenerate', e, stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to regenerate: ${e.toString()}',
      );
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await repository.deleteMessage(messageId);
      state = state.copyWith(
        messages: state.messages.where((msg) => msg.id != messageId).toList(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete message', e, stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to delete message: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
