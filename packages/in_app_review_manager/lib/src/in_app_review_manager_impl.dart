import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_review_manager/src/in_app_review_manager.dart';
import 'package:log_manager/log_manager.dart';

/// A manager class for handling in-app reviews.
///
/// This class implements the [InAppReviewManagerImpl] interface and provides
/// methods for checking if in-app review is available, opening the store
/// listing, and requesting a review.
///
/// The [InAppReviewManagerImpl] class requires an instance of [InAppReview]
/// to be passed in the constructor. The [InAppReview] instance is used to
/// perform the actual in-app review operations.
@immutable
final class InAppReviewManagerImpl implements InAppReviewManager {
  /// Creates a new [InAppReviewManagerImpl] instance.
  const InAppReviewManagerImpl(
    this._inAppReview, {
    this.appStoreId,
    this.microsoftStoreId,
    this.rethrowExceptions = true,
    LogManager? logManager,
  }) : _logManager = logManager;
  final InAppReview _inAppReview;
  final LogManager? _logManager;

  /// If true, exceptions will be rethrown.
  final bool rethrowExceptions;

  /// The app store ID for the app. You can find it in the App Store Connect.
  /// You can either set in the constructor or later pass it to the
  /// [openStoreListing] method.
  final String? appStoreId;

  /// The Microsoft store ID for the app. You can find in the Microsoft Store.
  /// You can either set in the constructor or later pass it to the
  /// [openStoreListing] method.
  final String? microsoftStoreId;

  /// Checks if in-app review is available on the current platform.
  ///
  /// Returns a [Future] that completes with a boolean value indicating whether
  /// in-app review is available.
  @override
  Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _inAppReview.isAvailable();
      _logManager?.lInfo('InAppReviewManagerImpl.isAvailable: $isAvailable');
      return isAvailable;
    } catch (error) {
      _logManager?.lError('InAppReviewManagerImpl.isAvailable error: $error');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  /// Opens the store listing for the app.
  @override
  Future<bool> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: appStoreId ?? this.appStoreId,
        microsoftStoreId: microsoftStoreId ?? this.microsoftStoreId,
      );
      _logManager?.lInfo('InAppReviewManagerImpl.openStoreListing called');
      return true;
    } catch (error) {
      _logManager
          ?.lError('InAppReviewManagerImpl.openStoreListing error: $error');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  /// Requests a review from the user.
  ///
  /// This method calls the [requestReview] method of the [InAppReview] instance
  /// to prompt the user to leave a review for the app.
  @override
  Future<bool> requestReview() async {
    try {
      final bool available = await isAvailable();
      if (!available) {
        throw Exception('In-app review is not available on this platform');
      }
      await _inAppReview.requestReview();
      _logManager?.lInfo('InAppReviewManagerImpl.requestReview called');
      return true;
    } catch (error) {
      _logManager?.lError('InAppReviewManagerImpl.requestReview error: $error');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }
}
