import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_payload.dart';
import '../models/identify_payload.dart';

abstract class RybbitTransport {
  Future<bool> sendEvent(TrackPayload payload);
  Future<bool> sendIdentify(IdentifyPayload payload);
}

class RybbitHttpClient implements RybbitTransport {
  RybbitHttpClient({
    required this.host,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String host;
  final http.Client _client;

  @override
  Future<bool> sendEvent(TrackPayload payload) async {
    try {
      final response = await _client.post(
        Uri.parse('$host/api/track'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload.toJson()),
      );
      return response.statusCode == 200;
    } catch (_) {
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

  void close() => _client.close();
}
