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

    try {
      final data = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }
    } catch (_) {}

    // Self-healing fallback: construct profile from auth metadata
    final meta = user.userMetadata ?? {};
    final fallbackProfile = UserProfile(
      id: user.id,
      role: (meta['role'] as String?) ?? 'CUSTOMER',
      fullName: (meta['full_name'] as String?) ??
          (user.email?.split('@').first ?? 'Customer'),
      phoneNumber: (meta['phone_number'] as String?) ?? '',
      nationality: (meta['nationality'] as String?) ?? 'ID',
      preferredLocale: 'id',
    );

    try {
      await client.from('user_profiles').upsert(fallbackProfile.toJson());
    } catch (_) {}

    return fallbackProfile;
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
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'nationality': nationality,
      },
    );

    if (res.user != null) {
      try {
        await client.from('user_profiles').upsert({
          'id': res.user!.id,
          'role': 'CUSTOMER',
          'full_name': fullName,
          'phone_number': phoneNumber,
          'nationality': nationality,
          'preferred_locale': nationality == 'ID' ? 'id' : 'en',
        });
      } catch (_) {
        // Trigger on DB already handles profile creation
      }
    }

    return res;
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
