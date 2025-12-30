import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class StudyToolsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tools;

  const StudyToolsGrid({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder digunakan untuk mendapatkan lebar layar yang akurat
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung lebar item (total lebar - padding kiri kanan - spacing tengah) / 2
        final double itemWidth = (constraints.maxWidth - 40 - 16) / 2;
        
        // Estimasi tinggi konten yang dibutuhkan agar tidak overflow:
        // Header (~40) + Spacer + Title (~50) + Desc (~40) + Footer (~20) + Padding (~32)
        // Kita set target tinggi sekitar 210-220px agar aman.
        const double targetHeight = 220.0; 
        
        // Hitung aspect ratio: Lebar / Tinggi
        final double childAspectRatio = itemWidth / targetHeight;

        return GridView.builder(
          // Padding bawah dilebihkan agar tidak tertutup FAB/Nav Bar
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          physics: const BouncingScrollPhysics(),
          
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Rasio dinamis mencegah overflow di berbagai ukuran layar
            childAspectRatio: childAspectRatio,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return _StudyToolCard(tool: tools[index]);
          },
        );
      },
    );
  }
}

// Widget dipisah agar lebih ringan (rebuild hanya per item jika perlu)
class _StudyToolCard extends StatelessWidget {
  final Map<String, dynamic> tool;

  const _StudyToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    final Color toolColor = tool['color'] as Color? ?? AppColors.primary;
    final bool isComingSoon = tool['screen'] == null;
    final String category = tool['category'] ?? "Tool";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Shadow lebih halus dan menyebar ke bawah
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
        // Border tipis untuk definisi
        border: Border.all(
          color: AppColors.freeBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (!isComingSoon) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => tool['screen']),
              );
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${tool['title']} is coming soon!"),
                  backgroundColor: AppColors.textMain,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(20),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: toolColor.withValues(alpha: 0.05),
          highlightColor: toolColor.withValues(alpha: 0.02),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Dekorasi Background (Lingkaran Pudar di pojok kanan atas)
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        toolColor.withValues(alpha: 0.08),
                        toolColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Konten Utama
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon Box & Category Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Box
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: toolColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            tool['icon'] as IconData,
                            color: toolColor,
                            size: 22,
                          ),
                        ),
                        // Category Pill (Kecil di pojok)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 4
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.freeBorder.withValues(alpha: 0.5)
                            ),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(), // Mendorong konten ke bawah

                    // Title
                    Text(
                      tool['title'],
                      maxLines: 1, // Batasi 1 baris agar rapi
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Expanded(
                      flex: 0,
                      child: Text(
                        tool['desc'],
                        maxLines: 2, // Maksimal 2 baris
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Footer Line (Indikator Warna)
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isComingSoon 
                                ? AppColors.freeBorder 
                                : toolColor.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        if (!isComingSoon)
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: toolColor.withValues(alpha: 0.5),
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