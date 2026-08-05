import 'package:cloud_firestore/cloud_firestore.dart';

/// A single note with a title and description, stored in Firestore.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Firestore document id. Empty for notes that haven't been saved yet.
  final String id;

  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note copyWith({
    String? title,
    String? description,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Builds a [Note] from a Firestore document snapshot map.
  factory Note.fromMap(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
