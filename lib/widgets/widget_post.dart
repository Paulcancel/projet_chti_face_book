import 'package:flutter/material.dart';

import '../modeles/commentaire.dart';
import '../modeles/date_heure.dart';
import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import 'widget_image_profil.dart';

class WidgetPost extends StatelessWidget {
  const WidgetPost({
    super.key,
    required this.post,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
    this.onOpenComments,
    this.afficherBoutonCommentaire = true,
  });

  final Post post;
  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;
  final VoidCallback? onOpenComments;
  final bool afficherBoutonCommentaire;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Membre?>(
      stream: firestoreService.membreForId(post.auteurId),
      builder: (context, auteurSnapshot) {
        return StreamBuilder<List<Commentaire>>(
          stream: firestoreService.commentairesForPost(post.id),
          builder: (context, commentairesSnapshot) {
            return _buildPost(
              context,
              auteurSnapshot.data,
              commentairesSnapshot.data?.length ??
                  firestoreService.nombreCommentaires(post.id),
            );
          },
        );
      },
    );
  }

  Widget _buildPost(
    BuildContext context,
    Membre? auteur,
    int nombreCommentaires,
  ) {
    final theme = Theme.of(context);
    final aime = post.estAimePar(membreConnecte.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (auteur == null)
                  const CircleAvatar(child: Icon(Icons.person_outline))
                else
                  WidgetImageProfil(
                    membre: auteur,
                    serviceStorage: storageService,
                    rayon: 23,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        auteur?.nomComplet ?? 'Membre inconnu',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateHeure.relative(post.dateCreation),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(post.contenu, style: theme.textTheme.bodyLarge),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: () {
                    firestoreService.toggleLike(
                      postId: post.id,
                      membreId: membreConnecte.id,
                    );
                  },
                  icon: Icon(aime ? Icons.star_rounded : Icons.star_border),
                  label: Text('${post.nombreLikes}'),
                ),
                if (afficherBoutonCommentaire)
                  OutlinedButton.icon(
                    onPressed: onOpenComments,
                    icon: const Icon(Icons.mode_comment_outlined),
                    label: Text('$nombreCommentaires'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
