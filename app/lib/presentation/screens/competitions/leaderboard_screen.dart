import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competition_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  final String competitionId;

  const LeaderboardScreen({super.key, required this.competitionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Consumer<CompetitionProvider>(
        builder: (context, provider, child) {
          final leaderboard = provider.getLeaderboard(competitionId);

          if (leaderboard.isEmpty) {
            return const Center(
              child: Text('No entries yet.'),
            );
          }

          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              final rank = index + 1;
              final averageRating = provider.getAverageRatingForEntry(entry.id);
              final totalVotes = provider.getVotesForEntry(entry.id).length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _buildRankIcon(rank),
                  title: Text(entry.username),
                  subtitle: Text('Votes: $totalVotes'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(averageRating.toStringAsFixed(2)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, color: Colors.amber);
    } else if (rank == 2) {
      return const Icon(Icons.emoji_events, color: Colors.grey);
    } else if (rank == 3) {
      return const Icon(Icons.emoji_events, color: Colors.brown);
    } else {
      return Text(
        '$rank',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
