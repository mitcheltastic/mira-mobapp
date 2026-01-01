import 'package:flutter/material.dart';
import '../constant/app_colors.dart';

class MiraTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  // --- TAMBAHAN BARU (Agar error hilang) ---
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const MiraTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    // --- MASUKKAN KE CONSTRUCTOR ---
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<MiraTextField> createState() => _MiraTextFieldState();
}

class _MiraTextFieldState extends State<MiraTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Style aslimu tetap aman
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        
        // --- SAMBUNGKAN PARAMETER BARU KE SINI ---
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,

        style: const TextStyle(color: AppColors.textMain),
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon, 
            color: AppColors.primary.withValues(alpha: 0.7)
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}