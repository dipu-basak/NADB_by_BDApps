import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grade_tracker/main.dart';

void main() {
  testWidgets('adding a subject shows it in the list and the summary',
      (tester) async {
    await tester.pumpWidget(const GradeTrackerApp());

    // The Add Subject tab is selected by default.
    await tester.enterText(
      find.byKey(const Key('subjectNameField')),
      'Mathematics',
    );
    await tester.enterText(find.byKey(const Key('subjectMarkField')), '92');
    await tester.tap(find.byKey(const Key('addSubjectButton')));
    await tester.pumpAndSettle();

    // Subject List tab shows the new subject with its mark and grade.
    await tester.tap(find.text('Subjects'));
    await tester.pumpAndSettle();
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Mark: 92 / 100'), findsOneWidget);
    expect(find.text('A'), findsWidgets);

    // Summary tab updates live with totals and the average.
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('92 / 100'), findsWidgets); // average mark
    expect(find.text('1'), findsWidgets); // total subjects + breakdown

    // Let the confirmation SnackBar timer expire.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('swiping a subject away deletes it', (tester) async {
    await tester.pumpWidget(const GradeTrackerApp());

    await tester.enterText(find.byKey(const Key('subjectNameField')), 'Physics');
    await tester.enterText(find.byKey(const Key('subjectMarkField')), '58');
    await tester.tap(find.byKey(const Key('addSubjectButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Subjects'));
    await tester.pumpAndSettle();
    expect(find.text('Physics'), findsOneWidget);

    // The list item's Dismissible — note SnackBars also contain an internal
    // Dismissible, so scope the finder to the list itself.
    final listItem = find.descendant(
      of: find.byKey(const Key('subjectList')),
      matching: find.byType(Dismissible),
    );
    await tester.drag(listItem, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsNothing);

    // The Summary must update live when a subject is removed too.
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsWidgets); // total subjects + breakdown

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the form rejects an empty name and an out-of-range mark',
      (tester) async {
    await tester.pumpWidget(const GradeTrackerApp());

    await tester.enterText(find.byKey(const Key('subjectMarkField')), '101');
    await tester.tap(find.byKey(const Key('addSubjectButton')));
    await tester.pumpAndSettle();

    expect(find.text('Subject name is required'), findsOneWidget);
    expect(find.text('Mark must be between 0 and 100'), findsOneWidget);
  });

  testWidgets('the AppBar toggle switches between light and dark mode',
      (tester) async {
    await tester.pumpWidget(const GradeTrackerApp());

    MaterialApp app() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });
}
