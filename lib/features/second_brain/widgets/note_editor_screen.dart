import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class NoteEditorScreen extends StatelessWidget {
  // Jika null, berarti Mode Tambah Baru
  final Map<String, dynamic>? existingNote; 

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  Widget build(BuildContext context) {
    // Controller untuk text
    final titleController = TextEditingController(text: existingNote?['title'] ?? "");
    final contentController = TextEditingController(text: existingNote?['content'] ?? "");

    return Scaffold(
      backgroundColor: Colors.white, // Editor biasanya putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tombol Save
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Note Saved!")),
                );
              },
              child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Input Judul
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain),
              decoration: const InputDecoration(
                hintText: "Title...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(),
            // Input Isi (Expandable)
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null, // Unlimited lines
                style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textMain),
                decoration: const InputDecoration(
                  hintText: "Start typing your thoughts...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}