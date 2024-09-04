import 'package:file_picker/file_picker.dart';

import '../constants/custom_file_picker_statuses.dart';

/// An extension on [FilePickerStatus] to convert it
/// to [CustomFilePickerStatuses].
extension CustomFilePickerStatusesExtensions on FilePickerStatus {
  /// Converts [FilePickerStatus] to [CustomFilePickerStatuses].
  CustomFilePickerStatuses get toCustomFilePickerStatus =>
      CustomFilePickerStatuses.values.byName(name);
}
