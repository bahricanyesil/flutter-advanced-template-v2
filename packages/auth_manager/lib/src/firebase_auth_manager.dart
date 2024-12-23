import 'dart:convert';
import 'dart:math';

import 'package:auth_manager/src/auth_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:log_manager/log_manager.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'entities/auth_result_entity.dart';
import 'entities/user_entity.dart';
import 'enum/auth_error_type.dart';
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
      _logManager?.lDebug('Firebase Auth Error signing in: $e');
      return AuthResultEntity(
        errorMessage: e.message ?? e.code,
        errorType: _mapFirebaseAuthError(e.code),
      );
    } on Exception catch (e) {
      _logManager?.lDebug('Error signing in: $e');
      return AuthResultEntity(
        errorMessage: e.toString(),
        errorType: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResultEntity> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _logManager?.lInfo('User signed out');
      return const AuthResultEntity();
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Firebase Auth Error signing out: $e');
      return AuthResultEntity(errorMessage: e.message ?? e.code);
    } catch (e) {
      _logManager?.lDebug('Error signing out: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> signUpWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null) {
        await userCredential.user?.updateDisplayName(displayName);
      }
      _logManager?.lInfo('User created: ${userCredential.user?.email}');
      return AuthResultEntity(user: userCredential.user?.toEntity);
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Firebase Auth Error creating user: $e');
      return AuthResultEntity(
        errorMessage: e.message ?? e.code,
        errorType: _mapFirebaseAuthError(e.code),
      );
    } catch (e) {
      _logManager?.lDebug('Error creating user: $e');
      return AuthResultEntity(
        errorMessage: e.toString(),
        errorType: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResultEntity> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logManager?.lInfo('Password reset email sent to: $email');
      return const AuthResultEntity();
    } on FirebaseAuthException catch (e) {
      _logManager
          ?.lDebug('Firebase Auth Error sending password reset email: $e');
      return AuthResultEntity(errorMessage: e.message ?? e.code);
    } catch (e) {
      _logManager?.lDebug('Error sending password reset email: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> sendEmailVerification(String email) async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      _logManager?.lInfo('Email verification sent to: $email');
      return const AuthResultEntity();
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Firebase Auth Error sending email verification: $e');
      return AuthResultEntity(errorMessage: e.message ?? e.code);
    } catch (e) {
      _logManager?.lDebug('Error sending email verification: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Future<AuthResultEntity> signInWithGoogle({
    List<String> scopes = const <String>['email', 'profile'],
  }) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _logManager?.lInfo('Google sign-in was cancelled by the user.');
        return const AuthResultEntity(
          errorMessage: 'User cancelled the sign-in process',
          errorType: AuthErrorType.userCancelled,
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        _logManager?.lWarning('Google authentication tokens are null.');
        return const AuthResultEntity(
          errorMessage: 'Failed to retrieve Google authentication tokens',
          errorType: AuthErrorType.tokenError,
        );
      }

      final OAuthCredential oauthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      // Update user profile with Google information
      if (googleUser.displayName != null) {
        await userCredential.user?.updateDisplayName(googleUser.displayName);
      }
      if (googleUser.photoUrl != null) {
        await userCredential.user?.updatePhotoURL(googleUser.photoUrl);
      }

      _logManager
          ?.lInfo('User signed in with Google: ${userCredential.user?.email}');
      return AuthResultEntity(user: userCredential.user?.toEntity);
    } on FirebaseAuthException catch (e) {
      _logManager?.lError(
        'Firebase Auth Error signing in with Google: $e',
        error: e,
      );
      return AuthResultEntity(
        errorMessage: e.message ?? e.code,
        errorType: _mapFirebaseAuthError(e.code),
      );
    } catch (e) {
      _logManager?.lError(
        'Unexpected error signing in with Google: $e',
        error: e,
      );
      return AuthResultEntity(
        errorMessage: e.toString(),
        errorType: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthResultEntity> signInWithApple() async {
    try {
      final String nonce = _generateNonce();
      final String hashedNonce = sha256.convert(utf8.encode(nonce)).toString();

      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (appleCredential.identityToken == null) {
        return const AuthResultEntity(
          errorMessage: 'Apple Sign In failed - no identity token received',
          errorType: AuthErrorType.tokenError,
        );
      }

      final OAuthCredential oauthCredential =
          OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: nonce,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final String givenName = appleCredential.givenName ?? '';
        final String familyName = appleCredential.familyName ?? '';
        final String displayName = '$givenName $familyName'.trim();

        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      return AuthResultEntity(user: userCredential.user?.toEntity);
    } on SignInWithAppleAuthorizationException catch (e) {
      _logManager?.lDebug('Apple Sign In Authorization Error: $e');
      return AuthResultEntity(
        errorMessage: e.message,
        errorType: e.code == AuthorizationErrorCode.canceled
            ? AuthErrorType.userCancelled
            : AuthErrorType.invalidCredentials,
      );
    } on FirebaseAuthException catch (e) {
      _logManager?.lDebug('Firebase Auth Error signing in with Apple: $e');
      return AuthResultEntity(
        errorMessage: e.message ?? e.code,
        errorType: _mapFirebaseAuthError(e.code),
      );
    } catch (e) {
      _logManager?.lDebug('Error signing in with Apple: $e');
      return AuthResultEntity(
        errorMessage: e.toString(),
        errorType: AuthErrorType.unknown,
      );
    }
  }

  String _generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
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
  Future<AuthResultEntity> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return AuthResultEntity(user: _firebaseAuth.currentUser?.toEntity);
    } catch (e) {
      _logManager?.lDebug('Error reloading user: $e');
      return AuthResultEntity(errorMessage: e.toString());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((User? user) => user?.toEntity);

  @override
  Future<bool> get appleSignInAvailable async => SignInWithApple.isAvailable();

  @override
  Future<bool> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
      _logManager?.lInfo('User deleted successfully');
      return true;
    } catch (e) {
      _logManager?.lDebug('Error deleting user: $e');
      return false;
    }
  }

  AuthErrorType _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return AuthErrorType.userNotFound;
      case 'wrong-password':
        return AuthErrorType.invalidCredentials;
      case 'invalid-email':
        return AuthErrorType.invalidEmail;
      case 'email-already-in-use':
        return AuthErrorType.emailAlreadyInUse;
      case 'weak-password':
        return AuthErrorType.weakPassword;
      case 'network-request-failed':
        return AuthErrorType.networkError;
      case 'invalid-credential':
        return AuthErrorType.invalidCredentials;
      case 'operation-not-allowed':
        return AuthErrorType.operationNotAllowed;
      case 'too-many-requests':
        return AuthErrorType.tooManyRequests;
      default:
        return AuthErrorType.unknown;
    }
  }
}
