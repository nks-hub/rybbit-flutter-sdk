import 'package:flutter/widgets.dart';

typedef LifecycleCallback = void Function(String eventName);

class RybbitLifecycleObserver with WidgetsBindingObserver {
  RybbitLifecycleObserver({
    required this.onLifecycleEvent,
    required this.onFlushRequested,
  });

  final LifecycleCallback onLifecycleEvent;
  final VoidCallback onFlushRequested;
  bool _isRegistered = false;
  AppLifecycleState? _lastState;

  void register() {
    if (!_isRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _isRegistered = true;
    }
  }

  void unregister() {
    if (_isRegistered) {
      WidgetsBinding.instance.removeObserver(this);
      _isRegistered = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == _lastState) return;
    _lastState = state;
    switch (state) {
      case AppLifecycleState.resumed:
        onLifecycleEvent('app_foreground');
      case AppLifecycleState.paused:
        onLifecycleEvent('app_background');
        onFlushRequested();
      case AppLifecycleState.detached:
        onFlushRequested();
      default:
        break;
    }
  }
}
