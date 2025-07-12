import '/services/supabase_service.dart';

class ReviewRepository {
  final _client = SupabaseService.client;

  Future<void> submitReview({
    required String ebookId,
    required String userId,
    required int rating,
    required String reviewText,
  }) async {
    await _client.from('reviews').insert({
      'ebook_id': ebookId,
      'user_id': userId,
      'rating': rating,
      'review_text': reviewText,
      'status': 'pending', // Or 'published' if no moderation is needed
    });
  }
}