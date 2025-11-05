import '../entities/user_entity.dart';
import '../../../../core/utils/result.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Get the current user
  UserEntity? get currentUser;

  /// Sign in with Google
  Future<Result<UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Result<void>> signOut();
}
