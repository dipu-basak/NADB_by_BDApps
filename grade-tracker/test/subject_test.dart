import 'package:flutter_test/flutter_test.dart';

import 'package:grade_tracker/models/subject.dart';

void main() {
  group('Subject.gradeForMark', () {
    test('returns A for marks >= 80', () {
      expect(Subject.gradeForMark(80), 'A');
      expect(Subject.gradeForMark(92), 'A');
      expect(Subject.gradeForMark(100), 'A');
    });

    test('returns B for marks 65-79', () {
      expect(Subject.gradeForMark(65), 'B');
      expect(Subject.gradeForMark(79), 'B');
    });

    test('returns C for marks 50-64', () {
      expect(Subject.gradeForMark(50), 'C');
      expect(Subject.gradeForMark(64), 'C');
    });

    test('returns F for marks below 50', () {
      expect(Subject.gradeForMark(49), 'F');
      expect(Subject.gradeForMark(0), 'F');
    });
  });

  group('Subject', () {
    test('exposes the private mark through a getter', () {
      final subject = Subject(name: 'Math', mark: 85);
      expect(subject.mark, 85);
      expect(subject.grade, 'A');
    });

    test('a subject is passing when it earns at least a C', () {
      expect(Subject(name: 'Science', mark: 50).isPassing, isTrue);
      expect(Subject(name: 'History', mark: 49).isPassing, isFalse);
    });
  });
}
