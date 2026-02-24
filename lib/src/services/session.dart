class SessionTracker {
  String? _currentScreen;
  String? _previousScreen;
  String? _currentTitle;

  String? get currentScreen => _currentScreen;
  String? get previousScreen => _previousScreen;
  String? get currentTitle => _currentTitle;

  void navigateTo(String screen, {String? title}) {
    _previousScreen = _currentScreen;
    _currentScreen = screen;
    _currentTitle = title;
  }

  String get referrer => _previousScreen ?? '';
}
