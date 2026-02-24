# API Reference

Complete API documentation for `rybbit_flutter` SDK.

---

## Rybbit

Main singleton class. All tracking methods are accessed via `Rybbit.instance`.

### Static Methods

#### `Rybbit.init()`

Initializes the SDK. Must be called before any tracking. Calling `init()` multiple times is safe (subsequent calls are no-ops).

```dart
static Future<void> init({
  required String host,
  required String siteId,
  bool debug = false,
  bool dryRun = false,
  bool autoTrackLifecycle = true,
  Map<String, dynamic> globalProperties = const {},
  int maxOfflineEvents = 1000,
  int offlineTtlDays = 7,
  int maxRetries = 3,
  Duration flushInterval = const Duration(seconds: 10),
  int flushThreshold = 20,
  // Testing only:
  RybbitTransport? transport,
  DeviceInfoProvider? deviceInfoProvider,
  OfflineEventStore? offlineStore,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `host` | `String` | **required** | Full URL of your Rybbit instance (e.g. `https://analytics.example.com`) |
| `siteId` | `String` | **required** | Site ID from your Rybbit dashboard |
| `debug` | `bool` | `false` | Enables verbose `[Rybbit]` log output via `debugPrint` |
| `dryRun` | `bool` | `false` | Logs events locally without sending any HTTP requests |
| `autoTrackLifecycle` | `bool` | `true` | Automatically tracks `app_open`, `app_foreground`, `app_background` |
| `globalProperties` | `Map<String, dynamic>` | `{}` | Properties merged into every event |
| `maxOfflineEvents` | `int` | `1000` | Maximum number of events stored in the offline Hive queue |
| `offlineTtlDays` | `int` | `7` | Days after which offline events expire and are discarded |
| `maxRetries` | `int` | `3` | Max retry attempts before an offline event is permanently discarded |
| `flushInterval` | `Duration` | `10 seconds` | How often the in-memory buffer is flushed |
| `flushThreshold` | `int` | `20` | Flush buffer immediately when this many events accumulate |

**Testing-only parameters:**

| Parameter | Type | Description |
|---|---|---|
| `transport` | `RybbitTransport?` | Custom HTTP transport (mock for tests) |
| `deviceInfoProvider` | `DeviceInfoProvider?` | Custom device info provider (mock for tests) |
| `offlineStore` | `OfflineEventStore?` | Custom offline store (mock for tests) |

#### `Rybbit.instance`

Returns the initialized `Rybbit` singleton. Throws `RybbitInitException` if `init()` has not been called.

```dart
static Rybbit get instance
```

#### `Rybbit.isInitialized`

Returns `true` if the SDK is initialized and ready.

```dart
static bool get isInitialized
```

#### `Rybbit.reset()`

Disposes the current instance and resets the singleton. Primarily for testing.

```dart
static Future<void> reset()
```

---

### Instance Properties

#### `state`

Current SDK lifecycle state.

```dart
RybbitState get state
```

**`RybbitState` values:**
- `idle` - Not yet initialized
- `initializing` - Init in progress
- `ready` - Fully operational
- `disposed` - Shut down

---

### Core Tracking

#### `screenView()`

Tracks a screen/page view. Updates the internal session tracker (current screen, referrer).

```dart
void screenView(String pathname, {String? title})
```

| Parameter | Type | Description |
|---|---|---|
| `pathname` | `String` | Screen path (e.g. `/home`, `/settings/profile`) |
| `title` | `String?` | Human-readable screen title |

Sends event type: `pageview`

#### `event()`

Tracks a custom event with optional properties.

```dart
void event(String name, {Map<String, dynamic>? properties})
```

| Parameter | Type | Description |
|---|---|---|
| `name` | `String` | Event name (e.g. `button_click`, `add_to_cart`) |
| `properties` | `Map<String, dynamic>?` | Event properties. JSON-stringified before sending (max 2048 bytes) |

Properties are merged with global properties. Event-level properties override globals.

Sends event type: `custom_event`

#### `trackError()`

Tracks an error with optional stack trace and context.

```dart
void trackError(
  Object error,
  StackTrace? stackTrace, {
  Map<String, dynamic>? context,
})
```

| Parameter | Type | Description |
|---|---|---|
| `error` | `Object` | The error/exception object |
| `stackTrace` | `StackTrace?` | Stack trace (truncated to 2000 chars) |
| `context` | `Map<String, dynamic>?` | Additional context (screen, user action, etc.) |

Error message is truncated to 500 chars, stack trace to 2000 chars. Properties max is 4096 bytes for error events.

Sends event type: `error`

---

### User Identity

#### `identify()`

Identifies the current user. Server-side, this backfills up to 30 days of anonymous events to this user ID.

```dart
void identify(String userId, {Map<String, dynamic>? traits})
```

| Parameter | Type | Description |
|---|---|---|
| `userId` | `String` | Unique user identifier |
| `traits` | `Map<String, dynamic>?` | User traits (plan, email, name, etc.) |

Sends POST to `/api/identify` with `is_new_identify: true`.

