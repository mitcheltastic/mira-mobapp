import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constant/app_colors.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late Stream<List<Map<String, dynamic>>> _commentsStream;

  // 1. Profile Cache (Prevents freezing by avoiding repeated fetches)
  final Map<String, Map<String, dynamic>> _profileCache = {};

  // 2. Pending comments (Optimistic UI)
  final List<Map<String, dynamic>> _pendingComments = [];
  Map<String, dynamic>? _myProfile;
  Map<String, dynamic>? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _commentsStream = _getCommentsStream();
  }

  Future<void> _loadUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select('full_name, nickname, avatar_url')
          .eq('id', userId)
          .single();
      if (mounted) {
        setState(() => _myProfile = data);
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getCommentsStream() {
    return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', widget.postId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          if (data.isEmpty) return <Map<String, dynamic>>[];

          // 1. Identify which profiles we don't have yet
          final userIds = data.map((e) => e['user_id'] as String).toSet();
          final missingIds = userIds
              .where((id) => !_profileCache.containsKey(id))
              .toList();

          // 2. Fetch ONLY missing profiles (This prevents the freeze)
          if (missingIds.isNotEmpty) {
            try {
              final profilesData = await _supabase
                  .from('profiles')
                  .select()
                  .filter('id', 'in', missingIds);

              for (var p in profilesData) {
                _profileCache[p['id'] as String] = p;
              }
            } catch (e) {
              debugPrint("Error fetching profiles: $e");
              // Continue anyway so comments still load even if profiles fail
            }
          }

          // 3. Merge data using Cache
          return data.map((comment) {
            final userId = comment['user_id'];
            final profile = _profileCache[userId] ?? {};
            return {
              ...comment,
              'user_name':
                  profile['full_name'] ?? profile['nickname'] ?? 'User',
              'user_avatar': profile['avatar_url'],
            };
          }).toList();
        });
  }

  void _onReplyTap(Map<String, dynamic> comment) {
    setState(() => _replyingTo = comment);
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
    _focusNode.unfocus();
  }

  Future<void> _handleSubmitted(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final parentId = _replyingTo?['id'];
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    _commentController.clear();
    _focusNode.unfocus();

    // 1. Create Fake Comment
    final tempId = DateTime.now().toIso8601String();
    final optimisticComment = {
      'id': tempId,
      'user_id': myId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
      'parent_id': parentId,
      'user_name': _myProfile?['full_name'] ?? _myProfile?['nickname'] ?? 'Me',
      'user_avatar': _myProfile?['avatar_url'],
      'is_pending': true,
    };

    // 2. Add to list immediately
    setState(() {
      _pendingComments.add(optimisticComment);
      _replyingTo = null;
    });

    try {
      // 3. Send to DB
      await _supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': myId,
        'content': content,
        'parent_id': parentId,
      });

      // No cleanup needed; StreamBuilder deduplication handles it.
    } catch (e) {
      if (mounted) {
        setState(() {
          _pendingComments.removeWhere((c) => c['id'] == tempId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to post: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Comments",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),

          // List Area
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                final streamComments = snapshot.data ?? [];

                // --- DEDUPLICATION LOGIC ---
                // Filter out pending comments that have arrived in the real stream
                final visiblePendingComments = _pendingComments.where((
                  pending,
                ) {
                  final isAlreadyInStream = streamComments.any(
                    (real) =>
                        real['content'] == pending['content'] &&
                        real['user_id'] == pending['user_id'],
                  );
                  return !isAlreadyInStream;
                }).toList();

                final allComments = [
                  ...streamComments,
                  ...visiblePendingComments,
                ];

                if (snapshot.connectionState == ConnectionState.waiting &&
                    allComments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (allComments.isEmpty) {
                  return Center(
                    child: Text(
                      "No comments yet.\nBe the first to share your thoughts!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  itemCount: allComments.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.grey[100]),
                  ),
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return _CommentItem(
                      data: comment,
                      onReply: () => _onReplyTap(comment),
                    );
                  },
                );
              },
            ),
          ),

          // Reply Banner
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    "Replying to ${_replyingTo!['user_name']}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _cancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          _CommentInput(
            controller: _commentController,
            focusNode: _focusNode,
            paddingBottom: keyboardPadding,
            onSubmit: _handleSubmitted,
            isReplying: _replyingTo != null,
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double paddingBottom;
  final Function(String) onSubmit;
  final bool isReplying;

  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.paddingBottom,
    required this.onSubmit,
    required this.isReplying,
  });

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkText);
    super.dispose();
  }

  void _checkText() {
    final isNotEmpty = widget.controller.text.trim().isNotEmpty;
    if (_isComposing != isNotEmpty) {
      setState(() => _isComposing = isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, widget.paddingBottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: widget.isReplying
                      ? "Write a reply..."
                      : "Add a comment...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _isComposing
                ? () => widget.onSubmit(widget.controller.text)
                : null,
            borderRadius: BorderRadius.circular(50),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _isComposing ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onReply;

  const _CommentItem({required this.data, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final name = data['user_name'] ?? "Unknown";
    final avatarUrl = data['user_avatar'];
    final content = data['content'] ?? "";
    final createdAt =
        DateTime.tryParse(data['created_at'] ?? "")?.toLocal() ??
        DateTime.now();
    final isReply = data['parent_id'] != null;
    final isPending = data['is_pending'] == true;

    return Opacity(
      opacity: isPending ? 0.6 : 1.0,
      child: Padding(
        padding: EdgeInsets.only(left: isReply ? 40.0 : 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: Colors.grey[200],
              backgroundImage: (avatarUrl != null)
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl == null)
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: isReply ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPending
                            ? "Sending..."
                            : timeago.format(createdAt, locale: 'en_short'),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: TextStyle(
                      color: isPending ? Colors.grey : const Color(0xFF334155),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (!isPending) ...[
                    const SizedBox(height: 4),
                    _ActionButton(label: "Reply", onTap: onReply),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
