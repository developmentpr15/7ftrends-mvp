import 'dart:convert';
import 'dart:typed_data';

class CompetitionEntry {
  final String id;
  final String competitionId;
  final String userId;
  final String username;
  final Uint8List imageData;
  final String caption;
  final DateTime submittedAt;
  final String? feedPostId;
  double? averageRating;
  int voteCount;

  CompetitionEntry({
    required this.id,
    required this.competitionId,
    required this.userId,
    required this.username,
    required this.imageData,
    required this.caption,
    required this.submittedAt,
    this.feedPostId,
    this.averageRating,
    this.voteCount = 0,
  });

  factory CompetitionEntry.fromJson(Map<String, dynamic> json) {
    return CompetitionEntry(
      id: json['id'],
      competitionId: json['competitionId'],
      userId: json['userId'],
      username: json['username'],
      imageData: base64Decode(json['imageData']),
      caption: json['caption'],
      submittedAt: DateTime.parse(json['submittedAt']),
      feedPostId: json['feedPostId'],
      averageRating: json['averageRating']?.toDouble(),
      voteCount: json['voteCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competitionId': competitionId,
      'userId': userId,
      'username': username,
      'imageData': base64Encode(imageData),
      'caption': caption,
      'submittedAt': submittedAt.toIso8601String(),
      'feedPostId': feedPostId,
      'averageRating': averageRating,
      'voteCount': voteCount,
    };
  }
}
