import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constant/app_colors.dart';

// --- 1. DATA MODEL ---
class Note {
  String id;
  String title;
  String content;
  DateTime date;
  bool isImportant;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
  });
}

// --- 2. MAIN NOTES SCREEN ---
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  // Database Catatan (Dummy Data)
  final List<Note> _allNotes = [
    Note(
      id: '1',
      title: "🔥 IoT Project Deadline",
      content: "Submit the final project report this Friday at 23:59. Need to double-check the PDF format and citation style.",
      date: DateTime.now().subtract(const Duration(hours: 5)),
      isImportant: true,
    ),
    Note(
      id: '2',
      title: "Thesis Ideas: Web Security",
      content: "Analysis of XSS attacks on legacy frameworks. Check IEEE 2024 papers regarding new CSP bypass techniques.",
      date: DateTime.now().subtract(const Duration(days: 1)),
      isImportant: false,
    ),
    Note(
      id: '3',
      title: "React Native vs Flutter",
      content: "Pros and cons for the next mobile app project. Flutter has better performance, but React Native has OTA updates.",
      date: DateTime.now().subtract(const Duration(days: 3)),
      isImportant: false,
    ),
  ];

  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _filteredNotes = _allNotes;
    _searchController.addListener(_runFilter);
    
    // Animasi Entry
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroGuide());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _runFilter() {
    List<Note> results = [];
    if (_searchController.text.isEmpty) {
      results = _allNotes;
    } else {
      results = _allNotes.where((note) {
        final query = _searchController.text.toLowerCase();
        return note.title.toLowerCase().contains(query) || 
               note.content.toLowerCase().contains(query);
      }).toList();
    }
    setState(() => _filteredNotes = results);
  }

  void _deleteNote(String id) {
    setState(() {
      _allNotes.removeWhere((n) => n.id == id);
      _runFilter();
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Note deleted"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.textMain,
        duration: const Duration(seconds: 1),
      )
    );
  }

  void _openEditor({Note? existingNote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: existingNote),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        final index = _allNotes.indexWhere((n) => n.id == result.id);
        if (index != -1) {
          _allNotes[index] = result;
        } else {
          _allNotes.insert(0, result);
        }
        _runFilter();
      });
    }
  }

  // --- INTRO GUIDE ---
  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75, 
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 0), 
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const Text("Smart Notes", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      const Text(
                        "Capture your ideas quickly and organize them efficiently.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 25),
                      
                      _buildGuideItem(Icons.edit_note_rounded, AppColors.primary, "Quick Capture", "Write down thoughts instantly with a distraction-free editor."),
                      _buildGuideItem(Icons.star_rounded, AppColors.secondary, "Prioritize", "Mark important notes to keep them visible at the top."),
                      _buildGuideItem(Icons.search_rounded, AppColors.success, "Instant Search", "Find any note in seconds with keywords."),
                    ],
                  ),
                ),
              ),
              
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Start Writing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(),
          backgroundColor: AppColors.textMain,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text("New Note", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),

      // FIX: Menggunakan Column agar Header & Search DIAM (Fixed), List yang Scroll
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- FIXED HEADER SECTION ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              color: AppColors.background, // Match background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row (Back & Help)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textMain),
                      ),
                      IconButton(
                        onPressed: _showIntroGuide,
                        icon: const Icon(Icons.help_outline_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    "Smart Notes",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar (Fixed)
                  _buildSearchBox(),
                ],
              ),
            ),

            // --- SCROLLABLE LIST SECTION ---
            Expanded(
              child: _filteredNotes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // Padding atas kecil, bawah besar untuk FAB
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _animController,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animController, 
                                  curve: Interval(
                                    index * 0.1 > 1.0 ? 1.0 : index * 0.1, 
                                    1.0, 
                                    curve: Curves.easeOutCubic
                                  )
                                )),
                                child: child,
                              ),
                            );
                          },
                          child: _buildNoteCard(_filteredNotes[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search notes...",
          hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: note.isImportant 
              ? AppColors.secondary.withValues(alpha: 0.5) 
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _openEditor(existingNote: note),
          onLongPress: () => _deleteNote(note.id),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isImportant)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.star_rounded, color: AppColors.secondary, size: 20),
                      ),
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted, 
                    height: 1.5, 
                    fontSize: 14
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(note.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_alt_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          const Text("No notes yet", style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}

// --- 3. EDITOR SCREEN (DISTRACTION FREE) ---
class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isImportant = false;
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");
    _isImportant = widget.note?.isImportant ?? false;
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      Navigator.pop(context); // Jangan simpan jika kosong
      return;
    }
    Navigator.pop(
      context,
      Note(
        id: widget.note?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
        isImportant: _isImportant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          onPressed: _save, // Back means save
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isImportant = !_isImportant);
              HapticFeedback.selectionClick();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                _isImportant ? Icons.star_rounded : Icons.star_border_rounded,
                key: ValueKey(_isImportant),
                color: _isImportant ? AppColors.secondary : AppColors.textMuted,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _contentFocus.requestFocus(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TextField(
                focusNode: _contentFocus,
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: "Start typing your thoughts...",
                  hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}