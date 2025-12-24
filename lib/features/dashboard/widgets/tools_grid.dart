import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

// Import Layar Fitur yang baru dibuat
import '../../study_tools/presentation/feynman_screen.dart';
import '../../study_tools/presentation/flashcard_screen.dart';

class ToolsGrid extends StatelessWidget {
  const ToolsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Menu + Navigasi
    final tools = [
      {
        "icon": Icons.psychology_outlined,
        "label": "Second Brain",
        "color": Colors.purple,
        // Navigasi manual via Tab Controller nanti (sementara dummy dulu atau arahkan ke screen)
        // Karena ini fitur kompleks, kita biarkan user akses lewat Bottom Nav Bar 'Brain'
        "action": () {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Access this via the 'Brain' tab below! 👇")),
           );
        }
      },
      {
        "icon": Icons.style_outlined,
        "label": "Flashcards",
        "color": Colors.orange,
        "action": () {
          // Buka Flashcard Screen
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardScreen()));
        }
      },
      {
        "icon": Icons.graphic_eq, // Icon Feynman (Suara/Penjelasan)
        "label": "Feynman",
        "color": Colors.blue,
        "action": () {
           // Buka Feynman Screen
           Navigator.push(context, MaterialPageRoute(builder: (context) => const FeynmanScreen()));
        }
      },
      {
        "icon": Icons.bar_chart_rounded,
        "label": "Analytics",
        "color": Colors.green,
        "action": () {
           // Sementara tampilkan info
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Analytics Dashboard coming in next update!")),
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
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          // PANGGIL ACTION SAAT DIKLIK
          onTap: tools[index]['action'] as VoidCallback, 
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (tools[index]['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tools[index]['icon'] as IconData,
                    color: tools[index]['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tools[index]['label'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}