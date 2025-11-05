import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/utils/result.dart';

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogle(repository);
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOut(repository);
});

// Auth State Provider
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

// Auth Controller Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final signInUseCase = ref.watch(signInWithGoogleUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  return AuthController(
    signInWithGoogle: signInUseCase,
    signOut: signOutUseCase,
  );
});

/// Auth state
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth controller
class AuthController extends StateNotifier<AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthController({
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(const AuthState());

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await signInWithGoogle();

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
      },
      onFailure: (message, _) {
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }

  Future<void> signOutUser() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await signOut();

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
      },
      onFailure: (message, _) {
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
