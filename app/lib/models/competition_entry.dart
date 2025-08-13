class CompetitionEntry {
  final String id;
  final String competitionId;
  final String userId;
  final String username;
  final String imageData;
  final String caption;
  final DateTime submittedAt;
  final double? averageRating;
  final int voteCount;

  const CompetitionEntry({
    required this.id,
    required this.competitionId,
    required this.userId,
    required this.username,
    required this.imageData,
    required this.caption,
    required this.submittedAt,
    this.averageRating,
    required this.voteCount,
  });
}
