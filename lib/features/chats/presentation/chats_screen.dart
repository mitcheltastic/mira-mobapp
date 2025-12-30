import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/constant/app_colors.dart';
import '../data/chat_user_model.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<ChatPreview> _allChats = [];
  List<ChatPreview> _foundChats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allChats = dummyChats;
    _foundChats = _allChats;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter(String keyword) {
    List<ChatPreview> results = [];
    if (keyword.isEmpty) {
      results = _allChats;
    } else {
      results = _allChats
          .where((item) =>
              item.user.name.toLowerCase().contains(keyword.toLowerCase()) ||
              item.lastMessage.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundChats = results;
    });
  }

  void _deleteChat(int index) {
    // Simpan item untuk fitur Undo
    final deletedItem = _foundChats[index];
    
    setState(() {
      _foundChats.removeAt(index);
      // Hapus juga dari _allChats agar sinkron
      _allChats.removeWhere((item) => item.user.name == deletedItem.user.name);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Conversation deleted"),
        backgroundColor: AppColors.textMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _foundChats.insert(index, deletedItem);
              _allChats.add(deletedItem); // Kembalikan ke list utama
            });
          },
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String name) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Delete Chat?"),
              content: Text(
                "Are you sure you want to delete conversation with $name?",
                style: const TextStyle(color: AppColors.textMuted),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel",
                      style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Background bersih
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER & SEARCH ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              color: const Color(0xFFFAFAFA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Messages",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Modern Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.freeBorder.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _runFilter(value),
                      style: const TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "Search conversations...",
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                color: AppColors.textMuted,
                                onPressed: () {
                                  _searchController.clear();
                                  _runFilter('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CHAT LIST ---
            Expanded(
              child: _foundChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_chat_unread_rounded,
                            size: 64,
                            color: AppColors.textMuted.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No messages found",
                            style: TextStyle(
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _foundChats.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final chat = _foundChats[index];
                        return _buildChatSlidable(chat, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSlidable(ChatPreview chat, int index) {
    return Slidable(
      key: Key(chat.user.name),
      endActionPane: ActionPane(
        motion: const ScrollMotion(), // Lebih smooth dari StretchMotion
        extentRatio: 0.25,
        dismissible: DismissiblePane(
          onDismissed: () => _deleteChat(index),
          confirmDismiss: () async =>
              await _showConfirmationDialog(context, chat.user.name),
        ),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              bool confirm =
                  await _showConfirmationDialog(context, chat.user.name);
              if (confirm) _deleteChat(index);
            },
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.error,
            padding: EdgeInsets.zero,
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 24),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(user: chat.user),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: chat.unreadCount > 0
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Hero(
                tag: chat.user.name,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: chat.unreadCount > 0
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                  ),
                  child: Center(
                    child: Text(
                      chat.user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: chat.unreadCount > 0
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chat.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          chat.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: chat.unreadCount > 0
                                ? AppColors.primary
                                : AppColors.textMuted.withValues(alpha: 0.7),
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: chat.unreadCount > 0
                                  ? AppColors.textMain
                                  : AppColors.textMuted,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}