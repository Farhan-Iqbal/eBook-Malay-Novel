import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://fymykhhwvegsuqpekryy.supabase.co'; // Replace with your URL
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5bXlraGh3dmVnc3VxcGVrcnl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE5NzM2NTMsImV4cCI6MjA2NzU0OTY1M30._B4DsNRBOvj1y5oFFOts40sAM-mTvE0cNioBfcavfS4'; // Replace with your key

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}