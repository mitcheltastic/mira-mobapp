import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORTS SCREEN (Pastikan path sesuai) ---
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
      const CommunityScreen(), // Index 2 (Tengah)
      const ChatsScreen(),
      const ProfileScreen(),
    ];

    // 1. Animasi Background (Breathing Effect) - Diperlambat agar lebih elegan
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Lebih lambat = lebih tenang
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    // 2. Animasi Entrance Navbar
    _navEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
      // Haptic yang lebih tajam untuk kesan responsif
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Status Bar Transparan
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
          // 1. Background Animasi
          _buildAnimatedBackground(size),

          // 2. Content Body
          // Menggunakan IndexedStack untuk performa lebih baik (state tidak hilang saat pindah tab)
          // Atau gunakan AnimatedSwitcher jika ingin efek fade antar halaman (seperti kodemu sebelumnya)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
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
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _navEntranceController,
              curve: Curves.easeOutQuart,
            ),
          ),
      child: Container(
        // Margin bawah sedikit dikurangi agar tidak terlalu "terbang"
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        height: 75, // Tinggi sedikit lebih compact agar proporsional
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // --- Glassmorphism Container ---
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.75,
                    ), // Lebih transparan
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1, // Border lebih tipis
                    ),
                    boxShadow: [
                      // Shadow yang sangat halus (Soft Glow)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      // Shadow outline tajam tipis
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 0,
                        offset: const Offset(0, 0),
                        spreadRadius: 0,
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
                            _PremiumNavItem(
                              activeIcon: Icons.home_rounded,
                              inactiveIcon: Icons.home_outlined,
                              label: "Home",
                              isSelected: _currentIndex == 0,
                              onTap: () => _onTabTapped(0),
                            ),
                            _PremiumNavItem(
                              activeIcon: Icons
                                  .auto_stories_rounded, // Ikon study lebih bagus
                              inactiveIcon: Icons.auto_stories_outlined,
                              label: "Study",
                              isSelected: _currentIndex == 1,
                              onTap: () => _onTabTapped(1),
                            ),
                          ],
                        ),
                      ),

                      // GAP TENGAH (Untuk tombol Community)
                      const SizedBox(width: 60),

                      // KANAN
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _PremiumNavItem(
                              activeIcon: Icons.chat_rounded,
                              inactiveIcon: Icons.chat_bubble_outline_rounded,
                              label: "Chats",
                              isSelected: _currentIndex == 3,
                              onTap: () => _onTabTapped(3),
                            ),
                            _PremiumNavItem(
                              activeIcon: Icons.person_rounded,
                              inactiveIcon: Icons.person_outline_rounded,
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

            // --- Floating Center Button (Community) ---
            Positioned(
              top: -25, // Membuatnya melayang keluar dock
              child: _buildCenterButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    bool isActive = _currentIndex == 2;

    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut, // Efek memantul saat berubah ukuran
            width: isActive ? 58 : 50,
            height: isActive ? 58 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Gradient Premium
              gradient: LinearGradient(
                colors: isActive
                    ? [
                        const Color(0xFF6366F1),
                        const Color(0xFF4F46E5),
                      ] // Indigo
                    : [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ], // Dark Blue/Black
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
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
                isActive ? Icons.groups_rounded : Icons.groups_outlined,
                key: ValueKey(isActive),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Label Community (Hanya muncul jika aktif untuk kesan bersih)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isActive ? 1.0 : 0.0,
            child: const Text(
              "Community",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return Stack(
      children: [
        // Orb 1 (Kanan Atas)
        Positioned(
          top: -80,
          right: -60,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
        // Orb 2 (Kiri Bawah)
        Positioned(
          bottom: 120,
          left: -80,
          child: ScaleTransition(
            scale: _bgScaleAnimation,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- PREMIUM NAV ITEM (CUSTOM WIDGET) ---
class _PremiumNavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Area sentuh optimal
      child: SizedBox(
        width: 60, // Lebar area sentuh
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. ICON DENGAN ANIMASI SWAP & BOUNCE
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0, // Logika Scale di sini
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack, // Efek memantul
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),

            const SizedBox(height: 4),

            // 2. INDIKATOR (DOT GLOWING)
            // Menggantikan text label agar lebih minimalis & premium
            // Jika ingin label text, ganti widget ini dengan Text(...)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: isSelected ? 4 : 0, // Membesar jika aktif
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            // Opsional: Jika tetap ingin text label, uncomment di bawah ini
            // dan comment bagian AnimatedContainer (Dot) di atas.
            /*
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}
