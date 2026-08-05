import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/subject.dart';
import '../providers/subject_provider.dart';
import '../theme/app_theme.dart';

/// Screen 1 — a form to add a subject name and its mark (0-100).
class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _markController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _markController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject name is required';
    }
    return null;
  }

  String? _validateMark(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Mark is required';
    final mark = int.tryParse(text);
    if (mark == null) return 'Enter a valid number';
    if (mark < 0 || mark > 100) return 'Mark must be between 0 and 100';
    return null;
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final name = _nameController.text.trim();
    final mark = int.parse(_markController.text.trim());
    context.read<SubjectProvider>().addSubject(name, mark);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Added "$name" — grade ${Subject.gradeForMark(mark)}')),
      );

    _nameController.clear();
    _markController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.school_outlined, size: 56, color: scheme.primary),
        const SizedBox(height: 12),
        Text(
          'Add a subject',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the subject name and the mark out of 100.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('subjectNameField'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Subject name',
                      hintText: 'e.g. Mathematics',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: _validateName,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('subjectMarkField'),
                    controller: _markController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mark',
                      hintText: '0 - 100',
                      prefixIcon: Icon(Icons.star_outline),
                      suffixText: '/ 100',
                    ),
                    validator: _validateMark,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _markController,
                    builder: (context, value, _) {
                      final mark = int.tryParse(value.text);
                      if (mark == null || mark < 0 || mark > 100) {
                        return const SizedBox.shrink();
                      }
                      final grade = Subject.gradeForMark(mark);
                      final color = gradeColor(scheme, grade);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            key: ValueKey(grade),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: color),
                            ),
                            child: Text(
                              'This mark earns a $grade',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('addSubjectButton'),
                    onPressed: _submit,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
