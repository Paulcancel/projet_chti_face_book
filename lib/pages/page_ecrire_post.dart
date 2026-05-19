import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';

class PageEcrirePost extends StatefulWidget {
  const PageEcrirePost({
    super.key,
    required this.membreConnecte,
    required this.firestoreService,
    required this.storageService,
    required this.onPublication,
  });

  final Membre membreConnecte;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;
  final VoidCallback onPublication;

  @override
  State<PageEcrirePost> createState() => _PageEcrirePostState();
}

class _PageEcrirePostState extends State<PageEcrirePost> {
  final _postController = TextEditingController();
  String? _nomImageSelectionnee;
  String? _imageUrl;
  bool _chargementImage = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _choisirImage() async {
    final image = await widget.storageService.choisirImageDepuisGalerie();
    if (image == null) {
      return;
    }
    setState(() {
      _chargementImage = true;
      _nomImageSelectionnee = image.name;
    });

    final imageUrl = await widget.storageService.addImage(
      image: image,
      dossier: 'posts/${widget.membreConnecte.id}',
      nomFichier: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _imageUrl = imageUrl;
      _chargementImage = false;
    });
  }

  void _publier() {
    widget.firestoreService.addPost(
      auteurId: widget.membreConnecte.id,
      contenu: _postController.text,
      imageUrl: _imageUrl,
    );
    _postController.clear();
    setState(() {
      _nomImageSelectionnee = null;
      _imageUrl = null;
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post publié.')));
    widget.onPublication();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          'Quoi de neuf, ${widget.membreConnecte.prenom} ?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _postController,
          minLines: 8,
          maxLines: 12,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            labelText: 'Votre publication',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _chargementImage ? null : _choisirImage,
          icon:
              _chargementImage
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.image_outlined),
          label: Text(_nomImageSelectionnee ?? 'Ajouter une photo'),
        ),
        if (_nomImageSelectionnee != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            widget.storageService.firebaseDisponible
                ? 'Photo prête à publier.'
                : 'Photo sélectionnée. Configurez Firebase Storage pour la sauvegarder.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _publier,
          icon: const Icon(Icons.send),
          label: const Text('Publier'),
        ),
      ],
    );
  }
}
