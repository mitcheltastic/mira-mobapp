class Post {
  final String id;
  final String userId;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;

  // Profile Data (Joined)
  final String userName;
  final String? userAvatar;

  // --- NEW: Interactive Data ---
  final int likeCount;
  final int commentCount;
  final bool isLiked; // Did the current user like this?

  Post({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.userName,
    this.userAvatar,
    // Initialize new fields with defaults
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] ?? {};

    return Post(
      id: map['id'],
      userId: map['user_id'],
      content: map['content'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      userName: profile['full_name'] ?? profile['nickname'] ?? 'Unknown',
      userAvatar: profile['avatar_url'],

      // Map the new fields (These keys will come from our query later)
      likeCount: map['likes_count'] ?? 0,
      commentCount: map['comments_count'] ?? 0,
      isLiked: map['is_liked'] ?? false,
    );
  }
}
