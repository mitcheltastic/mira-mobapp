import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/premium_helper.dart';

// Feature Imports
import 'pomodoro_screen.dart';
import 'feynman_screen.dart';
import 'flashcard_screen.dart';
import 'mind_map_screen.dart';
import 'notes_screen.dart';
import 'eisenhower_screen.dart';
import 'blurting_screen.dart';
import '../../second_brain/presentation/second_brain_screen.dart';
import 'ai_chat_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final TextEditingController _searchController = TextEditingController();

  // --- STATE ---
  String _searchQuery = "";
  String _selectedCategory = "All";
  bool _isPro = false;
  bool _isLoading = true; // Now actively used

  // --- LOCKED FEATURES ---
  final List<String> _lockedFeatures = ["Blurting Method", "Flashcards"];

  // --- MASTER DATA ---
  final List<Map<String, dynamic>> _allTools = [
    {
      "title": "Pomodoro Timer",
      "desc": "Boost focus with 25-min intervals.",
      "icon": Icons.timer_outlined,
      "color": const Color(0xFFF43F5E),
      "category": "Focus",
      "screen": const PomodoroScreen(),
    },
    {
      "title": "Eisenhower Matrix",
      "desc": "Prioritize tasks by urgency.",
      "icon": Icons.grid_view_rounded,
      "color": const Color(0xFF0EA5E9),
      "category": "Planning",
      "screen": const EisenhowerScreen(),
    },
    {
      "title": "Flashcards",
      "desc": "Active recall testing.",
      "icon": Icons.style_outlined,
      "color": const Color(0xFFF59E0B),
      "category": "Memory",
      "screen": const FlashcardScreen(),
    },
    {
      "title": "Feynman Method",
      "desc": "Learn by simplifying.",
      "icon": Icons.record_voice_over_outlined,
      "color": const Color(0xFF3B82F6),
      "category": "Understanding",
      "screen": const FeynmanScreen(),
    },
    {
      "title": "Mind Map",
      "desc": "Visualize & connect ideas.",
      "icon": Icons.hub_outlined,
      "color": const Color(0xFF10B981),
      "category": "Understanding",
      "screen": const MindMapScreen(),
    },
    {
      "title": "Smart Notes",
      "desc": "Capture & organize thoughts.",
      "icon": Icons.edit_note_rounded,
      "color": const Color(0xFF8B5CF6),
      "category": "Tools",
      "screen": const NotesScreen(),
    },
    {
      "title": "Blurting Method",
      "desc": "Test knowledge gaps quickly.",
      "icon": Icons.psychology_alt_outlined,
      "color": const Color(0xFFEC4899),
      "category": "Memory",
      "screen": const BlurtingScreen(),
    },
    {
      "title": "Second Brain",
      "desc": "Organize your digital knowledge",
      "icon": Icons.psychology_rounded,
      "color": const Color(0xFF1E293B),
      "category": "Knowledge",
      "screen": const SizedBox(), // Handled dynamically
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserStatus();
  }

  // --- FETCH SUBSCRIPTION STATUS ---
  Future<void> _fetchUserStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final levelData = await Supabase.instance.client
            .from('level')
            .select('status')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            if (levelData != null && levelData['status'] != null) {
              final status = levelData['status'];
              _isPro =
                  status == 'Monthly Premium' || status == 'Yearly Premium';
            }
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching study status: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTools {
    return _allTools.where((tool) {
      final categoryMatch =
          _selectedCategory == "All" || tool['category'] == _selectedCategory;
      final searchMatch =
          tool['title'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          tool['desc'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          backgroundColor: AppColors.textMain,
          elevation: 4,
          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          label: const Text(
            "Ask AI",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Study Hub",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Master your learning workflow",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                ],
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 16,
                    ),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip("All"),
                        _buildFilterChip("Focus"),
                        _buildFilterChip("Planning"),
                        _buildFilterChip("Memory"),
                        _buildFilterChip("Understanding"),
                        _buildFilterChip("Tools"),
                      ],
                    ),
                  ),

                  // Grid with Loading State
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _fetchUserStatus,
                            color: AppColors.primary,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _filteredTools.isEmpty
                                  ? _buildEmptyState()
                                  : _buildToolsGrid(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: _filteredTools.length,
      itemBuilder: (context, index) {
        final tool = _filteredTools[index];
        final title = tool['title'];
        final isLocked = _lockedFeatures.contains(title) && !_isPro;

        return _buildToolCard(tool, isLocked);
      },
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool, bool isLocked) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          showPremiumDialog(context, featureName: tool['title']);
          return;
        }

        if (tool['title'] == "Second Brain") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecondBrainScreen(isPro: _isPro),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => tool['screen']),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.freeBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (tool['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(tool['icon'], color: tool['color'], size: 28),
                  ),
                  const Spacer(),
                  Text(
                    tool['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tool['desc'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            if (isLocked)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.freeBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: "Search method or tool...",
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary.withValues(alpha: 0.8),
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textMain : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.textMain : AppColors.freeBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.freeBorder),
              ),
              child: Icon(
                Icons.manage_search_rounded,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No tools found",
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Try searching for something else",
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
