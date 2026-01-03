import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constant/app_colors.dart';
import 'comments_sheet.dart';

const String currentUserId = "user_001"; 

class PostCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReport; // TAMBAHAN: Callback Report

  const PostCard({
    super.key, 
    required this.data, 
    required this.onDelete,
    this.onEdit,
    this.onReport, // Tambahkan di constructor
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late bool isLiked;
  late int likeCount;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get isOwner => widget.data['userId'] == currentUserId;

  @override
  void initState() {
    super.initState();
    isLiked = widget.data['isLiked'] ?? false;
    likeCount = widget.data['likes'] ?? 0;
    _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    if (isLiked) _controller.forward().then((_) => _controller.reverse());
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CommentsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime postTime;
    try { postTime = DateTime.parse(widget.data['time']); } catch (e) { postTime = DateTime.now(); }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
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
                  backgroundImage: widget.data['avatar'] != null ? NetworkImage(widget.data['avatar']) : null,
                  child: widget.data['avatar'] == null
                      ? Text(widget.data['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(widget.data['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textMain))),
                          if (widget.data['isPro'] == true) ...[const SizedBox(width: 4), const Icon(Icons.verified, size: 14, color: Colors.blueAccent)],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(timeago.format(postTime), style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'delete') widget.onDelete();
                      if (value == 'edit' && widget.onEdit != null) widget.onEdit!();
                      if (value == 'report' && widget.onReport != null) widget.onReport!(); // TRIGGER REPORT
                    },
                    itemBuilder: (context) {
                      if (isOwner) {
                        return [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: AppColors.textMain), SizedBox(width: 12), Text("Edit Post")])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), SizedBox(width: 12), Text("Delete", style: TextStyle(color: Colors.redAccent))])),
                        ];
                      } else {
                        return [
                          const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag_outlined, size: 18, color: Colors.grey), SizedBox(width: 12), Text("Report")])),
                        ];
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // CONTENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(widget.data['content'], style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF334155))),
          ),
          Divider(height: 1, thickness: 0.5, color: Colors.grey[200]),
          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _toggleLike,
                  child: Row(children: [
                    ScaleTransition(scale: _scaleAnimation, child: Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isLiked ? const Color(0xFFE11D48) : Colors.grey[500], size: 22)),
                    const SizedBox(width: 6),
                    Text("$likeCount", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isLiked ? const Color(0xFFE11D48) : Colors.grey[600])),
                  ]),
                ),
                const SizedBox(width: 24), 
                InkWell(
                  onTap: _showComments,
                  child: Row(children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 20, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text("${widget.data['comments']}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                  ]),
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