import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final bool isPro;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.isPro = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.surface,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's start our journey",
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Row(
          children: [
            // BADGE STATUS SUBSCRIPTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPro ? AppColors.proBg : AppColors.freeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPro ? AppColors.proBorder : AppColors.freeBorder,
                ),
              ),
              child: Row(
                children: [
                  if (isPro)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: AppColors.proGold,
                      ),
                    ),
                  Text(
                    isPro ? "PRO" : "FREE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      // Menggunakan AppColors
                      color: isPro ? AppColors.proGold : AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),
            
            // AVATAR
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.surface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}