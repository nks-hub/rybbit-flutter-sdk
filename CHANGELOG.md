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
