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

  /// Gets the currently signed-in user.
  AuthResultEntity get currentUser;

  /// Listens to the authentication state changes.
  Stream<UserEntity?> get authStateChanges;
}
