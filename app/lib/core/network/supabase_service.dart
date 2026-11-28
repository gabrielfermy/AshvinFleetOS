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

  bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get client {
    final c = clientOrNull;
    if (c == null) {
      throw StateError('Supabase has not been initialized yet.');
    }
    return c;
  }

  User? get currentUser => clientOrNull?.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<String?> getCurrentUserRole() async {
    final user = currentUser;
    final c = clientOrNull;
    if (user == null || c == null) return null;
    try {
      final res = await c
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      return res?['role'] as String?;
    } catch (_) {
      return null;
    }
  }
}
