import 'package:flutter/material.dart';

import '../modeles/commentaire.dart';
import '../modeles/donnees.dart';
import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import 'avatar.dart';

class WidgetPost extends StatefulWidget {
  const WidgetPost({
    super.key,
    required this.post,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
    this.onOpenComments,
    this.afficherBoutonCommentaire = true,
    this.imageGrandeParDefaut = false,
  });

  final Post post;
  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;
  final VoidCallback? onOpenComments;
  final bool afficherBoutonCommentaire;
  final bool imageGrandeParDefaut;

  @override
  State<WidgetPost> createState() => _WidgetPostState();
}

class _WidgetPostState extends State<WidgetPost> {
  late bool _imageAgrandie;

  @override
  void initState() {
    super.initState();
    _imageAgrandie = widget.imageGrandeParDefaut;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Membre?>(
      stream: widget.firestoreService.membreForId(widget.post.auteurId),
      builder: (context, auteurSnapshot) {
        return StreamBuilder<List<Commentaire>>(
          stream: widget.firestoreService.commentairesForPost(widget.post.id),
          builder: (context, commentairesSnapshot) {
            return _buildPost(
              context,
              auteurSnapshot.data,
              commentairesSnapshot.data?.length ??
                  widget.firestoreService.nombreCommentaires(widget.post.id),
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
    final aime = widget.post.estAimePar(widget.membreConnecte.id);
    final imageUrl = widget.post.imageUrl;
    final peutOuvrirCommentaires =
        widget.afficherBoutonCommentaire && widget.onOpenComments != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: peutOuvrirCommentaires ? widget.onOpenComments : null,
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
                      serviceStorage: widget.storageService,
                      rayon: 23,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          auteur?.nomComplet ?? Jargon.membreInconnu,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          DateHeure.relative(widget.post.dateCreation),
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
              Text(widget.post.contenu, style: theme.textTheme.bodyLarge),
              if (imageUrl != null && imageUrl.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap:
                      () => setState(() {
                        _imageAgrandie = !_imageAgrandie;
                      }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: double.infinity,
                      height:
                          _imageAgrandie
                              ? MediaQuery.sizeOf(context).height * 0.5
                              : 220,
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
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
                      widget.firestoreService.toggleLike(
                        postId: widget.post.id,
                        membreId: widget.membreConnecte.id,
                      );
                    },
                    icon: Icon(aime ? Icons.star_rounded : Icons.star_border),
                    label: Text('${widget.post.nombreLikes} ${Jargon.like}'),
                  ),
                  if (widget.afficherBoutonCommentaire)
                    OutlinedButton.icon(
                      onPressed: widget.onOpenComments,
                      icon: const Icon(Icons.mode_comment_outlined),
                      label: Text('$nombreCommentaires ${Jargon.commentaires}'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
