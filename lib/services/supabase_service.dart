import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'YOUR_SUPABASE_URL'; // Replace with your URL
  static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your key

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}