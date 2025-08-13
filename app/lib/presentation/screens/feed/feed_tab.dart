import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/feed_post.dart';
import '../../../models/closet_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/closet_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/competition_provider.dart';
import '../../../shared/constants.dart';
import '../create_post_screen.dart';
import '../post_detail_screen.dart';
import '../../widgets/post_card.dart';

class FeedTab extends StatefulWidget {
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
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  @override
  void initState() {
    super.initState();
    widget.feedProvider.addListener(_onFeedChanged);
  }

  @override
  void dispose() {
    widget.feedProvider.removeListener(_onFeedChanged);
    super.dispose();
  }

  void _onFeedChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final feedProvider = widget.feedProvider;
    final authProvider = widget.authProvider;
    final closetProvider = widget.closetProvider;
    final competitionProvider = widget.competitionProvider;
    final currentUser = authProvider.profile!;

    return Scaffold(
      body: Column(
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
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : feedProvider.posts.isEmpty
                    ? const Center(child: Text('No posts yet. Be the first to share!'))
                    : ListView.builder(
                        itemCount: feedProvider.posts.length,
                        itemBuilder: (context, index) {
                          final post = feedProvider.posts[index];
                          return PostCard(
                            post: post,
                            currentUser: currentUser,
                            competitionProvider: competitionProvider,
                            onLikeToggle: (postId) => feedProvider.toggleLike(postId),
                            onDelete: (postId) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Post?'),
                                  content: const Text('Are you sure you want to delete this post?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await feedProvider.deletePost(postId);
                              }
                            },
                            onViewDetails: (post) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(
                                    post: post,
                                    currentUser: currentUser,
                                    onLikeToggle: (postId) => feedProvider.toggleLike(postId),
                                    onDelete: (postId) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Post?'),
                                          content: const Text('Are you sure you want to delete this post?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await feedProvider.deletePost(postId);
                                        if (mounted) Navigator.pop(context); // Pop detail screen
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newPost = await Navigator.of(context).push<FeedPost>(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                currentUser: currentUser,
                closetItems: closetProvider.items,
              ),
            ),
          );
          if (newPost != null) {
            await feedProvider.addPost(newPost);
          }
        },
      ),
    );
  }
}
