import 'dart:convert';

class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String imageData;
  final String caption;
  final List<String> hashtags;
  final int likes;
  final bool likedByMe;
  final DateTime createdAt;
  final String? closetItemId;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.imageData,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.likedByMe,
    required this.createdAt,
    this.closetItemId,
  });

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
    'createdAt': createdAt.millisecondsSinceEpoch,
    'closetItemId': closetItemId,
  };

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
    id: json['id'] as String,
    userId: json['userId'] as String,
    username: json['username'] as String,
    userAvatarUrl: json['userAvatarUrl'] as String?,
    imageData: json['imageData'] as String,
    caption: json['caption'] as String,
    hashtags: List<String>.from(json['hashtags'] as List),
    likes: json['likes'] as int,
    likedByMe: json['likedByMe'] as bool,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    closetItemId: json['closetItemId'] as String?,
  );
}