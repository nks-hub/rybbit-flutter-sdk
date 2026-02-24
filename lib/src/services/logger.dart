import 'package:flutter/foundation.dart';

class RybbitLogger {
  RybbitLogger({this.debug = false, this.dryRun = false});
  bool debug;
  bool dryRun;

  void log(String message, [Object? data]) {
    if (debug || dryRun) {
      if (data != null) {
        debugPrint('[Rybbit] $message $data');
      } else {
        debugPrint('[Rybbit] $message');
      }
    }
  }

  void warn(String message, [Object? data]) {
    if (debug) {
      debugPrint('[Rybbit WARN] $message ${data ?? ''}');
    }
  }

  void error(String message, [Object? error]) {
    debugPrint('[Rybbit ERROR] $message ${error ?? ''}');
  }
}
