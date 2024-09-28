/// A library for managing network requests and responses.
///
/// This library provides a typed and untyped interface for making
/// network requests.
@MappableLib(generateInitializerForScope: InitializerScope.package)
library network_manager;

import 'package:dart_mappable/dart_mappable.dart';

export 'src/default_network_manager.dart';
export 'src/entities/token_entity.dart';
export 'src/enums/method_types.dart';
export 'src/enums/token_types.dart';
export 'src/network_manager.dart';
export 'src/network_manager_impl.dart';
export 'src/utils/status_code_helpers.dart';
