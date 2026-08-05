import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/notes_repository.dart';

/// Screen used both to create a new note and to edit an existing one.
/// When [note] is null the screen is in "create" mode.
class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.note?.description ?? '');

  bool get _isEditing => widget.note != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title is required';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repository = context.read<NotesRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (_isEditing) {
        await repository.updateNote(
          widget.note!.copyWith(
            title: title,
            description: description,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await repository.addNote(title: title, description: description);
      }
      // The user may have backed out while the write was in flight.
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Note updated' : 'Note created')),
        );
      navigator.pop();
    } catch (error) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not save note: $error')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('"${widget.note!.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<NotesRepository>().deleteNote(widget.note!.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted "${widget.note!.title}"')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          if (_isEditing)
            IconButton(
              key: const Key('deleteNoteButton'),
              onPressed: _delete,
              tooltip: 'Delete note',
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('titleField'),
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'What is this note about?',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: _validateTitle,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('descriptionField'),
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Write the details here…',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes),
                    ),
                    validator: _validateDescription,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('saveNoteButton'),
                    onPressed: _save,
                    icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(_isEditing ? 'Save Changes' : 'Create Note'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
