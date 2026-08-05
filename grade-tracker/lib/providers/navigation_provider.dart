import 'package:flutter/foundation.dart';

/// Tracks the currently selected tab of the bottom navigation bar so the
/// active index is managed by Provider rather than local state.
class NavigationProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}
