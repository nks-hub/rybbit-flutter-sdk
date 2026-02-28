import 'package:flutter/widgets.dart';
import 'rybbit.dart';

/// Navigator observer that automatically tracks screen views on route changes.
///
/// Add to [MaterialApp.navigatorObservers] for automatic screen tracking:
/// ```dart
/// MaterialApp(navigatorObservers: [RybbitNavigatorObserver()]);
/// ```
class RybbitNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty && Rybbit.isInitialized) {
      Rybbit.instance.screenView(
        name,
        title: _extractTitle(route),
      );
    }
  }

  String? _extractTitle(Route<dynamic> route) {
    final args = route.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('title')) {
      return args['title'] as String?;
    }
    return route.settings.name;
  }
}
