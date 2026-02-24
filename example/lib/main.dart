import 'package:flutter/material.dart';
import 'package:rybbit_flutter/rybbit_flutter.dart';
import 'package:rybbit_flutter/ga4_events.dart';

void main() {
  Rybbit.runApp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Rybbit.init(
      host: 'https://tel.nks-hub.cz',
      siteId: 'YOUR_SITE_ID',
      debug: true,
      autoTrackLifecycle: true,
      autoTrackErrors: true,
    );

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rybbit Flutter Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      navigatorObservers: [RybbitNavigatorObserver()],
      home: const HomeScreen(),
      routes: {
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rybbit Flutter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Rybbit.instance.event('button_click', properties: {
                  'button': 'hero_cta',
                  'location': 'home',
                });
              },
              child: const Text('Track Custom Event'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Rybbit.instance.trackPurchase(
                  transactionId: 'tx-${DateTime.now().millisecondsSinceEpoch}',
                  value: 299.0,
                  currency: 'CZK',
                );
              },
              child: const Text('Track Purchase (GA4)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Rybbit.instance.identify('user-123', traits: {
                  'plan': 'pro',
                  'email': 'test@example.com',
                });
              },
              child: const Text('Identify User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}
