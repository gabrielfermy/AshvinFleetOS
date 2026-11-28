import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_service.dart';
import '../domain/user_profile.dart';

/// Repository for Supabase Auth and User Profile mutations
class AuthRepository {
  final SupabaseClient? _client;

  AuthRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService().clientOrNull;

  Stream<AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  User? get currentAuthUser => _client?.auth.currentUser;

  Future<UserProfile?> fetchCurrentProfile() async {
    final client = _client;
    final user = currentAuthUser;
    if (client == null || user == null) return null;

    final data = await client
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase client not initialized');
    }
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nationality,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase client not initialized');
    }
    final res = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName},
    );

    if (res.user != null) {
      await client.from('user_profiles').upsert({
        'id': res.user!.id,
        'role': 'CUSTOMER',
        'full_name': fullName,
        'phone_number': phoneNumber,
        'nationality': nationality,
        'preferred_locale': nationality == 'ID' ? 'id' : 'en',
      });
    }

    return res;
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