#### `setTraits()`

Updates traits for the currently identified user. Requires `identify()` to have been called first.

```dart
void setTraits(Map<String, dynamic> traits)
```

Sends POST to `/api/identify` with `is_new_identify: false`.

#### `clearUserId()`

Clears the current user identity. Subsequent events will be anonymous.

```dart
void clearUserId()
```

#### `getUserId()`

Returns the current user ID, or `null` if not identified.

```dart
String? getUserId()
```

---

### Global Properties

#### `setGlobalProperty()`

Sets a property that will be included in every subsequent event.

```dart
void setGlobalProperty(String key, dynamic value)
```

#### `removeGlobalProperty()`

Removes a global property.

```dart
void removeGlobalProperty(String key)
```

---

### Lifecycle

#### `dispose()`

Shuts down the SDK: cancels timers, flushes buffer, closes offline store, unregisters lifecycle observer.

```dart
Future<void> dispose()
```

---

## RybbitNavigatorObserver

A `NavigatorObserver` that automatically tracks screen views on navigation events.

```dart
class RybbitNavigatorObserver extends NavigatorObserver
```

### Tracked Navigation Events

| Method | Behavior |
|---|---|
| `didPush` | Tracks new route as screen view |
| `didPop` | Tracks the route being returned to |
| `didReplace` | Tracks the new replacement route |

Routes without a name or with an empty name are ignored. Title is extracted from route arguments if it's a `Map<String, dynamic>` with a `title` key, otherwise falls back to the route name.

### Usage

```dart
MaterialApp(
  navigatorObservers: [RybbitNavigatorObserver()],
)
```

---

## RybbitConfig

Immutable configuration class. Created internally by `Rybbit.init()`.

```dart
class RybbitConfig {
  final String host;
  final String siteId;
  final bool debug;
  final bool dryRun;
  final bool autoTrackLifecycle;
  final Map<String, dynamic> globalProperties;
  final int maxOfflineEvents;
  final int offlineTtlDays;
  final int maxRetries;
  final Duration flushInterval;
  final int flushThreshold;
}
```

---

## Models

### EventType

Enum mapping to the 9 Rybbit server event types.

```dart
enum EventType {
  pageview('pageview'),
  customEvent('custom_event'),
  performance('performance'),
  outbound('outbound'),
  error('error'),
  buttonClick('button_click'),
  copy('copy'),
  formSubmit('form_submit'),
  inputChange('input_change');

  const EventType(this.value);
  final String value;
}
```

### TrackPayload

Event payload sent to `POST /api/track`.

```dart
class TrackPayload {
  const TrackPayload({
    required EventType type,
    required String siteId,
    String? hostname,        // App package name (e.g. com.example.app)
    String? pathname,        // Current screen path
    String querystring,      // Default: ''
    int? screenWidth,        // Device screen width in pixels
    int? screenHeight,       // Device screen height in pixels
    String? language,        // Device locale (e.g. 'en-US')
    String? pageTitle,       // Screen title
    String? referrer,        // Previous screen path
    String? userId,          // Identified user ID
    String? userAgent,       // SDK user agent string
    String? eventName,       // For custom_event and error types
    Map<String, dynamic>? properties,  // JSON-stringified in toJson()
    double? lcp,             // Largest Contentful Paint
    double? cls,             // Cumulative Layout Shift
    double? inp,             // Interaction to Next Paint
    double? fcp,             // First Contentful Paint
    double? ttfb,            // Time to First Byte
  });

  Map<String, dynamic> toJson();
  factory TrackPayload.fromJson(Map<String, dynamic> json);
}
```

**JSON output** uses snake_case keys: `site_id`, `page_title`, `user_id`, `user_agent`, `event_name`. The `properties` field is JSON-stringified (string, not object) as required by the Rybbit server.

### IdentifyPayload

Payload sent to `POST /api/identify`.

```dart
class IdentifyPayload {
  const IdentifyPayload({
    required String siteId,
    required String userId,
    Map<String, dynamic>? traits,
    bool isNewIdentify = true,
  });

  Map<String, dynamic> toJson();
}
```

**JSON output:** `site_id`, `user_id`, `is_new_identify`, `traits`.

---

## Interfaces (for Testing)

### RybbitTransport

Abstract HTTP transport interface. Implement for custom transport or mocking.

```dart
abstract class RybbitTransport {
  Future<bool> sendEvent(TrackPayload payload);
  Future<bool> sendIdentify(IdentifyPayload payload);
}
```

### DeviceInfoProvider

Abstract device info provider. Implement for mocking device data in tests.

```dart
abstract class DeviceInfoProvider {
  Future<DeviceData> collect();
}
```

### OfflineEventStore

Abstract offline storage interface. Implement for custom persistence or mocking.

```dart
abstract class OfflineEventStore {
  Future<void> init();
  Future<void> add(TrackPayload payload);
  Future<List<OfflineEvent>> getAll();
  Future<void> remove(int index);
  Future<void> clear();
  Future<int> get count;
  Future<void> close();
}
```

