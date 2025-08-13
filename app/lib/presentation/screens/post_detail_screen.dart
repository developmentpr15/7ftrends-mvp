import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feed_post.dart';
import '../../models/user_profile.dart';
import '../providers/competition_provider.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final FeedPost post;
  final UserProfile currentUser;
  final ValueChanged<String> onLikeToggle;
  final ValueChanged<String> onDelete;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onLikeToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: ListView(
        children: [
          PostCard(
            post: post,
            currentUser: currentUser,
            competitionProvider: Provider.of<CompetitionProvider>(context, listen: false),
            onLikeToggle: onLikeToggle,
            onDelete: onDelete,
            onViewDetails: (_) {}, // No-op since we're already in detail view
          ),
          // Add comments section here when ready
        ],
      ),
    );
  }
}
