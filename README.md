# Flutter Advanced Template

Welcome to the **Flutter Advanced Template**! This starter kit is crafted to expedite Flutter app development with a set of essential modules and best practices. Leverage this template to jumpstart your projects, ensure high code quality, and implement industry-standard features.

![Flutter Advanced Template](assets/banner.png)

## 🚀 Features

- **Modular Architecture**: Core features are organized into modules, allowing you to include or exclude them as needed.
- **Best Practices**: Adheres to Flutter best practices for clean, maintainable, and scalable code.
- **Customizable**: Easily configure and extend the template to fit your project requirements.
- **Pre-configured Tools**: Comes with essential tools and libraries pre-configured for efficient development.

## 🛠️ Core Modules

### 📊 Analytics Manager

Track and analyze user interactions and app performance with integration support for popular analytics tools.

### 🌐 Connectivity Manager

Monitor network connectivity and handle offline scenarios gracefully.

### 📱 Device Manager

Retrieve detailed device information including OS version, model, and screen size.

### 📝 Exception Report Manager

Capture, log, and report exceptions to facilitate debugging and improve user support.

### 📁 File Picker

Select files from the device’s storage, including documents and other file types.

### 🖼️ Image Picker

Pick images from the device’s gallery or camera with ease.

### 📦 Package Info Manager

Retrieve information about the app package, including version, build number, and package name.

### 🔥 Firebase Manager

Manage Firebase integration with several submodules:

- **Firebase Auth Manager**: Handle user authentication with Firebase.
- **Firebase Storage Manager**: Manage file uploads and downloads using Firebase Storage.
- **Firestore Manager**: Perform real-time data storage and retrieval with Firestore.

### ⭐ In-App Review Manager

Request and manage in-app reviews to enhance app visibility and user feedback.

### 🌍 Language Manager

Support multiple languages and regions with robust internationalization features.

### 📝 Logger Manager

Implement logging mechanisms for debugging and monitoring application behavior.

### 🎨 Theme Manager

Support for custom themes and switching between light and dark modes.

### 🧩 Navigation Manager

Manage app navigation, including routing, deep linking, and nested navigation.

### 🌐 Network Manager

Handle network requests and manage APIs efficiently.

### 🔔 In-App Local Notification Manager

Display local notifications within the app to keep users informed.

### 📢 Push Notification Manager

Integrate with Firebase Cloud Messaging to handle push notifications.

### 🔐 Permission Manager

Manage and request permissions for accessing device features.

### 🔑 Basic Key-Value Storage Manager

Store simple key-value pairs for lightweight data persistence.

### 🗃️ Cache Storage Manager

Handle caching of data to improve app performance and reduce load times.

### 🗄️ DB Manager (SQL)

Manage SQL databases for structured data storage and queries.

### 🔒 Secure Storage Manager

Store sensitive information securely with encryption to protect private data.

### 📜 Lint Rules

Adopt consistent code quality and style guidelines using customized lint rules.

## 📖 Detailed Module Information

### 📊 Analytics Manager - Details

**Overview**: Integrate with analytics platforms to track user behavior and app performance.

**Features**:

- Supports Google Analytics, Firebase Analytics, etc.
- Track user events, screen views, and custom parameters.

**Usage**:

- Configure analytics providers in `packages/analytics_manager/config.dart`.

### 🌐 Connectivity Manager - Details

**Overview**: Monitor and manage network connectivity and offline scenarios.

**Features**:

- Check and handle network status changes.
- Provide offline behavior management.

**Usage**:

- Implement in `packages/connectivity_manager/connectivity_manager.dart`.

### 📱 Device Manager - Details

**Overview**: Access detailed device information.

**Features**:

- Retrieve OS version, device model, screen size, etc.

**Usage**:

- Use `packages/device_manager/device_manager.dart` for device details.

### 📝 Exception Report Manager - Details

**Overview**: Capture and report application exceptions.

**Features**:

- Handle unhandled exceptions and send reports.

**Usage**:

- Configure in `packages/exception_report_manager/exception_report_manager.dart`.

### 📁 File Picker - Details

**Overview**: Pick files from the device’s storage.

**Features**:

- Select and handle different types of files.

**Usage**:

- Use `packages/file_picker/file_picker.dart` for file picking functionality.

### 🖼️ Image Picker - Details

**Overview**: Pick images from the gallery or camera.

**Features**:

- Handle image selection and processing.

**Usage**:

- Integrate with `packages/image_picker/image_picker.dart`.

### 📦 Package Info Manager - Details

**Overview**: Retrieve information about the app package.

**Features**:

- Access package name, version, and build number.

**Usage**:

- Access package information via `packages/package_info_manager/package_info_manager.dart`.

### 🔥 Firebase Manager - Details

**Overview**: Manage Firebase services with these submodules:

**Firebase Auth Manager**:

- **Features**: Handle authentication flows.
- **Usage**: Implement in `packages/firebase_manager/firebase_auth_manager.dart`.

