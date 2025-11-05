import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/logger.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges =>
      remoteDataSource.authStateChanges.map((user) => user?.toEntity());

  @override
  UserEntity? get currentUser => remoteDataSource.currentUser?.toEntity();

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Success(userModel.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Sign in with Google failed', e, stackTrace);
      return Failure('Failed to sign in with Google: ${e.toString()}',
          e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      return Failure('Failed to sign out: ${e.toString()}',
          e is Exception ? e : Exception(e.toString()));
    }
  }
}
