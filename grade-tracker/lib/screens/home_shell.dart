import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../providers/theme_provider.dart';
import 'add_subject_screen.dart';
import 'subject_list_screen.dart';
import 'summary_screen.dart';

/// Root scaffold: an AppBar with the light/dark toggle and a
/// bottom navigation bar switching between the three screens.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _titles = ['Add Subject', 'Subjects', 'Summary'];

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[navigation.index]),
        actions: [
          IconButton(
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle theme',
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: navigation.index,
        children: const [
          AddSubjectScreen(),
          SubjectListScreen(),
          SummaryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigation.index,
        onDestinationSelected: navigation.setIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
