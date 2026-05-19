import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

import '../modeles/membre.dart';
import '../modeles/post.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/liste_commentaire.dart';
import '../widgets/widget_post.dart';

class PageDetailPost extends StatefulWidget {
  const PageDetailPost({
    super.key,
    required this.post,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
  });

  final Post post;
  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  State<PageDetailPost> createState() => _PageDetailPostState();
}

class _PageDetailPostState extends State<PageDetailPost> {
  final _commentaireController = TextEditingController();

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  void _envoyerCommentaire() {
    widget.firestoreService.addCommentaire(
      postId: widget.post.id,
      auteurId: widget.membreConnecte.id,
      contenu: _commentaireController.text,
    );
    _commentaireController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Jargon.commentaires)),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        children: <Widget>[
          StreamBuilder<Post?>(
            stream: widget.firestoreService.postForId(widget.post.id),
            builder: (context, snapshot) {
              final post = snapshot.data ?? widget.post;
              return WidgetPost(
                post: post,
                membreConnecte: widget.membreConnecte,
                firestoreService: widget.firestoreService,
                storageService: widget.storageService,
                afficherBoutonCommentaire: false,
                imageGrandeParDefaut: true,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              Jargon.commentaires,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          WidgetListeCommentaire(
            postId: widget.post.id,
            firestoreService: widget.firestoreService,
            storageService: widget.storageService,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _commentaireController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Écrire eun caqu'rie",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: Jargon.envoyer,
                onPressed: _envoyerCommentaire,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
