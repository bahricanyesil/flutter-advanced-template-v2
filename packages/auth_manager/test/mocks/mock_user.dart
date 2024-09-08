import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

final class MockUser extends Mock implements User {
  @override
  String get uid => 'testUid';

  @override
  String get email => 'test@example.com';

  @override
  String get displayName => 'testDisplayName';

  @override
  String get phoneNumber => '1234567890';

  @override
  String get photoURL => 'https://example.com/photo.jpg';

  @override
  bool get isAnonymous => false;

  @override
  bool get emailVerified => true;

  @override
  String? get refreshToken => 'testRefreshToken';

  @override
  String? get tenantId => 'testTenantId';

  @override
  UserMetadata get metadata => UserMetadata(12, 124);

  DateTime? get creationTimestamp => DateTime.now();

  DateTime? get lastSignInTimestamp => DateTime.now();

  @override
  List<UserInfo> get providerData => <UserInfo>[];
}
