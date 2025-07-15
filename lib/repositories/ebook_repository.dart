import '/models/ebook.dart';
import '/models/review.dart';
import '/services/supabase_service.dart';

class EbookRepository {
  final _client = SupabaseService.client;

  Future<List<Ebook>> getEbooks() async {
    final response = await _client
        .from('ebooks')
        .select('*, genres(genre_name)');

    return (response as List).map((json) {
      final genreName = json['genres']?['genre_name']; // Safely access genre_name
      return Ebook.fromJson({
        ...json,
        'genre_name': genreName, // Will be null if genres is null
      });
    }).toList();
  }

  Future<Ebook?> getEbookDetails(String ebookId) async {
    final response = await _client
        .from('ebooks')
        .select('*, genres(genre_name)')
        .eq('ebook_id', ebookId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final genreName = response['genres']?['genre_name']; // Safely access genre_name
    return Ebook.fromJson({
      ...response,
      'genre_name': genreName, // Will be null if genres is null
    });
  }

  Future<List<Review>> getEbookReviews(String ebookId) async {
    final response = await _client
        .from('reviews')
        .select('*, users(name)')
        .eq('ebook_id', ebookId);

    return (response as List).map((json) => Review.fromJson({
      ...json,
      'user_name': json['users']['name'],
    })).toList();
  }
}