import '/models/collection.dart';
import '/services/supabase_service.dart';

class UserRepository {
  final _client = SupabaseService.client;

  // -------------------------------
  // Favorites
  // -------------------------------
  Future<void> addToFavorites(String userId, String ebookId) async {
    await _client.from('collections').insert({
      'user_id': userId,
      'ebook_id': ebookId,
    });
  }

  Future<void> removeFromFavorites(String userId, String ebookId) async {
    await _client
        .from('collections')
        .delete()
        .eq('user_id', userId)
        .eq('ebook_id', ebookId);
  }

  Future<List<Collection>> getFavoriteEbooks(String userId) async {
    final response = await _client
        .from('collections')
        .select('*, ebooks(*, genres(genre_name))')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => Collection.fromJson(json))
        .toList();
  }

  Future<bool> isEbookInFavorites(String userId, String ebookId) async {
    final response = await _client
        .from('collections')
        .select()
        .eq('user_id', userId)
        .eq('ebook_id', ebookId)
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  // -------------------------------
  // Reading Status
  // -------------------------------
  Future<String?> getReadingStatus(String userId, String ebookId) async {
    final response = await _client
        .from('collections')
        .select('status')
        .eq('user_id', userId)
        .eq('ebook_id', ebookId)
        .maybeSingle();

    return response != null ? response['status'] as String? : null;
  }

  Future<void> updateReadingStatus(
      String userId, String ebookId, String status) async {
    final existing = await _client
        .from('collections')
        .select('collection_id')
        .eq('user_id', userId)
        .eq('ebook_id', ebookId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('collections')
          .update({'status': status})
          .eq('collection_id', existing['collection_id']);
    } else {
      await _client.from('collections').insert({
        'user_id': userId,
        'ebook_id': ebookId,
        'status': status,
        'added_date': DateTime.now().toIso8601String(),
      });
    }
  }
}
