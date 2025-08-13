import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/closet_item.dart';

class LocalClosetService {
  static const _closetKey = 'closet_items';

  Future<List<ClosetItem>> loadClosetItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_closetKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => ClosetItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveClosetItems(List<ClosetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_closetKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> clearClosetItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_closetKey);
  }
}
