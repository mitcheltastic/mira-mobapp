import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // 2. Verify OTP
  Future<void> verifyOtp({required String email, required String token}) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.signup,
      token: token,
      email: email,
    );
  }

  // 3. Sign In (NEW)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 4. Sign Out (Good to have ready)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 5. Send Password Reset Email (NEW)
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // 6. Confirm Password Reset (Verify Code + Update Password)
  Future<void> verifyRecoveryCodeAndResetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    // 1. Verify the Recovery Code (This logs the user in temporarily)
    final res = await _supabase.auth.verifyOTP(
      type: OtpType.recovery,
      token: token,
      email: email,
    );

    if (res.session == null) {
      throw const AuthException("Invalid recovery code");
    }

    // 2. Set the New Password
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
