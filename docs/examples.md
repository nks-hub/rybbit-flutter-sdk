# Examples

Practical usage examples for `rybbit_flutter` SDK.

---

## Basic Setup

### Minimal Initialization

```dart
import 'package:flutter/material.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Rybbit.init(
    host: 'https://analytics.example.com',
    siteId: 'my-app',
  );

  runApp(const MyApp());
}
```

### Full Configuration

```dart
await Rybbit.init(
  host: 'https://analytics.example.com',
  siteId: 'my-app',
  debug: true,                                    // Verbose logging
  autoTrackLifecycle: true,                        // app_open, app_foreground, app_background
  autoTrackErrors: true,                           // Auto capture Flutter/async errors
  globalProperties: {'app_variant': 'beta'},       // Attached to every event
  maxOfflineEvents: 500,                           // Max offline queue size
  offlineTtlDays: 3,                               // Offline events expire in 3 days
  maxRetries: 5,                                   // Retry failed events up to 5 times
  flushInterval: const Duration(seconds: 5),       // Flush buffer every 5 seconds
  flushThreshold: 10,                              // Flush immediately after 10 events
);
```

---

## Auto Screen Tracking with Navigator

### Named Routes

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [RybbitNavigatorObserver()],
      routes: {
        '/': (_) => const HomeScreen(),
        '/products': (_) => const ProductsScreen(),
        '/products/detail': (_) => const ProductDetailScreen(),
        '/cart': (_) => const CartScreen(),
        '/checkout': (_) => const CheckoutScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
```

Every `Navigator.pushNamed(context, '/products')` automatically sends a `pageview` event with `pathname: '/products'`.

### GoRouter Integration

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  observers: [RybbitNavigatorObserver()],
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/products/:id', builder: (_, state) => ProductScreen(id: state.pathParameters['id']!)),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
```

### Manual Screen Tracking (no Navigator)

For apps using custom navigation (bottom tabs, `PageView`, etc.):

```dart
class TabScreen extends StatefulWidget {
  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int _currentIndex = 0;
  final _tabs = ['/home', '/search', '/profile'];
  final _titles = ['Home', 'Search', 'Profile'];

  @override
  void initState() {
    super.initState();
    Rybbit.instance.screenView(_tabs[0], title: _titles[0]);
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    Rybbit.instance.screenView(_tabs[index], title: _titles[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        const HomeTab(),
        const SearchTab(),
        const ProfileTab(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

---

## Custom Events

### Button Tracking

```dart
ElevatedButton(
  onPressed: () {
    Rybbit.instance.event('button_click', properties: {
      'button': 'subscribe',
      'location': 'pricing_page',
      'plan': 'pro',
    });
    // ... actual button logic
  },
  child: const Text('Subscribe'),
)
```

### Form Submission

```dart
void _onFormSubmit() {
  if (_formKey.currentState!.validate()) {
    Rybbit.instance.event('form_submit', properties: {
      'form': 'registration',
      'fields_count': 5,
      'has_avatar': _avatarFile != null,
    });
    // ... submit logic
  }
}
```

### Feature Usage Tracking

```dart
void _toggleDarkMode() {
  setState(() => _isDarkMode = !_isDarkMode);
  Rybbit.instance.event('toggle_setting', properties: {
    'setting': 'dark_mode',
    'value': _isDarkMode,
  });
}
```

---

## Error Tracking

### Automatic Error Tracking (Default)

Error tracking is enabled by default (`autoTrackErrors: true`). The SDK automatically captures:
- Flutter framework errors (`FlutterError.onError`)
- Uncaught async exceptions (`PlatformDispatcher.instance.onError`)

For comprehensive coverage, wrap your app with `Rybbit.runApp()` to also capture zone-level errors:

```dart
void main() {
  Rybbit.runApp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Rybbit.init(
      host: 'https://analytics.example.com',
      siteId: 'my-app',
    );
    runApp(const MyApp());
  });
}
```

### Disabling Automatic Error Tracking

```dart
await Rybbit.init(
  host: 'https://analytics.example.com',
  siteId: 'my-app',
  autoTrackErrors: false,  // Disable automatic capture
);
```

### Try-Catch Error Tracking

```dart
Future<void> _loadData() async {
  try {
    final response = await api.fetchProducts();
    setState(() => _products = response);
  } catch (e, stack) {
    Rybbit.instance.trackError(e, stack, context: {
      'screen': '/products',
      'action': 'load_products',
    });
    // Show error UI...
  }
}
```

### API Error Tracking

```dart
Future<http.Response> apiCall(String endpoint) async {
  final response = await http.get(Uri.parse('$baseUrl$endpoint'));
  if (response.statusCode != 200) {
    Rybbit.instance.event('api_error', properties: {
      'endpoint': endpoint,
      'status_code': response.statusCode,
      'body': response.body.substring(0, 200),
    });
  }
  return response;
}
```

---

## User Identity

### Login Flow

```dart
Future<void> _login(String email, String password) async {
  final user = await authService.login(email, password);

  Rybbit.instance.identify(user.id, traits: {
    'email': user.email,
    'name': user.name,
    'plan': user.subscriptionPlan,
    'created_at': user.createdAt.toIso8601String(),
  });
}
```

### Update Traits After Purchase

```dart
Future<void> _completePurchase(Order order) async {
  await paymentService.charge(order);

  Rybbit.instance.setTraits({
    'plan': 'pro',
    'total_spent': order.total,
    'last_purchase': DateTime.now().toIso8601String(),
  });
}
```

### Logout

```dart
Future<void> _logout() async {
  await authService.logout();
  Rybbit.instance.clearUserId();
}
```

---

## E-commerce (GA4 Events)

### Full Purchase Flow

```dart
import 'package:rybbit_flutter/ga4_events.dart';

