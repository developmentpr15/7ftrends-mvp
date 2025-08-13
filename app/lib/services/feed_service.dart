import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feed_post.dart';

class FeedService {
  static const _feedKey = 'feed_posts';

  Future<List<FeedPost>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getStringList(_feedKey) ?? [];
    return postsJson.map((json) => FeedPost.fromJson(jsonDecode(json))).toList();
  }

  Future<void> savePosts(List<FeedPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((post) => jsonEncode(post.toJson())).toList();
    await prefs.setStringList(_feedKey, postsJson);
  }
}
