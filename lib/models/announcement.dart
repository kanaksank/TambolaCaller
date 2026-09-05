/// Everything the app needs to show and speak a single called number.
///
/// Built by [AnnouncementBuilder] so that the calling rules live in exactly
/// one place and can be unit tested without any UI or plugin.
class Announcement {
  const Announcement({
    required this.number,
    required this.title,
    required this.detail,
    required this.speech,
  });

  /// The called number, 1-90.
  final int number;

  /// Big on-screen caption, e.g. `NUMBER 67`.
  final String title;

  /// Supporting on-screen line, e.g. `6 and 7, number 67`.
  final String detail;

  /// The full sentence handed to text-to-speech.
  final String speech;

  @override
  String toString() => 'Announcement($number, "$speech")';

  @override
  bool operator ==(Object other) =>
      other is Announcement &&
      other.number == number &&
      other.title == title &&
      other.detail == detail &&
      other.speech == speech;

  @override
  int get hashCode => Object.hash(number, title, detail, speech);
}
