import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    final myId = _supabase.auth.currentUser!.id;

    try {
      // 1. Fetch Request
      // We join with 'profiles' to get the name.
      // NOTE: We fetch full_name and nickname, NOT username.
      final data = await _supabase
          .from('friendships')
          .select('*, profiles:requester_id(full_name, nickname, avatar_url)')
          .eq('receiver_id', myId)
          .eq('status', 'pending');

      if (mounted) {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _respond(String friendshipId, bool accept) async {
    // Optimistic Update (Remove from UI immediately)
    setState(() {
      _requests.removeWhere((r) => r['id'] == friendshipId);
    });

    try {
      if (accept) {
        await _supabase
            .from('friendships')
            .update({'status': 'accepted'})
            .eq('id', friendshipId);
      } else {
        await _supabase.from('friendships').delete().eq('id', friendshipId);
      }
    } catch (e) {
      // If error, maybe refresh list? For now just log it.
      debugPrint("Error responding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Friend Requests",
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No pending requests",
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _requests.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final req = _requests[index];
                final requester = req['profiles'];

                // Name Logic
                final fullName = requester['full_name'] as String?;
                final nickname = requester['nickname'] as String?;
                final name = fullName ?? nickname ?? "Unknown User";
                final char = name.isNotEmpty ? name[0].toUpperCase() : "?";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
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
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Wants to be your friend"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        onPressed: () => _respond(req['id'], true),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 32,
                        ),
                        onPressed: () => _respond(req['id'], false),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
