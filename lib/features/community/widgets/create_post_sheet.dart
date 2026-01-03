import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  final Function(String) onSubmit;

  const CreatePostSheet({super.key, required this.onSubmit});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi keyboard agar konten tidak tertutup
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Menggunakan tinggi dinamis, maksimal 95% layar
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // --- 1. HEADER (Cancel, Title, Post) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMain,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
                
                // Judul Tengah (Opsional, agar seimbang)
                const Text(
                  "Create Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),

                // Tombol Post (Animated)
                AnimatedOpacity(
                  opacity: _isTyping ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _isTyping
                        ? () {
                            widget.onSubmit(_controller.text);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMain, // Hitam Elegan
                      disabledBackgroundColor: Colors.grey[300],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Post",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 0.5),

          // --- 2. CONTENT AREA (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              // Padding bawah disesuaikan dengan keyboard agar teks tidak tertutup
              padding: EdgeInsets.fromLTRB(24, 24, 24, keyboardPadding + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=my_profile"),
                        backgroundColor: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hilmy Baihaqi", // Nama User
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Badge Privacy (Visual Only)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.public, size: 12, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  "Public",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // Input Text Area
                  TextField(
                    controller: _controller,
                    onChanged: (val) => setState(() => _isTyping = val.trim().isNotEmpty),
                    autofocus: true, // Keyboard otomatis muncul
                    maxLines: null, // Bisa mengetik panjang tak terbatas
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 18, 
                      height: 1.5, 
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: "What do you want to talk about?",
                      hintStyle: TextStyle(
                        color: Colors.grey[400], 
                        fontSize: 20,
                        fontWeight: FontWeight.w400
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}