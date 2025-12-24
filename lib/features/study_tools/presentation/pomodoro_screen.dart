import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_button.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // --- KONFIGURASI STATE ---
  int _studyMinutes = 25; // Default Fokus
  int _breakMinutes = 5;  // Default Istirahat
  late int _remainingSeconds;
  
  bool _isRunning = false;
  bool _isBreakMode = false; // True jika sedang istirahat
  Timer? _timer;

  // Controller untuk input nama tugas
  final TextEditingController _taskController = TextEditingController(text: "Mobile Programming");

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _studyMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  // Menghitung progress ring (0.0 - 1.0)
  double get _progress {
    final totalSeconds = (_isBreakMode ? _breakMinutes : _studyMinutes) * 60;
    return _remainingSeconds / totalSeconds;
  }

  // Format Waktu MM:SS
  String get _timerString {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Logika Timer
  void _startTimer() {
    if (_timer != null) return;
    setState(() => _isRunning = true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _finishSession();
        }
      });
    });
  }

  void _finishSession() {
    _stopTimer();
    // Ganti Mode (Fokus <-> Istirahat)
    setState(() {
      _isBreakMode = !_isBreakMode;
      _remainingSeconds = (_isBreakMode ? _breakMinutes : _studyMinutes) * 60;
    });

    // Tampilkan Dialog Sederhana
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBreakMode ? "Break Time! ☕" : "Back to Work! 🚀"),
        content: Text(_isBreakMode 
          ? "Great job! Take a cleaner break for $_breakMinutes minutes." 
          : "Break is over. Ready to focus again?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _isBreakMode = false; // Reset kembali ke mode kerja
      _remainingSeconds = _studyMinutes * 60;
    });
  }

  // --- MODAL SETTINGS (UNTUK UBAH WAKTU) ---
  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Kita pakai StatefulBuilder agar slider di dalam bottom sheet bisa gerak
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Timer Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Slider Fokus
                  Text("Focus Duration: $_studyMinutes min", style: const TextStyle(color: AppColors.textMuted)),
                  Slider(
                    value: _studyMinutes.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() => _studyMinutes = val.toInt());
                      // Update tampilan utama juga jika timer belum jalan
                      if (!_isRunning && !_isBreakMode) {
                        setState(() => _remainingSeconds = _studyMinutes * 60);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Slider Istirahat
                  Text("Break Duration: $_breakMinutes min", style: const TextStyle(color: AppColors.textMuted)),
                  Slider(
                    value: _breakMinutes.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: AppColors.success, // Hijau untuk istirahat
                    onChanged: (val) {
                      setModalState(() => _breakMinutes = val.toInt());
                    },
                  ),

                  const SizedBox(height: 24),
                  MiraButton(
                    text: "Save Settings",
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema berdasarkan mode (Indigo=Kerja, Hijau=Istirahat)
    final currentColor = _isBreakMode ? AppColors.success : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, // Agar keyboard tidak merusak layout
      appBar: AppBar(
        title: Text(_isBreakMode ? "Rest & Recover" : "Deep Work Session", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMain),
            onPressed: _isRunning ? null : _showSettingsBottomSheet, // Disable saat jalan
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. INPUT MANUAL TUGAS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: currentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: currentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      style: TextStyle(color: currentColor, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "What are you working on?",
                        hintStyle: TextStyle(color: Colors.grey),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // 2. Timer Indicator Besar
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 20,
                    color: Colors.grey.shade200,
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 20,
                    color: currentColor, // Warna berubah sesuai mode
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timerString,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _isBreakMode ? "until focus time" : "minutes left",
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // 3. Control Buttons
            if (!_isRunning)
              MiraButton(
                text: _remainingSeconds == (_studyMinutes * 60) || _remainingSeconds == (_breakMinutes * 60)
                    ? (_isBreakMode ? "Start Break" : "Start Focus") 
                    : "Resume",
                onPressed: _startTimer,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: MiraButton(
                      text: "Pause",
                      isOutline: true,
                      onPressed: _stopTimer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _resetTimer,
                      child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}