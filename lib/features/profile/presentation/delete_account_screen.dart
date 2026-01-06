import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/presentation/login_screen.dart'; // Ensure path is correct
import '../../auth/data/auth_repository.dart'; // Ensure path is correct

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isLoading = false;

  // --- DELETE LOGIC ---
  Future<void> _handleDeleteAccount() async {
    // 1. Show Confirmation Dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Final Confirmation",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "This action cannot be undone. Your data will be permanently wiped from our servers immediately. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Yes, Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);

    try {
      // 2. Perform Deletion using RPC
      // We call the SQL function we just created.
      // This deletes from auth.users, which automatically cascades to profiles, posts, etc.
      await Supabase.instance.client.rpc('delete_own_account');

      // 3. Local Cleanup
      // Even though the account is gone on server, we clear the local session
      await AuthRepository().signOut();

      if (mounted) {
        // 4. Reroute to Login Screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account successfully deleted."),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting account: $e"),
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
      backgroundColor: const Color(0xFFFFF1F2), // Light Red tint background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                // --- SCROLLABLE CONTENT ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "We're sorry to see you go.",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Before you proceed, please read the following consequences carefully:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- LONG TEXT TO FORCE SCROLLING ---
                        _buildWarningPoint("1. Loss of all Personal Data"),
                        _buildDescription(
                          "Deleting your account will permanently remove all your profile information, settings, and preferences. This data cannot be recovered once the deletion process has started.",
                        ),
                        const SizedBox(height: 16),
                        _buildWarningPoint("2. Notes and Flashcards"),
                        _buildDescription(
                          "All the notes you have created, Second Brain entries, and Flashcard decks will be wiped from our database. You will lose access to all your study materials immediately.",
                        ),
                        const SizedBox(height: 16),
                        _buildWarningPoint("3. Subscription Forfeiture"),
                        _buildDescription(
                          "If you have an active Monthly or Yearly Pro plan, deleting your account does NOT automatically cancel the billing with Apple or Google. You must cancel the subscription manually in your App Store settings to avoid future charges. Any remaining time on your subscription will be forfeited.",
                        ),
                        const SizedBox(height: 16),
                        _buildWarningPoint("4. History and Analytics"),
                        _buildDescription(
                          "Your chat history with the AI, learning progress, and usage analytics will be completely erased. We will not be able to retrieve this information for you in the future.",
                        ),
                        const SizedBox(height: 16),
                        _buildWarningPoint("5. Irreversible Action"),
                        _buildDescription(
                          "This action is final. If you change your mind later, you will need to create a brand new account and start from scratch.",
                        ),
                        const SizedBox(height: 16),
                        _buildDescription(
                          "By clicking the button below, you acknowledge that you understand these consequences and wish to proceed with the permanent deletion of your Mira App account.",
                        ),
                        const SizedBox(height: 16),
                        _buildDescription(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // --- BOTTOM BUTTON ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleDeleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "DELETE MY ACCOUNT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildWarningPoint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
      ),
    );
  }
}
