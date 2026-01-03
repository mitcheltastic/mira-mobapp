import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/constant/app_colors.dart';

import '../widgets/post_card.dart';
import '../widgets/create_post_sheet.dart';
import '../widgets/edit_post_sheet.dart'; // Pastikan file ini ada
import '../widgets/report_post_sheet.dart'; // Widget baru di bawah

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Data Postingan
  List<Map<String, dynamic>> _posts = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _posts = List.from(initialPosts);
        _isLoading = false;
      });
    }
  }

  // --- LOGIC REFRESH DENGAN SKELETON ---
  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true); // 1. Nyalakan Skeleton
    await Future.delayed(const Duration(seconds: 2)); // 2. Simulasi Network
    
    if (mounted) {
      setState(() {
        _posts = List.from(initialPosts)..shuffle(); // 3. Acak data
        _isLoading = false; // 4. Matikan Skeleton
      });
    }
  }

  // --- LOGIC CREATE POST ---
  void _handleCreatePost(String content) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _posts.insert(0, {
          "id": DateTime.now().toString(),
          "name": "You",
          "userId": "user_001",
          "avatar": null,
          "isPro": true,
          "time": "Just now",
          "content": content,
          "likes": 0,
          "comments": 0,
          "isLiked": false,
        });
      });
    }
  }

  // --- LOGIC SEARCH FILTER ---
  List<Map<String, dynamic>> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final content = post['content'].toString().toLowerCase();
      final name = post['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return content.contains(query) || name.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. FIXED HEADER
          _buildHeader(),

          // 2. SCROLLABLE CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.textMain,
              backgroundColor: Colors.white,
              notificationPredicate: (notification) => notification.depth == 0,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  const SliverPadding(padding: EdgeInsets.only(top: 10)),

                  if (_isLoading)
                    // STATE: LOADING (Skeleton)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const PostSkeleton(),
                        childCount: 5,
                      ),
                    )
                  else if (_filteredPosts.isEmpty)
                    // STATE: EMPTY
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    // STATE: LIST DATA
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = _filteredPosts[index];
                            return PostCard(
                              data: post,
                              // --- DELETE ---
                              onDelete: () {
                                setState(() {
                                  _posts.removeWhere((p) => p['id'] == post['id']);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Post deleted"), duration: Duration(seconds: 1)),
                                );
                              },
                              // --- EDIT ---
                              onEdit: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => EditPostSheet(
                                    initialContent: post['content'],
                                    onSave: (newContent) {
                                      setState(() {
                                        final idx = _posts.indexWhere((p) => p['id'] == post['id']);
                                        if (idx != -1) _posts[idx]['content'] = newContent;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Post updated successfully")),
                                      );
                                    },
                                  ),
                                );
                              },
                              // --- REPORT (POPUP BARU) ---
                              onReport: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => const ReportPostSheet(),
                                );
                              },
                            );
                          },
                          childCount: _filteredPosts.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CreatePostSheet(onSubmit: _handleCreatePost),
            );
          },
          backgroundColor: AppColors.textMain,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
          label: const Text(
            "New Post",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Helper Widget: Header
  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: const Text(
              "Community",
              style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: "Search discussions...",
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted.withValues(alpha: 0.5), size: 24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            "No posts found",
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET SKELETON (Tetap) ---
class PostSkeleton extends StatefulWidget {
  const PostSkeleton({super.key});

  @override
  State<PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<PostSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 100, height: 14, color: Colors.grey[200]),
                  const SizedBox(height: 6),
                  Container(width: 60, height: 12, color: Colors.grey[100]),
                ]),
              ],
            ),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 14, color: Colors.grey[100]),
            const SizedBox(height: 8),
            Container(width: 200, height: 14, color: Colors.grey[100]),
          ],
        ),
      ),
    );
  }
}

// --- DATA DUMMY ---
final List<Map<String, dynamic>> initialPosts = [
  {
    "id": "1",
    "userId": "user_001",
    "name": "Sarah Jenkins",
    "avatar": "https://i.pravatar.cc/150?u=a042581f4e29026024d",
    "isPro": true,
    "time": "2 hrs ago",
    "content": "Just finished the Pomodoro technique for 4 hours straight! 🍅",
    "likes": 24,
    "comments": 5,
    "isLiked": false,
  },
  {
    "id": "2",
    "userId": "user_999",
    "name": "David Chen",
    "avatar": "https://i.pravatar.cc/150?u=a042581f4e29026704d",
    "isPro": false,
    "time": "5 hrs ago",
    "content": "Does anyone have good resources for learning Flutter Advanced animations?",
    "likes": 12,
    "comments": 8,
    "isLiked": true,
  },
];