import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../data/chat_user_model.dart';
import 'chat_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  void _fetchFriends() async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      // 1. Friendships where I sent the request
      final sent = await _supabase
          .from('friendships')
          .select(
            'receiver_id, profiles:receiver_id(*)',
          ) // Fetch all profile columns
          .eq('requester_id', myId)
          .eq('status', 'accepted');

      // 2. Friendships where I received the request
      final received = await _supabase
          .from('friendships')
          .select('requester_id, profiles:requester_id(*)')
          .eq('receiver_id', myId)
          .eq('status', 'accepted');

      // 3. Merge them into a single list of Profiles
      final allFriends = [
        ...sent.map((e) => e['profiles']),
        ...received.map((e) => e['profiles']),
      ];

      if (mounted) {
        setState(() {
          _friends = List<Map<String, dynamic>>.from(allFriends);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startChat(Map<String, dynamic> friendProfile) async {
    final myId = _supabase.auth.currentUser!.id;
    final friendId = friendProfile['id'];

    // Safe Name Logic
    final fullName = friendProfile['full_name'] as String?;
    final nickname = friendProfile['nickname'] as String?;
    final displayName = fullName ?? nickname ?? "Unknown User";

    try {
      // 1. Check if room exists
      final existingRooms = await _supabase
          .from('chat_rooms')
          .select()
          .or(
            'and(participant_1.eq.$myId,participant_2.eq.$friendId),and(participant_1.eq.$friendId,participant_2.eq.$myId)',
          );

      String roomId;
      if (existingRooms.isNotEmpty) {
        roomId = existingRooms.first['id'];
      } else {
        // 2. Create new room if none exists
        final newRoom = await _supabase
            .from('chat_rooms')
            .insert({'participant_1': myId, 'participant_2': friendId})
            .select()
            .single();
        roomId = newRoom['id'];
      }

      // 3. Navigate
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              user: ChatUser(
                name: displayName,
                avatarUrl: roomId, // Passing room ID for navigation
                isOnline: true,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error starting chat: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not start chat. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Select Contact",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No friends yet",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _friends.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final friend = _friends[index];

                // --- SAFE NAME LOGIC (Prevents Crash) ---
                final fullName = friend['full_name'] as String?;
                final nickname = friend['nickname'] as String?;
                final name = fullName ?? nickname ?? "Unknown User";
                final char = name.isNotEmpty ? name[0].toUpperCase() : "?";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      char,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text(
                    "Tap to message",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => _startChat(friend),
                );
              },
            ),
    );
  }
}
