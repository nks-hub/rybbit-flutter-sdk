import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter_sdk/src/services/error_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<(Object, StackTrace?)> capturedErrors;
  late RybbitErrorHandler handler;

  setUp(() {
    capturedErrors = [];
    handler = RybbitErrorHandler(
      onError: (error, stackTrace) {
        capturedErrors.add((error, stackTrace));
      },
    );
  });

  tearDown(() {
    handler.uninstall();
  });

  group('RybbitErrorHandler', () {
    test('captures FlutterError.onError', () {
      handler.install();

      final error = FlutterErrorDetails(
        exception: StateError('test flutter error'),
        stack: StackTrace.current,
      );

      // Suppress default handler's console output in tests
      FlutterError.onError!(error);

      expect(capturedErrors, hasLength(1));
      expect(capturedErrors.first.$1, isA<StateError>());
      expect(capturedErrors.first.$1.toString(), contains('test flutter error'));
    });

    test('preserves and forwards to previous FlutterError handler', () {
      var previousCalled = false;
      final previousHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        previousCalled = true;
      };

      handler.install();

      FlutterError.onError!(FlutterErrorDetails(
        exception: StateError('test'),
        stack: StackTrace.current,
      ));

      expect(capturedErrors, hasLength(1));
      expect(previousCalled, isTrue);

      handler.uninstall();
      // Restore
      FlutterError.onError = previousHandler;
    });

    test('uninstall restores previous handlers', () {
      final originalHandler = FlutterError.onError;
      handler.install();

      expect(FlutterError.onError, isNot(equals(originalHandler)));

      handler.uninstall();
      expect(FlutterError.onError, equals(originalHandler));
    });

    test('install is idempotent', () {
      handler.install();
      final handlerAfterFirst = FlutterError.onError;
      handler.install();
      expect(FlutterError.onError, equals(handlerAfterFirst));
    });

    test('uninstall without install is safe', () {
      expect(() => handler.uninstall(), returnsNormally);
    });
  });
}
