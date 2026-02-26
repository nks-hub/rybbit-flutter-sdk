import 'dart:convert';
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
      // ignore: avoid_print
      print('[Rybbit HTTP] $msg');
    }
  }

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    try {
      final response = await _client.post(
        Uri.parse('$host/api/track'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload.toJson()),
      );
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
      );
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
      );
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
      );
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
