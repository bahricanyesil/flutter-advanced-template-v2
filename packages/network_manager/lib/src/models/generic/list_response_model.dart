import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';
import 'package:network_manager/src/models/base_data_model.dart';

part 'list_response_model.mapper.dart';

/// A generic model representing a list response from a network request.
///
/// This model is used to deserialize a JSON response into a list
/// of objects of type [T].
/// It implements the [BaseDataModel] interface and uses the
/// [ListResponseModelMappable] mixin
/// for mapping the JSON data to the model.
@MappableClass()
@immutable
final class ListResponseModel<T>
    with ListResponseModelMappable<T>
    implements BaseDataModel<ListResponseModel<T>> {
  /// Creates a new instance of [ListResponseModel] with the given [dataList].
  const ListResponseModel({required this.dataList});

  /// The list of objects of type [T] contained in the response.
  final List<T> dataList;
}
