import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/models/note.dart';

void main() {
  group('Note', () {
    test('fromMap reads the document fields', () {
      final note = Note.fromMap('note-1', {
        'title': 'Maths',
        'description': 'Chapter 5 exercises',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 5)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 8, 6)),
      });

      expect(note.id, 'note-1');
      expect(note.title, 'Maths');
      expect(note.description, 'Chapter 5 exercises');
      expect(note.createdAt, DateTime(2026, 8, 5));
      expect(note.updatedAt, DateTime(2026, 8, 6));
    });

    test('fromMap tolerates missing fields', () {
      final note = Note.fromMap('note-2', {});

      expect(note.title, '');
      expect(note.description, '');
      expect(note.createdAt, isNull);
      expect(note.updatedAt, isNull);
    });

    test('copyWith replaces fields and keeps the id', () {
      const note = Note(id: 'note-3', title: 'A', description: 'B');

      final updated = note.copyWith(title: 'C', description: 'D');

      expect(updated.id, 'note-3');
      expect(updated.title, 'C');
      expect(updated.description, 'D');
      expect(updated.createdAt, isNull);
    });
  });
}
