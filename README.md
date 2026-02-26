<h1 align="center">rybbit_flutter_sdk</h1>

<p align="center">
  Flutter SDK for <a href="https://github.com/rybbit-io/rybbit">Rybbit</a> — open-source, privacy-friendly web analytics.
</p>

<p align="center">
  <a href="https://pub.dev/packages/rybbit_flutter_sdk"><img src="https://img.shields.io/pub/v/rybbit_flutter_sdk?color=22c55e" alt="pub.dev"></a>
  <a href="https://github.com/nks-hub/rybbit-flutter-sdk/stargazers"><img src="https://img.shields.io/github/stars/nks-hub/rybbit-flutter-sdk?style=flat&color=22c55e" alt="Stars"></a>
  <a href="https://github.com/nks-hub/rybbit-flutter-sdk/network/members"><img src="https://img.shields.io/github/forks/nks-hub/rybbit-flutter-sdk?style=flat&color=3b82f6" alt="Forks"></a>
  <a href="https://github.com/nks-hub/rybbit-flutter-sdk/issues"><img src="https://img.shields.io/github/issues/nks-hub/rybbit-flutter-sdk?style=flat&color=f59e0b" alt="Issues"></a>
  <a href="https://github.com/nks-hub/rybbit-flutter-sdk/blob/main/LICENSE"><img src="https://img.shields.io/github/license/nks-hub/rybbit-flutter-sdk?style=flat&color=64748b" alt="License"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Android-5.0+-3DDC84?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/iOS-12+-000000?logo=apple&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/offline--first-Hive-orange" alt="Offline-first">
</p>

---

Track screen views, custom events, errors, and user identification from Flutter apps on all platforms.

## Features

- **Screen view tracking** - automatic via `NavigatorObserver` or manual
- **Custom events** - with typed properties
- **Automatic error tracking** - captures Flutter framework errors, async exceptions, and zone errors
- **Manual error tracking** - `trackError()` with stack traces and context
- **User identification** - `identify()` with traits, backfills 30 days
- **GA4-style typed events** - 23 pre-built methods (e-commerce, auth, engagement, CMS, lead gen)
- **Persistent offline queue** - Hive-backed, survives app restarts
- **App lifecycle tracking** - automatic `app_open`, `app_foreground`, `app_background`
- **Connectivity monitoring** - auto-drains offline queue when back online
- **Auto icon upload** - automatically uploads app icon to Rybbit dashboard
- **All platforms** - Android, iOS, macOS, Windows, Linux, Web

## Installation

### From pub.dev

```yaml
dependencies:
  rybbit_flutter_sdk: ^0.2.0
```

### From Git

```yaml
dependencies:
  rybbit_flutter_sdk:
    git:
      url: https://github.com/nks-hub/rybbit-flutter-sdk.git
      ref: main
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:rybbit_flutter_sdk/rybbit_flutter_sdk.dart';

void main() {
  Rybbit.runApp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Rybbit.init(
      host: 'https://your-rybbit-instance.com',
      siteId: 'your-site-id',
    );

    runApp(MaterialApp(
      navigatorObservers: [RybbitNavigatorObserver()],
      home: const HomeScreen(),
    ));
  });
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

- **[API Reference](doc/api.md)** - Complete API documentation for all classes, methods, and configuration options
- **[Examples](doc/examples.md)** - Practical usage examples: setup, navigation, e-commerce, error handling, testing, and more

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0

## Dependencies

[http](https://pub.dev/packages/http) | [device_info_plus](https://pub.dev/packages/device_info_plus) | [package_info_plus](https://pub.dev/packages/package_info_plus) | [connectivity_plus](https://pub.dev/packages/connectivity_plus) | [hive](https://pub.dev/packages/hive) | [path_provider](https://pub.dev/packages/path_provider)

## Related

- [Rybbit](https://github.com/rybbit-io/rybbit) - Open-source web analytics platform
- [@nks-hub/rybbit-ts](https://github.com/nks-hub/rybbit-ts) - TypeScript SDK for web
- [rybbit-app](https://github.com/nks-hub/rybbit-app) - Flutter dashboard for Rybbit

## Contributing

Contributions welcome! Please open an issue or pull request.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

---

<p align="center">
  Developed by <a href="https://nks-hub.cz">NKS Hub</a> | <a href="mailto:dev@nks-hub.cz">dev@nks-hub.cz</a>
</p>

<p align="center">
  <a href="https://github.com/nks-hub/rybbit-flutter-sdk">
    <img src="https://img.shields.io/badge/Give_a-⭐-yellow?style=for-the-badge" alt="Star this repo">
  </a>
</p>
