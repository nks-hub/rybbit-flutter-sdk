import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/src/services/session.dart';

void main() {
  group('SessionTracker', () {
    test('tracks current and previous screen', () {
      final tracker = SessionTracker();
      tracker.navigateTo('/home', title: 'Home');
      expect(tracker.currentScreen, '/home');
      expect(tracker.previousScreen, isNull);
      expect(tracker.referrer, '');

      tracker.navigateTo('/settings', title: 'Settings');
      expect(tracker.currentScreen, '/settings');
      expect(tracker.previousScreen, '/home');
      expect(tracker.referrer, '/home');
      expect(tracker.currentTitle, 'Settings');
    });

    test('referrer is empty string when no previous screen', () {
      final tracker = SessionTracker();
      expect(tracker.referrer, '');
    });
  });
}
