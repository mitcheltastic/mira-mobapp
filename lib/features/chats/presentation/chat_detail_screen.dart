import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/app_colors.dart';
import '../data/chat_user_model.dart';
import '../../../core/services/presence_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser user;
  final String otherUserId;
  final String? profileImage; // 1. Define the parameter

  const ChatDetailScreen({
    super.key,
    required this.user,
    required this.otherUserId,
    this.profileImage, // 2. Add to constructor
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _roomId;
  late String _myId;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _myId = _supabase.auth.currentUser!.id;
    _roomId = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markRoomAsRead() async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('room_id', _roomId)
          .neq('sender_id', _myId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    final content = text.trim();
    _textController.clear();
    setState(() => _isComposing = false);

    try {
      await _supabase.from('messages').insert({
        'room_id': _roomId,
        'sender_id': _myId,
        'content': content,
        'is_read': false,
      });

      await _supabase
          .from('chat_rooms')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', _roomId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending: $e")));
      }
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessagesStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', _roomId)
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                final hasUnread = messages.any(
                  (msg) => msg['sender_id'] != _myId && msg['is_read'] == false,
                );

                if (hasUnread) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _markRoomAsRead();
                  });
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  reverse: true,
                  itemCount: messages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == _myId;

                    return _MessageBubble(
                      text: msg['content'],
                      isMe: isMe,
                      time: DateTime.parse(msg['created_at']).toLocal(),
                      isRead: msg['is_read'] ?? false,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textMain,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: StreamBuilder<Set<String>>(
        stream: PresenceService().onlineUsersStream,
        builder: (context, snapshot) {
          final onlineUsers = snapshot.data ?? {};
          final isOnline = onlineUsers.contains(widget.otherUserId);

          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                // 3. Use the profileImage here
                backgroundImage:
                    (widget.profileImage != null &&
                        widget.profileImage!.isNotEmpty)
                    ? NetworkImage(widget.profileImage!)
                    : null,
                child:
                    (widget.profileImage == null ||
                        widget.profileImage!.isEmpty)
                    ? Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: AppColors.textMain, fontSize: 15),
                onChanged: (text) =>
                    setState(() => _isComposing = text.trim().isNotEmpty),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () =>
                _isComposing ? _handleSubmitted(_textController.text) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppColors.primary
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _isComposing ? Colors.white : AppColors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isRead;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: isMe ? 64 : 0, right: isMe ? 0 : 64),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  if (!isMe)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textMain,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe) ...[
                    Icon(
                      Icons.done_all_rounded,
                      size: 16,
                      color: isRead
                          ? const Color(0xFF3B82F6) // Blue if read
                          : Colors.grey.shade400, // Grey if unread
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    DateFormat('HH:mm').format(time),
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
