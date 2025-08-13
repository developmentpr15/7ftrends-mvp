import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_post.dart';

class LocalFeedService {
  static const _feedKey = 'feed_posts';

  Future<List<FeedPost>> loadFeedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_feedKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => FeedPost.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFeedPosts(List<FeedPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedKey, jsonEncode(posts.map((e) => e.toJson()).toList()));
  }

  Future<void> clearFeedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedKey);
  }
}
