# Flutter Chat App

A production-quality, cross-platform Flutter chat application that integrates with LLM endpoints. Think of it as a lightweight ChatGPT clone with Google Sign-In authentication, message history persistence, and cloud synchronization.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

### Core Functionality
- 🔐 **Google Sign-In Authentication** - Secure authentication using Firebase Auth and Google Sign-In
- 💬 **Chat Interface** - Clean, modern chat UI with message bubbles and markdown support
- 🤖 **LLM Integration** - Pluggable HTTP endpoint for any LLM API (OpenAI, Claude, custom endpoints)
- 📡 **Streaming Support** - Real-time streaming responses from LLM endpoints
- ✏️ **Edit & Regenerate** - Edit your last message and regenerate the response
- 💾 **Local Persistence** - Messages stored locally using Hive
- ☁️ **Cloud Sync** - Automatic synchronization with Firebase Firestore
- 🎨 **Material 3 Design** - Modern UI with light and dark theme support

### Architecture
- **Clean Architecture** - Separation of concerns with domain, data, and presentation layers
- **Riverpod State Management** - Type-safe, compile-time dependency injection
- **Repository Pattern** - Abstract data sources for easy testing and swapping
- **Stream-based LLM Communication** - Non-blocking UI during LLM responses
- **Offline-first** - Local storage with background cloud sync

## Screenshots

> Add your app screenshots here after building the app

## Project Structure

```
lib/
├── main.dart                           # App entry point
└── src/
    ├── core/                           # Core utilities and config
    │   ├── config/
    │   │   ├── app_config.dart         # App-wide configuration
    │   │   └── firebase_options.dart   # Firebase configuration
    │   ├── constants/
    │   │   └── app_strings.dart        # String constants
    │   └── utils/
    │       ├── logger.dart             # Logging utility
    │       └── result.dart             # Result type for error handling
    │
    └── features/
        ├── auth/                       # Authentication feature
        │   ├── data/
        │   │   ├── datasources/
        │   │   │   └── auth_remote_datasource.dart
        │   │   ├── models/
        │   │   │   └── user_model.dart
        │   │   └── repositories/
        │   │       └── auth_repository_impl.dart
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   └── user_entity.dart
        │   │   ├── repositories/
        │   │   │   └── auth_repository.dart
        │   │   └── usecases/
        │   │       ├── sign_in_with_google.dart
        │   │       └── sign_out.dart
        │   └── presentation/
        │       ├── providers/
        │       │   └── auth_provider.dart
        │       └── screens/
        │           └── auth_screen.dart
        │
        └── chat/                       # Chat feature
            ├── data/
            │   ├── datasources/
            │   │   ├── chat_local_datasource.dart
            │   │   ├── chat_remote_datasource.dart
            │   │   └── llm_service.dart
            │   ├── models/
            │   │   ├── chat_session_model.dart
            │   │   └── message_model.dart
            │   └── repositories/
            │       └── chat_repository_impl.dart
            ├── domain/
            │   ├── entities/
            │   │   ├── chat_session_entity.dart
            │   │   └── message_entity.dart
            │   ├── repositories/
            │   │   └── chat_repository.dart
            │   └── usecases/
            │       ├── get_llm_response.dart
            │       └── send_message.dart
            └── presentation/
                ├── providers/
                │   └── chat_provider.dart
                ├── screens/
                │   └── chat_screen.dart
                └── widgets/
                    ├── chat_app_bar.dart
                    ├── message_bubble.dart
                    ├── message_input.dart
                    ├── message_list.dart
                    └── new_chat_dialog.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- A Firebase project (for authentication and Firestore)
- An LLM API endpoint (OpenAI, Claude, or custom)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flutter-chat-app.git
   cd flutter-chat-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Google Sign-In in Authentication
   - Enable Firestore Database
   - Download your configuration files:
     - For Android: `google-services.json` → `android/app/`
     - For iOS: `GoogleService-Info.plist` → `ios/Runner/`
     - For Web: Copy your Firebase config

   - Update `lib/src/core/config/firebase_options.dart` with your Firebase configuration

   Or use FlutterFire CLI (recommended):
   ```bash
   flutterfire configure --project=your-project-id
   ```

4. **Configure LLM Endpoint**

   Edit `lib/src/core/config/app_config.dart`:
   ```dart
   static const String llmEndpoint = 'YOUR_LLM_ENDPOINT';
   static const bool llmSupportsStreaming = true; // or false
   ```

   Or set via environment variable:
   ```bash
   flutter run --dart-define=LLM_ENDPOINT=https://your-api.com/chat
   ```

5. **Generate code (for Hive adapters)**
   ```bash
   flutter pub run build_runner build
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### LLM Endpoint Format

