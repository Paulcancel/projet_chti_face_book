import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/widget_vide.dart';
import '../widgets/widget_post.dart';
import 'page_detail_post.dart';

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
        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: <Widget>[
            const _LogoAccueil(),
            if (posts.isEmpty)
              const SizedBox(
                height: 260,
                child: EmptyBody(
                  icon: Icons.article_outlined,
                  message: Jargon.aucunPost,
                ),
              )
            else
              ...posts.map((post) {
                return WidgetPost(
                  post: post,
                  membreConnecte: membreConnecte,
                  firestoreService: firestoreService,
                  storageService: storageService,
                  onOpenComments: () => _ouvrirCommentaires(context, post),
                );
              }),
          ],
        );
      },
    );
  }

  void _ouvrirCommentaires(BuildContext context, Post post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PageDetailPost(
              post: post,
              membreConnecte: membreConnecte,
              firestoreService: firestoreService,
              storageService: storageService,
            ),
      ),
    );
  }
}

class _LogoAccueil extends StatelessWidget {
  const _LogoAccueil();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'resources/logo.png',
            width: 96,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
