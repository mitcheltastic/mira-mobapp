import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import sesuai path project Anda
import '../../../core/constant/app_colors.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with TickerProviderStateMixin {
  // --- Constants ---
  static const Color _themeColor = AppColors.flashcardTheme; // Amber

  // --- Data (User Input) ---
  // FIX: Menambahkan 'final' karena referensi list tidak berubah, hanya isinya yang berubah.
  final List<Map<String, String>> _cards = [
    {
      "question": "Apa fungsi utama dari Widget 'Scaffold' di Flutter?",
      "answer": "Menyediakan struktur dasar visual Material Design (AppBar, Body, FloatingActionButton, dll)."
    },
    {
      "question": "Jelaskan konsep 'State' dalam Flutter!",
      "answer": "State adalah data atau informasi yang dapat berubah sepanjang masa hidup widget dan mempengaruhi tampilan UI."
    },
  ];

  // --- State ---
  int _currentIndex = 0;
  bool _isFlipped = false;
  
  // --- Animation ---
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _entryAnimController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Show guide only once
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroGuide());
  }

  void _setupAnimations() {
    // Setup Flip Animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    // Entry Animation
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _entryAnimController.dispose();
    super.dispose();
  }

  // --- LOGIC CRUD ---

  void _addCard(String question, String answer) {
    setState(() {
      _cards.add({"question": question, "answer": answer});
    });
    HapticFeedback.mediumImpact();
    
    // Jika ini kartu pertama, reset index
    if (_cards.length == 1) {
      setState(() => _currentIndex = 0);
    }
  }

  void _deleteCurrentCard() {
    if (_cards.isEmpty) return;

    setState(() {
      _cards.removeAt(_currentIndex);
      // Adjust index agar tidak error jika menghapus item terakhir
      if (_currentIndex >= _cards.length) {
        _currentIndex = max(0, _cards.length - 1);
      }
      _isFlipped = false;
      _flipController.reset();
    });
    HapticFeedback.heavyImpact();
  }

  void _flipCard() {
    if (_cards.isEmpty) return;
    
    HapticFeedback.selectionClick();
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_cards.isEmpty) return;

    if (_currentIndex < _cards.length - 1) {
      HapticFeedback.mediumImpact();
      // Reset flip visual sebelum pindah
      if (_isFlipped) {
        _flipController.reset();
        setState(() => _isFlipped = false);
      }
      setState(() => _currentIndex++);
    } else {
      _finishSession();
    }
  }

  void _finishSession() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Session Complete! Great job! 🎉", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _themeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
    // Reset session
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _flipController.reset();
    });
  }

  // --- UI FORMS (ADD CARD) ---

  void _showAddCardSheet() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              const Text("New Flashcard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain)),
              const SizedBox(height: 20),
              
              // Question Input
              TextField(
                controller: questionController,
                autofocus: true,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain),
                decoration: InputDecoration(
                  labelText: "Question",
                  hintText: "What do you want to ask?",
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Answer Input
              TextField(
                controller: answerController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  labelText: "Answer",
                  hintText: "The correct answer is...",
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (questionController.text.trim().isNotEmpty && answerController.text.trim().isNotEmpty) {
                      _addCard(questionController.text, answerController.text);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- INTRO GUIDE ---

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
                      const Text("Active Recall", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        "Test your memory actively rather than just reading passively.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 30),
                      _buildGuideItem(Icons.add_circle_outline_rounded, _themeColor, "Create", "Add your own questions & answers."),
                      _buildGuideItem(Icons.flip_camera_android_rounded, AppColors.primary, "Flip", "Tap to reveal the answer."),
                      _buildGuideItem(Icons.delete_outline_rounded, AppColors.error, "Manage", "Remove cards you have mastered."),
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
                      backgroundColor: _themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Start Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // App Bar
      appBar: AppBar(
        title: Text(
          _cards.isEmpty ? "Flashcards" : "Card ${_currentIndex + 1}/${_cards.length}", 
          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMain, fontSize: 16)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Hapus Kartu (Hanya muncul jika ada kartu)
          if (_cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
              onPressed: _deleteCurrentCard,
              tooltip: "Delete current card",
            ),
          IconButton(
            onPressed: _showIntroGuide,
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textMuted),
          )
        ],
      ),
      
      // Floating Action Button (Add Card)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardSheet,
        backgroundColor: _themeColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Card", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 80), // Bottom padding untuk FAB
          child: Column(
            children: [
              // Progress Bar
              if (_cards.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _cards.length,
                    backgroundColor: Colors.grey.shade200,
                    color: _themeColor,
                    minHeight: 6,
                  ),
                ),
              const SizedBox(height: 32),

              // CARD AREA
              Expanded(
                child: _cards.isEmpty 
                  ? _buildEmptyState() 
                  : SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_entryAnimController),
                      child: Center(
                        child: GestureDetector(
                          onTap: _flipCard,
                          child: AnimatedBuilder(
                            animation: _flipAnimation,
                            builder: (context, child) {
                              final angle = _flipAnimation.value;
                              final isFront = angle < pi / 2;
                              
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                alignment: Alignment.center,
                                child: isFront
                                    ? _buildFrontCard(_cards[_currentIndex]['question']!)
                                    : Transform(
                                        transform: Matrix4.identity()..rotateY(pi),
                                        alignment: Alignment.center,
                                        child: _buildBackCard(_cards[_currentIndex]['answer']!),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
              ),

              const SizedBox(height: 32),

              // CONTROLS (Hanya jika ada kartu & sudah dibalik)
              if (_cards.isNotEmpty)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isFlipped ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_isFlipped,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.error, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: AppColors.error.withValues(alpha: 0.05),
                            ),
                            onPressed: _nextCard,
                            child: const Text("Hard", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: _nextCard,
                            child: const Text("Easy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.style_outlined, size: 60, color: _themeColor),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Cards Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the + button to create your first flashcard.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard(String text) {
    return Container(
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _themeColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.help_outline_rounded, size: 40, color: _themeColor),
          ),
          const SizedBox(height: 24),
          const Text("QUESTION", style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textMain, height: 1.3),
          ),
          const Spacer(),
          const Text("Tap to flip", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBackCard(String text) {
    return Container(
      width: double.infinity,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _themeColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text("ANSWER", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}