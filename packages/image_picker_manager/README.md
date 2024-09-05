# Image Picker Manager

The `image_picker_manager` module provides a unified interface for managing image picking in Flutter applications. This module is designed to facilitate the selection of images from the device's gallery or camera.

## Features

- Pick images from the device's gallery or camera.
- Handle image selection changes.

## Installation

To use the `image_picker_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  image_picker_manager:
    path: ../packages/image_picker_manager
```

## Usage

Here's a basic example of how to use the `image_picker_manager` module:

```dart
import 'package:image_picker_manager/image_picker_manager.dart';

// Initialize the image picker manager
final imagePickerManager = ImagePickerManager();

// Use it in your code
final result = await imagePickerManager.pickImage();
```
