import 'package:flutter/material.dart';
import '../.././../../core/constant/app_colors.dart';
import '../../../../core/widgets/mira_text_field.dart';
import '../widgets/study_card.dart';

// --- IMPORT SEMUA HALAMAN TOOLS ---
import '../pomodoro_screen.dart';
import '../feynman_screen.dart';
import '../flashcard_screen.dart';
import '../eisenhower_screen.dart';
import '../blurting_screen.dart';
import '../../../second_brain/presentation/second_brain_screen.dart'; // Import Second Brain

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // Data Tools
  final List<Map<String, dynamic>> _tools = [
    {
      "title": "Pomodoro Timer",
      "desc": "Boost focus with 25-min work intervals.",
      "icon": Icons.timer_outlined,
      "color": AppColors.secondary, // Coral
      "category": "Focus"
    },
    {
      "title": "Feynman Technique",
      "desc": "Learn by teaching concept in simple terms.",
      "icon": Icons.record_voice_over_outlined,
      "color": Colors.purple,
      "category": "Understanding"
    },
    {
      "title": "Flashcards",
      "desc": "Active recall testing for better memory.",
      "icon": Icons.style_outlined,
      "color": Colors.orange,
      "category": "Memory"
    },
    {
      "title": "Eisenhower Matrix",
      "desc": "Prioritize tasks by urgency and importance.",
      "icon": Icons.grid_view,
      "color": Colors.blue,
      "category": "Productivity"
    },
    {
      "title": "Second Brain",
      "desc": "Organize your notes and ideas systematically.",
      "icon": Icons.psychology_outlined,
      "color": AppColors.primary, // Indigo
      "category": "Knowledge"
    },
    {
      "title": "Blurting Method",
      "desc": "Write everything you know to test gaps.",
      "icon": Icons.edit_note_rounded,
      "color": Colors.teal,
      "category": "Active Recall"
    },
  ];

  // --- FUNGSI NAVIGASI ---
  void _navigateToTool(String title) {
    Widget destination;

    switch (title) {
      case "Pomodoro Timer":
        destination = const PomodoroScreen();
        break;
      case "Feynman Technique":
        destination = const FeynmanScreen();
        break;
      case "Flashcards":
        destination = const FlashcardScreen();
        break;
      case "Eisenhower Matrix":
        destination = const EisenhowerScreen();
        break;
      case "Second Brain":
        destination = const SecondBrainScreen();
        break;
      case "Blurting Method":
        destination = const BlurtingScreen();
        break;
      default:
        // Fallback jika belum ada halaman
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("$title is coming soon!")),
        );
        return;
    }

    // Eksekusi Pindah Halaman
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Learning Library",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.filter_list, color: AppColors.textMain),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // 1. Search Bar
            const MiraTextField(
              hintText: "Search technique...",
              icon: Icons.search,
            ),

            // 2. Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All", true),
                  _buildFilterChip("Focus", false),
                  _buildFilterChip("Memory", false),
                  _buildFilterChip("Understanding", false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Grid Content
            Expanded(
              child: GridView.builder(
                itemCount: _tools.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, 
                ),
                itemBuilder: (context, index) {
                  final tool = _tools[index];
                  return StudyCard(
                    title: tool['title'],
                    description: tool['desc'],
                    icon: tool['icon'],
                    color: tool['color'],
                    category: tool['category'],
                    onTap: () {
                      // PANGGIL FUNGSI NAVIGASI
                      _navigateToTool(tool['title']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textMuted,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}