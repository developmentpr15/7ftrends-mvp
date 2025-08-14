import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/competition.dart';
import '../../../models/competition_entry.dart';
import '../../providers/competition_provider.dart';

class CompetitionDetailScreen extends StatelessWidget {
  final Competition competition;

  const CompetitionDetailScreen({super.key, required this.competition});

  @override
  Widget build(BuildContext context) {
    final timeRemaining = competition.endDate.difference(DateTime.now());
    final isCompetitionActive = timeRemaining.isNegative == false;
    final competitionProvider = Provider.of<CompetitionProvider>(context);
    final participantCount =
        competitionProvider.getParticipantCount(competition.id);
    final List<CompetitionEntry> entries =
        competitionProvider.getEntriesForCompetition(competition.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(competition.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoColumn(
                            context,
                            Icons.timer,
                            'Time Remaining',
                            isCompetitionActive
                                ? '${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h'
                                : 'Ended',
                          ),
                          _buildInfoColumn(
                            context,
                            Icons.people,
                            'Participants',
                            participantCount.toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Rules',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. All entries must be original work.\n'
                    '2. Submissions must adhere to the competition theme.\n'
                    '3. No late submissions will be accepted.',
                  ),
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
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
          onPressed: isCompetitionActive ? () {} : null,
          child: const Text('Join / Submit Entry'),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
