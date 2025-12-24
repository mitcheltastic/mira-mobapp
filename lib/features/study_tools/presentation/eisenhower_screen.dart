import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class EisenhowerScreen extends StatelessWidget {
  const EisenhowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Eisenhower Matrix"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Baris Atas
          Expanded(
            child: Row(
              children: [
                _buildQuadrant("Do First", "Urgent & Important", Colors.red.shade100, Colors.red),
                _buildQuadrant("Schedule", "Not Urgent & Important", Colors.blue.shade100, Colors.blue),
              ],
            ),
          ),
          // Baris Bawah
          Expanded(
            child: Row(
              children: [
                _buildQuadrant("Delegate", "Urgent & Not Important", Colors.orange.shade100, Colors.orange),
                _buildQuadrant("Don't Do", "Not Urgent & Not Important", Colors.grey.shade200, Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrant(String title, String subtitle, Color bgColor, Color accentColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: accentColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 12),
            // Dummy Tasks
            _buildTaskItem("Finish MIRA UI", accentColor),
            _buildTaskItem("Submit Assignment", accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}