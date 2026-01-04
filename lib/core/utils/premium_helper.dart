import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';

// Import your Subscription Screen
import '../../features/profile/widgets/subscription_screen.dart';

void showPremiumDialog(BuildContext context, {required String featureName}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.amber[700]),
          const SizedBox(width: 8),
          const Text(
            "Premium Required",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$featureName is a premium feature.",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Upgrade your plan to unlock unlimited access to this tool and remove all limits.",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Maybe Later",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.pop(context); // Close the dialog

            // Navigate to Subscription Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionScreen(),
              ),
            );
          },
          child: const Text(
            "Upgrade Now",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
