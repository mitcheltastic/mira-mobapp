import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import AppColors yang baru
import '../../../core/constant/app_colors.dart';

class BlurtingScreen extends StatefulWidget {
  const BlurtingScreen({super.key});

  @override
  State<BlurtingScreen> createState() => _BlurtingScreenState();
}

class _BlurtingScreenState extends State<BlurtingScreen> with TickerProviderStateMixin {
  // --- Controllers ---
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _entryAnimController;
  
  // --- Timer State ---
  Timer? _timer;
  static const int _defaultDuration = 10 * 60; // 10 Menit default
  int _remainingSeconds = _defaultDuration;
  
  // --- Status Flags ---
  bool _isBlurting = false; // Timer Berjalan (Mode Menulis Cepat)
  bool _isReviewMode = false; // Timer Habis (Mode Koreksi)

  @override
  void initState() {
    super.initState();
    // Animasi Detak Timer
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animasi Masuk Halaman
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Tampilkan Intro Guide saat pertama kali buka
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroGuide());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _topicController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _entryAnimController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  void _toggleSession() {
    HapticFeedback.mediumImpact();

    if (_isReviewMode) {
      _showResetConfirmation(); 
      return;
    }

    if (_isBlurting) {
      _pauseTimer();
    } else {
      if (_topicController.text.trim().isEmpty) {
        _showSnack("Please write a topic first!", isError: true);
        return;
      }
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() => _isBlurting = true);
    _pulseController.repeat(reverse: true);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _finishSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.value = 1.0; 
    setState(() => _isBlurting = false);
  }

  void _finishSession() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isBlurting = false;
      _isReviewMode = true;
    });
    _showCompletionDialog();
  }

  void _resetSession() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _remainingSeconds = _defaultDuration;
      _isBlurting = false;
      _isReviewMode = false;
      _topicController.clear();
      _contentController.clear();
    });
  }

  String get _timerString {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- UI DIALOGS & GUIDES ---

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        // UPDATE: Menggunakan AppColors.blurtingWriting (Rose) untuk error
        backgroundColor: isError ? AppColors.blurtingWriting : AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("New Session?", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        content: const Text("This will clear your current writing. Are you sure?", style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // UPDATE: Menggunakan AppColors.blurtingWriting
              backgroundColor: AppColors.blurtingWriting, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _resetSession();
            },
            child: const Text("Start New", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Time's Up! ✍️", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textMain)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // UPDATE: Menggunakan AppColors.blurtingWriting
                color: AppColors.blurtingWriting.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stop_rounded, color: AppColors.blurtingWriting, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              "Stop writing immediately!",
              style: TextStyle(color: AppColors.blurtingWriting, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Open your notes/textbook now. Switch to 'Review Mode' to check your answers and fix mistakes in a different color.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.5, fontSize: 14),
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // UPDATE: Menggunakan AppColors.blurtingReview
                  backgroundColor: AppColors.blurtingReview,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Start Reviewing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.70, 
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
                      const Text("The Blurting Method", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        "Active recall strategy to identify knowledge gaps under pressure.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 30),
                      
                      _buildGuideItem(Icons.timer_outlined, AppColors.textMain, "Set Timer", "Choose a topic. The timer creates helpful pressure."),
                      // UPDATE: Menggunakan AppColors
                      _buildGuideItem(Icons.edit_note_rounded, AppColors.blurtingWriting, "Blurt", "Write EVERYTHING you remember. Do not stop. Do not check notes."),
                      _buildGuideItem(Icons.fact_check_rounded, AppColors.blurtingReview, "Review", "When time is up, open your notes. Fix mistakes in a different color."),
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
                      backgroundColor: AppColors.blurtingWriting,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Let's Start", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- MAIN UI ---

  @override
  Widget build(BuildContext context) {
    // UPDATE: Menggunakan AppColors
    final Color activeColor = _isReviewMode ? AppColors.blurtingReview : AppColors.blurtingWriting;
    
    final Color statusBg = _isReviewMode 
        ? AppColors.blurtingReview.withValues(alpha: 0.1) 
        : (_isBlurting ? AppColors.blurtingWriting.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1));
    
    final String statusText = _isReviewMode ? "REVIEW MODE" : (_isBlurting ? "WRITING MODE" : "READY");

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Blurting Session", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.textMain.withValues(alpha: 0.8))
        ),
        actions: [
          IconButton(
            onPressed: _showIntroGuide,
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_entryAnimController),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            onPressed: _toggleSession,
            backgroundColor: activeColor,
            elevation: 8,
            highlightElevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: Icon(
              _isReviewMode ? Icons.refresh_rounded : (_isBlurting ? Icons.pause_rounded : Icons.play_arrow_rounded),
              color: Colors.white,
            ),
            label: Text(
              _isReviewMode ? "New Session" : (_isBlurting ? "Pause Timer" : "Start Blurting"),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER: TIMER & TOPIC ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  // Timer Display
                  ScaleTransition(
                    scale: _isBlurting 
                        ? Tween(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut))
                        : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: activeColor.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                        border: Border.all(color: activeColor.withValues(alpha: 0.1), width: 1),
                      ),
                      child: Text(
                        _timerString,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: activeColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Topic Input
                  TextField(
                    controller: _topicController,
                    textAlign: TextAlign.center,
                    enabled: !_isBlurting && !_isReviewMode,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    decoration: InputDecoration(
                      hintText: "What's the topic?",
                      hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4), fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),

            // --- WRITING SHEET (EXPANDED) ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, -5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Column(
                    children: [
                      // Status Bar Inside Sheet
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    statusText,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor, letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main Editor Area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            expands: true,
                            enabled: true, 
                            style: TextStyle(
                              fontSize: 16, 
                              height: 1.6, 
                              // UPDATE: Teks berubah jadi Indigo saat Review Mode
                              color: _isReviewMode ? AppColors.blurtingReview : AppColors.textMain, 
                            ),
                            cursorColor: activeColor,
                            decoration: InputDecoration(
                              hintText: _isBlurting 
                                ? "Don't stop writing! Focus on speed..." 
                                : (_isReviewMode 
                                    ? "Compare with your notes. Fill the gaps here..." 
                                    : "Press Start to begin blurting."),
                              hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.4)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(top: 20, bottom: 100), 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}