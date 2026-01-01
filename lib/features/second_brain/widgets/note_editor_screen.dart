import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  // State untuk Kategori
  String _selectedCategory = "Personal";
  final List<String> _categories = ["Personal", "Project", "Study", "Ideas"];
  
  // Mapping Warna Kategori (Agar konsisten)
  final Map<String, Color> _categoryColors = {
    "Personal": const Color(0xFFF43F5E), // Rose
    "Project": const Color(0xFF6366F1),  // Indigo
    "Study": const Color(0xFF10B981),    // Emerald
    "Ideas": const Color(0xFFF59E0B),    // Amber
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?['title'] ?? "");
    _contentController = TextEditingController(text: widget.existingNote?['content'] ?? "");
    if (widget.existingNote != null) {
      _selectedCategory = widget.existingNote?['category'] ?? "Personal";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    // Di sini nanti logika simpan ke Database/API
    // Untuk sekarang kita kembalikan data ke screen sebelumnya
    final newNoteData = {
      "title": _titleController.text,
      "content": _contentController.text,
      "category": _selectedCategory,
      "date": "Just now",
      "color": _categoryColors[_selectedCategory],
    };

    Navigator.pop(context, newNoteData); // Mengirim data balik
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Thought captured successfully!"),
        backgroundColor: _categoryColors[_selectedCategory],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _categoryColors[_selectedCategory]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: _saveNote,
              style: FilledButton.styleFrom(
                backgroundColor: activeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text("Save"),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // --- Category Selector (Penting untuk 'Organize') ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: _categories.map((category) {
                bool isSelected = _selectedCategory == category;
                Color catColor = _categoryColors[category]!;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    selected: isSelected,
                    selectedColor: catColor,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // --- Input Area ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Input Judul
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w800, 
                    color: AppColors.textMain,
                    height: 1.2,
                  ),
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                  ),
                  maxLines: null,
                ),
                
                const SizedBox(height: 16),
                
                // Input Isi
                TextField(
                  controller: _contentController,
                  maxLines: null, // Expandable
                  style: const TextStyle(
                    fontSize: 16, 
                    height: 1.6, 
                    color: AppColors.textMain
                  ),
                  decoration: const InputDecoration(
                    hintText: "Start typing details here...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
          
          // --- Formatting Toolbar (Opsional/Visual Saja) ---
          // Ini memberikan kesan 'Editor' yang serius
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                _FormatButton(icon: Icons.format_bold_rounded),
                _FormatButton(icon: Icons.format_italic_rounded),
                _FormatButton(icon: Icons.format_list_bulleted_rounded),
                const Spacer(),
                Text(
                  "${_contentController.text.length} chars",
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget kecil untuk tombol format
class _FormatButton extends StatelessWidget {
  final IconData icon;
  const _FormatButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {}, // Nanti diimplementasikan logikanya
      icon: Icon(icon, color: AppColors.textMuted, size: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}