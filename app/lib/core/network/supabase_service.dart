import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Singleton Service for Supabase Backend Interactions
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: false,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<String?> getCurrentUserRole() async {
    if (currentUser == null) return null;
    try {
      final res = await client
          .from('user_profiles')
          .select('role')
          .eq('id', currentUser!.id)
          .maybeSingle();
      return res?['role'] as String?;
    } catch (_) {
      return null;
    }
  }
}