The app expects the LLM endpoint to accept POST requests with this format:

```json
{
  "messages": [
    {"role": "user", "content": "Hello"},
    {"role": "assistant", "content": "Hi there!"},
    {"role": "user", "content": "How are you?"}
  ],
  "stream": true
}
```

#### Streaming Response Format

For streaming endpoints, the app supports:

1. **Server-Sent Events (SSE)**
   ```
   data: {"choices": [{"delta": {"content": "Hello"}}]}
   data: {"choices": [{"delta": {"content": " world"}}]}
   data: [DONE]
   ```

2. **Line-delimited JSON**
   ```json
   {"content": "Hello"}
   {"content": " world"}
   ```

#### Non-streaming Response Format

```json
{
  "choices": [
    {
      "message": {
        "content": "Complete response here"
      }
    }
  ]
}
```

### Environment Variables

You can configure the following via `--dart-define`:

- `LLM_ENDPOINT` - Your LLM API endpoint URL

Example:
```bash
flutter run --dart-define=LLM_ENDPOINT=https://api.openai.com/v1/chat/completions
```

## Architecture

This app follows **Clean Architecture** principles with clear separation of layers:

### Domain Layer
- **Entities**: Core business objects (User, Message, ChatSession)
- **Repositories**: Abstract interfaces for data operations
- **Use Cases**: Business logic (SignIn, SendMessage, GetLLMResponse)

### Data Layer
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**:
  - `AuthRemoteDataSource`: Firebase authentication
  - `ChatLocalDataSource`: Hive local storage
  - `ChatRemoteDataSource`: Firestore cloud storage
  - `LLMService`: HTTP communication with LLM endpoints
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer
- **Providers**: Riverpod state management
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

## State Management

The app uses **Riverpod** for state management:

- `AuthStateProvider`: Monitors Firebase authentication state
- `ChatControllerProvider`: Manages chat state and operations
- `CurrentChatSessionProvider`: Tracks the active chat session
- `MessagesProvider`: Provides messages for the current chat

## Data Persistence

### Local Storage (Hive)
- Messages and chat sessions are stored locally using Hive
- Provides offline access and fast loading
- Type-safe with generated adapters

### Cloud Storage (Firestore)
- Automatic background sync to Firestore
- Enables multi-device access
- Collections:
  - `chats`: Chat session metadata
  - `messages`: Individual messages

## Testing

### Run Unit Tests
```bash
flutter test test/unit
```

### Run Widget Tests
```bash
flutter test test/widget
```

### Run All Tests
```bash
flutter test
```

### Generate Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## Customization

### Changing the App Theme

Edit `lib/main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change this color
    brightness: Brightness.light,
  ),
  useMaterial3: true,
),
```

### Adding Custom LLM Response Parsing

Edit `lib/src/features/chat/data/datasources/llm_service.dart` and modify the `_extractContent` method to handle your API's response format.

### Customizing Message UI

Edit `lib/src/features/chat/presentation/widgets/message_bubble.dart` to change how messages are displayed.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Troubleshooting

### Firebase Auth Issues
- Ensure SHA-1 and SHA-256 fingerprints are added to Firebase Console (Android)
- Check that Google Sign-In is enabled in Firebase Console
- Verify `google-services.json` or `GoogleService-Info.plist` is in the correct location

### LLM Connection Issues
- Check that `LLM_ENDPOINT` is correctly configured
- Verify your API key (if required) is set
- Test the endpoint with curl or Postman first
- Check network permissions in `AndroidManifest.xml` and `Info.plist`

### Hive Storage Issues
- Delete and reinstall the app to clear local storage
- Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate adapters

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Firebase for backend services
- The open-source community

## Support

For issues, questions, or contributions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter**
