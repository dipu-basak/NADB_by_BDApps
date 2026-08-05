import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/main.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/services/notes_repository.dart';

/// In-memory repository so widget tests exercise the UI without Firestore.
class FakeNotesRepository implements NotesRepository {
  final List<Note> _notes = [];
  final StreamController<List<Note>> _controller =
      StreamController<List<Note>>.broadcast();

  void _emit() {
    if (_controller.hasListener) {
      _controller.add(List.unmodifiable(_notes));
    }
  }

  @override
  Stream<List<Note>> watchNotes() async* {
    // Emit the current state immediately, then follow live updates.
    yield List.unmodifiable(_notes);
    yield* _controller.stream;
  }

  @override
  Future<Note> addNote({
    required String title,
    required String description,
  }) async {
    final note = Note(
      id: 'note-${_notes.length + 1}',
      title: title,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, note);
    _emit();
    return note;
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
      _emit();
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    _emit();
  }
}

void main() {
  testWidgets('shows the empty state when there are no notes', (tester) async {
    await tester.pumpWidget(NotesApp(repository: FakeNotesRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('New Note'), findsOneWidget);
  });

  testWidgets('creates a note and shows it in the list', (tester) async {
    await tester.pumpWidget(NotesApp(repository: FakeNotesRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addNoteFab')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), 'Grocery list');
    await tester.enterText(
      find.byKey(const Key('descriptionField')),
      'Milk, eggs, bread',
    );
    await tester.tap(find.byKey(const Key('saveNoteButton')));
    await tester.pumpAndSettle();

    expect(find.text('Grocery list'), findsOneWidget);
    expect(find.text('Milk, eggs, bread'), findsOneWidget);

    // Let the confirmation SnackBar timer expire.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('validates that title and description are required',
      (tester) async {
    await tester.pumpWidget(NotesApp(repository: FakeNotesRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addNoteFab')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveNoteButton')));
    await tester.pumpAndSettle();

    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });

  testWidgets('edits an existing note', (tester) async {
    final repository = FakeNotesRepository();
    await repository.addNote(title: 'Draft', description: 'Original text');

    await tester.pumpWidget(NotesApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Draft'), findsOneWidget);

    await tester.tap(find.text('Draft'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Note'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('titleField')), 'Draft v2');
    await tester.tap(find.byKey(const Key('saveNoteButton')));
    await tester.pumpAndSettle();

    expect(find.text('Draft v2'), findsOneWidget);
    expect(find.text('Draft'), findsNothing);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('deletes a note by swiping', (tester) async {
    final repository = FakeNotesRepository();
    await repository.addNote(title: 'Old note', description: 'To be removed');

    await tester.pumpWidget(NotesApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Old note'), findsOneWidget);

    final listItem = find.descendant(
      of: find.byKey(const Key('notesList')),
      matching: find.byType(Dismissible),
    );
    await tester.drag(listItem, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Confirmation dialog.
    expect(find.text('Delete note?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Old note'), findsNothing);
    expect(find.text('No notes yet'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
  });
}
