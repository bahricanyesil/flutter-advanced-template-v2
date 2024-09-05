import 'package:flutter/foundation.dart';

/// A base interface for managing in-app reviews.
///
/// This interface defines methods for requesting a review, checking
/// if the review functionality is available,
/// and opening the store listing for the app.
@immutable
abstract interface class InAppReviewManager {
  /// Requests a review from the user.
  ///
  /// This method prompts the user to leave a review for the app.
  /// It should be called when the app determines it is an appropriate
  /// time to ask for a review.
  Future<bool> requestReview();

  /// Checks if the in-app review functionality is available.
  ///
  /// This method checks if the device and app meet the requirements for
  /// in-app reviews.
  /// It returns a boolean value indicating whether the functionality
  /// is available or not.
  Future<bool> isAvailable();

  /// Opens the store listing for the app.
  Future<bool> openStoreListing();
}
