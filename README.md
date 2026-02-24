# rybbit_flutter

Flutter SDK for [Rybbit](https://github.com/rybbit-io/rybbit) - open-source, privacy-friendly web analytics. Track screen views, custom events, errors, and user identification from Flutter apps on all platforms.

## Features

- **Screen view tracking** - automatic via `NavigatorObserver` or manual
- **Custom events** - with typed properties
- **Error tracking** - capture errors with stack traces
- **User identification** - `identify()` with traits, backfills 30 days
- **GA4-style typed events** - 23 pre-built methods (e-commerce, auth, engagement, CMS, lead gen)
- **Persistent offline queue** - Hive-backed, survives app restarts
- **App lifecycle tracking** - automatic `app_open`, `app_foreground`, `app_background`
- **Connectivity monitoring** - auto-drains offline queue when back online
- **All platforms** - Android, iOS, macOS, Windows, Linux, Web

## Installation

```yaml
dependencies:
  rybbit_flutter:
    git:
      url: https://github.com/nks-hub/rybbit-flutter.git
      ref: main
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Rybbit.init(
    host: 'https://your-rybbit-instance.com',
    siteId: 'your-site-id',
  );

  runApp(MaterialApp(
    navigatorObservers: [RybbitNavigatorObserver()],
    home: const HomeScreen(),
  ));
}
```

```dart
// Screen view
Rybbit.instance.screenView('/checkout', title: 'Checkout');

// Custom event
Rybbit.instance.event('button_click', properties: {'button': 'cta'});

// Error tracking
Rybbit.instance.trackError(error, stackTrace);

// User identification
Rybbit.instance.identify('user-123', traits: {'plan': 'pro'});
```

## Documentation

- **[API Reference](docs/api.md)** - Complete API documentation for all classes, methods, and configuration options
- **[Examples](docs/examples.md)** - Practical usage examples: setup, navigation, e-commerce, error handling, testing, and more

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0

## Dependencies

[http](https://pub.dev/packages/http) | [device_info_plus](https://pub.dev/packages/device_info_plus) | [package_info_plus](https://pub.dev/packages/package_info_plus) | [connectivity_plus](https://pub.dev/packages/connectivity_plus) | [hive](https://pub.dev/packages/hive) | [path_provider](https://pub.dev/packages/path_provider)

## Related

- [Rybbit](https://github.com/rybbit-io/rybbit) - Open-source web analytics platform
- [@nks-hub/rybbit-ts](https://github.com/nks-hub/rybbit-ts) - TypeScript SDK for web
- [rybbit-app](https://github.com/nks-hub/rybbit-app) - Flutter dashboard for Rybbit

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).
