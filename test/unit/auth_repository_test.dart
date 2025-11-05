import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_chat_app/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_chat_app/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_chat_app/src/features/auth/data/models/user_model.dart';
import 'package:flutter_chat_app/src/core/utils/result.dart';

@GenerateMocks([AuthRemoteDataSource])
import 'auth_repository_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('AuthRepository', () {
    const testUser = UserModel(
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
    );

    test('signInWithGoogle returns Success when sign in is successful',
        () async {
      // Arrange
      when(mockDataSource.signInWithGoogle())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await repository.signInWithGoogle();

      // Assert
      expect(result, isA<Success>());
      expect((result as Success).data.email, 'test@example.com');
      verify(mockDataSource.signInWithGoogle()).called(1);
    });

    test('signInWithGoogle returns Failure when sign in fails', () async {
      // Arrange
      when(mockDataSource.signInWithGoogle())
          .thenThrow(Exception('Sign in failed'));

      // Act
      final result = await repository.signInWithGoogle();

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).message, contains('Failed to sign in'));
      verify(mockDataSource.signInWithGoogle()).called(1);
    });

    test('signOut returns Success when sign out is successful', () async {
      // Arrange
      when(mockDataSource.signOut()).thenAnswer((_) async => {});

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isA<Success>());
      verify(mockDataSource.signOut()).called(1);
    });

    test('signOut returns Failure when sign out fails', () async {
      // Arrange
      when(mockDataSource.signOut()).thenThrow(Exception('Sign out failed'));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isA<Failure>());
      expect((result as Failure).message, contains('Failed to sign out'));
      verify(mockDataSource.signOut()).called(1);
    });
  });
}
