## 0.2.5

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
