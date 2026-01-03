import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import '../../../../core/constant/app_colors.dart';

class EditPostSheet extends StatefulWidget {
  final String postId; // 2. Need ID to identify post
  final String initialContent;
  final Function(String) onSave; // Optional: To update UI locally if needed

  const EditPostSheet({
    super.key,
    required this.postId,
    required this.initialContent,
    required this.onSave,
  });

  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  final _supabase = Supabase.instance.client; // 3. Client Instance
  late TextEditingController _controller;
  bool _hasChanges = false;
  bool _isSaving = false; // 4. Loading State

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);

    _controller.addListener(() {
      final isChanged =
          _controller.text.trim().isNotEmpty &&
          _controller.text != widget.initialContent;
      if (_hasChanges != isChanged) {
        setState(() => _hasChanges = isChanged);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- 5. LOGIC: Update Post in Database ---
  Future<void> _handleSave() async {
    if (!_hasChanges) return;

    setState(() => _isSaving = true);

    try {
      final content = _controller.text.trim();

      // Update Supabase
      await _supabase
          .from('posts')
          .update({'content': content})
          .eq('id', widget.postId); // Find by ID

      // Success
      if (mounted) {
        widget.onSave(content); // Notify parent (optional)
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error updating post: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- 1. DRAG HANDLE ---
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // --- 2. HEADER ACTION BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                ),

                // Title
                const Text(
                  "Edit Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),

                // Save Button (Updated with Loading State)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _hasChanges && !_isSaving
                        ? AppColors.textMain
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: (_hasChanges && !_isSaving) ? _handleSave : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey,
                              ),
                            )
                          : Text(
                              "Save",
                              style: TextStyle(
                                color: _hasChanges
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // --- 3. EDITOR AREA ---
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24, 24, keyboardPadding + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Identity (Static for now, or you can fetch it if needed)
                  Row(
                    children: [
                      // You can replace this with the actual user avatar if available
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Editing Post", // Generic title since we might not have the user name here easily
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                "Public",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.public,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Text Input
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      hintText: "What do you want to talk about?",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. BOTTOM BAR ---
          if (MediaQuery.of(context).viewInsets.bottom > 0)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _controller,
                    builder: (context, TextEditingValue value, child) {
                      return Text(
                        "${value.text.length} chars",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
