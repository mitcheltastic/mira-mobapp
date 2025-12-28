import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORTS SCREEN (Pastikan path sesuai dengan project kamu) ---
import '../../home/presentation/home_screen.dart';
import '../../community/presentation/community_screen.dart';
import '../../chats/presentation/chats_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../study_tools/presentation/study_screen.dart';
import '../../../core/constant/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Animation Controllers
  late AnimationController _bgController;
  late Animation<double> _bgScaleAnimation;
  late AnimationController _navEntranceController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(onSwitchTab: _onTabTapped),
      const StudyScreen(),
      const CommunityScreen(),
      const ChatsScreen(),
      const ProfileScreen(),
    ];

    // 1. Animasi Background (Breathing Effect)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    // 2. Animasi Entrance Navbar (Slide Up)
    _navEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navEntranceController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _navEntranceController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengatur Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true, // Body meluas ke belakang navbar
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Background Animasi
          _buildAnimatedBackground(size),

          // 2. Content Body dengan Transisi Fade & Scale
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutQuint,
            switchOutCurve: Curves.easeInQuint,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildPremiumDock(size),
    );
  }

  // --- PREMIUM DOCK BUILDER ---
  Widget _buildPremiumDock(Size size) {
    const double centerGapWidth = 70.0;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _navEntranceController,
              curve: Curves.easeOutQuart,
            ),
          ),
      child: Container(
        // Margin disesuaikan agar terlihat "melayang"
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // --- Glassmorphism Base ---
            ClipRRect(
              borderRadius: BorderRadius.circular(35), // Radius lebih lembut
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Blur premium
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(35),
                    
                    // Highlight Border (Efek Kaca)
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.5,
                    ),
                    
                    // KOMBINASI 3 LAYER SHADOW
                    boxShadow: [
                      // 1. Ambient Shadow (Jauh & Halus)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      // 2. Glow Shadow (Warna Tema)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      // 3. Outline Shadow (Definisi Tajam)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Sisi Kiri
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FixedNavItem(
                              icon: Icons.home_rounded,
                              label: "Home",
                              isSelected: _currentIndex == 0,
                              onTap: () => _onTabTapped(0),
                            ),
                            _FixedNavItem(
                              icon: Icons.school_rounded,
                              label: "Study",
                              isSelected: _currentIndex == 1,
                              onTap: () => _onTabTapped(1),
                            ),
                          ],
                        ),
                      ),
                      
                      // Gap Tengah
                      const SizedBox(width: centerGapWidth),

                      // Sisi Kanan
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _FixedNavItem(
                              icon: Icons.chat_bubble_rounded,
                              label: "Chats",
                              isSelected: _currentIndex == 3,
                              onTap: () => _onTabTapped(3),
                            ),
                            _FixedNavItem(
                              icon: Icons.person_rounded,
                              label: "Profile",
                              isSelected: _currentIndex == 4,
                              onTap: () => _onTabTapped(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // --- Tombol Tengah (Community) ---
            Positioned(
              top: -22, // Posisi sedikit naik keluar dari dock
              child: GestureDetector(
                onTap: () => _onTabTapped(2),
                child: _buildCenterButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    bool isActive = _currentIndex == 2;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          width: isActive ? 60 : 54,  
          height: isActive ? 60 : 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isActive
                  ? [const Color(0xFF6366F1), const Color(0xFF818CF8)]
                  : [const Color(0xFF4F46E5), const Color(0xFF4338CA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isActive ? 0.5 : 0.25,
                ),
                blurRadius: isActive ? 20 : 12,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              Icons.groups_rounded,
              key: ValueKey(isActive),
              color: Colors.white,
              size: isActive ? 30 : 26,
            ),
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Label Text Animasi
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuint,
          child: SizedBox(
            height: isActive ? 16 : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.0,
              child: const Text(
                "Community",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- FIXED NAV ITEM (STABIL & ANIMATIF) ---
class _FixedNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FixedNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        // Area sentuh vertikal diperbesar untuk UX
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. ICON dengan Animasi Warna & Skala
            TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 300),
              tween: ColorTween(
                begin: AppColors.textMuted,
                end: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              builder: (context, color, child) {
                return AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0, // Efek pop saat aktif
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 26,
                    color: color,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 4),
            
            // 2. TEXT LABEL (Fade In/Out)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800, // Bold agar terbaca jelas
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}