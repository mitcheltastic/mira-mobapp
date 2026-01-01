import 'package:flutter/material.dart';

class AppColors {
  // --- Backgrounds ---
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  
  // --- Brand Identity ---
  static const Color primary = Color(0xFF4F46E5);   // Indigo
  static const Color secondary = Color(0xFFF43F5E); // Rose
  static const Color third = Color(0xFF10B981);     // Emerald

  // --- Study Tools Specific ---
  
  // 1. Eisenhower Matrix
  static const Color eisenhowerDo = Color(0xFFEF4444);
  static const Color eisenhowerPlan = Color(0xFF3B82F6);
  static const Color eisenhowerDelegate = Color(0xFFF59E0B);
  static const Color eisenhowerDrop = Color(0xFF64748B);

  // 2. Blurting Method
  static const Color blurtingWriting = Color(0xFFF43F5E);
  static const Color blurtingReview = Color(0xFF6366F1);

  // 3. Feynman Technique (NEW)
  static const Color feynmanConcept = Color(0xFF0EA5E9); // Sky Blue (Intellect/Idea)
  static const Color feynmanTeach = Color(0xFF6366F1);   // Indigo (Teaching)
  static const Color feynmanRefine = Color(0xFF10B981);  // Emerald (Refining/Success)

  // --- Typography ---
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color flashcardTheme = Color(0xFFF59E0B);

  // --- Functional Status ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- Badge / Chips ---
  static const Color proGold = Color(0xFFD97706);
  static const Color proBg = Color(0xFFFFF7ED);
  static const Color proBorder = Color(0xFFFFEDD5);
  static const Color freeBg = Color(0xFFF1F5F9);
  static const Color freeBorder = Color(0xFFE2E8F0);

  // --- Borders & Shadows ---
  static const Color border = Color(0xFFE2E8F0);
  static Color shadow = const Color(0xFF94A3B8).withValues(alpha: 0.2);
}