import 'package:flutter/material.dart';

import '../../models/feed_post.dart';
import '../../presentation/providers/competition_provider.dart';

class SubmitToCompetitionDialog extends StatelessWidget {
  final FeedPost post;
  final CompetitionProvider provider;

  const SubmitToCompetitionDialog({
    super.key,
    required this.post,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit to Competition'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.competitions.isEmpty)
            const Text('No active competitions available.')
          else
            ...provider.competitions.map((comp) => ElevatedButton(
              onPressed: () async {
                try {
                  await provider.submitPost(comp.id, post);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post submitted to competition!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to submit post.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(comp.title),
            )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
