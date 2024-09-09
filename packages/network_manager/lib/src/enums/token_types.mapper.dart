// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'token_types.dart';

class TokenTypesMapper extends EnumMapper<TokenTypes> {
  TokenTypesMapper._();

  static TokenTypesMapper? _instance;
  static TokenTypesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TokenTypesMapper._());
    }
    return _instance!;
  }

  static TokenTypes fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TokenTypes decode(dynamic value) {
    switch (value) {
      case 'accessToken':
        return TokenTypes.accessToken;
      case 'refreshToken':
        return TokenTypes.refreshToken;
      case 'confirmToken':
        return TokenTypes.confirmToken;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TokenTypes self) {
    switch (self) {
      case TokenTypes.accessToken:
        return 'accessToken';
      case TokenTypes.refreshToken:
        return 'refreshToken';
      case TokenTypes.confirmToken:
        return 'confirmToken';
    }
  }
}

extension TokenTypesMapperExtension on TokenTypes {
  String toValue() {
    TokenTypesMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TokenTypes>(this) as String;
  }
}
