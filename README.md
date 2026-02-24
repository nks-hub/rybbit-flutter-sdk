# rybbit_flutter

Flutter SDK for [Rybbit](https://github.com/rybbit-io/rybbit) - open-source, privacy-friendly web analytics. Track screen views, custom events, errors, and user identification from Flutter apps on all platforms.

## Features

- **Screen view tracking** - automatic via `NavigatorObserver` or manual
- **Custom events** - with typed properties (JSON-stringified, max 2048 bytes)
- **Error tracking** - capture errors with stack traces
- **User identification** - `identify()` with traits, backfills 30 days of events
- **GA4-style typed events** - 23 pre-built methods (e-commerce, auth, engagement, CMS, lead gen)
- **Persistent offline queue** - Hive-backed, survives app restarts (max 1000 events, 7-day TTL)
- **App lifecycle tracking** - automatic `app_open`, `app_foreground`, `app_background`
- **Connectivity monitoring** - auto-drains offline queue when connection is restored
- **In-memory buffer** - batches events (20 threshold / 10s flush interval)
- **Global properties** - attach metadata to every event
- **Debug & dry-run modes** - verbose logging without sending data
- **All platforms** - Android, iOS, macOS, Windows, Linux, Web

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  rybbit_flutter:
    git:
      url: https://github.com/nks-hub/rybbit-flutter.git
      ref: main
```

Then run:

```bash
flutter pub get
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

  runApp(const MyApp());
}
```

### Automatic Screen Tracking

Add `RybbitNavigatorObserver` to your `MaterialApp`:

```dart
MaterialApp(
  navigatorObservers: [RybbitNavigatorObserver()],
  // ...
);
```

Every `Navigator.push`, `pop`, and `replace` is automatically tracked as a screen view.

### Manual Screen View

```dart
Rybbit.instance.screenView('/checkout', title: 'Checkout');
```

### Custom Events

```dart
Rybbit.instance.event('button_click', properties: {
  'button': 'hero_cta',
  'location': 'home_screen',
});
```

### Error Tracking

```dart
try {
  // ...
} catch (e, stackTrace) {
  Rybbit.instance.trackError(e, stackTrace, context: {
    'screen': '/payment',
    'user_action': 'submit_order',
  });
}
```

### User Identification

```dart
// Identify user (backfills 30 days of events)
Rybbit.instance.identify('user-123', traits: {
  'plan': 'pro',
  'email': 'user@example.com',
});

// Update traits
Rybbit.instance.setTraits({'plan': 'enterprise'});

