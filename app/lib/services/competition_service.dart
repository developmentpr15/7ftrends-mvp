import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/competition.dart';

class CompetitionService {
  static const _competitionsKey = 'competitions';
  static const _entriesKey = 'competition_entries';
  static const _votesKey = 'competition_votes';

  Future<List<Competition>> loadCompetitions() async {
    final prefs = await SharedPreferences.getInstance();
    final competitionsJson = prefs.getStringList(_competitionsKey) ?? [];
    return competitionsJson
        .map((json) => Competition.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveCompetitions(List<Competition> competitions) async {
    final prefs = await SharedPreferences.getInstance();
    final competitionsJson =
        competitions.map((comp) => jsonEncode(comp.toJson())).toList();
    await prefs.setStringList(_competitionsKey, competitionsJson);
  }

  Future<List<Map<String, dynamic>>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList(_entriesKey) ?? [];
    return entriesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveEntries(List<Map<String, dynamic>> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((entry) => jsonEncode(entry)).toList();
    await prefs.setStringList(_entriesKey, entriesJson);
  }

  Future<List<Vote>> loadVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final votesJson = prefs.getStringList(_votesKey) ?? [];
    return votesJson.map((json) => Vote.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveVotes(List<Vote> votes) async {
    final prefs = await SharedPreferences.getInstance();
    final votesJson = votes.map((vote) => jsonEncode(vote.toJson())).toList();
    await prefs.setStringList(_votesKey, votesJson);
  }
}
