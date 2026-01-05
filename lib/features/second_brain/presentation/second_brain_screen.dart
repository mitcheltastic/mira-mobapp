import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// IMPORT HELPER & CONSTANTS
import '../../../core/constant/app_colors.dart';
import '../widgets/note_card.dart';
import '../widgets/note_editor_screen.dart';

// --- IMPORT SUBSCRIPTION SERVICE ---
import '../../../core/services/subscription_service.dart';
import '../../profile/widgets/subscription_screen.dart';

class SecondBrainScreen extends StatefulWidget {
  final bool isPro;

  const SecondBrainScreen({super.key, required this.isPro});

  @override
  State<SecondBrainScreen> createState() => _SecondBrainScreenState();
}

class _SecondBrainScreenState extends State<SecondBrainScreen>
    with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  // --- Animation Controllers ---
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // --- Search Controller ---
  final TextEditingController _searchController = TextEditingController();

  // --- DATA CATATAN ---
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;

  // --- TIER STATE ---
  UserTier _currentTier = UserTier.regular;
  int _maxNotes = 5;

  @override
  void initState() {
    super.initState();

    // Setup Animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Fetch Data & Tier
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchTierInfo(), _fetchNotes()]);
  }

  Future<void> _fetchTierInfo() async {
    final tier = await SubscriptionService().getUserTier();
    if (mounted) {
      setState(() {
        _currentTier = tier;
        // Determine max notes for display based on tier
        if (tier == UserTier.plus) {
          _maxNotes = 25;
        } else if (tier == UserTier.premium) {
          _maxNotes = 9999; // Represents unlimited visually
        } else {
          _maxNotes = 5;
        }
      });
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notes = List<Map<String, dynamic>>.from(data);
          _filteredNotes = _notes; // Initialize filter
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA PENCARIAN ---
  void _runFilter(String keyword) {
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      results = _notes;
    } else {
      results = _notes
          .where(
            (note) =>
                (note["title"] ?? '').toLowerCase().contains(
                  keyword.toLowerCase(),
                ) ||
                (note["content"] ?? '').toLowerCase().contains(
                  keyword.toLowerCase(),
                ) ||
                (note["category"] ?? '').toLowerCase().contains(
                  keyword.toLowerCase(),
                ),
          )
          .toList();
    }
    setState(() {
      _filteredNotes = results;
    });
  }

  // --- LOGIKA CRUD ---

  void _addNewNote() async {
    HapticFeedback.mediumImpact();

    // --- 1. LOCAL LIMIT CHECK (FIXED) ---
    // We check against the actual list length we just loaded.
    // This ensures if the UI says "5/5", you CANNOT add more.
    int limit = 5;
    if (_currentTier == UserTier.plus) limit = 25;
    if (_currentTier == UserTier.premium) limit = 99999; // Unlimited

    if (_notes.length >= limit) {
      _showUpgradeDialog();
      return;
    }

    // Go to Editor
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
    );

    // Refresh data on return
    _fetchNotes();
  }

  void _editNote(Map<String, dynamic> currentNote) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(existingNote: currentNote),
      ),
    );
    // Refresh data on return
    _fetchNotes();
  }

  Future<void> _deleteNote(String noteId) async {
    final deletedNoteIndex = _notes.indexWhere((n) => n['id'] == noteId);
    if (deletedNoteIndex == -1) return;

    final deletedNote = _notes[deletedNoteIndex];

    setState(() {
      _notes.removeAt(deletedNoteIndex);
      _filteredNotes = List.from(_notes);
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: const Text("Note deleted"),
            action: SnackBarAction(
              label: "Undo",
              textColor: Colors.white,
              onPressed: () async {
                setState(() {
                  _notes.insert(deletedNoteIndex, deletedNote);
                  _filteredNotes = List.from(_notes);
                });
                return;
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        )
        .closed
        .then((reason) async {
          if (reason != SnackBarClosedReason.action) {
            try {
              await _supabase.from('notes').delete().eq('id', noteId);
            } catch (e) {
              debugPrint("Error deleting note: $e");
            }
          }
        });
  }

  void _showDeleteConfirmation(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note['id']);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog() {
    String message = SubscriptionService().getLimitMessage(
      _currentTier,
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

  // --- INTRO GUIDE ---
  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Unlock Your Second Brain",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Stop trying to remember everything. Use this method to free your mind.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _buildGuideItem(
              icon: Icons.bolt_rounded,
              color: const Color(0xFFF59E0B),
              title: "Capture Instantly",
              desc:
                  "Don't trust your memory. When you have an idea or insight, write it down immediately.",
            ),
            _buildGuideItem(
              icon: Icons.folder_open_rounded,
              color: const Color(0xFF6366F1),
              title: "Organize by Context",
              desc:
                  "Categorize notes by Projects (active) or Resources (reference). Keep it structured.",
            ),
            _buildGuideItem(
              icon: Icons.search_rounded,
              color: const Color(0xFF10B981),
              title: "Retrieve Anytime",
              desc:
                  "Use the search bar to find connections between old ideas and new projects effortlessly.",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewNote,
        backgroundColor: AppColors.textMain,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Capture Idea",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // --- Background Animations ---
          Positioned(
            top: -100,
            left: -50,
            child: _AnimatedOrb(
              color: AppColors.primary.withValues(alpha: 0.15),
              size: 300,
              controller: _pulseController,
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: _AnimatedOrb(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              size: 200,
              controller: _pulseController,
              reverse: true,
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _runFilter,
                      decoration: InputDecoration(
                        hintText: "Search your brain...",
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Note List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = _filteredNotes[index];

                            // --- PARSE COLOR FROM DB ---
                            Color noteColor = const Color(
                              0xFF6366F1,
                            ); // Default
                            if (note['color_hex'] != null) {
                              try {
                                noteColor = Color(int.parse(note['color_hex']));
                              } catch (e) {
                                // Fallback if hex is invalid
                              }
                            }

                            return FadeTransition(
                              opacity: _fadeController,
                              child: Dismissible(
                                key: Key(note['id']),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Note?"),
                                        content: const Text(
                                          "Are you sure you want to delete this note?",
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              context,
                                            ).pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  _deleteNote(note['id']);
                                },
                                child: GestureDetector(
                                  onLongPress: () =>
                                      _showDeleteConfirmation(note),
                                  child: NoteCard(
                                    title: note['title'] ?? 'Untitled',
                                    content: note['content'] ?? '',
                                    date:
                                        note['created_at'] ??
                                        DateTime.now().toIso8601String(),
                                    category:
                                        note['category'] ?? 'Uncategorized',
                                    accentColor: noteColor,
                                    onTap: () => _editNote(note),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // --- DETERMINE BADGE STYLE ---
    bool isUnlimited = _currentTier == UserTier.premium;
    int limit = _maxNotes;

    // Check if over limit
    bool isOverLimit = !isUnlimited && _notes.length >= limit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.textMain,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const Text(
            "Second Brain",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textMain,
            ),
          ),

          // Usage Counter / Help Icon
          Row(
            children: [
              // Usage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlimited
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isOverLimit
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOverLimit
                        ? Colors.red.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  isUnlimited ? "PRO" : "${_notes.length}/$limit",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlimited
                        ? AppColors.primary
                        : (isOverLimit ? Colors.red : Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.help_outline_rounded,
                  size: 24,
                  color: AppColors.textMuted,
                ),
                onPressed: _showIntroGuide,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 60,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No thoughts found",
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController controller;
  final bool reverse;

  const _AnimatedOrb({
    required this.color,
    required this.size,
    required this.controller,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: controller,
          curve: reverse
              ? const Interval(0.5, 1.0, curve: Curves.easeInOut)
              : const Interval(0.0, 0.5, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
