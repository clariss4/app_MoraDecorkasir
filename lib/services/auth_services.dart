import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ SIGN UP DENGAN TRICK AUTO CONFIRM
  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Step 1: Sign up normal
      final signUpResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      // Step 2: Jika butuh confirmation, langsung confirm via API
      if (signUpResponse.user != null && signUpResponse.session == null) {
        print('🔄 Auto-confirming email for: $email');

        // Trick: Coba sign in dengan magic link yang auto-confirm
        await _supabase.auth.signInWithOtp(
          email: email,
          shouldCreateUser: false,
        );

        // Tunggu sebentar lalu coba login
        await Future.delayed(const Duration(seconds: 2));

        // Coba login dengan password
        final loginResponse = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        return loginResponse;
      }

      return signUpResponse;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // ✅ SIGN IN DENGAN AUTO-RETRY
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful: ${response.user?.email}');
      return response;
    } catch (e) {
      // Jika masih error email not confirmed, coba confirm manual
      if (e.toString().contains('email_not_confirmed')) {
        print('🔄 Attempting auto-confirmation...');
        return await _retryWithAutoConfirm(email, password);
      }

      print('❌ Login error: $e');
      rethrow;
    }
  }

  // ✅ AUTO-CONFIRM RETRY
  Future<AuthResponse> _retryWithAutoConfirm(
    String email,
    String password,
  ) async {
    try {
      // Kirim magic link untuk confirm
      await _supabase.auth.signInWithOtp(email: email);

      // Tunggu dan coba login lagi
      await Future.delayed(const Duration(seconds: 3));

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      print('❌ Auto-confirm failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  Stream<User?> get authStateChange =>
      _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
}
