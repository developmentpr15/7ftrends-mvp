import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/feed_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/closet_provider.dart';
import '../../../providers/competition_provider.dart';

class FeedTab extends StatelessWidget {
  final FeedProvider feedProvider;
  final AuthProvider authProvider;
  final ClosetProvider closetProvider;
  final CompetitionProvider competitionProvider;

  const FeedTab({
    super.key,
    required this.feedProvider,
    required this.authProvider,
    required this.closetProvider,
    required this.competitionProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search posts by caption, hashtag, or username',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: feedProvider.setSearchQuery,
          ),
        ),
        Expanded(
          child: feedProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : feedProvider.posts.isEmpty
                  ? const Center(child: Text('No posts yet. Be the first to share!'))
                  : ListView.builder(
                      itemCount: feedProvider.posts.length,
                      itemBuilder: (context, index) {
                        final post = feedProvider.posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: post['userAvatarUrl'] != null
                                      ? NetworkImage(post['userAvatarUrl'])
                                      : null,
                                ),
                                title: Text(post['username'] ?? ''),
                                subtitle: Text(post['createdAt']?.toString() ?? ''),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(post['caption'] ?? ''),
                              ),
                              const SizedBox(height: 8),
                              if (post['imageData'] != null && post['imageData'].isNotEmpty)
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.memory(
                                    base64Decode(post['imageData']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        post['likedByMe'] == true
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: post['likedByMe'] == true ? Colors.red : null,
                                      ),
                                      onPressed: () =>
                                          feedProvider.toggleLike(post['id'], authProvider.profile?['userId']),
                                    ),
                                    Text('${post['likes'] ?? 0} likes'),
                                  ],
                                ),
                              ),
                              if (post['hashtags'] != null && (post['hashtags'] as List).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Wrap(
                                    spacing: 8,
                                    children: (post['hashtags'] as List)
                                        .map((tag) => Text(
                                              '#$tag',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
