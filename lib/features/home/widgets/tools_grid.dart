import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/services/analytics_service.dart'; // 1. Analytics
import '../../../core/utils/premium_helper.dart'; // 2. Premium Helper

// Feature Screens
import '../../study_tools/presentation/feynman_screen.dart';
import '../../study_tools/presentation/flashcard_screen.dart';
import '../../study_tools/presentation/mind_map_screen.dart';
import '../../study_tools/presentation/notes_screen.dart';
import '../../second_brain/presentation/second_brain_screen.dart';
import '../../study_tools/presentation/eisenhower_screen.dart';
import '../../study_tools/presentation/pomodoro_screen.dart'; // Ensure Pomodoro is imported

class ToolsGrid extends StatelessWidget {
  final bool isPro; // Accept isPro status

  const ToolsGrid({super.key, required this.isPro});

  @override
  Widget build(BuildContext context) {
    // Data Tools defined here to access 'isPro' easily
    final List<Map<String, dynamic>> tools = [
      {
        "icon": Icons.timer_outlined,
        "label": "Pomodoro",
        "desc": "Focus timer",
        "color": const Color(0xFFF43F5E),
        "screen": const PomodoroScreen(),
      },
      {
        "icon": Icons.graphic_eq,
        "label": "Feynman",
        "desc": "Explain ideas",
        "color": const Color(0xFF3B82F6),
        "screen": const FeynmanScreen(),
      },
      {
        "icon": Icons.hub_outlined,
        "label": "Mind Map",
        "desc": "Visualize logic",
        "color": const Color(0xFF10B981),
        "screen": const MindMapScreen(),
      },
      {
        "icon": Icons.edit_note_rounded,
        "label": "Notes",
        "desc": "Quick thoughts",
        "color": const Color(0xFF8B5CF6),
        "screen": const NotesScreen(),
      },
      {
        "icon": Icons.psychology_rounded,
        "label": "Second Brain",
        "desc": "Knowledge Base",
        "color": const Color(0xFF1E293B),
        "screen": SecondBrainScreen(isPro: isPro), // Pass isPro
      },
      {
        "icon": Icons.grid_view_rounded,
        "label": "Eisenhower",
        "desc": "Prioritize",
        "color": const Color(0xFF0EA5E9),
        "screen": const EisenhowerScreen(),
      },
      {
        "icon": Icons.style_outlined,
        "label": "Flashcards",
        "desc": "Active Recall",
        "color": const Color(0xFFF59E0B),
        "screen": const FlashcardScreen(),
        "isLocked": !isPro, // Locked feature example
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = tools[index];
        return _ToolCard(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          desc: item['desc'] as String,
          color: item['color'] as Color,
          isLocked: item['isLocked'] ?? false,
          onTap: () {
            // --- 1. TRACK ANALYTICS ---
            final featureKey = item['label']
                .toString()
                .toLowerCase()
                .replaceAll(' ', '_');
            AnalyticsService().logFeature(featureKey);

            // --- 2. CHECK LOCK ---
            if (item['isLocked'] == true) {
              showPremiumDialog(context, featureName: item['label']);
              return;
            }

            // --- 3. NAVIGATE ---
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen']),
            );
          },
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  final bool isLocked; // Added lock status

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.freeBorder.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withValues(alpha: 0.05),
          highlightColor: color.withValues(alpha: 0.02),
          child: Stack(
            children: [
              // Decorative Blob
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.1),
                        color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon Box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        if (isLocked)
                          Icon(
                            Icons.lock_rounded,
                            size: 18,
                            color: Colors.amber[700],
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Description
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Bottom Bar
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: color.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
