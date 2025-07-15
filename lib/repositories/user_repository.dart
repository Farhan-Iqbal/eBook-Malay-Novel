import '/models/collection.dart';
import '/services/supabase_service.dart';

class UserRepository {
  final _client = SupabaseService.client;
  
  Future<void> addToFavorites(String userId, String ebookId) async {
    await _client.from('collections').insert({
      'user_id': userId,
      'ebook_id': ebookId,
    });
  }

  Future<void> removeFromFavorites(String userId, String ebookId) async {
    await _client.from('collections').delete().eq('user_id', userId).eq('ebook_id', ebookId);
  }

  Future<List<Collection>> getFavoriteEbooks(String userId) async {
    final response = await _client
        .from('collections')
        .select('*, ebooks(*, genres(genre_name))')
        .eq('user_id', userId);
        
    return (response as List).map((json) => Collection.fromJson(json)).toList();
  }
  
  Future<bool> isEbookInFavorites(String ebookId) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return false; 
    final response = await _client
      .from('collections')
      .select()
      .eq('user_id', user.id)
      .eq('ebook_id', ebookId)
      .limit(1)
      .single()
      .maybeSingle();

    return response != null;
  }
}