// 1. User views product
void _onProductViewed(Product product) {
  Rybbit.instance.trackViewItem(
    itemId: product.sku,
    itemName: product.name,
    category: product.category,
    price: product.price,
  );
}

// 2. User adds to cart
void _onAddToCart(Product product, int qty) {
  Rybbit.instance.trackAddToCart(
    itemId: product.sku,
    itemName: product.name,
    price: product.price,
    quantity: qty,
  );
}

// 3. User views cart
void _onCartViewed(Cart cart) {
  Rybbit.instance.trackViewCart(
    itemsCount: cart.items.length,
    value: cart.total,
    currency: 'USD',
  );
}

// 4. User begins checkout
void _onCheckoutStarted(Cart cart) {
  Rybbit.instance.trackBeginCheckout(
    value: cart.total,
    currency: 'USD',
    itemsCount: cart.items.length,
  );
}

// 5. Purchase completed
void _onPurchaseCompleted(Order order) {
  Rybbit.instance.trackPurchase(
    transactionId: order.id,
    value: order.total,
    currency: 'USD',
    items: order.items.map((item) => {
      'item_id': item.sku,
      'item_name': item.name,
      'quantity': item.quantity,
      'price': item.price,
    }).toList(),
  );
}

// 6. Refund (if needed)
void _onRefund(String orderId, double amount) {
  Rybbit.instance.trackRefund(
    transactionId: orderId,
    value: amount,
    currency: 'USD',
  );
}
```

---

## Global Properties

### A/B Test Variant

```dart
await Rybbit.init(
  host: 'https://analytics.example.com',
  siteId: 'my-app',
  globalProperties: {
    'ab_variant': 'new_onboarding',
    'build_number': '142',
  },
);
```

### Dynamic Properties

```dart
// Set when user selects language
Rybbit.instance.setGlobalProperty('ui_language', 'cs');

// Set when user switches theme
Rybbit.instance.setGlobalProperty('theme', 'dark');

// Remove when no longer relevant
Rybbit.instance.removeGlobalProperty('ab_variant');
```

---

## Testing

### Unit Test with Dry Run

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';

void main() {
  setUp(() async {
    await Rybbit.init(
      host: 'https://test.example.com',
      siteId: 'test',
      dryRun: true,  // No HTTP calls, no Hive
    );
  });

  tearDown(() async {
    await Rybbit.reset();
  });

  test('tracks screen view', () {
    Rybbit.instance.screenView('/home', title: 'Home');
    // In dryRun mode, events are logged but not sent
    expect(Rybbit.isInitialized, true);
  });
}
```

### Mock Transport for Integration Tests

```dart
class MockTransport implements RybbitTransport {
  final events = <Map<String, dynamic>>[];
  final identifies = <Map<String, dynamic>>[];

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    events.add(payload.toJson());
    return true;
  }

  @override
  Future<bool> sendIdentify(IdentifyPayload payload) async {
    identifies.add(payload.toJson());
    return true;
  }
}

class MockDeviceInfo implements DeviceInfoProvider {
  @override
  Future<DeviceData> collect() async => const DeviceData(
    packageName: 'com.test.app',
    appVersion: '1.0.0',
    sdkVersion: '0.1.0',
    platform: 'Test',
    osVersion: '1.0',
    deviceModel: 'TestDevice',
    screenWidth: 1080,
    screenHeight: 2400,
    language: 'en-US',
  );
}

void main() {
  late MockTransport transport;

  setUp(() async {
    transport = MockTransport();
    await Rybbit.init(
      host: 'https://test.example.com',
      siteId: 'test',
      transport: transport,
      deviceInfoProvider: MockDeviceInfo(),
      flushInterval: const Duration(milliseconds: 50),
      flushThreshold: 1,  // Flush after every event
    );
  });

  tearDown(() async => await Rybbit.reset());

  test('event is sent via transport', () async {
    Rybbit.instance.event('test_event', properties: {'key': 'value'});
    await Future.delayed(const Duration(milliseconds: 100));
    expect(transport.events.length, 1);
    expect(transport.events.first['event_name'], 'test_event');
  });
}
```

---

## Advanced Patterns

### Conditional Tracking (GDPR Consent)

```dart
bool _analyticsConsent = false;

Future<void> _initAnalytics() async {
  if (!_analyticsConsent) return;

  await Rybbit.init(
    host: 'https://analytics.example.com',
    siteId: 'my-app',
  );
}

// When user grants consent
void _onConsentGranted() {
  _analyticsConsent = true;
  _initAnalytics();
}

// When user revokes consent
void _onConsentRevoked() async {
  _analyticsConsent = false;
  if (Rybbit.isInitialized) {
    await Rybbit.reset();
  }
}
```

### Wrapper for Safe Tracking

```dart
class Analytics {
  static void screen(String path, {String? title}) {
    if (Rybbit.isInitialized) {
      Rybbit.instance.screenView(path, title: title);
    }
  }

  static void event(String name, {Map<String, dynamic>? properties}) {
    if (Rybbit.isInitialized) {
      Rybbit.instance.event(name, properties: properties);
    }
  }

  static void error(Object error, StackTrace? stack) {
    if (Rybbit.isInitialized) {
      Rybbit.instance.trackError(error, stack);
    }
  }
}

// Usage:
Analytics.screen('/home');
Analytics.event('click', properties: {'button': 'cta'});
```

### Debug Mode for Development

```dart
import 'package:flutter/foundation.dart';

await Rybbit.init(
  host: 'https://analytics.example.com',
  siteId: 'my-app',
  debug: kDebugMode,     // Verbose logs only in debug builds
  dryRun: kDebugMode,    // Don't send events in debug builds
);
```
