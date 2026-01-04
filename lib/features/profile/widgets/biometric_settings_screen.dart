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
  bool _isSocialLogin = false;
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

      final String provider = user?.appMetadata['provider'] ?? 'email';
      _isSocialLogin = provider != 'email';

      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      final storedValue = await _storage.read(
        key: 'bio_enabled_$_currentUserEmail',
      );

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
          const SnackBar(
            content: Text("Biometric login disabled"),
            backgroundColor: Colors.grey,
          ),
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
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Setup Biometrics"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isSocialLogin
                        ? "Enable biometric login for $_currentUserEmail?"
                        : "Enter your password to securely enable biometric login.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isSocialLogin)
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
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          final password = passwordController.text.trim();
                          if (!_isSocialLogin && password.isEmpty) return;

                          setStateDialog(() => isDialogLoading = true);

                          try {
                            bool authenticated = await auth.authenticate(
                              localizedReason: 'Scan to confirm setup',
                              options: const AuthenticationOptions(
                                stickyAuth: true,
                              ),
                            );

                            if (!authenticated) {
                              setStateDialog(() => isDialogLoading = false);
                              return;
                            }

                            await _storage.write(
                              key: 'bio_enabled_$_currentUserEmail',
                              value: 'true',
                            );

                            if (!_isSocialLogin) {
                              await _storage.write(
                                key: 'bio_pass_$_currentUserEmail',
                                value: password,
                              );
                            }

                            await _storage.delete(
                              key: 'bio_ignored_$_currentUserEmail',
                            );
                            await _storage.write(
                              key: 'last_bio_user',
                              value: _currentUserEmail,
                            );

                            if (mounted) {
                              setState(() => _isBiometricEnabled = true);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Biometrics enabled!"),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
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
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    // Tentukan warna status: HIJAU (Success) jika aktif
    final statusColor = _isBiometricEnabled ? AppColors.success : Colors.grey;
    final statusText = _isBiometricEnabled ? "Active" : "Inactive";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Biometric Settings",
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textMain,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // 1. HERO ICON SECTION
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.1),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 64,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 2. TOGGLE CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          activeTrackColor: AppColors.success, 
                          activeThumbColor: Colors.white, 

                          title: const Text(
                            "Biometric Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            _canCheckBiometrics
                                ? "Log in faster with your face or fingerprint."
                                : "Not available on this device.",
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                          value: _isBiometricEnabled,
                          onChanged: _canCheckBiometrics ? _toggleBiometric : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. UPDATE CREDENTIALS INFO BOX
                  if (_isBiometricEnabled && !_isSocialLogin)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                "Did you change your password?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "If you recently changed your account password, you need to update it here to keep biometric login working.",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showSetupDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: Colors.blue.withValues(alpha: 0.3)),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Update Credentials",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}