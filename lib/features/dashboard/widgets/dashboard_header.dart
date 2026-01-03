import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Pastikan package ini ada
import '../../../core/constant/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final bool isPro;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final bool isLoading; // 1. Parameter baru untuk status loading

  const DashboardHeader({
    super.key,
    required this.userName,
    this.isPro = false,
    this.avatarUrl,
    this.onAvatarTap,
    this.isLoading = false, // Default false
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
                // 1. Sapaan (Tetap statis agar rapi)
                Text(
                  "Hello,",
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.textMain.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 4),

                // 2. Nama User & Badge (Tampilkan Skeleton jika loading)
                isLoading
                    ? _buildNameSkeleton()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              userName.isEmpty ? "User" : userName,
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

          // --- BAGIAN KANAN: AVATAR ---
          const SizedBox(width: 16),
          GestureDetector(
            // Disable tap saat loading
            onTap: isLoading ? null : onAvatarTap, 
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
              child: ClipOval(
                // Tampilkan Skeleton jika isLoading = true
                child: isLoading 
                  ? _buildAvatarSkeleton() 
                  : _buildAvatarImage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET SKELETON (SHIMMER) ---

  Widget _buildNameSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 180, // Lebar perkiraan nama
        height: 32, // Tinggi sesuai font size 32
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAvatarSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 52,
        height: 52,
        color: Colors.white,
      ),
    );
  }

  // --- LOGIC GAMBAR AVATAR ---

  Widget _buildAvatarImage() {
    // 1. Jika URL valid
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        // Loading Builder: Saat gambar sedang didownload (bytes), tampilkan skeleton juga
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildAvatarSkeleton();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar();
        },
      );
    }
    // 2. Fallback jika URL kosong
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    // Pastikan nama aman untuk URL (tidak error jika kosong)
    final safeName = userName.trim().isEmpty ? "User" : userName;
    
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(safeName)}&background=random&color=fff&bold=true',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback terakhir (Offline Icon)
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