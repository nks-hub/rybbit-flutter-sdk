class IdentifyPayload {
  const IdentifyPayload({
    required this.siteId,
    required this.userId,
    this.traits,
    this.isNewIdentify = true,
  });

  final String siteId;
  final String userId;
  final Map<String, dynamic>? traits;
  final bool isNewIdentify;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'site_id': siteId,
      'user_id': userId,
      'is_new_identify': isNewIdentify,
    };
    if (traits != null) json['traits'] = traits;
    return json;
  }
}
