import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../../profile/widgets/subscription_screen.dart';

// --- IMPORT SERVICE ---
import '../../../core/services/subscription_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _supabase = Supabase.instance.client;
  bool _isSaving = false;

  // State untuk Kategori
  String _selectedCategory = "Personal";
  final List<String> _categories = ["Personal", "Project", "Study", "Ideas"];

  // Mapping Warna Kategori
  final Map<String, Color> _categoryColors = {
    "Personal": const Color(0xFFF43F5E), // Rose
    "Project": const Color(0xFF6366F1), // Indigo
    "Study": const Color(0xFF10B981), // Emerald
    "Ideas": const Color(0xFFF59E0B), // Amber
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingNote?['title'] ?? "",
    );
    _contentController = TextEditingController(
      text: widget.existingNote?['content'] ?? "",
    );
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

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please add a title")));
      return;
    }

    setState(() => _isSaving = true);

    // --- 1. CHECK SUBSCRIPTION LIMITS (Only for NEW notes) ---
    if (widget.existingNote == null) {
      final tier = await SubscriptionService().getUserTier();
      final canCreate = await SubscriptionService().canCreateNote(tier);

      if (!canCreate) {
        if (mounted) {
          setState(() => _isSaving = false);
          _showUpgradeDialog(tier);
        }
        return;
      }
    }
    // --- END LIMIT CHECK ---

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // FIX: Use .toARGB32() instead of .value
      final colorHex = _categoryColors[_selectedCategory]!
          .toARGB32()
          .toString();

      if (widget.existingNote == null) {
        // --- INSERT NEW NOTE ---
        await _supabase.from('notes').insert({
          'user_id': userId,
          'title': title,
          'content': content,
          'category': _selectedCategory,
          'color_hex': colorHex,
        });
      } else {
        // --- UPDATE EXISTING NOTE ---
        await _supabase
            .from('notes')
            .update({
              'title': title,
              'content': content,
              'category': _selectedCategory,
              'color_hex': colorHex,
            })
            .eq('id', widget.existingNote!['id']); // Ensure ID is passed
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to signal refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Thought captured successfully!"),
            backgroundColor: _categoryColors[_selectedCategory],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving note: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showUpgradeDialog(UserTier currentTier) {
    String message = SubscriptionService().getLimitMessage(
      currentTier,
      'notes',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Storage Full"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Upgrade Now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
              onPressed: _isSaving ? null : _saveNote,
              style: FilledButton.styleFrom(
                backgroundColor: activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isSaving ? "Saving..." : "Save"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Category Selector ---
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textMain,
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

          // --- Formatting Toolbar ---
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
                ListenableBuilder(
                  listenable: _contentController,
                  builder: (context, _) {
                    return Text(
                      "${_contentController.text.length} chars",
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
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

class _FormatButton extends StatelessWidget {
  final IconData icon;
  const _FormatButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: AppColors.textMuted, size: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}
