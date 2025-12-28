import 'package:flutter/material.dart';
import '../../../core/widgets/mira_button.dart';
import '../../../core/widgets/mira_text_field.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email; // Need email to verify

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = AuthRepository();
      await authRepo.verifyOtp(
        email: widget.email,
        token: _otpController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Verified! Please Login.")),
        );
        // Success! Go to Login (or Home)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Enter the code sent to ${widget.email}"),
            const SizedBox(height: 20),
            MiraTextField(
              controller: _otpController,
              hintText: "6-Digit Code",
              icon: Icons.lock_clock,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            MiraButton(
              text: _isLoading ? "Verifying..." : "Verify",
              onPressed: _isLoading ? null : _handleVerify,
            ),
          ],
        ),
      ),
    );
  }
}
