import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final bool isPro;

  const DashboardHeader({super.key, required this.userName, this.isPro = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Memberikan ruang nafas pada header
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // BAGIAN KIRI: TEKS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.textMain, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "Hello, $userName",
                    style: const TextStyle(
                      fontSize: 26, // Ukuran sedikit disesuaikan agar lebih proporsional
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Let's start our journey",
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // BAGIAN KANAN: BADGE & AVATAR
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BADGE STATUS (PRO/FREE)
              _buildStatusBadge(),
              
              const SizedBox(width: 16),

              // AVATAR DENGAN RING DESIGN
              _buildAvatar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPro ? AppColors.proBg : AppColors.freeBg,
        borderRadius: BorderRadius.circular(20), // Pill style lebih rapi
        border: Border.all(
          color: isPro ? AppColors.proBorder : AppColors.freeBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isPro) ...[
            const Icon(
              Icons.verified_rounded,
              size: 14,
              color: AppColors.proGold,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            isPro ? "PRO" : "FREE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isPro ? AppColors.proGold : AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(2), // Jarak untuk ring border luar
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}