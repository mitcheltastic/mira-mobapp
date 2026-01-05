import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // 0 = Plus Monthly, 1 = Premium Monthly, 2 = Premium Yearly
  int _selectedPlanIndex = 2;
  bool _isLoading = false;
  bool _isFetching = true;

  // --- NEW: Track pending status and realtime channel ---
  bool _isPending = false;
  RealtimeChannel? _subscriptionChannel;

  // 'Reguler', 'Monthly Plus', 'Monthly Premium', 'Yearly Premium'
  String _currentStatus = 'Reguler';

  // --- PLAN CONFIGURATION ---
  final List<Map<String, dynamic>> _plans = [
    {
      "id": "Monthly Plus",
      "title": "Plus",
      "price": "Rp 15k",
      "period": "/mo",
      "desc": "100 AI Chats/day • 25 Notes",
      "color": const Color(0xFF6366F1), // Indigo
    },
    {
      "id": "Monthly Premium",
      "title": "Premium Monthly",
      "price": "Rp 29k",
      "period": "/mo",
      "desc": "Unlimited AI • Unlimited Notes",
      "color": const Color(0xFF0F766E), // Teal
    },
    {
      "id": "Yearly Premium",
      "title": "Premium Yearly",
      "price": "Rp 290k",
      "period": "/yr",
      "desc": "Best Value • 2 Months Free",
      "color": const Color(0xFFD97706), // Amber
      "isBestValue": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserLevel();
    _checkPendingStatus(); // <--- Check if we are already waiting
    _setupRealtimeListener(); // <--- Listen for Admin approval
  }

  @override
  void dispose() {
    // Clean up the realtime listener
    if (_subscriptionChannel != null) {
      Supabase.instance.client.removeChannel(_subscriptionChannel!);
    }
    super.dispose();
  }

  // --- NEW: Listen for changes in 'level' table ---
  void _setupRealtimeListener() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _subscriptionChannel = Supabase.instance.client
        .channel('public:level')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'level',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: user.id,
          ),
          callback: (payload) {
            // Admin approved! Refresh level and clear pending status.
            _fetchUserLevel();
            if (mounted) {
              setState(() {
                _isPending = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Upgrade Approved! Access granted."),
                  backgroundColor: Color(0xFF34D399),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        )
        .subscribe();
  }

  // --- NEW: Check if user has a pending request ---
  Future<void> _checkPendingStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('subscription_requests')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isPending = data != null;
        });
      }
    } catch (e) {
      debugPrint("Error checking pending status: $e");
    }
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

  // --- 2. SUBSCRIBE LOGIC (NOW REQUESTS ACCESS) ---
  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final String planToRequest = _plans[_selectedPlanIndex]['id'];

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Insert into Requests Table instead of directly updating level
      await Supabase.instance.client.from('subscription_requests').insert({
        'user_id': user.id,
        'requested_plan': planToRequest,
        'status': 'pending',
      });

      if (mounted) {
        setState(() {
          _isPending = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Request sent for $planToRequest! Waiting for approval.",
            ),
            backgroundColor: const Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar("Request failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. CANCEL SUBSCRIPTION LOGIC ---
  Future<void> _cancelSubscription() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Subscription?"),
        content: const Text(
          "You will lose access to Plus/Premium features immediately. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Keep Plan",
              style: TextStyle(color: Colors.grey),
            ),
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
              "Subscription cancelled. You are now on Reguler.",
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
    final activePlanId = _currentStatus;
    final selectedPlanId = _plans[_selectedPlanIndex]['id'];

    // Check if the user is already subscribed to the plan they currently have selected
    final bool isAlreadySubscribedToSelected = activePlanId == selectedPlanId;

    // Check if user has ANY paid plan active
    final bool hasActivePaidPlan = _currentStatus != 'Reguler';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            )
          : Stack(
              children: [
                // --- BACKGROUND HEADER ---
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF334155)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // --- MAIN CONTENT ---
                SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
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

                      // Title & Feature Highlights
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.diamond_outlined,
                                size: 56,
                                color: Color(0xFF34D399),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Upgrade Your Brain",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Choose the plan that fits your study style.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // --- DYNAMIC FEATURE LIST BASED ON SELECTION ---
                              _buildDynamicFeatures(),

                              const SizedBox(height: 32),

                              // --- PLAN LIST ---
                              ...List.generate(_plans.length, (index) {
                                final plan = _plans[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PlanListCard(
                                    title: plan['title'],
                                    price: plan['price'],
                                    period: plan['period'],
                                    desc: plan['desc'],
                                    color: plan['color'],
                                    isBestValue: plan['isBestValue'] ?? false,
                                    isSelected: _selectedPlanIndex == index,
                                    isActivePlan: _currentStatus == plan['id'],
                                    onTap: () => setState(
                                      () => _selectedPlanIndex = index,
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 24),

                              // --- ACTION BUTTON ---
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  // DISABLE BUTTON IF PENDING OR ALREADY SUBSCRIBED
                                  onPressed:
                                      (_isLoading ||
                                          isAlreadySubscribedToSelected ||
                                          _isPending)
                                      ? null
                                      : _subscribe,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    disabledBackgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation:
                                        (isAlreadySubscribedToSelected ||
                                            _isPending)
                                        ? 0
                                        : 5,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          _getButtonText(
                                            isAlreadySubscribedToSelected,
                                          ),
                                          style: TextStyle(
                                            color:
                                                (isAlreadySubscribedToSelected ||
                                                    _isPending)
                                                ? Colors.grey[600]
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ),

                              // --- CANCEL BUTTON ---
                              if (hasActivePaidPlan) ...[
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _cancelSubscription,
                                  child: const Text(
                                    "Cancel Subscription",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 30),
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

  // Helper for button text logic
  String _getButtonText(bool isAlreadySubscribed) {
    if (isAlreadySubscribed) return "Current Plan";
    if (_isPending) return "Waiting for Approval...";
    return "Request Upgrade to ${_plans[_selectedPlanIndex]['title']}";
  }

  Widget _buildDynamicFeatures() {
    // Show features based on selected plan
    final planId = _plans[_selectedPlanIndex]['id'];
    final bool isPlus = planId == 'Monthly Plus';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Common Features
          const _FeatureRow(
            text: "Unlock Blurting & Flashcards",
            isIncluded: true,
          ),
          const SizedBox(height: 12),

          // Differentiated Features
          _FeatureRow(
            text: isPlus ? "100 AI Chats / day" : "Unlimited AI Assistant",
            isIncluded: true,
            highlight: !isPlus, // Highlight if Premium
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            text: isPlus ? "25 Second Brain Ideas" : "Unlimited Idea Storage",
            isIncluded: true,
            highlight: !isPlus,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool isIncluded;
  final bool highlight;

  const _FeatureRow({
    required this.text,
    this.isIncluded = true,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isIncluded ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isIncluded
              ? (highlight ? const Color(0xFF0F766E) : const Color(0xFF34D399))
              : Colors.grey[300],
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            color: highlight
                ? const Color(0xFF0F766E)
                : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

class _PlanListCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String desc;
  final Color color;
  final bool isBestValue;
  final bool isSelected;
  final bool isActivePlan;
  final VoidCallback onTap;

  const _PlanListCard({
    required this.title,
    required this.price,
    required this.period,
    required this.desc,
    required this.color,
    required this.onTap,
    this.isBestValue = false,
    this.isSelected = false,
    this.isActivePlan = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isActivePlan
        ? Colors.blueAccent
        : (isSelected ? color : Colors.transparent);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: (isSelected || isActivePlan) ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Radio Circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badges
          if (isBestValue && !isActivePlan)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "SAVE 20%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (isActivePlan)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "ACTIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
