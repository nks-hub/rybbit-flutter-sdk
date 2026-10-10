import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../models/track_payload.dart';
import '../models/identify_payload.dart';

abstract class RybbitTransport {
  Future<bool> sendEvent(TrackPayload payload);
  Future<bool> sendIdentify(IdentifyPayload payload);
  Future<bool> hasSiteIcon(String siteId);
  Future<bool> uploadSiteIcon(String siteId, String base64Png);
}

class RybbitHttpClient implements RybbitTransport {
  RybbitHttpClient({
    required this.host,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String host;
  final http.Client _client;
  bool debug = false;

  void _log(String msg) {
    if (debug) {
      debugPrint('[Rybbit HTTP] $msg');
    }
  }

  static const _timeout = Duration(seconds: 15);

  /// Set once a server has rejected app_version/device_model, so the rest of
  /// the session skips straight to the payload it accepts.
  bool _serverRejectsNativeFields = false;

  /// Whether this host turned out to run a Rybbit without mobile support.
  bool get serverRejectsNativeFields => _serverRejectsNativeFields;

  Future<http.Response> _postEvent(Map<String, dynamic> json) {
    return _client.post(
      Uri.parse('$host/api/track'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(json),
    ).timeout(_timeout);
  }

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    try {
      final json = payload.toJson();
      final native = TrackPayload.nativeFields.where(json.containsKey).toList();
      if (_serverRejectsNativeFields) {
        json.removeWhere((key, _) => TrackPayload.nativeFields.contains(key));
      }

      var response = await _postEvent(json);

      // Upstream Rybbit validates the payload strictly and answers 400 to a
      // field it does not know, dropping the event. Retry without the mobile
      // fields; if that lands, the server is a plain upstream build and every
      // later event skips them.
      if (response.statusCode == 400 && !_serverRejectsNativeFields && native.isNotEmpty) {
        json.removeWhere((key, _) => TrackPayload.nativeFields.contains(key));
        final retry = await _postEvent(json);
        if (retry.statusCode == 200) {
          _serverRejectsNativeFields = true;
          _log('server does not accept ${native.join(", ")} - sending events without them');
          return true;
        }
        response = retry;
      }

      if (response.statusCode != 200) {
        _log('sendEvent failed: ${response.statusCode} ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      _log('sendEvent error: $e');
      return false;
    }
  }

  @override
  Future<bool> sendIdentify(IdentifyPayload payload) async {
    try {
      final response = await _client.post(
        Uri.parse('$host/api/identify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload.toJson()),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasSiteIcon(String siteId) async {
    try {
      final response = await _client.get(
        Uri.parse('$host/api/sites/$siteId/icon'),
      ).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      _log('hasSiteIcon error: $e');
      return false;
    }
  }

  @override
  Future<bool> uploadSiteIcon(String siteId, String base64Png) async {
    try {
      final response = await _client.put(
        Uri.parse('$host/api/sites/$siteId/icon'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'icon': base64Png}),
      ).timeout(_timeout);
      if (response.statusCode != 200) {
        _log('uploadSiteIcon failed: ${response.statusCode} ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      _log('uploadSiteIcon error: $e');
      return false;
    }
  }

  void close() => _client.close();
}
