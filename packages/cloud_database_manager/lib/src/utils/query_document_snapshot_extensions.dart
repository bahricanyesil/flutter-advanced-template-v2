import 'package:cloud_firestore/cloud_firestore.dart';

/// Extension methods for [QueryDocumentSnapshot].
extension QueryDocumentSnapshotExtensions
    on QueryDocumentSnapshot<Map<String, dynamic>> {
  /// Returns the data of the document with id.
  Map<String, dynamic> get dataWithId => data()..['id'] = id;
}

/// Extension methods for [DocumentSnapshot].
extension DocumentSnapshotExt on DocumentSnapshot<Map<String, dynamic>> {
  /// Returns the data of the document with id.
  Map<String, dynamic> get dataWithId =>
      (data() ?? <String, dynamic>{})..['id'] = id;
}
