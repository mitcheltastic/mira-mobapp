import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class MiraButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutline; // True jika ingin tombol transparan (border only)

  const MiraButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      height: 56, // Tinggi tombol yang nyaman disentuh
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: AppColors.primary,
              ),
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
    );
  }
}