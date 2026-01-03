import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  // Singleton pattern
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  // A stream that emits the list of currently online User IDs
  final _onlineUsersController = StreamController<Set<String>>.broadcast();
  Stream<Set<String>> get onlineUsersStream => _onlineUsersController.stream;

  // The current list of online user IDs
  Set<String> _onlineUserIds = {};

  /// 1. Start Broadcasting "I am Online"
  Future<void> connect() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Join a global channel called 'online_users'
    _channel = _supabase.channel('online_users');

    _channel!
        .onPresenceSync((payload) {
          // FIX: Handle the new List<SinglePresenceState> return type
          final newState = _channel!.presenceState();

          final Set<String> activeIds = {};

          // Iterate over the List of states directly
          for (final state in newState) {
            // Each 'state' is a SinglePresenceState object containing a 'presences' list
            for (final presence in state.presences) {
              // The actual data is inside 'payload'
              final Map<String, dynamic>? data = presence.payload;

              if (data != null && data.containsKey('user_id')) {
                activeIds.add(data['user_id'] as String);
              }
            }
          }

          _onlineUserIds = activeIds;
          _onlineUsersController.add(_onlineUserIds);
          debugPrint("👥 Online Users: ${_onlineUserIds.length}");
        })
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            // Send MY user_id to the room
            _channel!.track({
              'user_id': user.id,
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        });
  }

  /// 2. Stop Broadcasting (e.g., on logout)
  Future<void> disconnect() async {
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  // Helper to check if a specific user is online right now
  bool isUserOnline(String userId) {
    return _onlineUserIds.contains(userId);
  }
}
