import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';
import 'notes_repository.dart';

/// Stores notes in the Firestore `notes` collection.
class FirestoreNotesRepository implements NotesRepository {
  FirestoreNotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection('notes');

  /// Streams all notes ordered by creation time, newest first.
  @override
  Stream<List<Note>> watchNotes() {
    return _notes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Note.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Creates a note; timestamps are set by the server.
  @override
  Future<Note> addNote({
    required String title,
    required String description,
  }) async {
    final doc = await _notes.add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return Note(id: doc.id, title: title, description: description);
  }

  /// Updates an existing note's title and description.
  @override
  Future<void> updateNote(Note note) async {
    await _notes.doc(note.id).update({
      'title': note.title,
      'description': note.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes the note with the given id.
  @override
  Future<void> deleteNote(String id) async {
    await _notes.doc(id).delete();
  }
}
