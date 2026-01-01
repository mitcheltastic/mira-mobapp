import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// IMPORT FILE YANG SUDAH KITA BUAT SEBELUMNYA
import '../../../core/constant/app_colors.dart';
import '../widgets/note_card.dart';        
import '../widgets/note_editor_screen.dart'; 

class SecondBrainScreen extends StatefulWidget {
  const SecondBrainScreen({super.key});

  @override
  State<SecondBrainScreen> createState() => _SecondBrainScreenState();
}

class _SecondBrainScreenState extends State<SecondBrainScreen>
    with TickerProviderStateMixin {
  
  // --- Animation Controllers ---
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  // --- Search Controller ---
  final TextEditingController _searchController = TextEditingController();

  // --- DATA CATATAN (State Lokal) ---
  // PERBAIKAN: Tambahkan 'final' di sini karena list ini tidak pernah di-assign ulang
  final List<Map<String, dynamic>> _notes = [
    {
      "title": "Project MIRA Architecture",
      "content": "Implement Supabase Auth with RBAC. Design needs to be futuristic but clean.",
      "date": "2 mins ago",
      "category": "Project",
      "color": const Color(0xFF6366F1) // Indigo
    },
    {
      "title": "Network Security: IPSec",
      "content": "IPSec operates at Layer 3. Components: AH (Authentication Header) and ESP.",
      "date": "Yesterday",
      "category": "Study",
      "color": const Color(0xFF10B981) // Emerald
    },
    {
      "title": "Startup Ideas 2025",
      "content": "AI-powered gardening assistant? Or maybe a Second Brain app.",
      "date": "20 Oct 2025",
      "category": "Ideas",
      "color": const Color(0xFFF59E0B) // Amber
    },
  ];

  // List untuk hasil pencarian
  List<Map<String, dynamic>> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _filteredNotes = List.from(_notes); // Copy data awal

    // Setup Animasi Background
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
       _showIntroGuide(); 
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA PENCARIAN ---
  void _runFilter(String keyword) {
    List<Map<String, dynamic>> results = [];
    if (keyword.isEmpty) {
      results = _notes;
    } else {
      results = _notes
          .where((note) =>
              note["title"].toLowerCase().contains(keyword.toLowerCase()) ||
              note["content"].toLowerCase().contains(keyword.toLowerCase()) ||
              note["category"].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredNotes = results;
    });
  }

  // --- INTRO GUIDE (METHODOLOGY) ---
  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75, // Tinggi 75% layar
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            // Handle Bar (Garis kecil di atas)
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            
            // Title
            const Text(
              "Unlock Your Second Brain",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            
            // Subtitle
            const Text(
              "Stop trying to remember everything. Use this method to free your mind.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            
            // --- The C.O.R.E / C.O.R Concept ---
            
            // 1. Capture
            _buildGuideItem(
              icon: Icons.bolt_rounded,
              color: const Color(0xFFF59E0B), // Amber
              title: "Capture Instantly",
              desc: "Don't trust your memory. When you have an idea or insight, write it down immediately before it fades.",
            ),
            
            // 2. Organize
            _buildGuideItem(
              icon: Icons.folder_open_rounded,
              color: const Color(0xFF6366F1), // Indigo
              title: "Organize by Context",
              desc: "Categorize notes by Projects (active), Areas (ongoing), or Resources (reference). Keep it structured.",
            ),
            
            // 3. Retrieve
            _buildGuideItem(
              icon: Icons.search_rounded,
              color: const Color(0xFF10B981), // Emerald
              title: "Retrieve Anytime",
              desc: "Use the search bar to find connections between old ideas and new projects effortlessly.",
            ),
            
            const Spacer(),
            
            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textMain, // Dark button for premium feel
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Item Guide
  Widget _buildGuideItem({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIKA TAMBAH/EDIT DATA ---
  
  // 1. Menambah Catatan Baru
  void _addNewNote() async {
    HapticFeedback.mediumImpact();
    // Tunggu hasil (result) dari halaman editor
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
    );

    // Jika ada data yang dikembalikan (user menekan tombol Save)
    if (newNote != null) {
      setState(() {
        _notes.insert(0, newNote); // Masukkan ke paling atas
        _runFilter(_searchController.text); // Refresh filter
      });
    }
  }

  // 2. Mengedit Catatan
  void _editNote(int index, Map<String, dynamic> currentNote) async {
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(existingNote: currentNote),
      ),
    );

    if (updatedNote != null) {
      setState(() {
        // Cari index asli di _notes (karena _filteredNotes indexnya beda)
        int realIndex = _notes.indexOf(currentNote);
        if (realIndex != -1) {
          _notes[realIndex] = updatedNote;
          _runFilter(_searchController.text); // Refresh filter
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewNote, // Panggil fungsi tambah
        backgroundColor: AppColors.textMain, 
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Capture Idea", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: Stack(
        children: [
          // --- Background Animations (Orbs) ---
          Positioned(
            top: -100,
            left: -50,
            child: _AnimatedOrb(
              color: AppColors.primary.withValues(alpha: 0.15),
              size: 300,
              controller: _pulseController,
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: _AnimatedOrb(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              size: 200,
              controller: _pulseController,
              reverse: true,
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                
                // Search Bar Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _runFilter,
                      decoration: InputDecoration(
                        hintText: "Search your brain...",
                        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Note List
                Expanded(
                  child: _filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 100), // Padding bawah agar tidak tertutup FAB
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          
                          // Menggunakan Widget NoteCard yang baru kita buat
                          return FadeTransition(
                            opacity: _fadeController,
                            child: NoteCard(
                              title: note['title'],
                              content: note['content'],
                              date: note['date'],
                              category: note['category'],
                              accentColor: note['color'], // Mengirim warna kategori
                              onTap: () => _editNote(index, note), // Klik untuk edit
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Text("Second Brain",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textMain)),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                size: 24, color: AppColors.textMuted),
            onPressed: () {
              // Panggil fungsi intro guide disini jika perlu
            },
             padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 60, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            "No thoughts found",
            style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// Widget Orb untuk Background (Dicopy agar file ini bisa mandiri)
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
      scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(
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