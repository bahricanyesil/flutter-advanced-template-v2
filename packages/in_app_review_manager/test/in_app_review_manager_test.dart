import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review_manager/src/in_app_review_manager_impl.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_in_app_review.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  group('InAppReviewManager', () {
    late InAppReviewManagerImpl inAppReviewManager;
    late MockInAppReview mockInAppReview;
    late MockLogManager mockLogManager;
    const String appStoreId = 'app_store_id';
    const String microsoftStoreId = 'microsoft_store_id';

    setUp(() {
      mockInAppReview = MockInAppReview();
      mockLogManager = MockLogManager();
      inAppReviewManager = InAppReviewManagerImpl(
        mockInAppReview,
        logManager: mockLogManager,
        appStoreId: appStoreId,
        microsoftStoreId: microsoftStoreId,
      );
    });

    test('requestReview calls requestReview on InAppReview', () async {
      when(() => mockInAppReview.isAvailable()).thenAnswer((_) async => true);
      when(() => mockInAppReview.requestReview()).thenAnswer((_) async => true);

      await inAppReviewManager.requestReview();

      verify(() => mockInAppReview.requestReview()).called(1);
    });

    test('requestReview does not call requestReview if not available',
        () async {
      when(() => mockInAppReview.isAvailable()).thenAnswer((_) async => false);

      try {
        await inAppReviewManager.requestReview();
      } catch (e) {
        expect(e, isA<Exception>());
      }

      verifyNever(() => mockInAppReview.requestReview());
    });

    test('is available throws exception when there is an error', () async {
      when(() => mockInAppReview.isAvailable()).thenThrow(Exception('Error'));

      expect(() => inAppReviewManager.isAvailable(), throwsException);
    });

    test('openStoreListing calls openStoreListing on InAppReview', () async {
      when(
        () => mockInAppReview.openStoreListing(
          appStoreId: any(named: 'appStoreId'),
          microsoftStoreId: any(named: 'microsoftStoreId'),
        ),
      ).thenAnswer((_) async => true);

      await inAppReviewManager.openStoreListing();

      verify(
        () => mockInAppReview.openStoreListing(
          appStoreId: appStoreId,
          microsoftStoreId: microsoftStoreId,
        ),
      ).called(1);
    });

    test('openStoreListing uses provided appStoreId and microsoftStoreId',
        () async {
      when(
        () => mockInAppReview.openStoreListing(
          appStoreId: any(named: 'appStoreId'),
          microsoftStoreId: any(named: 'microsoftStoreId'),
        ),
      ).thenAnswer((_) async => true);
      await inAppReviewManager.openStoreListing(
        appStoreId: '123456',
        microsoftStoreId: '789012',
      );

      verify(
        () => mockInAppReview.openStoreListing(
          appStoreId: '123456',
          microsoftStoreId: '789012',
        ),
      ).called(1);
    });

    test('openStoreListing throws exception when there is an error', () async {
      when(
        () => mockInAppReview.openStoreListing(
          appStoreId: any(named: 'appStoreId'),
          microsoftStoreId: any(named: 'microsoftStoreId'),
        ),
      ).thenThrow(Exception('Error'));

      expect(() => inAppReviewManager.openStoreListing(), throwsException);
    });
  });
}
