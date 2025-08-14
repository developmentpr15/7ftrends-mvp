import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/competition_provider.dart';
import '../../providers/feed_provider.dart';

class SubmitEntryDialog extends StatefulWidget {
  final String competitionId;

  const SubmitEntryDialog({super.key, required this.competitionId});

  @override
  State<SubmitEntryDialog> createState() => _SubmitEntryDialogState();
}

class _SubmitEntryDialogState extends State<SubmitEntryDialog> {
  String? _selectedPostId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final posts = feedProvider.getPostsForUser(authProvider.profile!['userId']!);

    return AlertDialog(
      title: const Text('Submit an Entry'),
      content: DropdownButtonFormField<String>(
        value: _selectedPostId,
        hint: const Text('Select a post'),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPostId = newValue;
          });
        },
        items: posts.map((post) {
          return DropdownMenuItem<String>(
            value: post['id'],
            child: Row(
              children: [
                Image.memory(
                  base64Decode(post['imageData']),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post['caption'],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedPostId == null
              ? null
              : () {
                  final competitionProvider =
                      Provider.of<CompetitionProvider>(context, listen: false);
                  competitionProvider.submitEntry(
                    competitionId: widget.competitionId,
                    userId: authProvider.profile!['userId']!,
                    username: authProvider.profile!['username']!,
                    imageData: base64Decode(posts
                        .firstWhere(
                            (post) => post['id'] == _selectedPostId)['imageData']),
                    caption: posts
                        .firstWhere(
                            (post) => post['id'] == _selectedPostId)['caption'],
                    feedPostId: _selectedPostId!,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entry submitted successfully!'),
                    ),
                  );
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
