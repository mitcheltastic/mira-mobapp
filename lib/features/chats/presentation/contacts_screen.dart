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
          ) // (*) fetches avatar_url
          .eq('requester_id', myId)
          .eq('status', 'accepted');

      // 2. Friendships where I received the request
      final received = await _supabase
          .from('friendships')
          .select(
            'requester_id, profiles:requester_id(*)',
          ) // (*) fetches avatar_url
          .eq('receiver_id', myId)
          .eq('status', 'accepted');

      // 3. Merge raw lists
      final allRaw = [
        ...sent.map((e) => e['profiles']),
        ...received.map((e) => e['profiles']),
      ];

      // 4. Deduplicate
      final uniqueFriendsMap = {
        for (var friend in allRaw) friend['id']: friend,
      };

      final uniqueFriendsList = uniqueFriendsMap.values.toList();

      if (mounted) {
        setState(() {
          _friends = List<Map<String, dynamic>>.from(uniqueFriendsList);
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

    final fullName = friendProfile['full_name'] as String?;
    final nickname = friendProfile['nickname'] as String?;
    final displayName = fullName ?? nickname ?? "Unknown User";

    try {
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
        final newRoom = await _supabase
            .from('chat_rooms')
            .insert({'participant_1': myId, 'participant_2': friendId})
            .select()
            .single();
        roomId = newRoom['id'];
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              user: ChatUser(
                name: displayName,
                avatarUrl: roomId,
                isOnline: false,
              ),
              otherUserId: friendId,
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
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: const Color(0xFFF1F5F9),
                indent: 24,
                endIndent: 24,
              ),
              itemBuilder: (context, index) {
                final friend = _friends[index];

                final fullName = friend['full_name'] as String?;
                final nickname = friend['nickname'] as String?;
                final name = fullName ?? nickname ?? "Unknown User";
                final char = name.isNotEmpty ? name[0].toUpperCase() : "?";

                // 1. GET AVATAR URL
                final avatarUrl = friend['avatar_url'] as String?;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    // 2. SHOW IMAGE IF AVAILABLE
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    // 3. SHOW TEXT ONLY IF NO IMAGE
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                            char,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textMain,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Tap to message",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  onTap: () => _startChat(friend),
                );
              },
            ),
    );
  }
}
