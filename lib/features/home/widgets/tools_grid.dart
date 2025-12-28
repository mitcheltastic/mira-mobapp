import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

import '../../study_tools/presentation/feynman_screen.dart';
import '../../study_tools/presentation/pomodoro_screen.dart';
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
        "color": const Color(0xFFF43F5E),
        "action": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()));
        }
      },
      {
        "icon": Icons.graphic_eq,
        "label": "Feynman",
        "desc": "Explain ideas",
        "color": const Color(0xFF3B82F6),
        "action": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FeynmanScreen()));
        }
      },
      {
        "icon": Icons.hub_outlined,
        "label": "Mind Map",
        "desc": "Visualize logic",
        "color": const Color(0xFF10B981),
        "action": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MindMapScreen()));
        }
      },
      {
        "icon": Icons.edit_note_rounded,
        "label": "Notes",
        "desc": "Quick thoughts",
        "color": const Color(0xFF8B5CF6),
        "action": () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotesScreen()));
        }
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // 1. Padding dikurangi dari 24 ke 20 agar kartu punya ruang lebih lebar
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0), 
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // 2. Jarak antar kartu dirapatkan sedikit (16 -> 12) agar kartu makin lebar
        crossAxisSpacing: 12, 
        mainAxisSpacing: 12,
        // 3. Aspect Ratio dinaikkan. 
        // Coba 1.0 (Kotak) atau 1.1 (Agak Ceper). 
        // Di sini saya pakai 1.05 agar pas (tidak terlalu kurus, tidak terlalu ceper).
        childAspectRatio: 1.05, 
      ),
      itemBuilder: (context, index) {
        final item = tools[index];
        return _buildCard(
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

  Widget _buildCard({
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
              // Dekorasi Lingkaran
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90, // Dikecilkan sedikit agar proporsional dengan kotak
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
                // Padding dalam dikurangi sedikit agar konten tidak sesak
                padding: const EdgeInsets.all(14), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 22,
                      ),
                    ),

                    const Spacer(), // Mendorong konten ke bawah

                    // Title
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15, // Font size disesuaikan
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

                    // Footer Line (Action Indicator)
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
                    )
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