import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

/// Dialog for creating a new chat
class NewChatDialog extends StatefulWidget {
  const NewChatDialog({super.key});

  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final TextEditingController _controller = TextEditingController(
    text: 'New Chat',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.newChat),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Chat Title',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      Navigator.of(context).pop(title);
    }
  }
}
