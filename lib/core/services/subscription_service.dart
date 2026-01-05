import 'package:supabase_flutter/supabase_flutter.dart';

enum UserTier { regular, plus, premium }

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final _supabase = Supabase.instance.client;

  // --- LIMIT CONFIGURATION ---
  // Notes (Storage Limit)
  static const int _limitNotesRegular = 5;
  static const int _limitNotesPlus = 25;

  // AI Chat (Consumable Limit)
  static const int _limitAiRegular = 5;
  static const int _limitAiPlus = 100;

  // --- 1. GET CURRENT TIER ---
  Future<UserTier> getUserTier() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return UserTier.regular;

    try {
      final response = await _supabase
          .from('level')
          .select('status')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return UserTier.regular;

      final status = response['status'] as String?;

      if (status == 'Yearly Premium' || status == 'Monthly Premium') {
        return UserTier.premium;
      } else if (status == 'Monthly Plus') {
        return UserTier.plus;
      }
      return UserTier.regular;
    } catch (e) {
      return UserTier.regular;
    }
  }

  // --- 2. CHECK NOTE PERMISSION (Row Count Strategy) ---
  Future<bool> canCreateNote(UserTier tier) async {
    // Premium has no limits
    if (tier == UserTier.premium) return true;

    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    // Count actual active notes in DB
    final count = await _supabase
        .from('study_notes')
        .count(CountOption.exact)
        .eq('user_id', user.id);

    if (tier == UserTier.plus) {
      return count < _limitNotesPlus; // Max 25
    } else {
      return count < _limitNotesRegular; // Max 5
    }
  }

  // --- 3. CHECK & INCREMENT AI (Counter Strategy) ---
  /// Returns TRUE if allowed and incremented. Returns FALSE if limit reached.
  Future<bool> checkAndIncrementAi(UserTier tier) async {
    if (tier == UserTier.premium) return true; // Unlimited

    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      // A. Fetch current limitation data
      final data = await _supabase
          .from('limitation')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        // If no row exists, create one (Fail-safe)
        await _supabase.from('limitation').insert({'id': user.id});
        return true;
      }

      int counter = data['chatbot_counter'] as int;
      DateTime lastReset = DateTime.parse(data['last_reset_date']);
      final now = DateTime.now();

      // B. Check for Reset (Daily logic for example, change to Monthly if preferred)
      // Checking if today is different from last_reset_date
      bool needsReset =
          lastReset.year != now.year ||
          lastReset.month != now.month ||
          lastReset.day != now.day;

      if (needsReset) {
        counter = 0; // Reset local variable
        // Update DB reset date
        await _supabase
            .from('limitation')
            .update({
              'chatbot_counter': 0,
              'last_reset_date': now.toIso8601String(),
            })
            .eq('id', user.id);
      }

      // C. Check Limits
      int limit = (tier == UserTier.plus) ? _limitAiPlus : _limitAiRegular;

      if (counter >= limit) {
        return false; // Limit Reached
      }

      // D. Increment Usage
      await _supabase
          .from('limitation')
          .update({'chatbot_counter': counter + 1})
          .eq('id', user.id);

      return true;
    } catch (e) {
      // In case of error, default to block or allow based on preference.
      // Blocking is safer for business.
      return false;
    }
  }

  // --- 4. MESSAGES FOR UI ---
  String getLimitMessage(UserTier tier, String feature) {
    if (feature == 'notes') {
      if (tier == UserTier.plus) {
        return "You've reached the Plus limit of $_limitNotesPlus ideas.";
      }
      return "Free limit reached ($_limitNotesRegular ideas). Upgrade to Plus for 25 or Premium for unlimited.";
    } else if (feature == 'ai') {
      if (tier == UserTier.plus) {
        return "You've reached your daily limit of $_limitAiPlus messages.";
      }
      return "Free limit reached. Upgrade to Plus for 100 messages/day.";
    }
    return "Limit reached.";
  }
}
