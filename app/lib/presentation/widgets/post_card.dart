import 'dart:convert';
import 'package:flutter/material.dart';

import '../../shared/constants.dart';
import '../../models/feed_post.dart';
import '../../models/user_profile.dart';
import '../../presentation/providers/competition_provider.dart';
import '../widgets/avatar_circle.dart';
import '../screens/post_detail_screen.dart';
import '../screens/submit_to_competition_dialog.dart';

class PostCard extends StatelessWidget {
  final FeedPost post;
  final UserProfile currentUser;
  final CompetitionProvider competitionProvider;
  final ValueChanged<String> onLikeToggle;
  final ValueChanged<String> onDelete;
  final ValueChanged<FeedPost> onViewDetails;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.competitionProvider,
    required this.onLikeToggle,
    required this.onDelete,
    required this.onViewDetails,
  });

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Submit to Competition'),
              onTap: () async {
                Navigator.pop(ctx);
                await showDialog(
                  context: context,
                  builder: (_) => SubmitToCompetitionDialog(
                    post: post,
                    provider: competitionProvider,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                onDelete(post.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AvatarCircle(
                  initials: post.username.isNotEmpty ? post.username[0].toUpperCase() : '?',
                  radius: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (post.userId == currentUser.userId)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPostOptions(context),
                  ),
              ],
            ),
          ),
          if (post.imageData.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => onLikeToggle(post.id),
              child: Image.memory(
                base64Decode(post.imageData),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: post.likedByMe ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => onLikeToggle(post.id),
                    ),
                    Text('${post.likes} likes'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () => onViewDetails(post),
                    ),
                    const Text('0 comments'), // Placeholder for comments count
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                if (post.hashtags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      post.hashtags.map((e) => '#$e').join(' '),
                      style: const TextStyle(color: kPrimaryColor),
                    ),
                  ),
                if (post.closetItemId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Wearing: ${post.closetItemId}', // This should ideally show the item name
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
