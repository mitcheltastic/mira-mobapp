import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/app_colors.dart';
import '../data/chat_user_model.dart';
import 'chat_detail_screen.dart';

// --- NEW IMPORTS ---
import 'search_users_screen.dart';
import 'friend_requests_screen.dart';
import 'contacts_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Stream<List<Map<String, dynamic>>> _getChatRoomsStream() {
    final myUserId = _supabase.auth.currentUser!.id;
    return _supabase
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((rooms) {
          return rooms.where((room) {
            return room['participant_1'] == myUserId ||
                room['participant_2'] == myUserId;
          }).toList();
        });
  }

  void _deleteChat(String roomId) async {
    await _supabase.from('chat_rooms').delete().eq('id', roomId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Conversation deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // --- FIX: PUSH FAB UP ABOVE NAVBAR ---
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 90.0,
        ), // Added padding to clear Navbar
        child: FloatingActionButton(
          heroTag: "search_people_fab", // Unique tag to prevent hero errors
          backgroundColor: AppColors.textMain,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_search_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchUsersScreen()),
            );
          },
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Messages",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Connect with your friends",
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textMuted.withValues(
                                  alpha: 0.8,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Friend Requests (Bell)
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FriendRequestsScreen(),
                            ),
                          );
                        },
                      ),

                      // Start Chat (Plus)
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ContactsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                ],
              ),
            ),

            // CHAT LIST
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getChatRoomsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final rooms = snapshot.data!;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      bottom: 120,
                    ), // Extra padding for scrolling behind FAB
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return _ChatRoomTile(
                        roomId: room['id'],
                        participant1: room['participant_1'],
                        participant2: room['participant_2'],
                        searchQuery: _searchQuery,
                        onDelete: () => _deleteChat(room['id']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No chats yet",
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.freeBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: "Search conversations...",
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}

// SMART TILE WIDGET (Kept identical for stability)
class _ChatRoomTile extends StatefulWidget {
  final String roomId;
  final String participant1;
  final String participant2;
  final String searchQuery;
  final VoidCallback onDelete;

  const _ChatRoomTile({
    required this.roomId,
    required this.participant1,
    required this.participant2,
    required this.searchQuery,
    required this.onDelete,
  });

  @override
  State<_ChatRoomTile> createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<_ChatRoomTile> {
  final myId = Supabase.instance.client.auth.currentUser!.id;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _lastMessage;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _listenToLastMessage();
  }

  Future<void> _fetchDetails() async {
    final otherUserId = (widget.participant1 == myId)
        ? widget.participant2
        : widget.participant1;
    try {
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', otherUserId)
          .single();
      if (mounted) setState(() => _profile = profileData);
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  void _listenToLastMessage() {
    Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', widget.roomId)
        .order('created_at', ascending: false)
        .limit(1)
        .listen((messages) {
          if (mounted && messages.isNotEmpty) {
            setState(() => _lastMessage = messages.first);
            _fetchUnreadCount();
          }
        });
  }

  Future<void> _fetchUnreadCount() async {
    final count = await Supabase.instance.client
        .from('messages')
        .count()
        .eq('room_id', widget.roomId)
        .eq('is_read', false)
        .neq('sender_id', myId);
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const SizedBox.shrink();

    final fullName = _profile!['full_name'] as String?;
    final nickname = _profile!['nickname'] as String?;
    final name = fullName ?? nickname ?? "Unknown User";

    if (widget.searchQuery.isNotEmpty &&
        !name.toLowerCase().contains(widget.searchQuery.toLowerCase())) {
      return const SizedBox.shrink();
    }

    final lastMsgText = _lastMessage?['content'] ?? "No messages yet";
    final lastMsgTime = _lastMessage != null
        ? DateFormat(
            'HH:mm',
          ).format(DateTime.parse(_lastMessage!['created_at']).toLocal())
        : "";

    return Slidable(
      key: Key(widget.roomId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => widget.onDelete(),
            backgroundColor: Colors.red.shade500,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          final chatUser = ChatUser(
            name: name,
            avatarUrl: widget.roomId,
            isOnline: true,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(user: chatUser),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _unreadCount > 0
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        color: _unreadCount > 0
                            ? AppColors.primary
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          lastMsgTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: _unreadCount > 0
                                ? AppColors.primary
                                : Colors.grey.shade500,
                            fontWeight: _unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsgText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: _unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                              fontWeight: _unreadCount > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (_unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              _unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
