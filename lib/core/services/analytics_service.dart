import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  // Singleton
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Logs a feature usage event to Supabase
  Future<void> logFeature(String featureName) async {
    // 1. Check if user is logged in
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 2. Insert log (Fire and Forget - we don't await strictly to avoid blocking UI)
      await _supabase.from('feature_logs').insert({
        'user_id': user.id,
        'feature_name': featureName,
      });

      if (kDebugMode) {
        print("📊 Analytics Logged: $featureName");
      }
    } catch (e) {
      // Fail silently in production so it doesn't annoy the user
      if (kDebugMode) {
        print("⚠️ Analytics Error: $e");
      }
    }
  }
}
