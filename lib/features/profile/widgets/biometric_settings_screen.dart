import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_text_field.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  bool _canCheckBiometrics = false;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      _currentUserEmail = user?.email;

      if (_currentUserEmail == null) {
        setState(() => _isLoading = false);
        return;
      }

      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      final storedValue = await _storage.read(key: 'bio_enabled_$_currentUserEmail');

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheck || isDeviceSupported;
          _isBiometricEnabled = storedValue == 'true';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking biometrics: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      _showSetupDialog();
    } else {
      await _disableBiometrics();
    }
  }

  Future<void> _disableBiometrics() async {
    if (_currentUserEmail == null) return;
    setState(() => _isLoading = true);
    try {
      await _storage.delete(key: 'bio_enabled_$_currentUserEmail');
      await _storage.delete(key: 'bio_pass_$_currentUserEmail');
      await _storage.delete(key: 'bio_ignored_$_currentUserEmail');
      String? lastUser = await _storage.read(key: 'last_bio_user');
      if (lastUser == _currentUserEmail) {
        await _storage.delete(key: 'last_bio_user');
      }

      if (mounted) {
        setState(() {
          _isBiometricEnabled = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric login disabled for this account")),
        );
      }
    } catch (e) {
      debugPrint("Error disabling: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSetupDialog() {
    if (_currentUserEmail == null) return;

    final passwordController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Setup Biometrics"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "To enable biometric login for $_currentUserEmail, please enter your password to save it securely.",
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  MiraTextField(
                    controller: passwordController,
                    hintText: "Current Password",
                    isPassword: true,
                    icon: Icons.lock_outline,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final password = passwordController.text.trim();
                          if (password.isEmpty) return;

                          setStateDialog(() => isDialogLoading = true);

                          try {
                            bool authenticated = await auth.authenticate(
                              localizedReason: 'Scan to enable biometrics',
                              options:
                                  const AuthenticationOptions(stickyAuth: true),
                            );

                            if (!authenticated) {
                              setStateDialog(() => isDialogLoading = false);
                              return;
                            }

                            await _storage.write(
                                key: 'bio_enabled_$_currentUserEmail', value: 'true');
                            await _storage.write(
                                key: 'bio_pass_$_currentUserEmail', value: password);
                            await _storage.delete(key: 'bio_ignored_$_currentUserEmail');
                            await _storage.write(
                                key: 'last_bio_user', value: _currentUserEmail);
                            if (mounted) {
                              setState(() => _isBiometricEnabled = true);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Biometrics enabled successfully!"),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("Error setup: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                               setStateDialog(() => isDialogLoading = false);
                            }
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Enable & Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Biometric Settings",
          style:
              TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _canCheckBiometrics
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.fingerprint_rounded,
                                  size: 28,
                                  color: _canCheckBiometrics
                                      ? AppColors.primary
                                      : Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Biometric Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _canCheckBiometrics
                                        ? "Use fingerprint or face ID to log in."
                                        : "Biometrics not available.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_canCheckBiometrics)
                              Switch.adaptive(
                                value: _isBiometricEnabled,
                                activeTrackColor: AppColors.primary,
                                onChanged: _toggleBiometric,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  if (_isBiometricEnabled) ...[
                    const Text(
                      "Changed your password?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _showSetupDialog,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Update Biometric Credentials",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    const Text(
                      "If you changed your account password recently, please update it here so biometric login continues to work.",
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}