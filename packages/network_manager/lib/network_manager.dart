/// A library for managing network requests and responses.
///
/// This library provides a typed and untyped interface for making
/// network requests.
@MappableLib(generateInitializerForScope: InitializerScope.package)
library network_manager;

import 'package:dart_mappable/dart_mappable.dart';

export 'package:network_manager/src/constants/network_constants.dart';
export 'package:network_manager/src/default_network_manager.dart';
export 'package:network_manager/src/entities/token_entity.dart';
export 'package:network_manager/src/enums/index.dart';
export 'package:network_manager/src/enums/method_types.dart';
export 'package:network_manager/src/enums/token_types.dart';
export 'package:network_manager/src/models/index.dart';
export 'package:network_manager/src/network_manager.dart';
export 'package:network_manager/src/network_manager_impl.dart';
export 'package:network_manager/src/repositories/token_repository.dart';
export 'package:network_manager/src/token_network_manager.dart';
export 'package:network_manager/src/utils/index.dart';
