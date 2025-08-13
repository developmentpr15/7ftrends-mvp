import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/competition.dart';

class LocalCompetitionService {
  static const _competitionsKey = 'competitions_data';
  static const _entriesKey = 'competition_entries_data';
  static const _votesKey = 'competition_votes_data';

  Future<List<Competition>> loadCompetitions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_competitionsKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Competition.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCompetitions(List<Competition> competitions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_competitionsKey, jsonEncode(competitions.map((e) => e.toJson()).toList()));
  }

  Future<List<CompetitionEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_entriesKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => CompetitionEntry.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEntries(List<CompetitionEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<List<Vote>> loadVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_votesKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => Vote.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVotes(List<Vote> votes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_votesKey, jsonEncode(votes.map((e) => e.toJson()).toList()));
  }
}
