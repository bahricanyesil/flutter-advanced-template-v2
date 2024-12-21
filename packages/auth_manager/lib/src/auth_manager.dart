import 'entities/auth_result_entity.dart';
import 'entities/user_entity.dart';

/// Represents an interface for managing authentication related things.
abstract interface class AuthManager {
  /// Signs in a user with email and password.
  Future<AuthResultEntity> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Signs out the current user.
  Future<AuthResultEntity> signOut();

  /// Registers a user with email and password.
  Future<AuthResultEntity> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sends a password reset email to the given email address.
  Future<AuthResultEntity> sendPasswordResetEmail(String email);

  /// Sends an email verification link.
  Future<AuthResultEntity> sendEmailVerification(String email);

  /// Signs in a user with Google.
  Future<AuthResultEntity> signInWithGoogle({
    List<String> scopes = const <String>['email', 'profile'],
  });

  /// Returns whether the Apple sign-in is available.
  Future<bool> get appleSignInAvailable;

  /// Signs in a user with Apple.
  Future<AuthResultEntity> signInWithApple();

  /// Gets the currently signed-in user.
  AuthResultEntity get currentUser;

  /// Reloads the user data.
  Future<AuthResultEntity> reloadUser();

  /// Listens to the authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Deletes the current user.
  Future<bool> deleteUser();
}
