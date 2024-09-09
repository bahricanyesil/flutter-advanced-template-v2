// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'default_data_model.dart';

class LanguageTypesMapper extends EnumMapper<LanguageTypes> {
  LanguageTypesMapper._();

  static LanguageTypesMapper? _instance;
  static LanguageTypesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LanguageTypesMapper._());
    }
    return _instance!;
  }

  static LanguageTypes fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  LanguageTypes decode(dynamic value) {
    switch (value) {
      case 'en':
        return LanguageTypes.en;
      case 'tr':
        return LanguageTypes.tr;
      case 'de':
        return LanguageTypes.de;
      case 'fr':
        return LanguageTypes.fr;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(LanguageTypes self) {
    switch (self) {
      case LanguageTypes.en:
        return 'en';
      case LanguageTypes.tr:
        return 'tr';
      case LanguageTypes.de:
        return 'de';
      case LanguageTypes.fr:
        return 'fr';
    }
  }
}

extension LanguageTypesMapperExtension on LanguageTypes {
  String toValue() {
    LanguageTypesMapper.ensureInitialized();
    return MapperContainer.globals.toValue<LanguageTypes>(this) as String;
  }
}

class DefaultDataModelMapper extends ClassMapperBase<DefaultDataModel> {
  DefaultDataModelMapper._();

  static DefaultDataModelMapper? _instance;
  static DefaultDataModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DefaultDataModelMapper._());
      LanguageTypesMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DefaultDataModel';
  @override
  Function get typeFactory => <T>(f) => f<DefaultDataModel<T>>();

  static Map<LanguageTypes, String>? _$resultMessage(DefaultDataModel v) =>
      v.resultMessage;
  static const Field<DefaultDataModel, Map<LanguageTypes, String>>
      _f$resultMessage = Field('resultMessage', _$resultMessage);
  static String? _$resultCode(DefaultDataModel v) => v.resultCode;
  static const Field<DefaultDataModel, String> _f$resultCode =
      Field('resultCode', _$resultCode);
  static dynamic _$data(DefaultDataModel v) => v.data;
  static dynamic _arg$data<T>(f) => f<T>();
  static const Field<DefaultDataModel, dynamic> _f$data =
      Field('data', _$data, arg: _arg$data);

  @override
  final MappableFields<DefaultDataModel> fields = const {
    #resultMessage: _f$resultMessage,
    #resultCode: _f$resultCode,
    #data: _f$data,
  };

  @override
  final MappingHook hook = const DefaultDataHook();
  static DefaultDataModel<T> _instantiate<T>(DecodingData data) {
    return DefaultDataModel(
        resultMessage: data.dec(_f$resultMessage),
        resultCode: data.dec(_f$resultCode),
        data: data.dec(_f$data));
  }

  @override
  final Function instantiate = _instantiate;

  static DefaultDataModel<T> fromMap<T>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DefaultDataModel<T>>(map);
  }

  static DefaultDataModel<T> fromJson<T>(String json) {
    return ensureInitialized().decodeJson<DefaultDataModel<T>>(json);
  }
}

mixin DefaultDataModelMappable<T> {
  String toJson() {
    return DefaultDataModelMapper.ensureInitialized()
        .encodeJson<DefaultDataModel<T>>(this as DefaultDataModel<T>);
  }

  Map<String, dynamic> toMap() {
    return DefaultDataModelMapper.ensureInitialized()
        .encodeMap<DefaultDataModel<T>>(this as DefaultDataModel<T>);
  }

  DefaultDataModelCopyWith<DefaultDataModel<T>, DefaultDataModel<T>,
          DefaultDataModel<T>, T>
      get copyWith => _DefaultDataModelCopyWithImpl(
          this as DefaultDataModel<T>, $identity, $identity);
  @override
  String toString() {
    return DefaultDataModelMapper.ensureInitialized()
        .stringifyValue(this as DefaultDataModel<T>);
  }

  @override
  bool operator ==(Object other) {
    return DefaultDataModelMapper.ensureInitialized()
        .equalsValue(this as DefaultDataModel<T>, other);
  }

  @override
  int get hashCode {
    return DefaultDataModelMapper.ensureInitialized()
        .hashValue(this as DefaultDataModel<T>);
  }
}

extension DefaultDataModelValueCopy<$R, $Out, T>
    on ObjectCopyWith<$R, DefaultDataModel<T>, $Out> {
  DefaultDataModelCopyWith<$R, DefaultDataModel<T>, $Out, T>
      get $asDefaultDataModel =>
          $base.as((v, t, t2) => _DefaultDataModelCopyWithImpl(v, t, t2));
}

abstract class DefaultDataModelCopyWith<$R, $In extends DefaultDataModel<T>,
    $Out, T> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, LanguageTypes, String, ObjectCopyWith<$R, String, String>>?
      get resultMessage;
  $R call(
      {Map<LanguageTypes, String>? resultMessage, String? resultCode, T? data});
  DefaultDataModelCopyWith<$R2, $In, $Out2, T> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DefaultDataModelCopyWithImpl<$R, $Out, T>
    extends ClassCopyWithBase<$R, DefaultDataModel<T>, $Out>
    implements DefaultDataModelCopyWith<$R, DefaultDataModel<T>, $Out, T> {
  _DefaultDataModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DefaultDataModel> $mapper =
      DefaultDataModelMapper.ensureInitialized();
  @override
  MapCopyWith<$R, LanguageTypes, String, ObjectCopyWith<$R, String, String>>?
      get resultMessage => $value.resultMessage != null
          ? MapCopyWith(
              $value.resultMessage!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(resultMessage: v))
          : null;
  @override
  $R call(
          {Object? resultMessage = $none,
          Object? resultCode = $none,
          Object? data = $none}) =>
      $apply(FieldCopyWithData({
        if (resultMessage != $none) #resultMessage: resultMessage,
        if (resultCode != $none) #resultCode: resultCode,
        if (data != $none) #data: data
      }));
  @override
  DefaultDataModel<T> $make(CopyWithData data) => DefaultDataModel(
      resultMessage: data.get(#resultMessage, or: $value.resultMessage),
      resultCode: data.get(#resultCode, or: $value.resultCode),
      data: data.get(#data, or: $value.data));

  @override
  DefaultDataModelCopyWith<$R2, DefaultDataModel<T>, $Out2, T>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DefaultDataModelCopyWithImpl($value, $cast, t);
}
