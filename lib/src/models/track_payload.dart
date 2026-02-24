import 'dart:convert';
import 'event_type.dart';

class TrackPayload {
  const TrackPayload({
    required this.type,
    required this.siteId,
    this.hostname,
    this.pathname,
    this.querystring = '',
    this.screenWidth,
    this.screenHeight,
    this.language,
    this.pageTitle,
    this.referrer,
    this.userId,
    this.userAgent,
    this.eventName,
    this.properties,
    this.lcp,
    this.cls,
    this.inp,
    this.fcp,
    this.ttfb,
    this.appVersion,
    this.deviceModel,
  });

  final EventType type;
  final String siteId;
  final String? hostname;
  final String? pathname;
  final String querystring;
  final int? screenWidth;
  final int? screenHeight;
  final String? language;
  final String? pageTitle;
  final String? referrer;
  final String? userId;
  final String? userAgent;
  final String? eventName;
  final Map<String, dynamic>? properties;
  final double? lcp;
  final double? cls;
  final double? inp;
  final double? fcp;
  final double? ttfb;
  final String? appVersion;
  final String? deviceModel;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type.value,
      'site_id': siteId,
    };
    if (hostname != null) json['hostname'] = hostname;
    if (pathname != null) json['pathname'] = pathname;
    if (querystring.isNotEmpty) json['querystring'] = querystring;
    if (screenWidth != null) json['screenWidth'] = screenWidth;
    if (screenHeight != null) json['screenHeight'] = screenHeight;
    if (language != null) json['language'] = language;
    if (pageTitle != null) json['page_title'] = pageTitle;
    if (referrer != null) json['referrer'] = referrer;
    if (userId != null) json['user_id'] = userId;
    if (userAgent != null) json['user_agent'] = userAgent;
    if (eventName != null) json['event_name'] = eventName;
    if (properties != null) json['properties'] = jsonEncode(properties);
    if (lcp != null) json['lcp'] = lcp;
    if (cls != null) json['cls'] = cls;
    if (inp != null) json['inp'] = inp;
    if (fcp != null) json['fcp'] = fcp;
    if (ttfb != null) json['ttfb'] = ttfb;
    if (appVersion != null) json['app_version'] = appVersion;
    if (deviceModel != null) json['device_model'] = deviceModel;
    return json;
  }

  factory TrackPayload.fromJson(Map<String, dynamic> json) {
    return TrackPayload(
      type: EventType.values.firstWhere((e) => e.value == json['type']),
      siteId: json['site_id'] as String,
      hostname: json['hostname'] as String?,
      pathname: json['pathname'] as String?,
      querystring: json['querystring'] as String? ?? '',
      screenWidth: json['screenWidth'] as int?,
      screenHeight: json['screenHeight'] as int?,
      language: json['language'] as String?,
      pageTitle: json['page_title'] as String?,
      referrer: json['referrer'] as String?,
      userId: json['user_id'] as String?,
      userAgent: json['user_agent'] as String?,
      eventName: json['event_name'] as String?,
      properties: json['properties'] != null
          ? (json['properties'] is String
              ? jsonDecode(json['properties'] as String)
                  as Map<String, dynamic>
              : json['properties'] as Map<String, dynamic>)
          : null,
      lcp: (json['lcp'] as num?)?.toDouble(),
      cls: (json['cls'] as num?)?.toDouble(),
      inp: (json['inp'] as num?)?.toDouble(),
      fcp: (json['fcp'] as num?)?.toDouble(),
      ttfb: (json['ttfb'] as num?)?.toDouble(),
      appVersion: json['app_version'] as String?,
      deviceModel: json['device_model'] as String?,
    );
  }
}
