import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_provider.dart';
import '../../../../core/constants/app_strings.dart';

/// Widget to display a single message bubble
class MessageBubble extends ConsumerStatefulWidget {
  final MessageEntity message;
  final bool showActions;

  const MessageBubble({
    super.key,
    required this.message,
    this.showActions = false,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _editController.text = widget.message.content;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  void _saveAndRegenerate() {
    final newContent = _editController.text.trim();
    if (newContent.isEmpty) return;

    ref
        .read(chatControllerProvider.notifier)
        .editAndRegenerate(widget.message.id, newContent);

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: Icon(
                Icons.smart_toy,
                color: theme.colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  _buildEditingView(theme)
                else
                  _buildMessageView(theme, isUser),
                if (widget.showActions && !_isEditing && isUser)
                  _buildActions(theme),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageView(ThemeData theme, bool isUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.isStreaming)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.thinking,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          if (isUser)
            SelectableText(
              widget.message.content,
              style: theme.textTheme.bodyLarge,
            )
          else
            MarkdownBody(
              data: widget.message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyLarge,
                code: theme.textTheme.bodyMedium?.copyWith(
                  backgroundColor: theme.colorScheme.surface,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          if (widget.message.isError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Failed to send',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditingView(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _editController,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Edit your message...',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _cancelEditing,
                child: const Text(AppStrings.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveAndRegenerate,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.regenerate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: _startEditing,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text(AppStrings.edit),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}
