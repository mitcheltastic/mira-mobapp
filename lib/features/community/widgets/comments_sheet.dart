import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constant/app_colors.dart';

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

  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isComposing = _commentController.text.trim().isNotEmpty;
      });
    });
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
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final futures = data.map((comment) async {
            final profile = await _supabase
                .from('profiles')
                .select()
                .eq('id', comment['user_id'])
                .single();

            return {...comment, 'profile': profile};
          });
          return await Future.wait(futures);
        });
  }

  void _handleSubmitted() async {
    if (!_isComposing) return;

    final content = _commentController.text.trim();
    _commentController.clear();
    setState(() => _isComposing = false);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'content': content,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to post comment: $e")));
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
          // --- HEADER ---
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

          // --- LIST AREA ---
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getCommentsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!;

                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      "No comments yet.\nBe the first to say something!",
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
                  itemCount: comments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _CommentItem(data: comment);
                  },
                );
              },
            ),
          ),

          // --- INPUT AREA ---
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, keyboardPadding + 12),
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
                // REMOVED: CircleAvatar was here

                // Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMain,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Send Button
                InkWell(
                  onTap: _isComposing ? _handleSubmitted : null,
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
          ),
        ],
      ),
    );
  }
}

// --- WIDGET ITEM KOMENTAR (Keep unchanged) ---
class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CommentItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final profile = data['profile'] ?? {};
    final fullName = profile['full_name'] as String?;
    final nickname = profile['nickname'] as String?;
    final name = fullName ?? nickname ?? "Unknown";
    final avatarUrl = profile['avatar_url'] as String?;

    final createdAt = DateTime.parse(data['created_at']).toLocal();
    final timeString = timeago.format(createdAt, locale: 'en_short');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[200],
          backgroundImage: (avatarUrl != null) ? NetworkImage(avatarUrl) : null,
          child: (avatarUrl == null)
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
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
                    "•",
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeString,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                data['content'] ?? "",
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [_ActionButton(label: "Reply", onTap: () {})],
              ),
            ],
          ),
        ),
      ],
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
