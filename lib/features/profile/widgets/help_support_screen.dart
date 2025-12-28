import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // --- DATA FAQ YANG LEBIH BANYAK ---
  final List<Map<String, String>> _faqs = [
    {
      "question": "How do I upgrade to Pro Plan?",
      "answer": "Go to your Profile page, tap on the subscription card, and choose between the Monthly or Yearly plan to unlock all features."
    },
    {
      "question": "What is the 'Second Brain' feature?",
      "answer": "Second Brain is a digital note-taking system designed to help you organize thoughts, ideas, and learning materials efficiently in one place."
    },
    {
      "question": "Does the app support Offline Mode?",
      "answer": "Yes! You can access your Notes, Flashcards, and Eisenhower Matrix without an internet connection. However, AI Chat features require active data."
    },
    {
      "question": "How do I restore my purchase?",
      "answer": "If you changed devices or reinstalled the app, go to the Subscription page and tap the 'Restore' button at the top right corner."
    },
    {
      "question": "Can I sync my data across multiple devices?",
      "answer": "Yes, as long as you are logged in with the same email account, your data will automatically sync across all your devices in real-time."
    },
    {
      "question": "How do I reset my password?",
      "answer": "Go to Profile > Security & Password. If you are logged out, click 'Forgot Password' on the login screen and follow the instructions sent to your email."
    },
    {
      "question": "Is my data secure?",
      "answer": "Absolutely. We use end-to-end encryption for your personal notes and data. We do not sell your data to third parties."
    },
    {
      "question": "How do I cancel my subscription?",
      "answer": "You can cancel anytime via the Google Play Store or Apple App Store subscriptions menu. The Pro features will remain active until the end of the billing period."
    },
    {
      "question": "I found a bug, where can I report it?",
      "answer": "We appreciate your help! Please click the 'Send Email' button above to send us the details and screenshots of the bug."
    },
  ];

  // --- FUNGSI SIMULASI KONTAK (AGAR TERASA NYATA) ---
  
  void _contactCS() async {
    // 1. Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    // 2. Simulasi Delay (Mencari aplikasi WhatsApp...)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context); // Tutup Loading
      // 3. Tampilkan Feedback Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.headset_mic_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text("Opening WhatsApp Chat..."),
            ],
          ),
          backgroundColor: const Color(0xFF25D366), // Warna WA
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendEmail() async {
    // 1. Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );

    // 2. Simulasi Delay (Membuka aplikasi Email...)
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pop(context); // Tutup Loading
      // 3. Tampilkan Feedback Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Drafting email to support@mira.app..."),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Help & Support",
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How can we help you?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select a contact method or browse FAQs below.",
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // --- 1. CONTACT SUPPORT GRID (DIBUAT BERFUNGSI) ---
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.headset_mic_rounded, // Icon CS
                    title: "Live Chat",
                    subtitle: "Connect via WhatsApp",
                    color: Colors.green, // Identik dengan WA
                    onTap: _contactCS, // Panggil fungsi simulasi
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.email_rounded,
                    title: "Send Email",
                    subtitle: "Get response in 24h",
                    color: Colors.orange,
                    onTap: _sendEmail, // Panggil fungsi simulasi
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- 2. FAQ SECTION (LEBIH BANYAK) ---
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 16),
            
            // Generate list FAQ
            ..._faqs.map((faq) => _buildFAQItem(faq['question']!, faq['answer']!)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        // Menghilangkan garis pembatas default ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          iconColor: AppColors.primary,
          collapsedIconColor: Colors.grey,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}