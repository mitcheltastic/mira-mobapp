import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pastikan path ini sesuai dengan project Anda
import '../../../core/constant/app_colors.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // --- Configuration ---
  static const int _defaultWorkTime = 25;
  static const int _defaultShortBreakTime = 5;
  static const int _defaultLongBreakTime = 15;
  static const int _cyclesBeforeLongBreak = 4;

  // --- Theme Colors ---
  static const Color _focusColor = Color(0xFFF43F5E); // Rose
  static const Color _breakColor = Color(0xFF10B981); // Emerald
  static const Color _longBreakColor = Color(0xFF6366F1); // Indigo

  // --- State ---
  int _workTime = _defaultWorkTime;
  int _breakTime = _defaultShortBreakTime;

  // Logic Variables
  late int _remainingSeconds;
  bool _isRunning = false;

  // 0=Focus, 1=ShortBreak, 2=LongBreak
  int _currentMode = 0;
  int _pomodoroCount = 0;

  Timer? _timer;
  DateTime? _backgroundTime;

  // --- Animation ---
  late AnimationController _pulseController;
  late AnimationController _bgController;
  late Animation<Color?> _bgColorAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = _workTime * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bgColorAnimation = ColorTween(
      begin: const Color(0xFFFFF1F2),
      end: const Color(0xFFECFDF5),
    ).animate(_bgController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroGuide();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isRunning) {
        _backgroundTime = DateTime.now();
        _timer?.cancel();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isRunning && _backgroundTime != null) {
        final elapsed = DateTime.now().difference(_backgroundTime!).inSeconds;
        setState(() {
          _remainingSeconds -= elapsed;
          if (_remainingSeconds <= 0) {
            _remainingSeconds = 0;
            _completeTimer();
          } else {
            _startTimerTicker();
          }
        });
      }
    }
  }

  // --- Logic ---

  Color get _themeColor {
    if (_currentMode == 0) return _focusColor;
    if (_currentMode == 1) return _breakColor;
    return _longBreakColor;
  }

  void _updateTheme() {
    if (_currentMode == 0) {
      _bgController.reverse();
    } else {
      _bgController.forward();
    }
  }

  void _startTimerTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeTimer();
      }
    });
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _startTimerTicker();
    }
  }

  void _completeTimer() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      _isRunning = false;

      if (_currentMode == 0) {
        // Focus finished
        _pomodoroCount++;

        if (_pomodoroCount % _cyclesBeforeLongBreak == 0) {
          _currentMode = 2; // Long Break
          _remainingSeconds = _defaultLongBreakTime * 60;
        } else {
          _currentMode = 1; // Short Break
          _remainingSeconds = _breakTime * 60;
        }
      } else {
        // Break finished
        _currentMode = 0; // Back to Focus
        _remainingSeconds = _workTime * 60;
      }
    });

    _updateTheme();
    _showCompletionDialog();
  }

  void _resetTimer() {
    HapticFeedback.selectionClick();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _pomodoroCount = 0;
      _currentMode = 0;
      _remainingSeconds = _workTime * 60;
    });
    _updateTheme();
  }

  void _changeTime(bool isWork, int delta) {
    HapticFeedback.lightImpact();
    setState(() {
      if (isWork) {
        int newVal = _workTime + delta;
        if (newVal >= 1 && newVal <= 90) {
          _workTime = newVal;
          if (_currentMode == 0 && !_isRunning) {
            _remainingSeconds = _workTime * 60;
          }
        }
      } else {
        int newVal = _breakTime + delta;
        if (newVal >= 1 && newVal <= 30) {
          _breakTime = newVal;
          if (_currentMode == 1 && !_isRunning) {
            _remainingSeconds = _breakTime * 60;
          }
        }
      }
    });
  }

  // --- UI Components ---

  void _showCompletionDialog() {
    String title;
    String message;

    if (_currentMode == 0) {
      title = "Back to Work";
      message = "Break is over. Let's refocus.";
    } else if (_currentMode == 1) {
      title = "Short Break";
      message = "Great job! Take a breather.";
    } else {
      title = "Long Break Unlocked";
      message = "You've completed 4 sessions! Take a proper rest.";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textMain, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 30),
            const Text("Master Your Focus",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                    letterSpacing: -0.5)),
            const SizedBox(height: 10),
            const Text(
                "The Pomodoro Technique helps you stay productive without burning out.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 40),
            _buildGuideItem(
              icon: Icons.bolt_rounded,
              color: _focusColor,
              title: "Deep Focus (25 Mins)",
              desc: "Work on a single task with zero distractions.",
            ),
            _buildGuideItem(
              icon: Icons.coffee_rounded,
              color: _breakColor,
              title: "Short Break (5 Mins)",
              desc:
                  "Stretch, hydrate, or breathe. This prevents mental fatigue.",
            ),
            _buildGuideItem(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFF59E0B),
              title: "Long Break (15 Mins)",
              desc:
                  "After 4 focus sessions, take a longer break to fully recharge.",
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _focusColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Let's Start",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(
      {required IconData icon,
      required Color color,
      required String title,
      required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _currentMode == 2
              ? const Color(0xFFE0E7FF)
              : _bgColorAnimation.value,
          body: Stack(
            children: [
              // Background Orbs
              Positioned(
                top: -80,
                right: -80,
                child: _AnimatedOrb(
                    color: _themeColor.withValues(alpha: 0.15),
                    size: 250,
                    controller: _pulseController),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: _AnimatedOrb(
                    color: _themeColor.withValues(alpha: 0.1),
                    size: 180,
                    controller: _pulseController,
                    reverse: true),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 10),
                              // Mascot diganti dengan Icon agar lebih clean/estetik
                              _buildStatusIcon(_themeColor),
                              const Spacer(),
                              _buildTimerRing(_themeColor),
                              const SizedBox(height: 20),
                              _buildCycleIndicator(),
                              const Spacer(),
                              _buildTimeSettings(_themeColor),
                              const SizedBox(height: 30),
                              _buildControlPanel(_themeColor),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCycleIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isCompleted = index < (_pomodoroCount % 4);
        bool isCurrent = index == (_pomodoroCount % 4) && _currentMode == 0;

        if (_pomodoroCount > 0 && _pomodoroCount % 4 == 0) isCompleted = true;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent ? _themeColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Pomodoro Timer",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textMain)),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                size: 22, color: AppColors.textMuted),
            onPressed: _showIntroGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(Color color) {
    IconData iconData;
    String statusTitle;

    if (_currentMode == 0) {
      iconData = Icons.bolt_rounded;
      statusTitle = "Focus Mode";
    } else if (_currentMode == 1) {
      iconData = Icons.coffee_rounded;
      statusTitle = "Short Break";
    } else {
      iconData = Icons.landscape_rounded;
      statusTitle = "Long Break";
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5)
              ]),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              iconData,
              key: ValueKey("$_currentMode"),
              size: 40,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            statusTitle,
            key: ValueKey(_currentMode),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain),
          ),
        ),
        Text(
          _currentMode == 0 ? "Eliminate distractions" : "Refresh your mind",
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTimerRing(Color color) {
    int totalMinutes;
    // --- LINTER FIX: Curly braces added ---
    if (_currentMode == 0) {
      totalMinutes = _workTime;
    } else if (_currentMode == 1) {
      totalMinutes = _breakTime;
    } else {
      totalMinutes = _defaultLongBreakTime;
    }

    double totalTime = totalMinutes * 60.0;
    double progress = totalTime > 0 ? _remainingSeconds / totalTime : 0;

    int mins = _remainingSeconds ~/ 60;
    int secs = _remainingSeconds % 60;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size(260, 260),
                painter: _RingPainter(progress: value, color: color, width: 18),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: AppColors.textMain,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  _isRunning ? "RUNNING" : "PAUSED",
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettings(Color color) {
    return Opacity(
      opacity: _isRunning ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 15,
                  offset: const Offset(0, 5))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSettingItem(
                "Focus",
                _workTime,
                (val) => !_isRunning ? _changeTime(true, val) : null,
                _focusColor,
                _currentMode == 0),
            Container(width: 1, height: 40, color: Colors.grey[200]),
            _buildSettingItem(
                "Break",
                _breakTime,
                (val) => !_isRunning ? _changeTime(false, val) : null,
                _breakColor,
                _currentMode == 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, int value, Function(int) onDelta,
      Color activeColor, bool isActive) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _MiniButton(icon: Icons.remove, onTap: () => onDelta(-1)),
            SizedBox(
              width: 36,
              child: Text("$value",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? activeColor : AppColors.textMain)),
            ),
            _MiniButton(icon: Icons.add, onTap: () => onDelta(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildControlPanel(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          GestureDetector(
            onTap: _resetTimer,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.refresh_rounded,
                  color: AppColors.textMuted, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: _toggleTimer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 64,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: _isRunning ? 20 : 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28),
                    const SizedBox(width: 8),
                    Text(
                      _isRunning ? "PAUSE" : "START",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Components ---

class _AnimatedOrb extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController controller;
  final bool reverse;

  const _AnimatedOrb(
      {required this.color,
      required this.size,
      required this.controller,
      this.reverse = false});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.15).animate(CurvedAnimation(
        parent: controller,
        curve: reverse
            ? const Interval(0.5, 1.0, curve: Curves.easeInOut)
            : const Interval(0.0, 0.5, curve: Curves.easeInOut),
      )),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                RadialGradient(colors: [color, color.withValues(alpha: 0)])),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: AppColors.textMuted),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;

  _RingPainter(
      {required this.progress, required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - width) / 2;

    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}