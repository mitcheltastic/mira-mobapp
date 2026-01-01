import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final bool isPro;
  final VoidCallback? onAvatarTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.isPro = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding disamakan dengan StudyScreen & ChatsScreen (24, 24, 24, 16)
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- BAGIAN KIRI: TEKS ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Sapaan kecil (Opsional, atau bisa digabung)
                Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textMain.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                
                // 2. Nama User (Style Title H1 - Konsisten dengan "Study Hub" / "Messages")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 32, // Ukuran font header standar aplikasi
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                    ),
                    
                    // 3. Badge PRO (Minimalis di sebelah nama)
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B), // Warna Emas/Orange Pro
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "PRO",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),

                // 4. Subtitle konsisten
                Text(
                  "Let's start your journey today",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // --- BAGIAN KANAN: AVATAR (Simple Clean) ---
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.freeBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.textMain,
                    size: 30,
                  ),
                  // Nanti ganti child ini dengan Image.asset(...) jika sudah ada foto
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}