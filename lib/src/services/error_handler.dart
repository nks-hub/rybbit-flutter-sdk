import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Automatic error capture for Flutter/Dart errors.
///
/// Sets up [FlutterError.onError] for framework errors and
/// [PlatformDispatcher.instance.onError] for uncaught async errors.
/// Previous handlers are preserved and called after tracking.
class RybbitErrorHandler {
  RybbitErrorHandler({
    required this.onError,
  });

  /// Callback invoked with (error, stackTrace) for each captured error.
  final void Function(Object error, StackTrace? stackTrace) onError;

  FlutterExceptionHandler? _previousFlutterHandler;
  ErrorCallback? _previousPlatformHandler;
  bool _installed = false;

  /// Install error handlers. Safe to call multiple times.
  void install() {
    if (_installed) return;
    _installed = true;

    // Capture Flutter framework errors (widget build, layout, etc.)
    _previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = _handleFlutterError;

    // Capture uncaught async errors (unhandled Future exceptions, etc.)
    _previousPlatformHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  /// Uninstall error handlers, restoring previous handlers.
  void uninstall() {
    if (!_installed) return;
    _installed = false;

    FlutterError.onError = _previousFlutterHandler;
    PlatformDispatcher.instance.onError = _previousPlatformHandler;
    _previousFlutterHandler = null;
    _previousPlatformHandler = null;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    onError(details.exception, details.stack);
    // Forward to previous handler (default prints to console)
    _previousFlutterHandler?.call(details);
  }

  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    onError(error, stackTrace);
    // Forward to previous handler if present
    if (_previousPlatformHandler != null) {
      return _previousPlatformHandler!(error, stackTrace);
    }
    // Return true = error was handled (prevents app crash in release mode)
    return true;
  }
}
