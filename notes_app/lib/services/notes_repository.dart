import '../models/note.dart';

/// Abstraction over where notes are stored, so screens can be tested with an
/// in-memory fake instead of a live Firestore.
abstract class NotesRepository {
  /// Live list of notes, newest first.
  Stream<List<Note>> watchNotes();

  /// Creates a note and returns the saved version (with its id).
  Future<Note> addNote({required String title, required String description});

  /// Updates an existing note's title and description.
  Future<void> updateNote(Note note);

  /// Removes the note with the given id.
  Future<void> deleteNote(String id);
}
