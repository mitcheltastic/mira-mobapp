import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

// Import Screen Fitur
import '../../study_tools/presentation/feynman_screen.dart';
import '../../study_tools/presentation/pomodoro_screen.dart';
// 1. Tambahkan Import MindMapScreen
import '../../study_tools/presentation/mind_map_screen.dart';
import '../../study_tools/presentation/notes_screen.dart';

class ToolsGrid extends StatelessWidget {
  const ToolsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {
        "icon": Icons.timer_outlined,
        "label": "Pomodoro",
        "desc": "Focus timer",
        "color": const Color(0xFFF43F5E), // Rose/Red
        "action": () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const PomodoroScreen())
          );
        }
      },
      {
        "icon": Icons.graphic_eq,
        "label": "Feynman",
        "desc": "Explain ideas",
        "color": const Color(0xFF3B82F6), // Blue
        "action": () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const FeynmanScreen())
          );
        }
      },
      {
        "icon": Icons.hub_outlined,
        "label": "Mind Map",
        "desc": "Visualize logic",
        "color": const Color(0xFF10B981), // Emerald/Green
        "action": () {
          // 2. UPDATE NAVIGASI KE MIND MAP SCREEN
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const MindMapScreen())
          );
        }
      },
      {
        "icon": Icons.edit_note_rounded,
        "label": "Notes",
        "desc": "Quick thoughts",
        "color": const Color(0xFF8B5CF6), // Violet
        "action": () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const NotesScreen())
          );
        }
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = tools[index];
        return _buildToolCard(
          context: context,
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          desc: item['desc'] as String,
          color: item['color'] as Color,
          onTap: item['action'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildToolCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.shadow.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 26,
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
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
}