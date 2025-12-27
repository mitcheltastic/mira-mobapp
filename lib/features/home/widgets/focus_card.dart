import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../study_tools/presentation/pomodoro_screen.dart'; 

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140, // Tinggi fix agar proporsional
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Shadow yang lebih soft dan menyebar
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      // ClipRRect penting agar dekorasi background tidak keluar dari border
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. BACKGROUND GRADIENT & PATTERN
            _buildBackground(),

            // 2. CONTENT UTAMA (Ripple Effect wrapper)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PomodoroScreen()),
                  );
                },
                splashColor: Colors.white.withValues(alpha: 0.1),
                highlightColor: Colors.white.withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // KIRI: Teks & Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tag Kecil
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                                  const SizedBox(width: 6),
                                  Text(
                                    "POMODORO",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Judul Utama
                            const Text(
                              "Deep Focus",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Subtitle
                            Text(
                              "25 min • High Priority",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // KANAN: Play Button Besar
                      _buildPlayButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Terpisah untuk Kerapihan ---

  Widget _buildBackground() {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                const Color(0xFF6366F1), // Warna Indigo sedikit lebih terang
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Dekorasi Lingkaran Abstrak 1 (Pojok Kanan Atas)
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        
        // Dekorasi Lingkaran Abstrak 2 (Pojok Kiri Bawah)
        Positioned(
          bottom: -40,
          left: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          // Inner Shadow effect (sedikit)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          // Glow effect keluar
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 0,
            spreadRadius: 6, // Ring transparan di luar tombol
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.play_arrow_rounded,
          color: AppColors.primary,
          size: 30,
        ),
      ),
    );
  }
}