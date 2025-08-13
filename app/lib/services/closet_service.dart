import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/closet_item.dart';

class ClosetService {
  static const _closetKey = 'closet_items';

  Future<List<ClosetItem>> loadClosetItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getStringList(_closetKey) ?? [];
    return itemsJson.map((json) => ClosetItem.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveClosetItems(List<ClosetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_closetKey, itemsJson);
  }
}
