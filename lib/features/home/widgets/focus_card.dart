import 'dart:async';
import 'dart:math';
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
  late final Timer _timer;
  late DateTime _now;

  final PageController _pageController = PageController(
    viewportFraction: 0.94,
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

    _now = DateTime.now();
    _currentTip = _studyTips[Random().nextInt(_studyTips.length)];

    _pageController.addListener(() {
      if (!mounted) return;
      setState(() => _pageOffset = _pageController.page ?? 1.0);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final delta = (_pageOffset - index).abs();
                  final scale = (1 - delta * 0.15).clamp(0.9, 1.0);
                  final rotation = (_pageOffset - index) * 0.08;
                  final opacity = (1 - delta * 0.5).clamp(0.5, 1.0);

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..scaleByDouble(scale, scale, 1.0, 1.0)
                      ..rotateY(rotation),
                    child: Opacity(
                      opacity: opacity,
                      child: _buildHeroCard(index),
                    ),
                  );
                },
              );
            },
          ),
        ),
        _buildAnimatedIndicator(),
      ],
    );
  }

  Widget _buildHeroCard(int index) {
    final gradients = [
      [const Color(0xFF0F172A), const Color(0xFF334155)],
      [AppColors.primary, const Color(0xFF6366F1)],
      [const Color(0xFFD97706), const Color(0xFFF59E0B)],
    ];

    final icons = [
      Icons.schedule_rounded,
      Icons.rocket_launch_rounded,
      Icons.auto_awesome_rounded,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          colors: gradients[index],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradients[index].first.withValues(alpha: 0.35),
            blurRadius: 25,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -20,
              child: Icon(
                icons[index],
                size: 130,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            _buildCardContent(index),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(35),
                onTap: () {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PomodoroScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    setState(() {
                      _currentTip =
                          _studyTips[Random().nextInt(_studyTips.length)];
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(_now),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(_now).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    if (index == 1) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge("POMODORO"),
            const Spacer(),
            const Text(
              "Deep Focus",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Starting to lose focus? Try it",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge("DAILY MINDSET"),
          const Spacer(),
          Text(
            _currentTip,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "TAP FOR NEW TIP",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAnimatedIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final delta = (index - _pageOffset).abs();
          final proximity = (1 - delta).clamp(0.0, 1.0);
          final width = 6 + (24 * proximity);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: width,
            decoration: BoxDecoration(
              color: Color.lerp(
                Colors.grey.withValues(alpha: 0.3),
                AppColors.primary,
                proximity,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: proximity > 0.6
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
