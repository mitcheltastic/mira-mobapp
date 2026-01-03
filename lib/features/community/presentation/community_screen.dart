import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constant/app_colors.dart';
import '../data/post_model.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_sheet.dart';
// Adjust the path below to match where your ProfileScreen is located
import '../../profile/presentation/profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _supabase = Supabase.instance.client;

  // 1. Fetch current user's avatar URL just for the header
  Future<String?> _getCurrentUserAvatar() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .single();
      return data['avatar_url'] as String?;
    } catch (e) {
      debugPrint("Error fetching current user avatar: $e");
      return null;
    }
  }

  // Stream for the timeline posts
  Stream<List<Post>> _getPostsStream() {
    final myId = _supabase.auth.currentUser?.id;

    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((List<Map<String, dynamic>> data) async {
          if (data.isEmpty) return <Post>[];

          // 1. Prepare Lists for Batch Querying
          final userIds = data.map((e) => e['user_id']).toSet().toList();
          final postIds = data.map((e) => e['id']).toList();

          // 2. Batch Fetch Profiles (Optimization)
          final profilesData = await _supabase
              .from('profiles')
              .select()
              .filter('id', 'in', userIds);

          final profilesMap = {
            for (var p in profilesData) p['id'] as String: p,
          };

          // 3. Batch Fetch "My Likes" (To see which posts I already liked)
          Set<String> myLikedPostIds = {};
          if (myId != null) {
            final myLikesData = await _supabase
                .from('post_likes')
                .select('post_id')
                .eq('user_id', myId)
                .filter('post_id', 'in', postIds);

            myLikedPostIds = myLikesData
                .map((e) => e['post_id'] as String)
                .toSet();
          }

          // 4. Process each post to get Counts and Merge Data
          final postsFuture = data.map((post) async {
            final userId = post['user_id'];
            final postId = post['id'];
            final profile = profilesMap[userId];

            // --- FIX IS HERE ---
            // .count() returns an int directly, not an object
            final likeCount = await _supabase
                .from('post_likes')
                .count(CountOption.exact)
                .eq('post_id', postId);

            final commentCount = await _supabase
                .from('comments')
                .count(CountOption.exact)
                .eq('post_id', postId);

            // Merge everything into the map
            final newMap = Map<String, dynamic>.from(post);
            newMap['profiles'] = profile ?? {};

            // Assign the int directly
            newMap['likes_count'] = likeCount;
            newMap['comments_count'] = commentCount;
            newMap['is_liked'] = myLikedPostIds.contains(postId);

            return Post.fromMap(newMap);
          });

          return await Future.wait(postsFuture);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Timeline",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // Clickable Profile Avatar
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: FutureBuilder<String?>(
                future: _getCurrentUserAvatar(),
                builder: (context, snapshot) {
                  final avatarUrl = snapshot.data;

                  // Placeholder Widget
                  Widget placeholderMsg = CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  );

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return placeholderMsg;
                  }

                  if (avatarUrl != null && avatarUrl.isNotEmpty) {
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(avatarUrl),
                    );
                  } else {
                    return placeholderMsg;
                  }
                },
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<List<Post>>(
        stream: _getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No posts yet. Be the first!",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreatePostSheet(),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Post",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
