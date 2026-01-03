import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';

class ReportPostSheet extends StatefulWidget {
  const ReportPostSheet({super.key});

  @override
  State<ReportPostSheet> createState() => _ReportPostSheetState();
}

class _ReportPostSheetState extends State<ReportPostSheet> {
  // Opsi Report
  final List<String> _reasons = [
    "It's spam",
    "Nudity or sexual activity",
    "Hate speech or symbols",
    "Violence or dangerous organizations",
    "Bullying or harassment",
    "False information",
    "Scam or fraud",
    "Something else",
  ];

  String? _selectedReason;

  void _submitReport() {
    Navigator.pop(context); // Tutup sheet
    
    // Tampilkan konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("Thanks for letting us know"),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Report",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Why are you reporting this post?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          // List Options
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _reasons.length,
              separatorBuilder: (c, i) => const Divider(height: 1, indent: 24, endIndent: 24),
              itemBuilder: (context, index) {
                final reason = _reasons[index];
                final isSelected = _selectedReason == reason;

                return InkWell(
                  onTap: () => setState(() => _selectedReason = reason),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 15, color: AppColors.textMain),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Button
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null ? _submitReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textMain,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "Submit Report",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}