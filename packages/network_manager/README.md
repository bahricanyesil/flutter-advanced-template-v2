# Network Manager

The Network Manager provides a unified interface for handling network operations in Flutter applications. It simplifies making HTTP requests, handling responses, and managing network-related tasks with strong typing support.

## Features

- Make GET, POST, PUT, DELETE, and other HTTP requests
- Handle request headers and body
- Parse response data with typed models
- Manage authentication tokens
- Handle network errors and timeouts
- Support for request cancellation
- Interceptors for request/response manipulation
- Progress tracking for file uploads and downloads
- Caching support
- Flexible and extensible design with generic types

## Getting Started

To use this package, add `network_manager` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  network_manager:
    path: ../packages/network_manager
```

## Usage

Here's a basic example of how to use the Network Manager:

```dart
import 'package:network_manager/network_manager.dart';

void main() async {
  final networkManager = NetworkManagerImpl<MyErrorType, MyOptionsType, MyCancelTokenType, MyInterceptorType>(
    logManager: yourLogManager
  );

  // Make a GET request
  final response = await networkManager.requestWithoutBody<UserModel>(
    'users',
    methodType: MethodTypes.get,
    queryParameters: {'id': '123'},
  );

  if (response.isSuccessful) {
    final user = response.data;
    print('User: ${user.name}');
  } else {
    print('Error: ${response.error}');
  }

  // Make a POST request
  final postResponse = await networkManager.sendRequest<CreateUserRequest, UserModel>(
    'users',
    methodType: MethodTypes.post,
    body: CreateUserRequest(name: 'John Doe', email: 'john@example.com'),
  );

  if (postResponse.isSuccessful) {
    print('User created successfully: ${postResponse.data.id}');
  } else {
    print('Error creating user: ${postResponse.error}');
  }
}
```

## API Reference

### INetworkManagerTyped

The `INetworkManagerTyped` interface provides the following methods:

- `Future<INetworkResponse<R, E>> sendRequest<T, R>(...)`: Send a network request with a body.
- `Future<INetworkResponse<R, E>> requestWithoutBody<R>(...)`: Send a network request without a body.
- `Future<INetworkResponse<ListResponseModel<int>, E>> downloadFile<T>(...)`: Download a file.
- `Future<INetworkResponse<R, E>> uploadFile<FormDataT, R>(...)`: Upload a file.
- `void addBaseHeader(MapEntry<String, String> entry)`: Add a base header.
- `Map<String, dynamic> get allHeaders`: Get all headers.
- `void removeHeader(String key)`: Remove a specific header.
- `void clearHeader()`: Clear all headers.
- `void addAllInterceptors(List<InterceptorT> newInterceptorList)`: Add multiple interceptors.
- `bool addInterceptor(InterceptorT newInterceptor)`: Add a single interceptor.
- `bool insertInterceptor(int index, InterceptorT newInterceptor)`: Insert an interceptor at a specific index.
- `bool removeInterceptor(InterceptorT deletedInterceptor)`: Remove a specific interceptor.
- `List<InterceptorT> get allInterceptors`: Get all interceptors.

## Testing

To run the tests for this package, use the following command:

```dart
flutter test packages/network_manager
```

## Implementation Details

The `INetworkManagerTyped` is a generic interface that allows for flexible implementations with different error types, options, cancel tokens, and interceptors. Concrete implementations should provide specific types for these generic parameters.

## Error Handling

The package uses the `INetworkResponse<R, E>` class to encapsulate the response data, status code, and any errors that occurred during the request. Always check the `isSuccessful` property of the response before accessing the data.

## Logging

The Network Manager uses a `LogManager` for logging network operations and errors. Make sure to provide a proper `LogManager` implementation when initializing the concrete Network Manager.

## Contributing

Contributions to the Network Manager are welcome. Please refer to the project's contribution guidelines for more information.
