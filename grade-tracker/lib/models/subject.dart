/// A single subject a student is taking, with its mark and computed grade.
class Subject {
  Subject({required this.name, required int mark}) : _mark = mark {
    assert(mark >= 0 && mark <= 100, 'Mark must be between 0 and 100.');
  }

  /// Monotonically increasing id so [Dismissible] items keep a stable,
  /// unique key across rebuilds even when subjects share the same name.
  static int _nextId = 0;
  final int id = _nextId++;

  final String name;

  /// The raw mark out of 100. Stored privately on purpose.
  final int _mark;

  int get mark => _mark;

  /// Letter grade: A (>=80), B (>=65), C (>=50), F otherwise.
  String get grade => gradeForMark(_mark);

  /// Shared grading logic so the summary's overall grade always matches a
  /// subject's own grade at the same mark.
  static String gradeForMark(num mark) {
    if (mark >= 80) return 'A';
    if (mark >= 65) return 'B';
    if (mark >= 50) return 'C';
    return 'F';
  }

  /// A subject passes when it earns at least a C.
  bool get isPassing => grade != 'F';
}
