import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/widget_vide.dart';
import '../widgets/avatar.dart';
import '../widgets/widget_post.dart';
import 'page_detail_post.dart';
import 'page_modifier_profil.dart';

class PageProfil extends StatelessWidget {
  const PageProfil({
    super.key,
    required this.membreId,
    required this.membreConnecte,
    required this.authentificationService,
    required this.firestoreService,
    required this.storageService,
    this.afficherAppBar = false,
  });

  final String membreId;
  final Membre membreConnecte;
  final ServiceAuthentification authentificationService;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;
  final bool afficherAppBar;

  @override
  Widget build(BuildContext context) {
    final contenu = StreamBuilder<Membre?>(
      stream: firestoreService.membreForId(membreId),
      builder: (context, snapshot) {
        final membre = snapshot.data;
        if (membre == null) {
          return const EmptyBody(
            icon: Icons.person_off_outlined,
            message: 'Membre introuvable.',
          );
        }
        return _ContenuProfil(
          membre: membre,
          membreConnecte: membreConnecte,
          authentificationService: authentificationService,
          firestoreService: firestoreService,
          storageService: storageService,
        );
      },
    );

    if (!afficherAppBar) {
      return contenu;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(Jargon.profil)),
      body: contenu,
    );
  }
}

class _ContenuProfil extends StatelessWidget {
  const _ContenuProfil({
    required this.membre,
    required this.membreConnecte,
    required this.authentificationService,
    required this.firestoreService,
    required this.storageService,
  });

  final Membre membre;
  final Membre membreConnecte;
  final ServiceAuthentification authentificationService;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  bool get _estMonProfil => membre.id == membreConnecte.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        _CouvertureProfil(membre: membre),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  WidgetImageProfil(
                    membre: membre,
                    serviceStorage: storageService,
                    rayon: 42,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          membre.nomComplet,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          membre.profession,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_estMonProfil)
                    IconButton.filledTonal(
                      tooltip: 'Modifier le profil',
                      onPressed: () => _ouvrirEdition(context),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(membre.bio, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
          child: Text(
            _estMonProfil ? "Mes racontaches" : "Racontaches",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        StreamBuilder<List<Post>>(
          stream: firestoreService.postsForMember(membre.id),
          builder: (context, snapshot) {
            final posts = snapshot.data ?? const <Post>[];
            if (posts.isEmpty) {
              return const SizedBox(
                height: 220,
                child: EmptyBody(
                  icon: Icons.article_outlined,
                  message: Jargon.aucunPost,
                ),
              );
            }
            return Column(
              children:
                  posts.map((post) {
                    return WidgetPost(
                      post: post,
                      membreConnecte: membreConnecte,
                      firestoreService: firestoreService,
                      storageService: storageService,
                      onOpenComments: () => _ouvrirCommentaires(context, post),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _ouvrirEdition(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PageModifierProfil(
              membre: membre,
              authentificationService: authentificationService,
              firestoreService: firestoreService,
              storageService: storageService,
            ),
      ),
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

class _CouvertureProfil extends StatelessWidget {
  const _CouvertureProfil({required this.membre});

  final Membre membre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couvertureUrl = membre.couvertureUrl;

    return SizedBox(
      height: 150,
      width: double.infinity,
      child:
          couvertureUrl == null || couvertureUrl.isEmpty
              ? DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                child: Icon(
                  Icons.landscape_outlined,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
              : Image.network(couvertureUrl, fit: BoxFit.cover),
    );
  }
}
