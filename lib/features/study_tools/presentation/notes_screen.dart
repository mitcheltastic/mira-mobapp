import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Diperlukan untuk BackdropFilter (jika ingin efek glass kedepannya)
import '../../../core/constant/app_colors.dart';

// --- 1. MODEL DATA (TETAP SAMA) ---
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

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Dummy Data Awal
  List<Note> notes = [
    Note(
      id: '1',
      title: "🔥 Deadline Tugas Besar IoT",
      content:
          "Kumpulkan laporan akhir project hari Jumat jam 23.59. Jangan lupa cek format PDF dan lampiran source code.",
      date: DateTime.now().subtract(const Duration(hours: 5)),
      isImportant: true,
    ),
    Note(
      id: '2',
      title: "Ide Skripsi Web Security",
      content:
          "Analisis serangan XSS pada framework legacy. Coba cari referensi paper tahun 2024 di IEEE Explore.",
      date: DateTime.now().subtract(const Duration(days: 1)),
      isImportant: false,
    ),
    Note(
      id: '3',
      title: "Bahan Belajar Flutter Bloc",
      content:
          "Cek dokumentasi resmi bloclibrary.dev, lalu coba buat project counter sederhana.",
      date: DateTime.now().subtract(const Duration(days: 2)),
      isImportant: false,
    ),
  ];

  void _addOrUpdateNote(Note note) {
    setState(() {
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
      } else {
        if (note.isImportant) {
          notes.insert(0, note);
        } else {
          notes.add(note);
        }
      }
    });
  }

  void _deleteNote(String id) {
    setState(() {
      notes.removeWhere((n) => n.id == id);
    });
    HapticFeedback.mediumImpact();
  }

  void _openEditor({Note? existingNote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: existingNote),
      ),
    );

    if (result != null && result is Note) {
      _addOrUpdateNote(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Custom AppBar yang lebih modern
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textMain,
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Journal & Notes",
              style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            Text(
              "Capture your thoughts",
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: notes.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildPremiumNoteItem(note);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Your notebook is empty",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to start writing!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // --- REDESIGNED NOTE CARD ---
  Widget _buildPremiumNoteItem(Note note) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNote(note.id),
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: AppColors.error,
          size: 32,
        ),
      ),
      child: GestureDetector(
        onTap: () => _openEditor(existingNote: note),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Jika penting, beri tint warna merah halus di background
            color: note.isImportant
                ? AppColors.secondary.withValues(alpha: 0.05)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              // Jika penting, bordernya sedikit lebih terlihat
              color: note.isImportant
                  ? AppColors.secondary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(
                  alpha: note.isImportant ? 0.1 : 0.06,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header
              Text(
                note.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800, // Lebih tebal
                  color: note.isImportant
                      ? AppColors.secondary
                      : AppColors.textMain,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Content Preview
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 18),

              // Footer: Date & Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(note.date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  // Important Tag (Jika ada)
                  if (note.isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Urgent",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper simpel untuk format tanggal
  String _formatDate(DateTime date) {
    // Bisa diganti pakai package intl jika mau lebih kompleks
    return "${date.day}/${date.month} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

// --- 2. REDESIGNED EDITOR SCREEN ---

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(
      text: widget.note?.content ?? "",
    );
    _isImportant = widget.note?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title cannot be empty!"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newNote = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now(),
      isImportant: _isImportant,
    );

    HapticFeedback.lightImpact();
    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background sedikit off-white agar mata nyaman
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      // Important Toggle Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isImportant = !_isImportant;
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isImportant
                                ? AppColors.secondary.withValues(alpha: 0.1)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isImportant
                                  ? AppColors.secondary
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Icon(
                            _isImportant
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: _isImportant
                                ? AppColors.secondary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Save Button
                      TextButton(
                        onPressed: _saveNote,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: const Text(
                          "Save Note",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- EDITOR CANVAS ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE INPUT (Big & Bold)
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Untitled Idea...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black26),
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.next,
                          maxLines: null,
                        ),
                        const SizedBox(height: 20),

                        // CONTENT INPUT (Clean)
                        TextField(
                          controller: _contentController,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Start typing your thoughts here...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black12),
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null, // Unlimited lines
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
