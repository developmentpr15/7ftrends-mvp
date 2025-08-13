import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/feed_post.dart';

class PostWidget extends StatelessWidget {
  final FeedPost post;
  final VoidCallback onLike;

  const PostWidget({
    Key? key,
    required this.post,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userAvatarUrl != null
                  ? NetworkImage(post.userAvatarUrl!)
                  : null,
              child: post.userAvatarUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post.username),
          ),
          Image.memory(
            const Base64Decoder().convert(post.imageData),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: post.likedByMe ? Colors.red : null,
                  ),
                  onPressed: onLike,
                ),
                Text('${post.likes} likes'),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(post.caption),
            ),
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4.0,
                children: post.hashtags
                    .map((tag) => Text(
                          '#$tag',
                          style: const TextStyle(color: Colors.blue),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
