import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // 0 = Monthly, 1 = Yearly
  int _selectedPlanIndex = 1;
  bool _isLoading = false; // Processing payment/cancellation
  bool _isFetching = true; // Loading initial data

  // 'Reguler', 'Monthly Premium', 'Yearly Premium'
  String _currentStatus = 'Reguler';

  @override
  void initState() {
    super.initState();
    _fetchUserLevel();
  }

  // --- 1. FETCH CURRENT LEVEL ---
  Future<void> _fetchUserLevel() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('level')
            .select('status')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _currentStatus = data?['status'] ?? 'Reguler';
            _isFetching = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching level: $e");
      if (mounted) setState(() => _isFetching = false);
    }
  }

  // --- 2. SUBSCRIBE LOGIC ---
  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final String newStatus = _selectedPlanIndex == 0
          ? 'Monthly Premium'
          : 'Yearly Premium';

      // Simulate Payment
      await Future.delayed(const Duration(seconds: 2));

      // Update DB
      await Supabase.instance.client.from('level').upsert({
        'id': user.id,
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _currentStatus = newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Success! You are now a $newStatus user."),
            backgroundColor: const Color(0xFF34D399),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Subscription failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. CANCEL SUBSCRIPTION LOGIC ---
  Future<void> _cancelSubscription() async {
    // Show Confirmation Dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Subscription?"),
        content: const Text(
          "You will lose access to all Pro features immediately. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep Pro", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Confirm Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Revert status to 'Reguler'
      await Supabase.instance.client.from('level').upsert({
        'id': user.id,
        'status': 'Reguler',
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _currentStatus = 'Reguler');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Subscription cancelled. You are now on Reguler plan.",
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Cancellation failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the selected plan is the one the user ALREADY has
    bool isMonthly = _selectedPlanIndex == 0;
    bool isAlreadySubscribedToSelected =
        (isMonthly && _currentStatus == 'Monthly Premium') ||
        (!isMonthly && _currentStatus == 'Yearly Premium');

    // Check if user has ANY premium plan active
    bool hasActivePremium = _currentStatus != 'Reguler';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            )
          : Stack(
              children: [
                // --- HEADER BACKGROUND ---
                Container(
                  height: 450,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(48),
                      bottomRight: Radius.circular(48),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // --- TOP BAR ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // --- ICON & TITLE ---
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF34D399,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 56,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Maximize Your Learning",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Unlock advanced study techniques\nand unleash your full potential.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFCBD5E1),
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // --- FEATURE CARD ---
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const _FeatureItem(
                                      text: "Unlock Blurting Method",
                                      icon: Icons.edit_note_rounded,
                                    ),
                                    const _FeatureItem(
                                      text: "Unlock Second Brain & Flashcards",
                                      icon: Icons.psychology_rounded,
                                    ),
                                    const _FeatureItem(
                                      text: "Unlock Eisenhower Matrix",
                                      icon: Icons.grid_view_rounded,
                                    ),
                                    const _FeatureItem(
                                      text: "Unlimited AI Chat Tokens",
                                      icon: Icons.auto_awesome_rounded,
                                    ),

                                    const SizedBox(height: 24),
                                    const Divider(color: Color(0xFFF1F5F9)),
                                    const SizedBox(height: 24),

                                    // --- PLAN SELECTION ---
                                    Row(
                                      children: [
                                        // Monthly
                                        Expanded(
                                          child: _PlanCard(
                                            index: 0,
                                            title: "Monthly",
                                            price: "Rp 29k",
                                            subtitle: "/mo",
                                            isSelected: _selectedPlanIndex == 0,
                                            isActivePlan:
                                                _currentStatus ==
                                                'Monthly Premium',
                                            onTap: () => setState(
                                              () => _selectedPlanIndex = 0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Yearly
                                        Expanded(
                                          child: _PlanCard(
                                            index: 1,
                                            title: "Yearly",
                                            price: "Rp 290k",
                                            subtitle: "/yr",
                                            isSelected: _selectedPlanIndex == 1,
                                            isBestValue: true,
                                            isActivePlan:
                                                _currentStatus ==
                                                'Yearly Premium',
                                            onTap: () => setState(
                                              () => _selectedPlanIndex = 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 32),

                                    // --- SUBSCRIBE BUTTON ---
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            (_isLoading ||
                                                isAlreadySubscribedToSelected)
                                            ? null
                                            : _subscribe,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0F172A,
                                          ),
                                          disabledBackgroundColor:
                                              Colors.grey[300],
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation:
                                              isAlreadySubscribedToSelected
                                              ? 0
                                              : 5,
                                          shadowColor: const Color(
                                            0xFF0F172A,
                                          ).withValues(alpha: 0.4),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : Text(
                                                isAlreadySubscribedToSelected
                                                    ? "Current Plan"
                                                    : "Start Pro Access",
                                                style: TextStyle(
                                                  color:
                                                      isAlreadySubscribedToSelected
                                                      ? Colors.grey[600]
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // --- CANCEL BUTTON (Only if Premium) ---
                                    if (hasActivePremium) ...[
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _cancelSubscription,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                        ),
                                        child: const Text(
                                          "Cancel Subscription",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Auto-renewable. Cancel anytime.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// --- OPTIMIZED WIDGETS ---

class _FeatureItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FeatureItem({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF059669)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final int index;
  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final bool isBestValue;
  final bool isActivePlan;
  final VoidCallback onTap;

  const _PlanCard({
    required this.index,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isBestValue = false,
    this.isActivePlan = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool highlight = isSelected || isActivePlan;
    final Color borderColor = isActivePlan
        ? Colors.blueAccent
        : (isSelected ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0));

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: highlight ? const Color(0xFFF0FDFA) : Colors.white,
              border: Border.all(color: borderColor, width: highlight ? 2 : 1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: highlight
                            ? const Color(0xFF0F766E)
                            : Colors.grey[600],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: highlight
                              ? const Color(0xFF0F766E)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        color: highlight ? const Color(0xFF0F766E) : null,
                      ),
                      child: highlight
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    text: price,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      fontFamily: 'sans-serif',
                    ),
                    children: [
                      TextSpan(
                        text: subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isBestValue && !isActivePlan)
            Positioned(
              top: -12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "SAVE 20%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (isActivePlan)
            Positioned(
              top: -12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
