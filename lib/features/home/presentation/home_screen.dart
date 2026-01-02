import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';

import '../../dashboard/widgets/dashboard_header.dart';
import '../widgets/focus_card.dart';
import '../widgets/tools_grid.dart';

import '../../study_tools/presentation/ai_chat_screen.dart';
import '../../study_tools/presentation/blurting_screen.dart';
import '../../study_tools/presentation/eisenhower_screen.dart';
import '../../study_tools/presentation/flashcard_screen.dart';
import '../../study_tools/presentation/feynman_screen.dart';
import '../../study_tools/presentation/mind_map_screen.dart';
import '../../study_tools/presentation/notes_screen.dart';
import '../../study_tools/presentation/pomodoro_screen.dart';
import '../../second_brain/presentation/second_brain_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onSwitchTab;

  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // --- STATE UI ---
  bool _isSearching = false;
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  // --- STATE DATA (Dynamic) ---
  String _userName = "Friend";
  String? _avatarUrl;
  String _levelStatus = "Reguler"; // Default status
  bool _isPro = false; // Derived from levelStatus

  // --- MASTER DATA ---
  final List<Map<String, dynamic>> _masterSearchData = [
    {
      "title": "Pomodoro Timer",
      "desc": "Focus sessions with break intervals",
      "icon": Icons.timer_outlined,
      "color": const Color(0xFFF43F5E),
      "category": "Focus",
      "screen": const PomodoroScreen(),
    },
    {
      "title": "Feynman Method",
      "desc": "Learn by explaining concepts simply",
      "icon": Icons.record_voice_over_outlined,
      "color": const Color(0xFF3B82F6),
      "category": "Method",
      "screen": const FeynmanScreen(),
    },
    {
      "title": "Flashcards",
      "desc": "Test your memory with active recall",
      "icon": Icons.style_outlined,
      "color": const Color(0xFFF59E0B),
      "category": "Memory",
      "screen": const FlashcardScreen(),
    },
    {
      "title": "Mind Mapping",
      "desc": "Visualize connections between ideas",
      "icon": Icons.hub_outlined,
      "color": const Color(0xFF10B981),
      "category": "Visual",
      "screen": const MindMapScreen(),
    },
    {
      "title": "Second Brain",
      "desc": "Organize your digital knowledge",
      "icon": Icons.psychology_rounded,
      "color": const Color(0xFF1E293B),
      "category": "Knowledge",
      "screen": const SecondBrainScreen(),
    },
    {
      "title": "Eisenhower Matrix",
      "desc": "Prioritize tasks by urgency",
      "icon": Icons.grid_view_rounded,
      "color": const Color(0xFF0EA5E9),
      "category": "Planning",
      "screen": const EisenhowerScreen(),
    },
    {
      "title": "Blurting Method",
      "desc": "Write down everything you remember",
      "icon": Icons.psychology_alt_outlined,
      "color": Colors.pink,
      "category": "Memory",
      "screen": const BlurtingScreen(),
    },
    {
      "title": "Smart Notes",
      "desc": "Capture and organize your thoughts",
      "icon": Icons.edit_note_rounded,
      "color": const Color(0xFF8B5CF6),
      "category": "Tools",
      "screen": const NotesScreen(),
    },
    {
      "title": "AI Learning Assistant",
      "desc": "Ask AI for instant study solutions",
      "icon": Icons.auto_awesome_rounded,
      "color": AppColors.primary,
      "category": "AI Support",
      "screen": const AIChatScreen(),
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Updated function name
    _searchController.addListener(_onSearchChanged);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(
      begin: -20,
      end: 20,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  // --- FUNGSI FETCH DATA (Parallel Fetch) ---
  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Run both queries in parallel for speed
        final results = await Future.wait([
          // 0: Profile Data
          Supabase.instance.client
              .from('profiles')
              .select('full_name, avatar_url')
              .eq('id', user.id)
              .single(),
          // 1: Level Data
          Supabase.instance.client
              .from('level')
              .select('status')
              .eq('id', user.id)
              .maybeSingle(),
        ]);

        final profileData = results[0] as Map<String, dynamic>;
        final levelData = results[1];

        if (mounted) {
          setState(() {
            // 1. Set Name
            String fullName = profileData['full_name'] ?? "Friend";
            _userName = fullName.split(' ')[0];

            // 2. Set Avatar
            _avatarUrl = profileData['avatar_url'];

            // 3. Set Status & Pro Flag
            if (levelData != null && levelData['status'] != null) {
              _levelStatus = levelData['status'];
              // Check if status contains "Premium"
              _isPro =
                  _levelStatus == 'Monthly Premium' ||
                  _levelStatus == 'Yearly Premium';
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching home data: $e");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (_isSearching) {
        _searchResults = _masterSearchData.where((item) {
          final title = item['title'].toString().toLowerCase();
          final desc = item['desc'].toString().toLowerCase();
          final category = item['category'].toString().toLowerCase();
          return title.contains(query) ||
              desc.contains(query) ||
              category.contains(query);
        }).toList();

        _searchResults.sort((a, b) {
          bool aMatch = a['title'].toString().toLowerCase().startsWith(query);
          bool bMatch = b['title'].toString().toLowerCase().startsWith(query);
          if (aMatch && !bMatch) return -1;
          if (!aMatch && bMatch) return 1;
          return 0;
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _bgController.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          RepaintBoundary(child: _buildBackgroundDecoration()),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _isSearching
                      ? const SizedBox(height: 10)
                      : Column(
                          children: [
                            // --- UPDATED HEADER CALL ---
                            DashboardHeader(
                              userName: _userName,
                              isPro: _isPro,
                              avatarUrl: _avatarUrl, // Pass URL from DB
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildFunctionalSearchBar(),
                ),

                const SizedBox(height: 24),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isSearching
                        ? _buildSearchResults()
                        : _buildDashboardContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionTitle(
              title: "Focus Mode",
              subtitle: "Boost your concentration",
            ),
          ),
          const SizedBox(height: 18),
          const FocusSection(),
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSectionTitle(
              title: "Study Tools",
              subtitle: "Master your learning process",
              actionText: "View All",
              onAction: () => widget.onSwitchTab(1),
            ),
          ),
          const SizedBox(height: 16),
          const ToolsGrid(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              "No matching features found",
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.freeBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item['icon'], color: item['color'], size: 24),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            subtitle: Text(
              item['desc'],
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item['screen']),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFunctionalSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSearching
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: "What do you want to learn?",
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _bgAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: -80 + _bgAnimation.value,
                  right: -60,
                  child: _buildOptimizedBlob(
                    300,
                    AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  top: 350 - _bgAnimation.value,
                  left: -80,
                  child: _buildOptimizedBlob(
                    250,
                    AppColors.secondary.withValues(alpha: 0.06),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: CustomPaint(painter: const DotPatternPainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizedBlob(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  const DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    const double spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
