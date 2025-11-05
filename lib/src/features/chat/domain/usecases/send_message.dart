import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';
import '../../../../core/utils/result.dart';

/// Use case for sending a message
class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Result<MessageEntity>> call(MessageEntity message) async {
    return await repository.addMessage(message);
  }
}
