import '../repositories/auth_repository.dart';
import '../../../../core/utils/result.dart';

/// Use case for signing out
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Result<void>> call() async {
    return await repository.signOut();
  }
}