**Firebase Storage Manager**:

- **Features**: Manage file uploads and downloads.
- **Usage**: Configure in `packages/firebase_manager/firebase_storage_manager.dart`.

**Firestore Manager**:

- **Features**: Interact with Cloud Firestore.
- **Usage**: Use `packages/firebase_manager/firestore_manager.dart`.

### ⭐ In-App Review Manager - Details

**Overview**: Request and manage in-app reviews.

**Features**:

- Prompt users to review your app within the app.

**Usage**:

- Implement in `packages/in_app_review_manager/in_app_review_manager.dart`.

### 🌍 Language Manager - Details

**Overview**: Handle app localization and internationalization.

**Features**:

- Support multiple languages and regions.
- Manage translation resources.

**Usage**:

- Configure in `packages/language_manager/language_manager.dart`.

### 📝 Logger Manager - Details

**Overview**: Implement logging for debugging and monitoring.

**Features**:

- Log application events and errors.

**Usage**:

- Set up in `packages/logger_manager/logger_manager.dart`.

### 🎨 Theme Manager - Details

**Overview**: Manage themes and support for light/dark modes.

**Features**:

- Define and switch between different themes.

**Usage**:

- Customize themes in `packages/theme_manager/theme_manager.dart`.

### 🧩 Navigation Manager - Details

**Overview**: Efficiently manage app navigation.

**Features**:

- Handle routing, deep linking, and navigation stack.

**Usage**:

- Implement navigation in `packages/navigation_manager/navigation_manager.dart`.

### 🌐 Network Manager - Details

**Overview**: Handle network requests and API management.

**Features**:

- Manage network operations and requests.

**Usage**:

- Configure in `packages/network_manager/network_manager.dart`.

### 🔔 In-App Local Notification Manager - Details

**Overview**: Display local notifications within the app.

**Features**:

- Schedule and trigger local notifications.

**Usage**:

- Integrate with `packages/in_app_local_notification_manager/in_app_local_notification_manager.dart`.

### 📢 Push Notification Manager - Details

**Overview**: Manage push notifications with Firebase Cloud Messaging.

**Features**:

- Handle and process push notifications.

**Usage**:

- Set up in `packages/push_notification_manager/push_notification_manager.dart`.

### 🔐 Permission Manager - Details

**Overview**: Request and manage app permissions.

**Features**:

- Handle device permissions for accessing features.

**Usage**:

- Use `packages/permission_manager/permission_manager.dart`.

### 🔑 Basic Key-Value Storage Manager - Details

**Overview**: Store simple key-value pairs.

**Features**:

- Manage lightweight data persistence.

**Usage**:

- Access through `packages/basic_key_value_storage_manager/basic_key_value_storage_manager.dart`.

### 🗃️ Cache Storage Manager - Details

**Overview**: Handle caching of data to improve app performance.

**Features**:

- Implement caching strategies and manage cached data.

**Usage**:

- Set up in `packages/cache_storage_manager/cache_storage_manager.dart`.

### 🗄️ DB Manager (SQL) - Details

**Overview**: Manage SQL databases for structured data storage.

**Features**:

- Perform CRUD operations and queries.

**Usage**:

- Integrate with `packages/db_manager/db_manager.dart`.

### 🔒 Secure Storage Manager - Details

**Overview**: Securely store sensitive information.

**Features**:

- Encrypt and store private data like passwords.

**Usage**:

- Configure in `packages/secure_storage_manager/secure_storage_manager.dart`.

### 📜 Lint Rules - Details

**Overview**: Ensure consistent code quality with custom lint rules.

**Features**:

- Enforce best practices and coding standards.

**Usage**:

- Configure in `analysis_options.yaml` at the root of the project.

// ... existing content ...

## 🔐 Required Permissions

Depending on the modules you use, you may need to add the following permissions to your app:

### Android Permissions

Add these to your `android/app/src/main/AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA" />
<!-- Storage Permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<!-- Notifications Permission -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<!-- ... other app components ... -->
</manifest>
```

### iOS Permissions

Add these to your `ios/Runner/Info.plist` file:

```plist
<dict>
<!-- Camera Usage Description -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos.</string>
<!-- Photo Library Usage Description -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select photos.</string>
</dict>

```

## 📚 Getting Started

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/yourusername/flutter-advanced-template.git
   cd flutter-advanced-template
   ```

2. **Install Dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the App**:

   ```bash
   flutter run
   ```

4. **Customize and Extend**:

- Modify packages/config for module-specific settings.
- Use the provided modules as per your project requirements.

## 📖 Documentation

For detailed documentation on each module, please refer to the respective files and folders within the packages directory.

## 🛠️ Contribution

Contributions are welcome! Please refer to the CONTRIBUTING.md file for guidelines.

## 📄 License

This project is licensed under the [Non-Commercial License with Patent Rights](./LICENSE) - see the LICENSE file for details.
