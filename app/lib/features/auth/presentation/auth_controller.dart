import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthStateData {
  final bool isLoading;
  final UserProfile? profile;
  final String? errorMessage;

  const AuthStateData({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  bool get isAuthenticated => profile != null;

  AuthStateData copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthStateData(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthStateData> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthStateData(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final profile = await _repo.fetchCurrentProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }

    _repo.authStateChanges.listen((data) async {
      if (data.session == null) {
        state = const AuthStateData(isLoading: false, profile: null);
      } else {
        final p = await _repo.fetchCurrentProfile();
        state = AuthStateData(isLoading: false, profile: p);
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signIn(email: email, password: password);
      final p = await _repo.fetchCurrentProfile();
      state = state.copyWith(isLoading: false, profile: p);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nationality,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        nationality: nationality,
      );
      final p = await _repo.fetchCurrentProfile();
      state = state.copyWith(isLoading: false, profile: p);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthStateData(isLoading: false, profile: null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStateData>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
