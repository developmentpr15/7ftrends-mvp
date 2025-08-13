import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/feed_post.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/post_widget.dart';

class FeedPostScreen extends StatelessWidget {
  final FeedPost post;

  const FeedPostScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PostWidget(
              post: post,
              onLike: () {
                context.read<FeedProvider>().toggleLike(post.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
