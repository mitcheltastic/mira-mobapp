import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constant/app_colors.dart';
import '../data/post_model.dart';
import 'comments_sheet.dart';
import 'edit_post_sheet.dart';
import 'report_post_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onDelete;

  const PostCard({super.key, required this.post, this.onDelete});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  // Local state for instant feedback
  late bool isLiked;
  late int likeCount;
  late int commentCount; // New state

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get isOwner => _supabase.auth.currentUser?.id == widget.post.userId;

  @override
  void initState() {
    super.initState();
    // Initialize with data from DB (passed via widget.post)
    isLiked = widget.post.isLiked;
    likeCount = widget.post.likeCount;
    commentCount = widget.post.commentCount;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- LOGIC: Toggle Like ---
  Future<void> _toggleLike() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    // 1. Optimistic Update (Update UI immediately)
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    if (isLiked) {
      _controller.forward().then((_) => _controller.reverse());
    }

    try {
      if (isLiked) {
        // Add Like
        await _supabase.from('post_likes').insert({
          'user_id': myId,
          'post_id': widget.post.id,
        });
      } else {
        // Remove Like
        await _supabase.from('post_likes').delete().match({
          'user_id': myId,
          'post_id': widget.post.id,
        });
      }
    } catch (e) {
      // Revert if error
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
      debugPrint("Error toggling like: $e");
    }
  }

  void _editPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditPostSheet(
        postId: widget.post.id,
        initialContent: widget.post.content ?? "",
        onSave: (newContent) {},
      ),
    );
  }

  void _deletePost() async {
    try {
      await _supabase.from('posts').delete().eq('id', widget.post.id);
      if (widget.onDelete != null) widget.onDelete!();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Post deleted")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting post: $e")));
      }
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: widget.post.id),
    );
  }

  void _reportPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportPostSheet(postId: widget.post.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[50],
                  backgroundImage: (widget.post.userAvatar != null)
                      ? NetworkImage(widget.post.userAvatar!)
                      : null,
                  child: widget.post.userAvatar == null
                      ? Text(
                          widget.post.userName.isNotEmpty
                              ? widget.post.userName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // MENU
                SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') _deletePost();
                      if (value == 'edit') _editPost();
                      if (value == 'report') _reportPost();
                    },
                    itemBuilder: (context) {
                      if (isOwner) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.textMain,
                                ),
                                SizedBox(width: 12),
                                Text("Edit Post"),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ];
                      } else {
                        return [
                          const PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 12),
                                Text("Report"),
                              ],
                            ),
                          ),
                        ];
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // CONTENT (TEXT)
          if (widget.post.content != null && widget.post.content!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.post.content!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF334155),
                ),
              ),
            ),

          // CONTENT (IMAGE)
          if (widget.post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, loading) {
                    if (loading == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),

          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // LIKE
                InkWell(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isLiked
                              ? const Color(0xFFE11D48)
                              : Colors.grey[500],
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$likeCount",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isLiked
                              ? const Color(0xFFE11D48)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // COMMENT
                InkWell(
                  onTap: _showComments,
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        // Blue if has comments
                        color: commentCount > 0
                            ? AppColors.primary
                            : Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        commentCount > 0 ? "$commentCount" : "Comment",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          // Blue text if has comments
                          color: commentCount > 0
                              ? AppColors.primary
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
