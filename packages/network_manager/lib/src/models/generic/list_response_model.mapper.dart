// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'list_response_model.dart';

class ListResponseModelMapper extends ClassMapperBase<ListResponseModel> {
  ListResponseModelMapper._();

  static ListResponseModelMapper? _instance;
  static ListResponseModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ListResponseModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ListResponseModel';
  @override
  Function get typeFactory => <T>(f) => f<ListResponseModel<T>>();

  static List<dynamic> _$dataList(ListResponseModel v) => v.dataList;
  static dynamic _arg$dataList<T>(f) => f<List<T>>();
  static const Field<ListResponseModel, List<dynamic>> _f$dataList =
      Field('dataList', _$dataList, arg: _arg$dataList);

  @override
  final MappableFields<ListResponseModel> fields = const {
    #dataList: _f$dataList,
  };

  static ListResponseModel<T> _instantiate<T>(DecodingData data) {
    return ListResponseModel(dataList: data.dec(_f$dataList));
  }

  @override
  final Function instantiate = _instantiate;

  static ListResponseModel<T> fromMap<T>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ListResponseModel<T>>(map);
  }

  static ListResponseModel<T> fromJson<T>(String json) {
    return ensureInitialized().decodeJson<ListResponseModel<T>>(json);
  }
}

mixin ListResponseModelMappable<T> {
  String toJson() {
    return ListResponseModelMapper.ensureInitialized()
        .encodeJson<ListResponseModel<T>>(this as ListResponseModel<T>);
  }

  Map<String, dynamic> toMap() {
    return ListResponseModelMapper.ensureInitialized()
        .encodeMap<ListResponseModel<T>>(this as ListResponseModel<T>);
  }

  ListResponseModelCopyWith<ListResponseModel<T>, ListResponseModel<T>,
          ListResponseModel<T>, T>
      get copyWith => _ListResponseModelCopyWithImpl(
          this as ListResponseModel<T>, $identity, $identity);
  @override
  String toString() {
    return ListResponseModelMapper.ensureInitialized()
        .stringifyValue(this as ListResponseModel<T>);
  }

  @override
  bool operator ==(Object other) {
    return ListResponseModelMapper.ensureInitialized()
        .equalsValue(this as ListResponseModel<T>, other);
  }

  @override
  int get hashCode {
    return ListResponseModelMapper.ensureInitialized()
        .hashValue(this as ListResponseModel<T>);
  }
}

extension ListResponseModelValueCopy<$R, $Out, T>
    on ObjectCopyWith<$R, ListResponseModel<T>, $Out> {
  ListResponseModelCopyWith<$R, ListResponseModel<T>, $Out, T>
      get $asListResponseModel =>
          $base.as((v, t, t2) => _ListResponseModelCopyWithImpl(v, t, t2));
}

abstract class ListResponseModelCopyWith<$R, $In extends ListResponseModel<T>,
    $Out, T> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, T, ObjectCopyWith<$R, T, T>> get dataList;
  $R call({List<T>? dataList});
  ListResponseModelCopyWith<$R2, $In, $Out2, T> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _ListResponseModelCopyWithImpl<$R, $Out, T>
    extends ClassCopyWithBase<$R, ListResponseModel<T>, $Out>
    implements ListResponseModelCopyWith<$R, ListResponseModel<T>, $Out, T> {
  _ListResponseModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ListResponseModel> $mapper =
      ListResponseModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, T, ObjectCopyWith<$R, T, T>> get dataList => ListCopyWith(
      $value.dataList,
      (v, t) => ObjectCopyWith(v, $identity, t),
      (v) => call(dataList: v));
  @override
  $R call({List<T>? dataList}) =>
      $apply(FieldCopyWithData({if (dataList != null) #dataList: dataList}));
  @override
  ListResponseModel<T> $make(CopyWithData data) =>
      ListResponseModel(dataList: data.get(#dataList, or: $value.dataList));

  @override
  ListResponseModelCopyWith<$R2, ListResponseModel<T>, $Out2, T>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _ListResponseModelCopyWithImpl($value, $cast, t);
}
