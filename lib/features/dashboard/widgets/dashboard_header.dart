import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final bool isPro;
  final String? avatarUrl; // 1. New parameter for the image URL
  final VoidCallback? onAvatarTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.isPro = true,
    this.avatarUrl, // 2. Accept it here
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                // 1. Sapaan
                Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textMain.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),

                // 2. Nama User & Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                    ),

                    // 3. Badge PRO (Dynamic)
                    if (isPro) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B), // Gold/Orange Pro
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

                // 4. Subtitle
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

          // --- BAGIAN KANAN: AVATAR (Dynamic Fetch) ---
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
              child: ClipOval(child: _buildAvatarImage()),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER UNTUK MENAMPILKAN GAMBAR ---
  Widget _buildAvatarImage() {
    // 1. Jika ada URL dari DB
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        // Loading indicator kecil saat gambar di-download
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          );
        },
        // Jika URL error/expired, fallback ke inisial nama
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar();
        },
      );
    }
    // 2. Jika tidak ada URL (user belum upload), pakai inisial nama
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random&color=fff',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // 3. Fallback terakhir jika offline (Icon biasa)
        return Container(
          color: AppColors.primary.withValues(alpha: 0.05),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.textMain,
            size: 30,
          ),
        );
      },
    );
  }
}
