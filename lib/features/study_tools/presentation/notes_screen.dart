import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../../profile/widgets/subscription_screen.dart';

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

  // Convert from Database (JSON) -> Object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['created_at']).toLocal(),
      isImportant: map['is_important'] ?? false,
    );
  }

  // Convert Object -> Database (JSON)
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'is_important': isImportant,
    };
  }
}

// --- 2. MAIN NOTES SCREEN ---
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;

  // --- NEW: User Status State ---
  String _userStatus = 'Reguler';

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_runFilter);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Fetch Notes AND User Status
    _fetchNotes();
    _fetchUserStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // --- DB LOGIC ---

  // 1. Fetch User Level/Status
  Future<void> _fetchUserStatus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('level') // Query the level table
          .select('status')
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle in case row doesn't exist yet

      if (mounted && response != null) {
        setState(() {
          _userStatus = response['status'] ?? 'Reguler';
        });
      }
    } catch (e) {
      debugPrint("Error fetching user status: $e");
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('study_notes')
          .select()
          .order('is_important', ascending: false)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notes = (response as List).map((e) => Note.fromMap(e)).toList();
          _filteredNotes = _notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (deleteNote, restoreNote, runFilter remain the same) ...
  Future<void> _deleteNote(String id) async {
    // ... keep existing code ...
    final index = _notes.indexWhere((n) => n.id == id);
    final backup = _notes[index];

    setState(() {
      _notes.removeAt(index);
      _runFilter();
    });
    HapticFeedback.lightImpact();

    try {
      await _supabase.from('study_notes').delete().eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Note deleted"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: AppColors.textMain,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: "Undo",
              textColor: Colors.white,
              onPressed: () => _restoreNote(backup),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _notes.insert(index, backup);
        _runFilter();
      });
    }
  }

  Future<void> _restoreNote(Note note) async {
    // ... keep existing code ...
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.from('study_notes').insert(note.toMap(userId));
      _fetchNotes();
    } catch (e) {
      debugPrint("Error restoring: $e");
    }
  }

  void _runFilter() {
    // ... keep existing code ...
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes.where((note) {
          return note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // --- NEW: LOGIC TO CHECK LIMIT BEFORE OPENING EDITOR ---
  void _handleCreateNote() {
    // 1. Define Limits based on your DB Schema values
    int limit = 5; // Default for 'Reguler'

    switch (_userStatus) {
      case 'Monthly Plus':
        limit = 25;
        break;
      case 'Monthly Premium':
      case 'Yearly Premium':
        limit = -1; // Use -1 to represent 'Unlimited'
        break;
      case 'Reguler':
      default:
        limit = 5;
        break;
    }

    // 2. Check Count
    // If limit is -1, user is Premium (Unlimited), so we skip the check.
    if (limit != -1 && _notes.length >= limit) {
      _showUpgradeDialog(limit);
    } else {
      _openEditor(); // Proceed to create
    }
  }

  void _showUpgradeDialog(int limit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Limit Reached"),
        content: Text.rich(
          TextSpan(
            text: "You are currently on the ",
            style: const TextStyle(height: 1.5, color: AppColors.textMain),
            children: [
              TextSpan(
                text: "$_userStatus Plan",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    ", which is limited to $limit notes.\n\nUpgrade to Premium for unlimited storage!",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // 1. Close the dialog
              Navigator.pop(context);

              // 2. Navigate to the Subscription Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Upgrade", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openEditor({Note? existingNote}) async {
    // Pass the existing note to the editor
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: existingNote),
      ),
    );

    // Reload if saved/updated
    if (result == true) {
      _fetchNotes();
    }
  }

  // ... (Build method mostly stays the same, just update FAB) ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: _handleCreateNote, // <--- CHANGED THIS
          backgroundColor: AppColors.textMain,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            "New Note",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // ... Rest of the body code remains exactly the same as your snippet ...
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textMain,
                        ),
                      ),
                      // Optional: Show current count/limit for debugging or UX
                      Text(
                        "${_notes.length} Notes",
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                  _buildSearchBox(),
                ],
              ),
            ),
            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteCard(_filteredNotes[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (All other helper widgets: _buildSearchBox, _buildNoteCard, _buildEmptyState remain unchanged) ...
  Widget _buildSearchBox() {
    // ... same as your code ...
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
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: "Search notes...",
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    // ... same as your code ...
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
          onTap: () =>
              _openEditor(existingNote: note), // Editing is always allowed
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
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
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
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                    ),
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
    // ... same as your code ...
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
            child: Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No notes yet",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year}";
  }
}

// --- 3. EDITOR SCREEN (CONNECTED TO DB) ---
class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _supabase = Supabase.instance.client;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isImportant = false;
  bool _isSaving = false;
  final FocusNode _contentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(
      text: widget.note?.content ?? "",
    );
    _isImportant = widget.note?.isImportant ?? false;
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // If empty title, just back without saving
    if (title.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (widget.note == null) {
        // Create
        await _supabase.from('study_notes').insert({
          'user_id': userId,
          'title': title,
          'content': content,
          'is_important': _isImportant,
        });
      } else {
        // Update
        await _supabase
            .from('study_notes')
            .update({
              'title': title,
              'content': content,
              'is_important': _isImportant,
            })
            .eq('id', widget.note!.id);
      }

      if (mounted) {
        Navigator.pop(context, true); // True triggers refresh in parent
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          onPressed: _save, // Back means save
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textMain,
            size: 20,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                setState(() => _isImportant = !_isImportant);
                HapticFeedback.selectionClick();
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isImportant ? Icons.star_rounded : Icons.star_border_rounded,
                  key: ValueKey(_isImportant),
                  color: _isImportant
                      ? AppColors.secondary
                      : AppColors.textMuted,
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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
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
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textMain,
                ),
                decoration: InputDecoration(
                  hintText: "Start typing your thoughts...",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
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
