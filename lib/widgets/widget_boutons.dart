import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

class WidgetBoutons extends StatelessWidget {
  const WidgetBoutons({
    super.key,
    required this.aime,
    required this.nombreLikes,
    required this.onLike,
    this.nombreCommentaires,
    this.onCommentaires,
  });

  final bool aime;
  final int nombreLikes;
  final VoidCallback onLike;
  final int? nombreCommentaires;
  final VoidCallback? onCommentaires;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: onLike,
          icon: Icon(aime ? Icons.star_rounded : Icons.star_border),
          label: Text('$nombreLikes ${Jargon.like}'),
        ),
        if (nombreCommentaires != null)
          OutlinedButton.icon(
            onPressed: onCommentaires,
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text('$nombreCommentaires ${Jargon.commentaires}'),
          ),
      ],
    );
  }
}
