import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/notes_repository.dart';
import 'note_edit_screen.dart';

/// Home screen — lists every note from Firestore, newest first.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  Stream<List<Note>>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<NotesRepository>().watchNotes();
  }

  void _retry() {
    setState(() {
      _stream = context.read<NotesRepository>().watchNotes();
    });
  }

  Future<void> _openEditor([Note? note]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NoteEditScreen(note: note),
      ),
    );
  }

  Future<bool> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('"${note.title}" will be permanently removed.'),
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
    return confirmed ?? false;
  }

  Future<void> _delete(Note note) async {
    await context.read<NotesRepository>().deleteNote(note.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted "${note.title}"')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addNoteFab'),
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorView(
              error: snapshot.error!,
              onRetry: _retry,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return const _EmptyView();
          }
          return ListView.builder(
            key: const Key('notesList'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(note),
                  onDismissed: (_) => _delete(note),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  child: _NoteCard(note: note, onTap: () => _openEditor(note)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateText = _formatDate(note.updatedAt ?? note.createdAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              if (note.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  note.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              if (dateText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: scheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      dateText,
                      style: TextStyle(fontSize: 12, color: scheme.outline),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "New Note" to create your first note.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load notes',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and that Firestore is enabled '
              '(see README for setup).',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$error',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
