import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../../core/constant/app_colors.dart'; 

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // --- DATA FAQ ---
  final List<Map<String, String>> _faqs = [
    {
      "question": "How do I upgrade to Pro Plan?",
      "answer": "Go to your Profile page, tap on the subscription card, and choose between the Monthly or Yearly plan."
    },
    {
      "question": "What is the 'Second Brain' feature?",
      "answer": "Second Brain is a digital note-taking system designed to help you organize thoughts and ideas efficiently."
    },
    {
      "question": "Does the app support Offline Mode?",
      "answer": "Yes! You can access your Notes and Flashcards without an internet connection."
    },
    {
      "question": "How do I restore my purchase?",
      "answer": "Go to the Subscription page and tap the 'Restore' button at the top right corner."
    },
    {
      "question": "Can I sync my data?",
      "answer": "Yes, as long as you are logged in, your data syncs across devices in real-time."
    },
    {
      "question": "How do I reset my password?",
      "answer": "Go to Profile > Security. If logged out, click 'Forgot Password' on the login screen."
    },
    {
      "question": "Is my data secure?",
      "answer": "Absolutely. We use end-to-end encryption. We do not sell your data."
    },
    {
      "question": "How do I cancel my subscription?",
      "answer": "You can cancel anytime via the Google Play Store or Apple App Store subscriptions menu."
    },
    {
      "question": "I found a bug, where can I report it?",
      "answer": "Please use the 'Contact Support' button above to email us details regarding the bug."
    },
  ];

  // --- FUNGSI EMAIL ---
  Future<void> _sendEmail() async {
    final String supportEmail = 'support@mira.app';
    final String subject = 'Help & Support Request';
    final String body = 'Hello Mira Team,\n\nI need help with...';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open email app."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help & Support",
          style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.w700,
              fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              const Text(
                "How can we help?",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                "Find answers to common questions or contact our team directly.",
                style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),

              // --- CONTACT CARD (EMAIL) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                        AppColors.primary, 
                        // PERBAIKAN 1: Ganti withOpacity -> withValues
                        AppColors.primary.withValues(alpha: 0.8) 
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      // PERBAIKAN 2: Ganti withOpacity -> withValues
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mail_lock_outlined, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Still need help?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Our team is ready to assist you.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Email support@mira.app",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Frequently Asked Questions",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ),
              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  return _BuildFAQItem(
                    question: _faqs[index]['question']!,
                    answer: _faqs[index]['answer']!,
                  );
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildFAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _BuildFAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}