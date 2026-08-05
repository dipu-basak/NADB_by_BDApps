import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/notes_list_screen.dart';
import 'services/firestore_notes_repository.dart';
import 'services/notes_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: this fails until you run `flutterfire configure` (see README.md),
  // which replaces lib/firebase_options.dart with your project's settings.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(NotesApp(repository: FirestoreNotesRepository()));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key, required this.repository});

  final NotesRepository repository;

  @override
  Widget build(BuildContext context) {
    return Provider<NotesRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const NotesListScreen(),
      ),
    );
  }
}
