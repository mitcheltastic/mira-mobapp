import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constant/app_colors.dart';

// --- IMPORT LAYAR FITUR ---
import 'pomodoro_screen.dart';
import 'feynman_screen.dart';
import 'flashcard_screen.dart';
import 'mind_map_screen.dart'; // Fitur Baru
import 'notes_screen.dart';    // Fitur Baru

// --- IMPORT WIDGET GRID (Kita buat di bawah) ---
import '../widgets/study_tools_grid.dart'; 

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // 1. State untuk Filter & Search
  String _searchQuery = "";
  String _selectedCategory = "All";

  // 2. Data Master Tools
  final List<Map<String, dynamic>> _allTools = [
    {
      "title": "Pomodoro Timer",
      "desc": "Boost focus with 25-min intervals.",
      "icon": Icons.timer_outlined,
      "color": const Color(0xFFF43F5E), // Rose
      "category": "Focus",
      "screen": const PomodoroScreen(),
    },
    {
      "title": "Flashcards",
      "desc": "Active recall testing.",
      "icon": Icons.style_outlined,
      "color": const Color(0xFFF59E0B), // Amber
      "category": "Memory",
      "screen": const FlashcardScreen(),
    },
    {
      "title": "Feynman Method",
      "desc": "Learn by simplifying.",
      "icon": Icons.record_voice_over_outlined,
      "color": const Color(0xFF3B82F6), // Blue
      "category": "Understanding",
      "screen": const FeynmanScreen(),
    },
    {
      "title": "Mind Map",
      "desc": "Visualize & connect ideas.",
      "icon": Icons.hub_outlined,
      "color": const Color(0xFF10B981), // Emerald
      "category": "Understanding",
      "screen": const MindMapScreen(),
    },
    {
      "title": "Smart Notes",
      "desc": "Capture & organize thoughts.",
      "icon": Icons.edit_note_rounded,
      "color": const Color(0xFF8B5CF6), // Violet
      "category": "Tools",
      "screen": const NotesScreen(),
    },
    // Placeholder untuk fitur masa depan
    {
      "title": "Blurting",
      "desc": "Test knowledge gaps.",
      "icon": Icons.psychology_alt_outlined,
      "color": Colors.teal,
      "category": "Memory",
      "screen": null, // Belum ada screen
    },
  ];

  // 3. Logika Filter
  List<Map<String, dynamic>> get _filteredTools {
    return _allTools.where((tool) {
      // Cek Kategori
      final categoryMatch = _selectedCategory == "All" || tool['category'] == _selectedCategory;
      
      // Cek Search Text
      final searchMatch = tool['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          tool['desc'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Status Bar Style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Learning Library",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select a tool to upgrade your learning process.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  _buildSearchBar(),
                ],
              ),
            ),

            // --- FILTER CHIPS ---
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip("All"),
                  _buildFilterChip("Focus"),
                  _buildFilterChip("Memory"),
                  _buildFilterChip("Understanding"),
                  _buildFilterChip("Tools"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- GRID SECTION (Modular) ---
            Expanded(
              child: _filteredTools.isEmpty
                  ? _buildEmptyState()
                  : StudyToolsGrid(tools: _filteredTools), // Memanggil Widget Grid Terpisah
            ),
          ],
        ),
      ),
    );
  }

  // Widget Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Search method or tool...",
          hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // Widget Filter Chip
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
          Icon(Icons.search_off_rounded, size: 60, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            "No tools found",
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}