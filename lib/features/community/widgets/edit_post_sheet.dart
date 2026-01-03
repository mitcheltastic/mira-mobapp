import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';

class EditPostSheet extends StatefulWidget {
  final String initialContent;
  final Function(String) onSave;

  const EditPostSheet({
    super.key, 
    required this.initialContent, 
    required this.onSave
  });

  @override
  State<EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<EditPostSheet> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    
    // Listener untuk mendeteksi perubahan real-time
    _controller.addListener(() {
      final isChanged = _controller.text.trim().isNotEmpty && 
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

  @override
  Widget build(BuildContext context) {
    // Mengambil padding keyboard
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
          // --- 1. DRAG HANDLE (Visual Cue) ---
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

                // Save Button (Pill Styled)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _hasChanges ? AppColors.textMain : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: _hasChanges
                        ? () {
                            widget.onSave(_controller.text);
                            Navigator.pop(context);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: _hasChanges ? Colors.white : Colors.grey[400],
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
                  // User Identity (Context)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=my_profile"),
                        backgroundColor: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hilmy Baihaqi",
                            style: TextStyle(
                              fontWeight: FontWeight.w700, 
                              fontSize: 15, 
                              color: AppColors.textMain
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                "Editing",
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.public, size: 12, color: Colors.grey[500]),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Text Input
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null, // Unlimited lines
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 17, 
                      height: 1.6, // Line height agar enak dibaca
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

          // --- 4. BOTTOM BAR (Character Count) ---
          // Opsional: Bar kecil di atas keyboard untuk indikator
          if (MediaQuery.of(context).viewInsets.bottom > 0)
            Container(
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Character Counter Real-time
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