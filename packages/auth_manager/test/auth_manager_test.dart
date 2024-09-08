import 'package:auth_manager/src/entities/auth_result_entity.dart';
import 'package:auth_manager/src/entities/user_entity.dart';
import 'package:auth_manager/src/firebase_auth_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_firebase_auth.dart';
import 'mocks/mock_user.dart';
import 'mocks/mock_user_credential.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseAuthManager authManager;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authManager = FirebaseAuthManager(mockFirebaseAuth);
  });

  group('FirebaseAuthManager', () {
    test('signInWithEmailAndPassword - success', () async {
      final MockUserCredential mockUserCredential = MockUserCredential();
      final MockUser mockUser = MockUser();
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final AuthResultEntity result =
          await authManager.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result.user, isNotNull);
      expect(result.user?.email, 'test@example.com');
      expect(result.user?.uid, 'testUid');
      expect(result.errorMessage, isNull);
    });

    test('signInWithEmailAndPassword - failure', () async {
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final AuthResultEntity result =
          await authManager.signInWithEmailAndPassword(
        'test@example.com',
        'wrongpassword',
      );

      expect(result.user, isNull);
      expect(result.errorMessage, isNotNull);
    });

    test('signOut - success', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {
        return;
      });

      final AuthResultEntity result = await authManager.signOut();

      expect(result.errorMessage, isNull);
    });

    test('signUpWithEmailAndPassword - success', () async {
      final MockUserCredential mockUserCredential = MockUserCredential();
      final MockUser mockUser = MockUser();
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'newpassword123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final AuthResultEntity result =
          await authManager.signUpWithEmailAndPassword(
        'test@example.com',
        'newpassword123',
      );

      expect(result.user, isNotNull);
      expect(result.user?.email, 'test@example.com');
      expect(result.user?.uid, 'testUid');
      expect(result.errorMessage, isNull);
    });

    test('sendPasswordResetEmail - success', () async {
      when(
        () => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        ),
      ).thenAnswer((_) async {
        return;
      });

      final AuthResultEntity result =
          await authManager.sendPasswordResetEmail('test@example.com');

      expect(result.errorMessage, isNull);
    });

    test('currentUser - logged in', () {
      final MockUser mockUser = MockUser();
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final AuthResultEntity result = authManager.currentUser;

      expect(result.user, isNotNull);
      expect(result.user?.email, 'test@example.com');
      expect(result.user?.uid, 'testUid');
      expect(result.errorMessage, isNull);
    });

    test('currentUser - not logged in', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final AuthResultEntity result = authManager.currentUser;

      expect(result.user, isNull);
      expect(result.errorMessage, isNull);
    });

    test('authStateChanges', () {
      final MockUser mockUser = MockUser();
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
        (_) => Stream<User?>.fromIterable(<User?>[null, mockUser, null]),
      );

      expect(
        authManager.authStateChanges,
        emitsInOrder(<Matcher?>[
          predicate<UserEntity?>((UserEntity? user) => user == null),
          predicate<UserEntity?>(
            (UserEntity? user) =>
                user != null &&
                user.email == 'test@example.com' &&
                user.uid == 'testUid',
          ),
          predicate<UserEntity?>((UserEntity? user) => user == null),
        ]),
      );
    });

    test('signInWithEmailAndPassword - error', () async {
      final Exception exception = Exception('wrong-password');
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenThrow(exception);

      final AuthResultEntity result =
          await authManager.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result.user, isNull);
      expect(result.errorMessage, exception.toString());
    });

    test('signUpWithEmailAndPassword - error', () async {
      final Exception exception =
          Exception('signUpWithEmailAndPassword failed');
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'newpassword123',
        ),
      ).thenThrow(exception);

      final AuthResultEntity result =
          await authManager.signUpWithEmailAndPassword(
        'test@example.com',
        'newpassword123',
      );

      expect(result.user, isNull);
      expect(result.errorMessage, exception.toString());

      const String firebaseErrorMessage =
          'The email address is not valid. Please enter a valid email address.';
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'newpassword123',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: exception.toString(),
          message: firebaseErrorMessage,
        ),
      );

      final AuthResultEntity result2 =
          await authManager.signUpWithEmailAndPassword(
        'test@example.com',
        'newpassword123',
      );

      expect(result2.errorMessage, firebaseErrorMessage);
    });

    test('signOut - error', () async {
      final Exception exception = Exception('signOut failed');
      when(() => mockFirebaseAuth.signOut()).thenThrow(exception);

      final AuthResultEntity result = await authManager.signOut();

      expect(result.errorMessage, exception.toString());

      const String firebaseErrorMessage =
          'Sign out failed. You are not currently signed in.';
      when(() => mockFirebaseAuth.signOut()).thenThrow(
        FirebaseAuthException(
          code: exception.toString(),
          message: firebaseErrorMessage,
        ),
      );

      final AuthResultEntity result2 = await authManager.signOut();

      expect(result2.errorMessage, firebaseErrorMessage);
    });

    test('signOut - error', () async {
      final Exception exception = Exception('signOut failed');
      when(() => mockFirebaseAuth.signOut()).thenThrow(exception);

      final AuthResultEntity result = await authManager.signOut();

      expect(result.errorMessage, exception.toString());

      const String firebaseErrorMessage =
          'Sign out failed. You are not currently signed in.';
      when(() => mockFirebaseAuth.signOut()).thenThrow(
        FirebaseAuthException(
          code: exception.toString(),
          message: firebaseErrorMessage,
        ),
      );

      final AuthResultEntity result2 = await authManager.signOut();

      expect(result2.errorMessage, firebaseErrorMessage);
    });

    test('sendPasswordResetEmail - error', () async {
      final Exception exception = Exception('sendPasswordResetEmail failed');
      when(
        () => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        ),
      ).thenThrow(exception);

      final AuthResultEntity result =
          await authManager.sendPasswordResetEmail('test@example.com');

      expect(result.errorMessage, exception.toString());

      const String firebaseErrorMessage =
          'The email address is not valid. Please enter a valid email address.';
      when(
        () => mockFirebaseAuth.sendPasswordResetEmail(
          email: 'test@example.com',
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: exception.toString(),
          message: firebaseErrorMessage,
        ),
      );

      final AuthResultEntity result2 =
          await authManager.sendPasswordResetEmail('test@example.com');

      expect(result2.errorMessage, firebaseErrorMessage);
    });

    test('currentUser - error', () {
      final Exception exception = Exception('currentUser failed');
      when(() => mockFirebaseAuth.currentUser).thenThrow(exception);

      final AuthResultEntity result = authManager.currentUser;

      expect(result.user, isNull);
      expect(result.errorMessage, exception.toString());
    });
  });
}
