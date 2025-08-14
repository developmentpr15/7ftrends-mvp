import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/competition_provider.dart';

class VoteDialog extends StatefulWidget {
  final String entryId;

  const VoteDialog({super.key, required this.entryId});

  @override
  State<VoteDialog> createState() => _VoteDialogState();
}

class _VoteDialogState extends State<VoteDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cast Your Vote'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            onPressed: () {
              setState(() {
                _rating = index + 1;
              });
            },
            icon: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _rating == 0
              ? null
              : () {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final competitionProvider =
                      Provider.of<CompetitionProvider>(context, listen: false);
                  competitionProvider.vote(
                    entryId: widget.entryId,
                    userId: authProvider.profile!['userId']!,
                    rating: _rating,
                  );
                  Navigator.of(context).pop();
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
