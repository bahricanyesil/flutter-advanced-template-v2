import 'package:auth_manager/src/auth_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:log_manager/log_manager.dart';

import 'entities/auth_result_entity.dart';
import 'entities/user_entity.dart';
import 'extensions/user_entity_extensions.dart';

/// A concrete implementation of the BaseFirebaseAuthManager.
final class FirebaseAuthManager implements AuthManager {
  /// Creates a new instance of the [FirebaseAuthManager].
  FirebaseAuthManager(this._firebaseAuth, {LogManager? logManager})
      : _logManager = logManager;

  /// The [FirebaseAuth] instance.
  final FirebaseAuth _firebaseAuth;

  /// The [LogManager] instance.
  final LogManager? _logManager;

  @override
  Future<AuthResultEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _logManager?.lInfo('User signed in: ${userCredential.user?.email}');
      return AuthResultEntity(user: userCredential.user?.toEntity);
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Error signing out: $e');
      return AuthResultEntity(errorMessage: e.message);
    } catch (e) {
      _logManager?.lDebug('Error signing in: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _logManager?.lInfo('User signed out');
      return const AuthResultEntity();
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Error signing out: $e');
      return AuthResultEntity(errorMessage: e.message);
    } catch (e) {
      _logManager?.lDebug('Error signing out: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logManager?.lInfo('User created: ${userCredential.user?.email}');
      return AuthResultEntity(user: userCredential.user?.toEntity);
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Error creating user: $e');
      return AuthResultEntity(errorMessage: e.message);
    } catch (e) {
      _logManager?.lDebug('Error creating user: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logManager?.lInfo('Password reset email sent to: $email');
      return const AuthResultEntity();
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Error creating user: $e');
      return AuthResultEntity(errorMessage: e.message);
    } catch (e) {
      _logManager?.lDebug('Error sending password reset email: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  AuthResultEntity get currentUser {
    try {
      final UserEntity? u = _firebaseAuth.currentUser?.toEntity;
      return AuthResultEntity(user: u);
    } catch (e) {
      _logManager?.lDebug('Error getting current user: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((User? user) => user?.toEntity);
}
