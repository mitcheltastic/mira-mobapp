import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/app_colors.dart';
import '../../study_tools/presentation/pomodoro_screen.dart';

class FocusSection extends StatefulWidget {
  const FocusSection({super.key});

  @override
  State<FocusSection> createState() => _FocusSectionState();
}

class _FocusSectionState extends State<FocusSection> {
  final PageController _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: 1,
  );

  double _pageOffset = 1.0;

  final List<String> _studyTips = [
    "Feynman Technique: Master a concept by explaining it simply to a child.",
    "Active Recall: Close your book and test yourself instead of re-reading notes.",
    "Spaced Repetition: Review materials at increasing intervals (1 day, 3 days, 1 week).",
    "Blurting Method: Write down everything you remember on a blank paper after studying.",
    "Method of Loci: Imagine placing information in rooms of a house you know well.",
    "Mnemonic Devices: Create acronyms or songs to remember complex lists.",

    "Pomodoro Technique: Work for 25 mins, then take a 5-min break to stay fresh.",
    "Eat the Frog: Complete your hardest or most dreaded task first thing in the morning.",
    "Time Blocking: Schedule specific hours for specific subjects in your calendar.",
    "The 2-Minute Rule: If a task takes less than 2 minutes, do it immediately.",
    "Parkinson's Law: Set shorter deadlines to prevent tasks from dragging on.",

    "Deep Work: Study in a distraction-free zone for at least 90 minutes.",
    "Digital Detox: Put your phone in another room while doing focus sessions.",
    "Ambient Noise: Use Lo-Fi or White Noise if total silence is too distracting.",
    "The 20-20-20 Rule: Every 20 mins, look at something 20 feet away for 20 seconds.",
    "Clutter-Free Desk: A clean workspace reduces mental fog and anxiety.",

    "Interleaving: Switch between different subjects to improve problem-solving skills.",
    "SQ3R Method: Survey, Question, Read, Recite, and Review your textbook.",
    "Mind Mapping: Use diagrams to visualize connections between different ideas.",
    "Leitner System: Use flashcards and move them to different boxes based on mastery.",
    "Cornell Note-taking: Divide your paper into notes, cues, and a summary section.",

    "Sleep is Essential: Your brain solidifies new memories while you sleep.",
    "Stay Hydrated: Even mild dehydration can lower your concentration levels.",
    "Study Snacks: Eat walnuts, berries, or dark chocolate for a quick brain boost.",
    "Exercise: A 10-minute walk increases blood flow and oxygen to the brain.",
    "Self-Compassion: Don't beat yourself up on bad days; just start again tomorrow.",
    "Power Nap: A 20-minute nap can restore alertness better than more coffee.",
  ];

  late String _currentTip;

  @override
  void initState() {
    super.initState();
    _currentTip = _studyTips[Random().nextInt(_studyTips.length)];

    _pageController.addListener(() {
      if (!mounted) return;
      setState(() => _pageOffset = _pageController.page ?? 1.0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _randomizeTip() {
    setState(() {
      _currentTip = _studyTips[Random().nextInt(_studyTips.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: 3,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  // Kalkulasi Animasi
                  final delta = (_pageOffset - index).abs();
                  final scale = (1 - delta * 0.1).clamp(0.9, 1.0);
                  final opacity = (1 - delta * 0.5).clamp(0.5, 1.0);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..scale(scale),
                    child: Opacity(
                      opacity: opacity,
                      child: RepaintBoundary(child: _buildHeroCard(index)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildAnimatedIndicator(),
      ],
    );
  }

  Widget _buildHeroCard(int index) {
    // Gradient yang lebih vibrant
    final gradients = [
      [const Color(0xFF1E293B), const Color(0xFF0F172A)],
      [const Color(0xFF6366F1), const Color(0xFF4338CA)],
      [const Color(0xFFF59E0B), const Color(0xFFEA580C)],
    ];

    final icons = [
      Icons.schedule_rounded,
      Icons.timer_outlined,
      Icons.lightbulb_outline_rounded,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: gradients[index],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradients[index].last.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
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
              left: -20,
              bottom: -30,
              child: Icon(
                icons[index],
                size: 140,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PomodoroScreen()),
                    );
                  } else if (index == 2) {
                    _randomizeTip();
                  }
                },
                splashColor: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: _buildCardContent(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(int index) {
    // 0 = Jam
    if (index == 0) {
      return const _LiveClock();
    }

    // 1 = Pomodoro
    if (index == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge("FOCUS TOOL", Icons.bolt_rounded),
          const Spacer(),
          const Text(
            "Pomodoro",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Start a session now",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // 2 = Tips
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge("DAILY TIP", Icons.tips_and_updates_rounded),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _currentTip,
            key: ValueKey(_currentTip),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.refresh_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              "Tap to shuffle",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final delta = (index - _pageOffset).abs();
        final isActive = delta < 0.5;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 24.0 : 6.0, // Indikator memanjang saat aktif
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.textMuted.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late final Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // JAM
        Text(
          DateFormat('HH:mm').format(_now),
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -2,
            fontFeatures: [ui.FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        // TANGGAL
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('EEEE, d MMMM').format(_now).toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
