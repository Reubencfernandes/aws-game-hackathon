import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';

/// Use case for signing in with Google
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Result<UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
