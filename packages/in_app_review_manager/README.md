# In-App Review Manager

The `in_app_review_manager` module provides a unified interface for managing in-app reviews in Flutter applications. This module is designed to facilitate the request for user reviews within the app.

## Features

- Request in-app reviews from users.
- Handle review request responses.

## Installation

To use the `in_app_review_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  in_app_review_manager:
    path: ../packages/in_app_review_manager
```

## Usage

Here's a basic example of how to use the `in_app_review_manager` module:

```dart
import 'package:in_app_review_manager/in_app_review_manager.dart';

// Initialize the in-app review manager
final inAppReviewManager = InAppReviewManager();

// Use it in your code
await inAppReviewManager.requestReview();
```
