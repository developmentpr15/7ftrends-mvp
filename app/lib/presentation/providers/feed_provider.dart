import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../../models/feed_post.dart';

class FeedProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  static const _feedKey = 'feed_posts';

  bool get isLoading => _isLoading;

  FeedProvider() {
    loadPosts();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<Map<String, dynamic>> get posts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((post) {
      final searchText = _searchQuery.toLowerCase();
      return (post['caption']?.toLowerCase().contains(searchText) ?? false) ||
          (post['username']?.toLowerCase().contains(searchText) ?? false) ||
          ((post['hashtags'] ?? []).any((tag) => tag.toLowerCase().contains(searchText)));
    }).toList();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getStringList(_feedKey);
  if (postsJson != null) {
    _posts = postsJson
    .map((json) => jsonDecode(json) as Map<String, dynamic>)
    .toList()
    .reversed
    .toList();
  }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPost(Map<String, dynamic> post) async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts.insert(0, post);
      await _savePosts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPostParams({
    required String userId,
    required String username,
    required String userAvatarUrl,
    required String imageData,
    required String caption,
    required List<String> hashtags,
    String? closetItemId,
  }) async {
    final post = {
      'id': DateTime.now().toString(),
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'imageData': imageData,
      'caption': caption,
      'hashtags': hashtags,
      'likes': 0,
      'likedByMe': false,
      'createdAt': DateTime.now(),
      'closetItemId': closetItemId,
    };

    await addPost(post);
  }

  Future<void> toggleLike(String postId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final postIndex = _posts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = {
          ...post,
          'likes': post['likedByMe'] == true ? (post['likes'] ?? 0) - 1 : (post['likes'] ?? 0) + 1,
          'likedByMe': !(post['likedByMe'] == true),
        };
        await _savePosts();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
  _posts.removeWhere((p) => p['id'] == postId);
      await _savePosts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(Map<String, dynamic> post) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _posts.indexWhere((p) => p['id'] == post['id']);
      if (index != -1) {
        _posts[index] = post;
        await _savePosts();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
  final postsJson = _posts.map((p) => jsonEncode(p)).toList();
  await prefs.setStringList(_feedKey, postsJson);
  }
}
