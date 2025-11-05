/// Application-wide string constants
class AppStrings {
  AppStrings._();

  // Auth
  static const String signInWithGoogle = 'Sign in with Google';
  static const String signOut = 'Sign Out';
  static const String welcomeMessage = 'Welcome to Flutter Chat';
  static const String signInRequired = 'Please sign in to continue';

  // Chat
  static const String newChat = 'New Chat';
  static const String typeMessage = 'Type a message...';
  static const String send = 'Send';
  static const String regenerate = 'Regenerate';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String save = 'Save';

  // Errors
  static const String errorOccurred = 'An error occurred';
  static const String authError = 'Authentication failed';
  static const String networkError = 'Network error';
  static const String llmError = 'Failed to get response from LLM';
  static const String syncError = 'Failed to sync data';

  // Messages
  static const String thinking = 'Thinking...';
  static const String noMessages = 'No messages yet. Start a conversation!';
  static const String loadingChats = 'Loading chats...';
}
