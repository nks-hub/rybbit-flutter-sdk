import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'http_client.dart';
import 'logger.dart';

const int _iconSize = 128;

class IconUploader {
  IconUploader({
    required RybbitTransport transport,
    required RybbitLogger logger,
    required String siteId,
    this.iconAssetPath,
  })  : _transport = transport,
        _logger = logger,
        _siteId = siteId;

  final RybbitTransport _transport;
  final RybbitLogger _logger;
  final String _siteId;
  final String? iconAssetPath;

  /// Check if the site already has an icon; if not, load the app's
  /// launcher icon, resize to 128x128 PNG, and upload it.
  Future<void> uploadIfMissing() async {
    try {
      final hasIcon = await _transport.hasSiteIcon(_siteId);
      if (hasIcon) {
        _logger.log('Site already has an icon, skipping upload');
        return;
      }

      _logger.log('No site icon found, attempting auto-upload');
      final pngBytes = await _loadAndResizeIcon();
      if (pngBytes == null) {
        _logger.warn('Could not load launcher icon');
        return;
      }

      final base64 = base64Encode(pngBytes);
      final ok = await _transport.uploadSiteIcon(_siteId, base64);
      if (ok) {
        _logger.log('Site icon uploaded successfully');
      } else {
        _logger.warn('Site icon upload failed');
      }
    } catch (e) {
      _logger.warn('Auto icon upload error: $e');
    }
  }

  Future<Uint8List?> _loadAndResizeIcon() async {
    try {
      final bytes = await _loadIconBytes();
      if (bytes == null) return null;
      return _resizeToPng(bytes);
    } catch (e) {
      _logger.warn('Icon load/resize error: $e');
      return null;
    }
  }

  Future<Uint8List?> _loadIconBytes() async {
    if (iconAssetPath != null) {
      final data = await rootBundle.load(iconAssetPath!);
      return data.buffer.asUint8List();
    }

    // Try common Flutter launcher icon paths
    const paths = [
      'assets/icon/icon.png',
      'assets/icons/icon.png',
      'assets/icon.png',
      'assets/launcher_icon.png',
      'assets/images/icon.png',
    ];

    for (final path in paths) {
      try {
        final data = await rootBundle.load(path);
        return data.buffer.asUint8List();
      } catch (_) {
        // Try next path
      }
    }

    _logger.warn(
      'No launcher icon found in common paths. '
      'Set iconAssetPath in Rybbit.init() to specify a custom path.',
    );
    return null;
  }

  Future<Uint8List> _resizeToPng(Uint8List sourceBytes) async {
    final codec = await ui.instantiateImageCodec(
      sourceBytes,
      targetWidth: _iconSize,
      targetHeight: _iconSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();

    return byteData!.buffer.asUint8List();
  }
}
