import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/src/services/lifecycle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RybbitLifecycleObserver', () {
    test('fires app_foreground on resumed', () {
      final events = <String>[];
      var flushCount = 0;
      final observer = RybbitLifecycleObserver(
        onLifecycleEvent: events.add,
        onFlushRequested: () => flushCount++,
      );
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(events, ['app_foreground']);
      expect(flushCount, 0);
    });

    test('fires app_background and flush on paused', () {
      final events = <String>[];
      var flushCount = 0;
      final observer = RybbitLifecycleObserver(
        onLifecycleEvent: events.add,
        onFlushRequested: () => flushCount++,
      );
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(events, ['app_background']);
      expect(flushCount, 1);
    });

    test('fires flush only on detached', () {
      final events = <String>[];
      var flushCount = 0;
      final observer = RybbitLifecycleObserver(
        onLifecycleEvent: events.add,
        onFlushRequested: () => flushCount++,
      );
      observer.didChangeAppLifecycleState(AppLifecycleState.detached);
      expect(events, isEmpty);
      expect(flushCount, 1);
    });

    test('ignores duplicate state changes', () {
      final events = <String>[];
      final observer = RybbitLifecycleObserver(
        onLifecycleEvent: events.add,
        onFlushRequested: () {},
      );
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(events, ['app_foreground']);
    });
  });
}
