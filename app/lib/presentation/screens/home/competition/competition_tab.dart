import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/competition_provider.dart';
import '../../../../shared/constants.dart';

class CompetitionTab extends StatelessWidget {
  const CompetitionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, child) {
        if (provider.competitions.isEmpty) {
          return const Center(
            child: Text('No competitions yet'),
          );
        }

        return ListView.builder(
          itemCount: provider.competitions.length,
          itemBuilder: (context, index) {
            final competition = provider.competitions[index];
            final entries = provider.getEntriesForCompetition(competition.id);
            final daysLeft = competition.endDate.difference(DateTime.now()).inDays;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  // TODO: Navigate to competition detail screen
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.memory(
                        base64Decode(competition.coverImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            competition.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(competition.description),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.style,
                                    size: 16,
                                    color: kPrimaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(competition.theme),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: kPrimaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$daysLeft days left'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 1 - (daysLeft / 30), // Assuming 30-day competitions
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (entries.isNotEmpty)
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: entries.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  final rating = provider.getAverageRatingForEntry(entry['id']);
                                  return SizedBox(
                                    width: 80,
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.memory(
                                            base64Decode(entry['imageData'] ?? ''),
                                            height: 60,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
