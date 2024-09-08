import 'entities/user_entity.dart';

/// Represents an interface for managing authentication related things.
abstract interface class AuthManager {
  /// Signs in a user with email and password.
  Future<(UserEntity?, String?)> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Signs out the current user.
  Future<String?> signOut();

  /// Registers a user with email and password.
  Future<(UserEntity?, String?)> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sends a password reset email to the given email address.
  Future<String?> sendPasswordResetEmail(String email);

  /// Gets the currently signed-in user.
  (UserEntity?, String?) get currentUser;

  /// Listens to the authentication state changes.
  Stream<UserEntity?> get authStateChanges;
}
