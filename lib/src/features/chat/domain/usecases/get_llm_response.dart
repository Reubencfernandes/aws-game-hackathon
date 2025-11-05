import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Use case for getting LLM response (streaming)
class GetLLMResponse {
  final ChatRepository repository;

  GetLLMResponse(this.repository);

  Stream<String> call(String message, List<MessageEntity> history) {
    return repository.sendMessageToLLM(message, history);
  }
}
