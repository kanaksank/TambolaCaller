import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/services/announcement_builder.dart';

void main() {
  group('single numbers (1-9)', () {
    test('uses the "single number" phrasing and repeats itself', () {
      final announcement = AnnouncementBuilder.build(5);
      expect(
        announcement.speech,
        'Single number, number 5; I repeat, number 5.',
      );
      expect(announcement.title, 'NUMBER 5');
      expect(announcement.detail, 'Single number, number 5');
    });

    test('applies to every number from 1 to 9', () {
      for (int n = 1; n <= 9; n++) {
        expect(
          AnnouncementBuilder.build(n).speech,
          'Single number, number $n; I repeat, number $n.',
        );
      }
    });
  });

  group('double-digit numbers (10-90)', () {
    test('splits the digits', () {
      expect(
        AnnouncementBuilder.build(25).speech,
        'Number 25; 2 and 5, number 25.',
      );
      expect(
        AnnouncementBuilder.build(67).speech,
        'Number 67; 6 and 7, number 67.',
      );
      expect(
        AnnouncementBuilder.build(84).speech,
        'Number 84; 8 and 4, number 84.',
      );
    });

    test('repeated digits are spoken as digits, never as "double"', () {
      expect(
        AnnouncementBuilder.build(77).speech,
        'Number 77; 7 and 7, number 77.',
      );
    });

    test('handles round tens and the top of the board', () {
      expect(
        AnnouncementBuilder.build(10).speech,
        'Number 10; 1 and 0, number 10.',
      );
      expect(
        AnnouncementBuilder.build(90).speech,
        'Number 90; 9 and 0, number 90.',
      );
    });

    test('detail line matches the on-screen format', () {
      expect(AnnouncementBuilder.build(67).detail, '6 and 7, number 67');
    });
  });

  test('no announcement ever says "double"', () {
    for (int n = 1; n <= 90; n++) {
      expect(
        AnnouncementBuilder.build(n).speech.toLowerCase().contains('double'),
        isFalse,
        reason: 'number $n must not use the word "double"',
      );
    }
  });

  test('rejects numbers outside 1-90', () {
    expect(() => AnnouncementBuilder.build(0), throwsArgumentError);
    expect(() => AnnouncementBuilder.build(91), throwsArgumentError);
    expect(() => AnnouncementBuilder.build(-3), throwsArgumentError);
  });
}
