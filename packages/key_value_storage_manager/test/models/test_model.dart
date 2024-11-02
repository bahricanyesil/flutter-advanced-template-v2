import 'dart:convert';

import 'package:key_value_storage_manager/src/models/base_data_model.dart';

final class TestModel implements BaseDataModel<TestModel> {
  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
    return TestModel(
      id: int.tryParse(map['id'].toString()),
      name: map['name'].toString(),
    );
  }
  final int? id;
  final String name;

  @override
  String toJson() => '{"id":$id,"name":"$name"}';

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{'id': id, 'name': name};
}
