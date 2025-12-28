import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    // Animasi Background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    // Animasi Entrance Navbar
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Background
          _buildAnimatedBackground(size),

          // 2. Content
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

  Widget _buildPremiumDock(Size size) {
    // Ukuran gap tengah FIX agar layout tidak geser
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        height: 80, 
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // --- Glassmorphism Container ---
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0), // Padding 0 agar Expanded maksimal
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // KIRI
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
                      
                      // TENGAH (FIXED SIZE GAP)
                      const SizedBox(width: centerGapWidth),

                      // KANAN
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
              top: -20, // Posisi naik sedikit
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
        
        // Label Text
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. ICON
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 26,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
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