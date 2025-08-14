import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/competition.dart';
import '../../../models/competition_entry.dart';
import '../../../models/competition_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/competition_provider.dart';
import '../../widgets/vote_dialog.dart';
import 'leaderboard_screen.dart';
import 'submit_entry_dialog.dart';

class CompetitionDetailScreen extends StatelessWidget {
  final Competition competition;

  const CompetitionDetailScreen({super.key, required this.competition});

  @override
  Widget build(BuildContext context) {
    final competitionProvider = Provider.of<CompetitionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isCompetitionActive = competition.status == CompetitionStatus.active;
    final participantCount =
        competitionProvider.getParticipantCount(competition.id);
    final List<CompetitionEntry> entries =
        competitionProvider.getEntriesForCompetition(competition.id);
    final hasUserEntered = competitionProvider.hasUserEntered(
        competition.id, authProvider.profile!['userId']!);
    final winners = competitionProvider.getWinners(competition.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(competition.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LeaderboardScreen(competitionId: competition.id),
                ),
              );
            },
            icon: const Icon(Icons.leaderboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(context, competition.status),
            Image.memory(
              base64Decode(competition.coverImageUrl),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    competition.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  if (competition.status == CompetitionStatus.ended &&
                      winners.isNotEmpty)
                    _buildWinnersSection(context, winners),
                  const SizedBox(height: 24),
                  Text(
                    'Entries',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  entries.isEmpty
                      ? const Center(
                          child: Text('No entries yet. Be the first to submit!'),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final hasVoted = competitionProvider.hasUserVoted(
                                entry.id, authProvider.profile!['userId']!);
                            return GestureDetector(
                              onTap: () {
                                if (isCompetitionActive && !hasVoted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        VoteDialog(entryId: entry.id),
                                  );
                                }
                              },
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Image.memory(
                                        entry.imageData,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.caption,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'by ${entry.username}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: isCompetitionActive && !hasUserEntered
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => SubmitEntryDialog(
                      competitionId: competition.id,
                    ),
                  );
                }
              : null,
          child:
              Text(hasUserEntered ? 'Already Entered' : 'Join / Submit Entry'),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
      BuildContext context, CompetitionStatus status) {
    return Container(
      width: double.infinity,
      color: status == CompetitionStatus.active ? Colors.green : Colors.red,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Status: ${status.name.toUpperCase()}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWinnersSection(
      BuildContext context, List<CompetitionEntry> winners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Winners',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: winners.length,
            itemBuilder: (context, index) {
              final winner = winners[index];
              return SizedBox(
                width: 100,
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.memory(
                          winner.imageData,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          winner.username,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
