import 'building.dart';
import 'category.dart';
import 'report_limits.dart';

/// Form validators. Each returns an error message, or null when the value is valid.
abstract final class ReportValidators {
  static String? title(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Enter a title.';
    if (title.length < ReportLimits.minTitleLength ||
        title.length > ReportLimits.maxTitleLength) {
      return 'Use between ${ReportLimits.minTitleLength} and '
          '${ReportLimits.maxTitleLength} characters.';
    }
    return null;
  }

  static String? description(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) return 'Describe what happened.';
    if (description.length < ReportLimits.minDescriptionLength ||
        description.length > ReportLimits.maxDescriptionLength) {
      return 'Use between ${ReportLimits.minDescriptionLength} and '
          '${ReportLimits.maxDescriptionLength} characters.';
    }
    return null;
  }

  static String? room(String? value) {
    final room = value?.trim() ?? '';
    return room.length > ReportLimits.maxRoomLength
        ? 'Use at most ${ReportLimits.maxRoomLength} characters.'
        : null;
  }

  static String? statusNote(String? value) {
    final note = value?.trim() ?? '';
    if (note.isEmpty) return 'Explain the change.';
    if (note.length < ReportLimits.minNoteLength ||
        note.length > ReportLimits.maxNoteLength) {
      return 'Use between ${ReportLimits.minNoteLength} and '
          '${ReportLimits.maxNoteLength} characters.';
    }
    return null;
  }

  static String? category(Category? value) =>
      value == null ? 'Choose a category.' : null;

  static String? building(Building? value) =>
      value == null ? 'Choose a building.' : null;
}
