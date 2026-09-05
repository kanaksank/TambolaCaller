import '../models/announcement.dart';

/// Turns a Tambola number into the exact words a caller would say.
///
/// Rules:
///   * 1-9  -> "Single number, number 5; I repeat, number 5."
///   * 10-90 -> "Number 67; 6 and 7, number 67."
///
/// The phrase "double number" is deliberately never used, including for
/// repeated digits such as 77 ("Number 77; 7 and 7, number 77.").
abstract final class AnnouncementBuilder {
  static const int minNumber = 1;
  static const int maxNumber = 90;

  static Announcement build(int number) {
    if (number < minNumber || number > maxNumber) {
      throw ArgumentError.value(
        number,
        'number',
        'Tambola numbers must be between $minNumber and $maxNumber',
      );
    }

    if (number < 10) {
      return Announcement(
        number: number,
        title: 'NUMBER $number',
        detail: 'Single number, number $number',
        speech: 'Single number, number $number; I repeat, number $number.',
      );
    }

    final int tens = number ~/ 10;
    final int units = number % 10;
    return Announcement(
      number: number,
      title: 'NUMBER $number',
      detail: '$tens and $units, number $number',
      speech: 'Number $number; $tens and $units, number $number.',
    );
  }
}
