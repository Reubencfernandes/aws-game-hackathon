import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/message_entity.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/logger.dart';

/// LLM service for communicating with the LLM endpoint
class LLMService {
  final http.Client _client;
  final String endpoint;

  LLMService({
    http.Client? client,
    String? endpoint,
  })  : _client = client ?? http.Client(),
        endpoint = endpoint ?? AppConfig.llmEndpoint;

  /// Send message to LLM and get streaming response
  Stream<String> sendMessage(
    String message,
    List<MessageEntity> history,
  ) async* {
    try {
      AppLogger.info('Sending message to LLM: $endpoint');

      // Prepare the request body
      final messages = [
        ...history.map((msg) => {
              'role': msg.role.name,
              'content': msg.content,
            }),
        {
          'role': 'user',
          'content': message,
        },
      ];

      final requestBody = jsonEncode({
        'messages': messages,
        'stream': AppConfig.llmSupportsStreaming,
      });

      // Send POST request
      final request = http.Request('POST', Uri.parse(endpoint));
      request.headers['Content-Type'] = 'application/json';
      request.body = requestBody;

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'LLM request failed with status: ${streamedResponse.statusCode}');
      }

      // Handle streaming response
      if (AppConfig.llmSupportsStreaming) {
        await for (final chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          // Parse SSE format or line-delimited JSON
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.trim().isEmpty) continue;

            // Handle Server-Sent Events format
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();
              if (data == '[DONE]') continue;

              try {
                final json = jsonDecode(data);
                final content = _extractContent(json);
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              } catch (e) {
                AppLogger.warning('Failed to parse SSE chunk: $e');
                // If it's not JSON, yield the raw data
                if (data.isNotEmpty) yield data;
              }
            } else {
              // Handle line-delimited JSON
              try {
                final json = jsonDecode(line);
                final content = _extractContent(json);
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              } catch (e) {
                // If it's not JSON, yield the raw line
                if (line.trim().isNotEmpty) yield line.trim();
              }
            }
          }
        }
      } else {
        // Handle non-streaming response
        final response = await http.Response.fromStream(streamedResponse);
        final json = jsonDecode(response.body);
        final content = _extractContent(json);
        if (content != null) {
          yield content;
        }
      }

      AppLogger.info('LLM response completed');
    } catch (e, stackTrace) {
      AppLogger.error('LLM request failed', e, stackTrace);
      yield '[ERROR: ${e.toString()}]';
    }
  }

  /// Extract content from various response formats
  String? _extractContent(dynamic json) {
    if (json is Map<String, dynamic>) {
      // OpenAI format
      if (json.containsKey('choices')) {
        final choices = json['choices'] as List;
        if (choices.isNotEmpty) {
          final choice = choices[0] as Map<String, dynamic>;
          if (choice.containsKey('delta')) {
            final delta = choice['delta'] as Map<String, dynamic>;
            return delta['content'] as String?;
          } else if (choice.containsKey('message')) {
            final message = choice['message'] as Map<String, dynamic>;
            return message['content'] as String?;
          }
        }
      }

      // Simple format
      if (json.containsKey('content')) {
        return json['content'] as String?;
      }

      if (json.containsKey('response')) {
        return json['response'] as String?;
      }

      if (json.containsKey('text')) {
        return json['text'] as String?;
      }
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
