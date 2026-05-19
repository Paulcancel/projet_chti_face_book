import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/empty_body.dart';
import '../widgets/widget_post.dart';
import 'page_commentaires.dart';

class PageAccueil extends StatelessWidget {
  const PageAccueil({
    super.key,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
  });

  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: firestoreService.posts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const <Post>[];
        if (posts.isEmpty) {
          return const EmptyBody(
            icon: Icons.article_outlined,
            message: 'Aucun post pour le moment.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return WidgetPost(
              post: post,
              membreConnecte: membreConnecte,
              firestoreService: firestoreService,
              storageService: storageService,
              onOpenComments: () => _ouvrirCommentaires(context, post),
            );
          },
        );
      },
    );
  }

  void _ouvrirCommentaires(BuildContext context, Post post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PageCommentaires(
              post: post,
              membreConnecte: membreConnecte,
              firestoreService: firestoreService,
              storageService: storageService,
            ),
      ),
    );
  }
}
