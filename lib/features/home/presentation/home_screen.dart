import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import '../../../core/constant/app_colors.dart';

// Import widget yang sudah ada
import '../../dashboard/widgets/dashboard_header.dart';
import '../widgets/focus_card.dart';
import '../widgets/tools_grid.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onSwitchTab;

  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Controller untuk menangani input teks
  final TextEditingController _searchController = TextEditingController();

  // State untuk mengecek apakah sedang ada teks atau tidak
  bool _isSearching = false;

  // 2. Variable untuk menampung nama user (Default sementara)
  String _userName = "Friend";

  @override
  void initState() {
    super.initState();

    // Panggil fungsi ambil data user
    _getUserProfile();

    // Listener search
    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty;
      });
    });
  }

  // 3. Fungsi mengambil data nama dari Supabase
  Future<void> _getUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Query ke tabel 'profiles' ambil kolom 'full_name'
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            // Ambil nama depan saja biar rapi (opsional)
            String fullName = data['full_name'] ?? "Friend";
            _userName = fullName.split(' ')[0]; // Ambil kata pertama
          });
        }
      }
    } catch (e) {
      // Jika error (misal koneksi jelek), biarkan default "Friend"
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi simulasi pencarian
  void _handleSearch(String query) {
    if (query.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Searching for '$query'..."),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. Update Header dengan variabel _userName
              DashboardHeader(userName: _userName), // Tidak const lagi

              const SizedBox(height: 24),

              // FUNCTIONAL SEARCH BAR
              _buildFunctionalSearchBar(),

              const SizedBox(height: 32),

              // Focus Mode Section
              _buildSectionTitle(
                title: "Focus Mode",
                subtitle: "Let's get productive",
              ),
              const SizedBox(height: 16),
              const FocusCard(),

              const SizedBox(height: 32),

              // Study Tools Section
              _buildSectionTitle(
                title: "Study Tools",
                subtitle: "Essentials for you",
                actionText: "View All",
                onAction: () => widget.onSwitchTab(1),
              ),
              const SizedBox(height: 16),
              const ToolsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER (Sama seperti sebelumnya) ---

  Widget _buildFunctionalSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isSearching ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _handleSearch,
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: "Search notes, tools...",
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 22,
          ),
          suffixIcon: _isSearching
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
