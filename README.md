# Rybbit Flutter SDK

[![pub.dev](https://img.shields.io/pub/v/rybbit_flutter_sdk.svg)](https://pub.dev/packages/rybbit_flutter_sdk)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?logo=android&logoColor=white)](#requirements)
[![iOS](https://img.shields.io/badge/iOS-12+-000000?logo=apple&logoColor=white)](#requirements)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

> Flutter SDK for [Rybbit](https://github.com/rybbit-io/rybbit), the open-source web analytics. It tracks screen views, custom events, errors and user identity from Flutter apps on Android, iOS, macOS, Windows, Linux and Web.

## Features

- 📱 **Screen view tracking** - Through `NavigatorObserver` or by calling `screenView()`
- 🎯 **Custom events** - With typed properties
- 🐛 **Automatic error tracking** - Captures Flutter framework errors, async exceptions, and zone errors
- 🧾 **Manual error tracking** - `trackError()` with stack traces and context
- 👤 **User identification** - `identify()` with traits, backfills 30 days
- 🔑 **Stable device id** - One `anonymous_id` per install, so a changing IP or an app update doesn't split one device into several users
- 🛒 **GA4-style typed events** - 23 methods (e-commerce, auth, engagement, CMS, lead gen)
- 💾 **Persistent offline queue** - Stored in Hive, kept across app restarts
- 🔄 **App lifecycle tracking** - Sends `app_open`, `app_foreground`, `app_background`
- 📶 **Connectivity monitoring** - Sends the offline queue when the device is back online
- 🖼️ **App icon upload** - Uploads the app icon to the Rybbit dashboard (`autoUploadIcon`, off by default)
- 🌍 **Platforms** - Android, iOS, macOS, Windows, Linux, Web

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0
- Rybbit server with [PR #921](https://github.com/rybbit-io/rybbit/pull/921) merged (adds `identified_user_id` and traits to funnel step sessions)

Dependencies: [http](https://pub.dev/packages/http) | [device_info_plus](https://pub.dev/packages/device_info_plus) | [package_info_plus](https://pub.dev/packages/package_info_plus) | [connectivity_plus](https://pub.dev/packages/connectivity_plus) | [hive](https://pub.dev/packages/hive) | [path_provider](https://pub.dev/packages/path_provider)

## Installation

### From pub.dev

```yaml
dependencies:
  rybbit_flutter_sdk: ^0.3.0
```

### From Git

```yaml
dependencies:
  rybbit_flutter_sdk:
    git:
      url: https://github.com/nks-hub/rybbit-flutter-sdk.git
      ref: main
```

## Usage

### Quick start

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

### Device identity

Every event carries an `anonymous_id`. The server hashes it into `user_id`
instead of falling back to a hash of IP + user agent, which on mobile changes
with every network switch and app update and turns one phone into several
"users".

The SDK generates and stores a UUID on first run. When the app already has its
own id, such as a device hash it sends to its backend or an install UUID, pass
it in and analytics uses the same identifier as your records:

```dart
await Rybbit.init(
  host: 'https://analytics.example.com',
  siteId: 'my-site',
  anonymousId: myDeviceHash,
);

// or later, if the id isn't known at init
Rybbit.instance.setAnonymousId(myDeviceHash);
```

The id survives restarts, but not a reinstall.

## Documentation

- **[API reference](doc/api.md)** - Classes, methods and configuration options
- **[Examples](doc/examples.md)** - Setup, navigation, e-commerce, error handling, testing
- **[Changelog](CHANGELOG.md)**

## Related projects

- [Rybbit](https://github.com/rybbit-io/rybbit) - Open-source web analytics platform
- [@nks-hub/rybbit-ts](https://github.com/nks-hub/rybbit-ts) - TypeScript SDK for web
- [rybbit-app](https://github.com/nks-hub/rybbit-app) - Flutter dashboard for Rybbit
- [@nks-hub/rybbit-mcp](https://github.com/nks-hub/rybbit-mcp) - MCP server for querying Rybbit from AI assistants

## Testing

```bash
flutter pub get
flutter analyze
flutter test
```

## Contributing

Contributions are welcome! For major changes, please open an issue first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: description'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

- 📧 **Email:** dev@nks-hub.cz
- 🐛 **Bug reports:** [GitHub Issues](https://github.com/nks-hub/rybbit-flutter-sdk/issues)

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/nks-hub">NKS Hub</a>
</p>
