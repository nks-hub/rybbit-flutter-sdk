class IdentifyPayload {
  const IdentifyPayload({
    required this.siteId,
    required this.userId,
    this.anonymousId,
    this.traits,
    this.isNewIdentify = true,
  });

  final String siteId;
  final String userId;

  /// Stable per-install id, so the alias links the same device the events carry.
  final String? anonymousId;

  final Map<String, dynamic>? traits;
  final bool isNewIdentify;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'site_id': siteId,
      'user_id': userId,
      'is_new_identify': isNewIdentify,
    };
    if (anonymousId != null) json['anonymous_id'] = anonymousId;
    if (traits != null) json['traits'] = traits;
    return json;
  }
}
