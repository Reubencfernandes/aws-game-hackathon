import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_strings.dart';

/// Custom app bar for chat screen
class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final ChatSessionEntity session;
  final VoidCallback onNewChat;

  const ChatAppBar({
    super.key,
    required this.session,
    required this.onNewChat,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(session.title),
          Text(
            '${session.messageCount} messages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: AppStrings.newChat,
          onPressed: onNewChat,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'sign_out':
                ref.read(authControllerProvider.notifier).signOutUser();
                break;
            }
          },
          itemBuilder: (context) => [
            if (user != null)
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'sign_out',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(AppStrings.signOut),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
