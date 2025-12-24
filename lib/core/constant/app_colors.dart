import 'package:flutter/material.dart';

class AppColors {

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Cloud White
  static const Color surface = Color(0xFFFFFFFF);    // Pure White

  // Brand Identity
  static const Color primary = Color(0xFF4F46E5);    // Vivid Indigo
  static const Color secondary = Color(0xFFF43F5E);  // Sunrise Coral (Cheerful Accent)

  // Typography (Dark text for Light background)
  static const Color textMain = Color(0xFF0F172A);   // Deep Navy
  static const Color textMuted = Color(0xFF64748B);  // Cool Grey

  // Functional Status
  static const Color success = Color(0xFF10B981);    // Fresh Mint
  static const Color error = Color(0xFFEF4444);      // Red
  static const Color warning = Color(0xFFF59E0B);    // Orange
  
  // Shadow Color (Penting untuk depth di light mode)
  static Color shadow = const Color(0xFF94A3B8).withValues(alpha: 0.2);
}