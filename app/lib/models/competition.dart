import 'competition_status.dart';

class Competition {
  final String id;
  final String title;
  final String description;
  final String theme;
  final DateTime endDate;
  final String coverImageUrl;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.endDate,
    required this.coverImageUrl,
  });

  CompetitionStatus get status =>
      DateTime.now().isAfter(endDate) ? CompetitionStatus.ended : CompetitionStatus.active;

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      theme: json['theme'] ?? '',
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      coverImageUrl: json['coverImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'theme': theme,
    'endDate': endDate.toIso8601String(),
    'coverImageUrl': coverImageUrl,
  };
}


class Vote {
  final String entryId;
  final String userId;
  final int rating;

  Vote({
    required this.entryId,
    required this.userId,
    required this.rating,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      entryId: json['entryId'] ?? '',
      userId: json['userId'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'entryId': entryId,
    'userId': userId,
    'rating': rating,
  };
}

class LeaderboardEntry {
  final Map<String, dynamic> entry;
  final double averageRating;
  final int voteCount;

  LeaderboardEntry({
    required this.entry,
    required this.averageRating,
    required this.voteCount,
  });
}