---

## Internal Classes

### DeviceData

Immutable device metadata collected during init.

```dart
class DeviceData {
  final String packageName;   // e.g. 'com.example.app'
  final String appVersion;    // e.g. '1.2.3'
  final String sdkVersion;    // e.g. '0.1.0'
  final String platform;      // 'Android', 'iOS', 'macOS', 'Windows', 'Linux', 'Web'
  final String osVersion;     // e.g. '14', '17.2'
  final String deviceModel;   // e.g. 'Samsung SM-S911B', 'iPhone15,3'
  final int screenWidth;
  final int screenHeight;
  final String language;      // e.g. 'cs-CZ', 'en-US'

  String get userAgent;       // 'RybbitFlutter/0.1.0 (Android 14; Samsung SM-S911B)'
}
```

### RybbitHttpClient

Default HTTP transport implementation. Sends JSON POST to `/api/track` and `/api/identify`.

```dart
class RybbitHttpClient implements RybbitTransport {
  RybbitHttpClient({required String host, http.Client? client});
}
```

### HiveOfflineStore

Default offline storage using Hive. Events are stored as JSON strings.

```dart
class HiveOfflineStore implements OfflineEventStore {
  HiveOfflineStore({
    int maxEvents = 1000,
    int ttlDays = 7,
    int maxRetries = 3,
    String boxName = 'rybbit_offline_events',
  });
}
```

### SessionTracker

Tracks the current and previous screen for referrer resolution.

```dart
class SessionTracker {
  String? get currentScreen;
  String? get previousScreen;
  String? get currentTitle;
  String get referrer;          // previousScreen ?? ''
  void navigateTo(String screen, {String? title});
}
```

### EventQueue

FIFO queue for events received before `init()` completes.

```dart
class EventQueue {
  EventQueue({int maxSize = 100});
  int get size;
  bool get isEmpty;
  void enqueue(TrackPayload payload);
  List<QueuedEvent> drain();
  void clear();
}
```

### RybbitLifecycleObserver

`WidgetsBindingObserver` that maps app lifecycle states to analytics events.

| App State | Event | Flush |
|---|---|---|
| `resumed` | `app_foreground` | No |
| `paused` | `app_background` | Yes |
| `detached` | *(none)* | Yes |

Deduplicates consecutive identical state changes.

---

## GA4 Typed Events

Import: `import 'package:rybbit_flutter/ga4_events.dart';`

Extension `RybbitGA4Events` on `Rybbit` class.

### Authentication

| Method | Event Name | Parameters |
|---|---|---|
| `trackLogin({String? method})` | `login` | `method` |
| `trackSignUp({String? method})` | `sign_up` | `method` |
| `trackLogout()` | `logout` | *(none)* |

### E-commerce

| Method | Event Name | Required | Optional |
|---|---|---|---|
| `trackViewItem()` | `view_item` | `itemId`, `itemName` | `category`, `price` |
| `trackAddToCart()` | `add_to_cart` | `itemId`, `itemName` | `price`, `quantity` |
| `trackRemoveFromCart()` | `remove_from_cart` | `itemId`, `itemName` | |
| `trackViewCart()` | `view_cart` | | `itemsCount`, `value`, `currency` |
| `trackBeginCheckout()` | `begin_checkout` | | `value`, `currency`, `itemsCount` |
| `trackPurchase()` | `purchase` | `transactionId`, `value` | `currency`, `items` |
| `trackRefund()` | `refund` | `transactionId` | `value`, `currency` |
| `trackAddToWishlist()` | `add_to_wishlist` | `itemId`, `itemName` | `price` |
| `trackViewPromotion()` | `view_promotion` | | `promotionId`, `promotionName`, `location` |
| `trackSelectPromotion()` | `select_promotion` | | `promotionId`, `promotionName` |

### Engagement

| Method | Event Name | Required | Optional |
|---|---|---|---|
| `trackSearch()` | `search` | `searchTerm` | `resultsCount` |
| `trackShare()` | `share` | | `method`, `contentType`, `itemId` |
| `trackClickCta()` | `click_cta` | | `button`, `location` |
| `trackVideoPlay()` | `video_play` | | `videoId`, `videoTitle`, `duration` |
| `trackScrollDepth()` | `scroll_depth` | `percent` | `page` |
| `trackFileDownload()` | `file_download` | `fileName` | `fileExtension` |

### CMS

| Method | Event Name | Required | Optional |
|---|---|---|---|
| `trackCommentSubmit()` | `comment_submit` | | `pageId`, `pageTitle` |
| `trackRatingSubmit()` | `rating_submit` | `rating` | `itemId`, `maxRating` |

### Lead Generation

| Method | Event Name | Required | Optional |
|---|---|---|---|
| `trackGenerateLead()` | `generate_lead` | | `source`, `value` |
| `trackContactFormSubmit()` | `contact_form_submit` | | `formId`, `formName` |
| `trackNewsletterSubscribe()` | `newsletter_subscribe` | | `source` |
