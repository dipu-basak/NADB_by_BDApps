import 'package:flutter/foundation.dart';

import '../models/subject.dart';

/// Holds the list of subjects and all derived result statistics.
///
/// Every screen reads this provider with `context.watch` / `context.read`,
/// so the UI stays in sync whenever a subject is added or removed.
class SubjectProvider extends ChangeNotifier {
  final List<Subject> _subjects = [];

  List<Subject> get subjects => List.unmodifiable(_subjects);

  int get totalSubjects => _subjects.length;

  /// Subjects that earned at least a C (uses `.where` to filter).
  int get passingCount => _subjects.where((s) => s.isPassing).length;

  /// Average mark across all subjects (0 when there are none).
  /// Uses `.map` to pull the marks out before reducing.
  double get averageMark {
    if (_subjects.isEmpty) return 0;
    final sum = _subjects.map((s) => s.mark).reduce((a, b) => a + b);
    return sum / _subjects.length;
  }

  /// Overall letter grade derived from the average mark.
  String get overallGrade => Subject.gradeForMark(averageMark);

  /// How many subjects earned a specific grade (uses `.where` to count).
  int countWithGrade(String grade) =>
      _subjects.where((s) => s.grade == grade).length;

  void addSubject(String name, int mark) {
    _subjects.add(Subject(name: name, mark: mark));
    notifyListeners();
  }

  void removeSubject(Subject subject) {
    _subjects.remove(subject);
    notifyListeners();
  }
}
