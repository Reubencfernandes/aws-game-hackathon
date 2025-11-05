import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../../../core/utils/logger.dart';

/// Remote data source for authentication
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  /// Get current user
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      AppLogger.info('Starting Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      AppLogger.info('Google Sign-In successful: ${userCredential.user!.email}');
      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e, stackTrace) {
      AppLogger.error('Google Sign-In failed', e, stackTrace);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out...');
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      AppLogger.info('Sign-out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Sign-out failed', e, stackTrace);
      rethrow;
    }
  }
}
