# Grade Tracker

A Flutter app where a student can **add subjects with marks**, **see the grade for each subject**, and **view a live result summary**. Built as part of the National App Development Bootcamp (BDApps).

This app lives in the `grade-tracker/` subdirectory of this repository.

## Features

- **3 screens** — Add Subject, Subject List, Summary — switched with a Material 3 `BottomNavigationBar`
- **Light / dark theme toggle** in the AppBar, with a hand-built custom `ThemeData` for each mode (no default themes)
- **Grade computation** — `A` (≥80), `B` (≥65), `C` (≥50), `F` (otherwise)
- **Swipe to delete** subjects with `Dismissible`
- **Live-updating Summary** — total subjects, passing count, average mark, overall grade, and a per-grade breakdown; updates the moment a subject is added or removed
- **Form validation** — subject name is required and the mark must be an integer between 0 and 100
- **All state managed with Provider** — there are **zero `setState` calls** in the app
- **No hardcoded colours** in widget code — every colour comes from `Theme.of(context)` (the seed colours are defined once in `lib/theme/app_theme.dart`)

## Screens

| Screen | What it does |
| --- | --- |
| **Add Subject** | Enter a subject name and a mark out of 100. A live chip previews the grade the mark would earn. Validation blocks empty names and marks outside 0–100. |
| **Subject List** | Every subject in a `ListView.builder` showing name, mark, and grade badge. Swipe a row left to delete it. |
| **Summary** | Total subjects, passing count (C or above), average mark, overall grade, and how many subjects earned each grade. |

## Grading

| Mark | Grade |
| --- | --- |
| ≥ 80 | A |
| ≥ 65 | B |
| ≥ 50 | C |
| < 50 | F |

The same logic (`Subject.gradeForMark`) is used for individual subjects and the summary's overall grade, so they always agree.

## Project structure

```
lib/
├── main.dart                  # MultiProvider + MaterialApp (light/dark themes)
├── models/
│   └── subject.dart           # Subject model — private _mark field + grade getter
├── providers/
│   ├── subject_provider.dart  # List<Subject>, stats (.map / .where)
│   ├── theme_provider.dart    # light/dark toggle
│   └── navigation_provider.dart
├── screens/
│   ├── home_shell.dart        # AppBar + BottomNavigationBar
│   ├── add_subject_screen.dart
│   ├── subject_list_screen.dart
│   └── summary_screen.dart
└── theme/
    └── app_theme.dart         # Custom light & dark ThemeData
```

## Run it

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```sh
flutter pub get     # fetch dependencies
flutter run         # run on a connected device/emulator (or -d chrome)
flutter test        # run the unit + widget tests
```

## Tests

- `test/subject_test.dart` — unit tests for the grade boundaries (A/B/C/F) and the private mark getter
- `test/widget_test.dart` — widget tests for the full flow: adding a subject, seeing it in the list, the live summary (add **and** remove), form validation, swipe-to-delete, and the theme toggle
