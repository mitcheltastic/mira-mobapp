import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  // Dummy Data Flashcards
  final List<Map<String, String>> _cards = [
    {
      "question": "Apa fungsi utama dari Widget 'Scaffold' di Flutter?",
      "answer": "Menyediakan struktur dasar visual Material Design (AppBar, Body, FloatingActionButton, dll)."
    },
    {
      "question": "Jelaskan konsep 'State' dalam Flutter!",
      "answer": "State adalah data atau informasi yang dapat berubah sepanjang masa hidup widget dan mempengaruhi tampilan UI."
    },
    {
      "question": "Apa bedanya Stateless dan Stateful Widget?",
      "answer": "Stateless tidak bisa berubah setelah dibuat (statis). Stateful bisa berubah (dinamis) menggunakan setState()."
    },
  ];

  int _currentIndex = 0;
  bool _isFlipped = false; // Status apakah kartu sedang dibalik (lihat jawaban)

  void _nextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _isFlipped = false; // Reset ke pertanyaan
      } else {
        // Selesai
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session Complete! Great job! 🎉")),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Flashcards (${_currentIndex + 1}/${_cards.length})"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _cards.length,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.secondary, // Coral
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 32),

            // AREA KARTU (CARD)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isFlipped = !_isFlipped; // Balik kartu
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _isFlipped ? AppColors.surface : AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    border: _isFlipped ? Border.all(color: AppColors.primary, width: 2) : null,
                    boxShadow: [
                      BoxShadow(
                        color: _isFlipped 
                            ? AppColors.shadow 
                            : AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isFlipped ? Icons.lightbulb : Icons.help_outline,
                        size: 48,
                        color: _isFlipped ? AppColors.primary : Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isFlipped ? "ANSWER" : "QUESTION",
                        style: TextStyle(
                          color: _isFlipped ? AppColors.textMuted : Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isFlipped ? currentCard['answer']! : currentCard['question']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isFlipped ? AppColors.textMain : Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _isFlipped ? "Tap to hide" : "Tap to reveal answer",
                        style: TextStyle(
                          color: _isFlipped ? AppColors.textMuted : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // TOMBOL AKSI (Hanya muncul jika jawaban sudah dibuka)
            if (_isFlipped)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextCard,
                      child: const Text("Hard", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextCard,
                      child: const Text("Easy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              // Placeholder agar layout tidak lompat
              const SizedBox(height: 50), 
          ],
        ),
      ),
    );
  }
}