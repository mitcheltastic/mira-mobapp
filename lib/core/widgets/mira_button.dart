import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class MiraButton extends StatelessWidget {
  final String text;
  // CHANGE 1: Added '?' to allow null (which disables the button)
  final VoidCallback? onPressed;
  final bool isOutline;

  const MiraButton({
    super.key,
    required this.text,
    // CHANGE 2: This is still required, but now you can pass 'null' into it
    required this.onPressed,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutline
          ? OutlinedButton(
              onPressed: onPressed, // Flutter handles null automatically here
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed, // Flutter handles null automatically here
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // This ensures the disabled color looks right if onPressed is null
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
