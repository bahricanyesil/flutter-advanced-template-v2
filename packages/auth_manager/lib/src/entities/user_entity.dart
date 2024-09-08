import 'package:flutter/foundation.dart';

/// Represents a user entity.
///
/// This class is used to define the structure of a user
/// entity in the authentication domain.
@immutable
base class UserEntity {
  /// Represents a user entity.
  ///
  /// This class is used to define the structure of a user
  /// entity in the authentication domain.
  const UserEntity({
    required this.uid,
    required this.isAnonymous,
    required this.isEmailVerified,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.tenantId,
    this.refreshToken,
    this.creationTimestamp,
    this.lastSignInTimestamp,
  });

  /// The unique identifier of the user.
  final String uid;

  /// The email address of the user.
  final String? email;

  /// The display name of the user.
  final String? displayName;

  /// The URL of the user's photo.
  final String? photoUrl;

  /// The phone number of the user.
  final String? phoneNumber;

  /// A flag indicating whether the user is anonymous.
  final bool isAnonymous;

  /// A flag indicating whether the user's email is verified.
  final bool isEmailVerified;

  /// The ID of the tenant.
  final String? tenantId;

  /// The refresh token of the user.
  final String? refreshToken;

  /// The creation timestamp of the user.
  final DateTime? creationTimestamp;

  /// The last sign-in timestamp of the user.
  final DateTime? lastSignInTimestamp;
}
