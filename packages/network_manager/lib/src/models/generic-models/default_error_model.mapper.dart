// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'default_error_model.dart';

class DefaultErrorModelMapper extends ClassMapperBase<DefaultErrorModel> {
  DefaultErrorModelMapper._();

  static DefaultErrorModelMapper? _instance;
  static DefaultErrorModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DefaultErrorModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DefaultErrorModel';

  static String? _$message(DefaultErrorModel v) => v.message;
  static const Field<DefaultErrorModel, String> _f$message =
      Field('message', _$message, opt: true);
  static String? _$resultCode(DefaultErrorModel v) => v.resultCode;
  static const Field<DefaultErrorModel, String> _f$resultCode =
      Field('resultCode', _$resultCode, opt: true);

  @override
  final MappableFields<DefaultErrorModel> fields = const {
    #message: _f$message,
    #resultCode: _f$resultCode,
  };

  @override
  final MappingHook hook = const DefaultErrorHook();
  static DefaultErrorModel _instantiate(DecodingData data) {
    return DefaultErrorModel(
        message: data.dec(_f$message), resultCode: data.dec(_f$resultCode));
  }

  @override
  final Function instantiate = _instantiate;

  static DefaultErrorModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DefaultErrorModel>(map);
  }

  static DefaultErrorModel fromJson(String json) {
    return ensureInitialized().decodeJson<DefaultErrorModel>(json);
  }
}

mixin DefaultErrorModelMappable {
  String toJson() {
    return DefaultErrorModelMapper.ensureInitialized()
        .encodeJson<DefaultErrorModel>(this as DefaultErrorModel);
  }

  Map<String, dynamic> toMap() {
    return DefaultErrorModelMapper.ensureInitialized()
        .encodeMap<DefaultErrorModel>(this as DefaultErrorModel);
  }

  DefaultErrorModelCopyWith<DefaultErrorModel, DefaultErrorModel,
          DefaultErrorModel>
      get copyWith => _DefaultErrorModelCopyWithImpl(
          this as DefaultErrorModel, $identity, $identity);
  @override
  String toString() {
    return DefaultErrorModelMapper.ensureInitialized()
        .stringifyValue(this as DefaultErrorModel);
  }

  @override
  bool operator ==(Object other) {
    return DefaultErrorModelMapper.ensureInitialized()
        .equalsValue(this as DefaultErrorModel, other);
  }

  @override
  int get hashCode {
    return DefaultErrorModelMapper.ensureInitialized()
        .hashValue(this as DefaultErrorModel);
  }
}

extension DefaultErrorModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DefaultErrorModel, $Out> {
  DefaultErrorModelCopyWith<$R, DefaultErrorModel, $Out>
      get $asDefaultErrorModel =>
          $base.as((v, t, t2) => _DefaultErrorModelCopyWithImpl(v, t, t2));
}

abstract class DefaultErrorModelCopyWith<$R, $In extends DefaultErrorModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? message, String? resultCode});
  DefaultErrorModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DefaultErrorModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DefaultErrorModel, $Out>
    implements DefaultErrorModelCopyWith<$R, DefaultErrorModel, $Out> {
  _DefaultErrorModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DefaultErrorModel> $mapper =
      DefaultErrorModelMapper.ensureInitialized();
  @override
  $R call({Object? message = $none, Object? resultCode = $none}) =>
      $apply(FieldCopyWithData({
        if (message != $none) #message: message,
        if (resultCode != $none) #resultCode: resultCode
      }));
  @override
  DefaultErrorModel $make(CopyWithData data) => DefaultErrorModel(
      message: data.get(#message, or: $value.message),
      resultCode: data.get(#resultCode, or: $value.resultCode));

  @override
  DefaultErrorModelCopyWith<$R2, DefaultErrorModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DefaultErrorModelCopyWithImpl($value, $cast, t);
}
