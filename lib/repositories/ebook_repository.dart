import '/models/ebook.dart';
import '/models/review.dart';
import '/services/supabase_service.dart';

class EbookRepository {
  final _client = SupabaseService.client;

  Future<List<Ebook>> getEbooks() async {
    final response = await _client
        .from('ebooks')
        .select('*, genres(genre_name)');
    
    return (response as List).map((json) => Ebook.fromJson({
      ...json,
      'genre_name': json['genres']['genre_name'],
    })).toList();
  }
  
  Future<Ebook?> getEbookDetails(String ebookId) async {
    final response = await _client
        .from('ebooks')
        .select('*, genres(genre_name)')
        .eq('ebook_id', ebookId)
        .single();

    return Ebook.fromJson({
      ...response,
      'genre_name': response['genres']['genre_name'],
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