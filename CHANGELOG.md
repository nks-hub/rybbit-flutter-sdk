## 0.3.0

- Send a stable `anonymous_id` with every event and identify call. Without it
  the server has nothing device-specific to key on and derives `user_id` from a
  hash of IP + user agent, so one phone becomes a new "user" whenever it changes
  network or the app is updated — a single user showed up under four different
  ids in one day. The id is resolved once at `init` (caller-supplied wins, then
  the persisted one, then a fresh UUID v4) and stored next to the identify id,
  so the first lifecycle event already carries it.
- `Rybbit.init(anonymousId: ...)` accepts an id the app already owns, so
  analytics can be keyed on the same device id the app sends to its own backend.
  `setAnonymousId()` covers apps that learn their id after init, and
  `getAnonymousId()` reads it back.

## 0.2.5

- Fix a crash in the host app when the SDK is disposed while a flush is still
  running. The flush timer, the lifecycle observer and the connectivity listener
  start their work without awaiting it, so `dispose()` could close the offline
  box underneath one of them and the write surfaced as an uncatchable
  `HiveError: Box has already been closed.` Everything that touches the offline
  store now runs on one chain that `dispose()` waits for, work queued after
  disposal is skipped, and a failure there is logged instead of reaching the
  host app's zone handler.
- `autoUploadIcon` now defaults to `false`. The upload endpoint requires an
  authenticated site admin, so a shipped app always got a 403 back — the option
  only ever produced a warning in the log. Upload the icon from Site Settings
  instead.

## 0.2.4

- Fix pub.dev version sync with latest changes

## 0.2.3

- Fix `dart:io` import breaking web compilation (conditional imports)
- Fix SDK version constant synced with pubspec (0.2.3)
- Fix offline store data loss: events are now sent before clearing the store
- Add 15s timeout to all HTTP requests
- Replace `print()` with `debugPrint()` in HTTP client
- Close HTTP client on `dispose()`

## 0.2.2

- Add server PR #921 dependency note to README

## 0.2.1

- Add dartdoc comments to public API (20%+ coverage for pub.dev score)
- Widen `connectivity_plus` constraint to support 7.x (`>=6.0.0 <8.0.0`)

## 0.2.0

- **BREAKING**: Package renamed from `rybbit_flutter` to `rybbit_flutter_sdk`
- Auto icon upload — automatically uploads app launcher icon to Rybbit dashboard
- `hasSiteIcon()` and `uploadSiteIcon()` transport methods
- `autoUploadIcon` and `iconAssetPath` configuration options

## 0.1.0

- Initial release
- Core tracking: screenView, event, trackError
- User identification: identify, setTraits, clearUserId
- Persistent offline queue (Hive)
- App lifecycle tracking
- NavigatorObserver for auto screen tracking
- GA4 typed event extensions
- Debug and dry-run modes
- Global properties
