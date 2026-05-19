import 'package:flutter/material.dart';

import '../modeles/post.dart';

class ContenuPost extends StatelessWidget {
  const ContenuPost({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(post.contenu, style: Theme.of(context).textTheme.bodyLarge),
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              post.imageUrl!,
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.5,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }
}