// Clear identity
Rybbit.instance.clearUserId();
```

### Global Properties

Attach metadata to every event:

```dart
Rybbit.instance.setGlobalProperty('app_variant', 'beta');
Rybbit.instance.removeGlobalProperty('app_variant');
```

## GA4 Typed Events

Import the GA4 extension for 23 pre-built typed event methods:

```dart
import 'package:rybbit_flutter/ga4_events.dart';
```

### Authentication

```dart
Rybbit.instance.trackLogin(method: 'google');
Rybbit.instance.trackSignUp(method: 'email');
Rybbit.instance.trackLogout();
```

### E-commerce

```dart
Rybbit.instance.trackViewItem(itemId: 'SKU-001', itemName: 'T-Shirt', price: 29.99);
Rybbit.instance.trackAddToCart(itemId: 'SKU-001', itemName: 'T-Shirt', quantity: 2);
Rybbit.instance.trackRemoveFromCart(itemId: 'SKU-001', itemName: 'T-Shirt');
Rybbit.instance.trackViewCart(itemsCount: 3, value: 89.97, currency: 'USD');
Rybbit.instance.trackBeginCheckout(value: 89.97, currency: 'USD');
Rybbit.instance.trackPurchase(
  transactionId: 'TX-12345',
  value: 89.97,
  currency: 'USD',
  items: [
    {'item_id': 'SKU-001', 'item_name': 'T-Shirt', 'quantity': 2},
  ],
);
Rybbit.instance.trackRefund(transactionId: 'TX-12345', value: 29.99);
Rybbit.instance.trackAddToWishlist(itemId: 'SKU-001', itemName: 'T-Shirt');
Rybbit.instance.trackViewPromotion(promotionId: 'SUMMER24', promotionName: 'Summer Sale');
Rybbit.instance.trackSelectPromotion(promotionId: 'SUMMER24');
```

### Engagement

```dart
Rybbit.instance.trackSearch(searchTerm: 'flutter sdk', resultsCount: 42);
Rybbit.instance.trackShare(method: 'twitter', contentType: 'article', itemId: 'post-1');
Rybbit.instance.trackClickCta(button: 'upgrade', location: 'pricing_page');
Rybbit.instance.trackVideoPlay(videoId: 'vid-1', videoTitle: 'Getting Started');
Rybbit.instance.trackScrollDepth(percent: 75, page: '/blog/post-1');
Rybbit.instance.trackFileDownload(fileName: 'report.pdf', fileExtension: 'pdf');
```

### CMS & Lead Generation

```dart
Rybbit.instance.trackCommentSubmit(pageId: 'post-1');
Rybbit.instance.trackRatingSubmit(rating: 4.5, itemId: 'product-1', maxRating: 5);
Rybbit.instance.trackGenerateLead(source: 'landing_page', value: 100.0);
Rybbit.instance.trackContactFormSubmit(formId: 'contact', formName: 'Contact Us');
Rybbit.instance.trackNewsletterSubscribe(source: 'footer');
```

## Configuration

All configuration options for `Rybbit.init()`:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `host` | `String` | **required** | Rybbit instance URL |
| `siteId` | `String` | **required** | Site ID from Rybbit dashboard |
| `debug` | `bool` | `false` | Enable verbose logging |
| `dryRun` | `bool` | `false` | Log events without sending |
| `autoTrackLifecycle` | `bool` | `true` | Track app_open/foreground/background |
| `globalProperties` | `Map` | `{}` | Properties attached to every event |
| `maxOfflineEvents` | `int` | `1000` | Max events in offline queue |
| `offlineTtlDays` | `int` | `7` | Days before offline events expire |
| `maxRetries` | `int` | `3` | Max retry attempts per event |
| `flushInterval` | `Duration` | `10s` | Buffer flush interval |
| `flushThreshold` | `int` | `20` | Flush buffer when this many events |

## Event Types

The SDK supports all 9 Rybbit event types:

| Type | Description |
|---|---|
| `pageview` | Screen/page view (used by `screenView()`) |
| `custom_event` | Custom event (used by `event()`) |
| `error` | Error tracking (used by `trackError()`) |
| `performance` | Web Vitals metrics (LCP, CLS, INP, FCP, TTFB) |
| `outbound` | Outbound link click |
| `button_click` | Button click |
| `copy` | Text copy |
| `form_submit` | Form submission |
| `input_change` | Input field change |

## Architecture

```
Rybbit (singleton)
  ├── RybbitConfig           - SDK configuration
  ├── RybbitHttpClient       - HTTP transport (POST /api/track, /api/identify)
  ├── DeviceInfoService      - Device metadata (platform, screen, language)
  ├── SessionTracker         - Current/previous screen, referrer
  ├── EventQueue             - Pre-init queue (max 100, replayed on ready)
  ├── HiveOfflineStore       - Persistent offline storage
  ├── RybbitLifecycleObserver - App lifecycle (WidgetsBindingObserver)
  └── RybbitLogger           - Debug/dry-run logging
```

### Offline Behavior

1. Events are buffered in memory (max 20 / 10s flush)
2. On flush, events are sent via HTTP POST to `/api/track`
3. Failed events move to Hive offline store
4. When connectivity is restored, offline events are drained and retried
5. Events expire after 7 days or 3 failed retries

### Pre-init Queue

Events tracked before `Rybbit.init()` completes are queued (max 100) and automatically replayed once the SDK is ready.

## Testing

The SDK uses dependency injection for testability:

```dart
await Rybbit.init(
  host: 'https://test.example.com',
  siteId: 'test',
  dryRun: true,  // No HTTP calls
  transport: MockTransport(),
  deviceInfoProvider: MockDeviceInfo(),
  offlineStore: MockOfflineStore(),
);
```

Run tests:

```bash
flutter test
```

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0

## Dependencies

- [http](https://pub.dev/packages/http) - HTTP client
- [device_info_plus](https://pub.dev/packages/device_info_plus) - Device metadata
- [package_info_plus](https://pub.dev/packages/package_info_plus) - App version info
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - Network state
- [hive](https://pub.dev/packages/hive) - Persistent offline storage
- [path_provider](https://pub.dev/packages/path_provider) - App directories

## Related

- [Rybbit](https://github.com/rybbit-io/rybbit) - Open-source web analytics platform
- [@nks-hub/rybbit-ts](https://github.com/nks-hub/rybbit-ts) - TypeScript SDK for web
- [rybbit-app](https://github.com/nks-hub/rybbit-app) - Flutter dashboard for Rybbit

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
