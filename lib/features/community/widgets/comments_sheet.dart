import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isComposing = false;

  final List<Map<String, dynamic>> _comments = [
    {
      "name": "Sarah Jenkins",
      "avatar": "https://i.pravatar.cc/150?u=1",
      "content": "This is exactly what I needed to hear today. Great explanation! 👏",
      "time": "2h",
      "likes": 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Listener untuk mengecek apakah textfield kosong/tidak
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

  // Fungsi Menambah Komentar
  void _handleSubmitted() {
    if (!_isComposing) return;

    final String text = _commentController.text;

    setState(() {
      // Masukkan komentar baru ke indeks 0 (Paling atas)
      _comments.insert(0, {
        "name": "You", // Nama User Login
        "avatar": null, // null akan merender inisial
        "content": text,
        "time": "Just now",
        "likes": 0,
      });
      _isComposing = false;
    });

    _commentController.clear();
    // Opsional: Tutup keyboard setelah kirim
    // _focusNode.unfocus(); 
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
          // --- 1. HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title Dynamic
                Text(
                  "Comments (${_comments.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),

          // --- 2. LIST AREA ---
          Expanded(
            child: _comments.isEmpty
                ? Center(
                    child: Text(
                      "No comments yet.\nBe the first to say something!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _CommentItem(data: comment);
                    },
                  ),
          ),

          // --- 3. INPUT AREA ---
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
                // User Avatar (Current User)
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=my_profile"),
                ),
                const SizedBox(width: 12),
                
                // Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate 100
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 14, color: AppColors.textMain),
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
                          : AppColors.primary.withValues(alpha: 0.1), // Dimmed if empty
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded, // Icon panah lebih modern utk "Send"
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

// --- WIDGET ITEM KOMENTAR (Refined Layout) ---
class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CommentItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[200],
          backgroundImage: data['avatar'] != null ? NetworkImage(data['avatar']) : null,
          child: data['avatar'] == null
              ? Text(data['name'][0], style: const TextStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.bold))
              : null,
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Name • Time)
              Row(
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13, // Sedikit lebih kecil dari body text
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
                    data['time'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Comment Text
              Text(
                data['content'],
                style: const TextStyle(
                  color: Color(0xFF334155), // Slate 700 standard text
                  fontSize: 14,
                  height: 1.4, // Line height 140% untuk keterbacaan
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),

              // Actions (Reply, Like)
              Row(
                children: [
                  _ActionButton(label: "Reply", onTap: () {}),
                  const SizedBox(width: 16),
                  _ActionButton(
                    label: data['likes'] > 0 ? "${data['likes']} likes" : "Like",
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // Optional Heart Icon (Instagram Style)
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 4),
          child: Icon(
            Icons.favorite_outline,
            size: 14,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

// Helper Widget
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