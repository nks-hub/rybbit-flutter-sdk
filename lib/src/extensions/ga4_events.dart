import '../rybbit.dart';

/// GA4-compatible typed event methods for common analytics scenarios.
///
/// Provides strongly-typed wrappers for e-commerce, auth, search,
/// and engagement events following Google Analytics 4 naming conventions.
extension RybbitGA4Events on Rybbit {
  // Auth
  void trackLogin({String? method}) =>
      event('login', properties: {if (method != null) 'method': method});

  void trackSignUp({String? method}) =>
      event('sign_up', properties: {if (method != null) 'method': method});

  void trackLogout() => event('logout');

  // E-commerce
  void trackViewItem({
    required String itemId,
    required String itemName,
    String? category,
    double? price,
  }) =>
      event('view_item', properties: {
        'item_id': itemId,
        'item_name': itemName,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
      });

  void trackAddToCart({
    required String itemId,
    required String itemName,
    double? price,
    int? quantity,
  }) =>
      event('add_to_cart', properties: {
        'item_id': itemId,
        'item_name': itemName,
        if (price != null) 'price': price,
        if (quantity != null) 'quantity': quantity,
      });

  void trackRemoveFromCart({
    required String itemId,
    required String itemName,
  }) =>
      event('remove_from_cart', properties: {
        'item_id': itemId,
        'item_name': itemName,
      });

  void trackViewCart({int? itemsCount, double? value, String? currency}) =>
      event('view_cart', properties: {
        if (itemsCount != null) 'items_count': itemsCount,
        if (value != null) 'value': value,
        if (currency != null) 'currency': currency,
      });

  void trackBeginCheckout({
    double? value,
    String? currency,
    int? itemsCount,
  }) =>
      event('begin_checkout', properties: {
        if (value != null) 'value': value,
        if (currency != null) 'currency': currency,
        if (itemsCount != null) 'items_count': itemsCount,
      });

  void trackPurchase({
    required String transactionId,
    required double value,
    String? currency,
    List<Map<String, dynamic>>? items,
  }) =>
      event('purchase', properties: {
        'transaction_id': transactionId,
        'value': value,
        if (currency != null) 'currency': currency,
        if (items != null) 'items': items,
      });

  void trackRefund({
    required String transactionId,
    double? value,
    String? currency,
  }) =>
      event('refund', properties: {
        'transaction_id': transactionId,
        if (value != null) 'value': value,
        if (currency != null) 'currency': currency,
      });

  void trackAddToWishlist({
    required String itemId,
    required String itemName,
    double? price,
  }) =>
      event('add_to_wishlist', properties: {
        'item_id': itemId,
        'item_name': itemName,
        if (price != null) 'price': price,
      });

  void trackViewPromotion({
    String? promotionId,
    String? promotionName,
    String? location,
  }) =>
      event('view_promotion', properties: {
        if (promotionId != null) 'promotion_id': promotionId,
        if (promotionName != null) 'promotion_name': promotionName,
        if (location != null) 'location': location,
      });

  void trackSelectPromotion({
    String? promotionId,
    String? promotionName,
  }) =>
      event('select_promotion', properties: {
        if (promotionId != null) 'promotion_id': promotionId,
        if (promotionName != null) 'promotion_name': promotionName,
      });

  // Engagement
  void trackSearch({required String searchTerm, int? resultsCount}) =>
      event('search', properties: {
        'search_term': searchTerm,
        if (resultsCount != null) 'results_count': resultsCount,
      });

  void trackShare({String? method, String? contentType, String? itemId}) =>
      event('share', properties: {
        if (method != null) 'method': method,
        if (contentType != null) 'content_type': contentType,
        if (itemId != null) 'item_id': itemId,
      });

  void trackClickCta({String? button, String? location}) =>
      event('click_cta', properties: {
        if (button != null) 'button': button,
        if (location != null) 'location': location,
      });

  void trackVideoPlay({
    String? videoId,
    String? videoTitle,
    double? duration,
  }) =>
      event('video_play', properties: {
        if (videoId != null) 'video_id': videoId,
        if (videoTitle != null) 'video_title': videoTitle,
        if (duration != null) 'duration': duration,
      });

  void trackScrollDepth({required int percent, String? page}) =>
      event('scroll_depth', properties: {
        'percent': percent,
        if (page != null) 'page': page,
      });

  void trackFileDownload({
    required String fileName,
    String? fileExtension,
  }) =>
      event('file_download', properties: {
        'file_name': fileName,
        if (fileExtension != null) 'file_extension': fileExtension,
      });

  // CMS
  void trackCommentSubmit({String? pageId, String? pageTitle}) =>
      event('comment_submit', properties: {
        if (pageId != null) 'page_id': pageId,
        if (pageTitle != null) 'page_title': pageTitle,
      });

  void trackRatingSubmit({
    required double rating,
    String? itemId,
    double? maxRating,
  }) =>
      event('rating_submit', properties: {
        'rating': rating,
        if (itemId != null) 'item_id': itemId,
        if (maxRating != null) 'max_rating': maxRating,
      });

  // Lead gen
  void trackGenerateLead({String? source, double? value}) =>
      event('generate_lead', properties: {
        if (source != null) 'source': source,
        if (value != null) 'value': value,
      });

  void trackContactFormSubmit({String? formId, String? formName}) =>
      event('contact_form_submit', properties: {
        if (formId != null) 'form_id': formId,
        if (formName != null) 'form_name': formName,
      });

  void trackNewsletterSubscribe({String? source}) =>
      event('newsletter_subscribe', properties: {
        if (source != null) 'source': source,
      });
}
