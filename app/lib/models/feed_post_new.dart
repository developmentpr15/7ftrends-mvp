class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String imageData;
  final String caption;
  final List<String> hashtags;
  final int likes;
  final bool likedByMe;
  final DateTime createdAt;
  final String? closetItemId;

  FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.imageData,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.likedByMe,
    required this.createdAt,
    this.closetItemId,
  });

  FeedPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? imageData,
    String? caption,
    List<String>? hashtags,
    int? likes,
    bool? likedByMe,
    DateTime? createdAt,
    String? closetItemId,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt ?? this.createdAt,
      closetItemId: closetItemId ?? this.closetItemId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'username': username,
    'userAvatarUrl': userAvatarUrl,
    'imageData': imageData,
    'caption': caption,
    'hashtags': hashtags,
    'likes': likes,
    'likedByMe': likedByMe,
    'createdAt': createdAt.toIso8601String(),
    'closetItemId': closetItemId,
  };

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      imageData: json['imageData'] ?? '',
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: json['likes'] ?? 0,
      likedByMe: json['likedByMe'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      closetItemId: json['closetItemId'],
    );
  }
}
