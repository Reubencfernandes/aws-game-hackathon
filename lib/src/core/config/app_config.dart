/// Application-wide configuration constants
class AppConfig {
  AppConfig._();

  static const String appName = 'Flutter Chat';
  static const String version = '1.0.0';

  // LLM Configuration
  // Configure your LLM endpoint here
  static const String llmEndpoint =
      String.fromEnvironment('LLM_ENDPOINT', defaultValue: 'http://localhost:8000/chat');

  static const bool llmSupportsStreaming = true;
  static const int llmTimeoutSeconds = 60;

  // Firebase Configuration
  static const String firestoreUsersCollection = 'users';
  static const String firestoreChatsCollection = 'chats';
  static const String firestoreMessagesCollection = 'messages';

  // Local Storage
  static const String hiveChatBoxName = 'chats';
  static const String hiveMessagesBoxName = 'messages';
  static const String hiveUserBoxName = 'user';

  // UI Configuration
  static const int maxMessageLength = 5000;
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
}
