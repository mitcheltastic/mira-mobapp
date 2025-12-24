import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class BlurtingScreen extends StatelessWidget {
  const BlurtingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Blurting Method"),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {}, 
            child: const Text("Timer: 10:00", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Topic:",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted),
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: "e.g. OSI Layers",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                maxLines: null, // Unlimited lines
                decoration: const InputDecoration(
                  hintText: "Write everything you remember without stopping...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(height: 1.5, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}