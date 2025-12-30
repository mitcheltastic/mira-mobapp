import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pastikan path ini sesuai dengan project Anda
import '../../../core/constant/app_colors.dart';

class FeynmanScreen extends StatefulWidget {
  const FeynmanScreen({super.key});

  @override
  State<FeynmanScreen> createState() => _FeynmanScreenState();
}

class _FeynmanScreenState extends State<FeynmanScreen>
    with TickerProviderStateMixin {
  
  // --- State ---
  final PageController _pageController = PageController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();

  int _currentStep = 0; // 0: Define, 1: Teach, 2: Review

  // Checklist for Step 3 (Review)
  bool _checkSimpleLanguage = false;
  bool _checkNoJargon = false;
  bool _checkAnalogyUsed = false;
  bool _checkSmoothFlow = false;

  // --- Animation ---
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Background breathing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Show guide on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroGuide();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _topicController.dispose();
    _explanationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- Logic ---

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < 2) {
      // Validation
      if (_currentStep == 0 && _topicController.text.trim().isEmpty) {
        _showError("Please enter a topic first.");
        return;
      }
      if (_currentStep == 1 && _explanationController.text.trim().length < 20) {
        _showError("Try to explain it in more detail (min 20 chars).");
        return;
      }

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Finish
      _finishSession();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishSession() {
    HapticFeedback.heavyImpact();
    // Logic penyimpanan data bisa diletakkan di sini
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // --- UI Components ---

  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const Text(
                      "The Feynman Technique",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "The most effective way to learn anything is to teach it simply.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 30),
                    
                    _buildGuideItem(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.feynmanConcept,
                      title: "Choose a Concept",
                      desc: "Identify exactly what you want to understand.",
                    ),
                    _buildGuideItem(
                      icon: Icons.school_outlined,
                      color: AppColors.feynmanTeach,
                      title: "Teach it to a Child",
                      desc: "Write an explanation in simple language. Avoid jargon completely.",
                    ),
                    _buildGuideItem(
                      icon: Icons.manage_search_rounded,
                      color: AppColors.feynmanRefine,
                      title: "Identify Gaps & Simplify",
                      desc: "If you get stuck, go back to the source material. Refine until it's crystal clear.",
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feynmanConcept,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Start Learning",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic color based on step
    final Color activeThemeColor = _currentStep == 0 
        ? AppColors.feynmanConcept 
        : (_currentStep == 1 ? AppColors.feynmanTeach : AppColors.feynmanRefine);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Orbs
          Positioned(
            top: -100,
            right: -50,
            child: _AnimatedOrb(
              color: AppColors.feynmanConcept.withValues(alpha: 0.15),
              size: 300,
              controller: _pulseController,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _AnimatedOrb(
              color: AppColors.feynmanTeach.withValues(alpha: 0.1),
              size: 200,
              controller: _pulseController,
              reverse: true,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildProgressBar(activeThemeColor),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Define(),
                      _buildStep2Teach(),
                      _buildStep3Review(),
                    ],
                  ),
                ),
                _buildBottomNavigation(activeThemeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Feynman Method",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textMain,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 22, color: AppColors.textMuted),
            onPressed: _showIntroGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color activeTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          _buildStepIndicator(0, "Concept", AppColors.feynmanConcept),
          _buildLine(0),
          _buildStepIndicator(1, "Teach", AppColors.feynmanTeach),
          _buildLine(1),
          _buildStepIndicator(2, "Refine", AppColors.feynmanRefine),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String label, Color color) {
    bool isActive = _currentStep >= stepIndex;
    bool isCurrent = _currentStep == stepIndex;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color : AppColors.border,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)]
                : [],
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    "${stepIndex + 1}",
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        color: _currentStep > index ? AppColors.textMain : AppColors.border,
      ),
    );
  }

  // --- Step 1: Define ---
  Widget _buildStep1Define() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIconHeader(Icons.lightbulb_outline_rounded, "Choose a Concept", AppColors.feynmanConcept),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What do you want to learn today?",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _topicController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: "e.g. Quantum Physics, Recursion...",
                    hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 2: Teach ---
  Widget _buildStep2Teach() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildIconHeader(Icons.school_outlined, "Teach it to a Child", AppColors.feynmanTeach),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explain \"${_topicController.text}\" simply.",
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const Divider(height: 30),
                TextField(
                  controller: _explanationController,
                  maxLines: 12,
                  style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: "Start writing here... Imagine you are talking to a 12-year-old. Don't use complex jargon.",
                    hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Review ---
  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildIconHeader(Icons.youtube_searched_for_rounded, "Identify Gaps", AppColors.feynmanRefine),
          const SizedBox(height: 10),
          const Text(
            "Be honest. If you can't explain it simply, you don't understand it well enough.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 30),
          _buildChecklistTile("I used simple words (No Jargon)", _checkNoJargon, (v) => setState(() => _checkNoJargon = v)),
          _buildChecklistTile("I used an analogy or example", _checkAnalogyUsed, (v) => setState(() => _checkAnalogyUsed = v)),
          _buildChecklistTile("The explanation flows logically", _checkSmoothFlow, (v) => setState(() => _checkSmoothFlow = v)),
          _buildChecklistTile("A child would understand this", _checkSimpleLanguage, (v) => setState(() => _checkSimpleLanguage = v)),
        ],
      ),
    );
  }

  Widget _buildIconHeader(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.feynmanRefine : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.surface,
        activeTrackColor: AppColors.feynmanRefine,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? AppColors.feynmanRefine : AppColors.textMain,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBottomNavigation(Color activeTheme) {
    bool isLastStep = _currentStep == 2;
    // Check if all checkboxes are true for the last step validation
    bool isReviewComplete = _checkNoJargon && _checkAnalogyUsed && _checkSmoothFlow && _checkSimpleLanguage;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.textMuted, size: 24),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep && !isReviewComplete ? Colors.grey : activeTheme,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: (isLastStep && !isReviewComplete) ? null : _nextStep,
              child: Text(
                isLastStep ? "Finish & Save" : "Continue",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Background Orb Helper ---

class _AnimatedOrb extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController controller;
  final bool reverse;

  const _AnimatedOrb({
    required this.color,
    required this.size,
    required this.controller,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(
          parent: controller,
          curve: reverse
              ? const Interval(0.5, 1.0, curve: Curves.easeInOut)
              : const Interval(0.0, 0.5, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}