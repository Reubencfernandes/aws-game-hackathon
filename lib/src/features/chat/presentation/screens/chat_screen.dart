import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_list.dart';
import '../widgets/message_input.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/new_chat_dialog.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../../../core/utils/logger.dart';

/// Main chat screen
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final sessions = await ref.read(chatSessionsProvider.future);

    if (sessions.isEmpty) {
      // Create a new chat session
      await _createNewChat();
    } else {
      // Load the most recent chat
      ref.read(currentChatSessionProvider.notifier).state = sessions.first;
      await ref
          .read(chatControllerProvider.notifier)
          .loadMessages(sessions.first.id);
    }
  }

  Future<void> _createNewChat() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const NewChatDialog(),
    );

    if (title != null && title.isNotEmpty) {
      final repository = ref.read(chatRepositoryProvider);
      final userId = ref.read(currentChatSessionProvider)?.userId ?? '';

      final result = await repository.createChatSession(userId, title);

      result.fold(
        onSuccess: (session) {
          ref.read(currentChatSessionProvider.notifier).state = session;
          ref.invalidate(chatSessionsProvider);
          AppLogger.info('Created new chat: ${session.id}');
        },
        onFailure: (message, _) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = ref.watch(currentChatSessionProvider);
    final chatState = ref.watch(chatControllerProvider);

    ref.listen<ChatState>(chatControllerProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(chatControllerProvider.notifier).clearError();
      }
    });

    if (currentSession == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flutter Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: ChatAppBar(
        session: currentSession,
        onNewChat: _createNewChat,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: MessageList(messages: chatState.messages),
          ),

          // Loading Indicator
          if (chatState.isStreamingResponse)
            const LinearProgressIndicator(),

          // Message Input
          MessageInput(
            onSend: (message) {
              ref
                  .read(chatControllerProvider.notifier)
                  .sendMessage(currentSession.id, message);
            },
            enabled: !chatState.isStreamingResponse,
          ),
        ],
      ),
    );
  }
}
