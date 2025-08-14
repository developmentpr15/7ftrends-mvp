import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import '../../models/competition_entry.dart';
import '../../services/competition_service.dart';
import '../../models/competition.dart';

class CompetitionProvider extends ChangeNotifier {
  final _competitionService = CompetitionService();
  List<Competition> _competitions = [];
  List<CompetitionEntry> _entries = [];
  List<Vote> _votes = [];

  bool _isLoading = false;
  Map<String, int> _participantCounts = {};

  CompetitionProvider() {
    loadAll();
  }

  bool get isLoading => _isLoading;
  List<Competition> get competitions => List.unmodifiable(_competitions);
  List<CompetitionEntry> get entries => List.unmodifiable(_entries);
  List<Vote> get votes => List.unmodifiable(_votes);

  int getParticipantCount(String competitionId) {
    return _participantCounts[competitionId] ?? 0;
  }

  bool hasUserEntered(String competitionId, String userId) {
    return _entries.any((entry) =>
        entry.competitionId == competitionId && entry.userId == userId);
  }

  bool hasPostBeenSubmitted(String postId) {
    return false;
  }

  Future<void> addEntry(CompetitionEntry entry) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries.add(entry);
      _updateParticipantCount(entry.competitionId);
      await _competitionService.saveEntries(_entries);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CompetitionEntry> getLeaderboard(String competitionId) {
    final competitionEntries =
        _entries.where((entry) => entry.competitionId == competitionId).toList();

    competitionEntries.sort((a, b) =>
        getAverageRatingForEntry(b.id).compareTo(getAverageRatingForEntry(a.id)));

    return competitionEntries;
  }

  List<CompetitionEntry> getWinners(String competitionId) {
    final leaderboard = getLeaderboard(competitionId);
    if (leaderboard.isEmpty) {
      return [];
    }

    final winners = <CompetitionEntry>[];
    for (int i = 0; i < leaderboard.length && i < 3; i++) {
      winners.add(leaderboard[i]);
    }

    if (leaderboard.length > 3) {
      final thirdPlaceRating = getAverageRatingForEntry(leaderboard[2].id);
      for (int i = 3; i < leaderboard.length; i++) {
        if (getAverageRatingForEntry(leaderboard[i].id) == thirdPlaceRating) {
          winners.add(leaderboard[i]);
        }
      }
    }

    return winners;
  }

  void _updateParticipantCount(String competitionId) {
    _participantCounts[competitionId] = _entries
        .where((entry) => entry.competitionId == competitionId)
        .map((entry) => entry.userId)
        .toSet()
        .length;
  }

  Future<void> loadAll() async {
    _competitions = await _competitionService.loadCompetitions();
    _entries = await _competitionService.loadEntries();
    _votes = await _competitionService.loadVotes();
    notifyListeners();
  }

  Future<void> addCompetition({
    required String title,
    required String description,
    required String theme,
    required DateTime endDate,
    required String coverImageUrl,
  }) async {
    final competition = Competition(
      id: DateTime.now().toString(),
      title: title,
      description: description,
      theme: theme,
      endDate: endDate,
      coverImageUrl: coverImageUrl,
    );

    _competitions.add(competition);
    await _competitionService.saveCompetitions(_competitions);
    notifyListeners();
  }

  Future<void> submitEntry({
    required String competitionId,
    required String userId,
    required String username,
    required Uint8List imageData,
    required String caption,
    required String feedPostId,
  }) async {
    final entry = CompetitionEntry(
      id: DateTime.now().toString(),
      competitionId: competitionId,
      userId: userId,
      username: username,
      imageData: imageData,
      caption: caption,
      submittedAt: DateTime.now(),
      feedPostId: feedPostId,
    );
    _entries.add(entry);
    await _competitionService.saveEntries(_entries);
    notifyListeners();
  }

  Future<void> vote({
    required String entryId,
    required String userId,
    required int rating,
  }) async {
    final existingVoteIndex = _votes.indexWhere(
      (v) => v.entryId == entryId && v.userId == userId,
    );

    if (existingVoteIndex != -1) {
      _votes.removeAt(existingVoteIndex);
    }

    final vote = Vote(
      entryId: entryId,
      userId: userId,
      rating: rating,
    );

    _votes.add(vote);
    await _competitionService.saveVotes(_votes);
    notifyListeners();
  }

  Future<void> deleteCompetition(String id) async {
    _competitions.removeWhere((comp) => comp.id == id);
    _entries.removeWhere((entry) => entry.competitionId == id);
    _votes.removeWhere((vote) =>
        _entries.any((entry) => entry.id == vote.entryId && entry.competitionId == id));

    await Future.wait([
      _competitionService.saveCompetitions(_competitions),
      _competitionService.saveEntries(_entries),
      _competitionService.saveVotes(_votes),
    ]);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    _votes.removeWhere((vote) => vote.entryId == id);

    await Future.wait([
      _competitionService.saveEntries(_entries),
      _competitionService.saveVotes(_votes),
    ]);
    notifyListeners();
  }

  List<CompetitionEntry> getEntriesForCompetition(String competitionId) {
    return _entries.where((entry) => entry.competitionId == competitionId).toList();
  }

  List<Vote> getVotesForEntry(String entryId) {
    return _votes.where((vote) => vote.entryId == entryId).toList();
  }

  double getAverageRatingForEntry(String entryId) {
    final entryVotes = getVotesForEntry(entryId);
    if (entryVotes.isEmpty) return 0;
    return entryVotes.map((v) => v.rating).reduce((a, b) => a + b) / entryVotes.length;
  }

  bool hasUserVoted(String entryId, String userId) {
    return _votes.any((vote) => vote.entryId == entryId && vote.userId == userId);
  }
}
