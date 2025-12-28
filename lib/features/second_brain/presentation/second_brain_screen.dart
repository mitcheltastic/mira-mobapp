import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/mira_text_field.dart';
import '../widgets/note_editor_screen.dart';
import '../widgets/note_card.dart';

class SecondBrainScreen extends StatefulWidget {
  const SecondBrainScreen({super.key});

  @override
  State<SecondBrainScreen> createState() => _SecondBrainScreenState();
}

class _SecondBrainScreenState extends State<SecondBrainScreen> {
  // Data Dummy Catatan
  final List<Map<String, dynamic>> _notes = [
    {
      "title": "Project MIRA Ideas",
      "content": "Implement Supabase Auth with RBAC. Design needs to be futuristic but clean. Use Bento grid layout for dashboard.",
      "date": "2 mins ago",
      "category": "Project"
    },
    {
      "title": "Network Security Summary",
      "content": "IPSec operates at Layer 3. Key components: AH (Authentication Header) and ESP (Encapsulating Security Payload).",
      "date": "Yesterday",
      "category": "Kuliah"
    },
    {
      "title": "Groceries List",
      "content": "Coffee, Milk, Eggs, Bread. Don't forget to buy energy drinks for coding night.",
      "date": "24 Oct 2025",
      "category": "Personal"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Second Brain", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: AppColors.textMain),
            onPressed: () {},
          ),
        ],
      ),
      
      // Tombol Tambah Catatan (Floating Action Button)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Buka Editor Mode Baru
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Note", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Search Bar
            const MiraTextField(
              hintText: "Search your brain...",
              icon: Icons.search,
            ),
            
            const SizedBox(height: 16),

            // Daftar Catatan
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return NoteCard(
                    title: note['title'],
                    content: note['content'],
                    date: note['date'],
                    category: note['category'],
                    onTap: () {
                      // Buka Editor Mode Edit (Bawa data)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(existingNote: note),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}