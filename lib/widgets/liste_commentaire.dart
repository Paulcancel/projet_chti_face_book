import 'package:flutter/material.dart';

import '../modeles/commentaire.dart';
import '../modeles/donnees.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import 'widget_vide.dart';
import 'avatar.dart';

class WidgetListeCommentaire extends StatelessWidget {
  const WidgetListeCommentaire({
    super.key,
    required this.postId,
    required this.firestoreService,
    required this.storageService,
  });

  final String postId;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Commentaire>>(
      stream: firestoreService.commentairesForPost(postId),
      builder: (context, snapshot) {
        final commentaires = snapshot.data ?? const <Commentaire>[];
        if (commentaires.isEmpty) {
          return const SizedBox(
            height: 220,
            child: EmptyBody(
              icon: Icons.mode_comment_outlined,
              message: Jargon.aucunCommentaire,
            ),
          );
        }

        return Column(
          children:
              commentaires.map((commentaire) {
                return _CommentaireItem(
                  commentaire: commentaire,
                  firestoreService: firestoreService,
                  storageService: storageService,
                );
              }).toList(),
        );
      },
    );
  }
}

class _CommentaireItem extends StatelessWidget {
  const _CommentaireItem({
    required this.commentaire,
    required this.firestoreService,
    required this.storageService,
  });

  final Commentaire commentaire;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Membre?>(
      stream: firestoreService.membreForId(commentaire.auteurId),
      builder: (context, snapshot) {
        final auteur = snapshot.data;
        return ListTile(
          leading:
              auteur == null
                  ? const CircleAvatar(child: Icon(Icons.person_outline))
                  : WidgetImageProfil(
                    membre: auteur,
                    serviceStorage: storageService,
                    rayon: 22,
                  ),
          title: Text(auteur?.nomComplet ?? Jargon.membreInconnu),
          subtitle: Text(commentaire.contenu),
          trailing: Text(
            DateHeure.relative(commentaire.dateCreation),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      },
    );
  }
}
