import 'package:firebase_auth/firebase_auth.dart';

import '../entities/user_entity.dart';

/// Extension methods for [User].
extension UserEntityExtensions on User {
  /// Converts the [User] to a [UserEntity].
  UserEntity get toEntity => UserEntity(
        uid: uid,
        isAnonymous: isAnonymous,
        isEmailVerified: emailVerified,
        email: email,
        displayName: displayName,
        photoUrl: photoURL,
        phoneNumber: phoneNumber,
        tenantId: tenantId,
        refreshToken: refreshToken,
        creationTimestamp: metadata.creationTime,
        lastSignInTimestamp: metadata.lastSignInTime,
      );
}
