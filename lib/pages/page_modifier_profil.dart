import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/avatar.dart';

class PageModifierProfil extends StatefulWidget {
  const PageModifierProfil({
    super.key,
    required this.membre,
    required this.authentificationService,
    required this.firestoreService,
    required this.storageService,
  });

  final Membre membre;
  final ServiceAuthentification authentificationService;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  State<PageModifierProfil> createState() => _PageModifierProfilState();
}

class _PageModifierProfilState extends State<PageModifierProfil> {
  late final TextEditingController _prenomController;
  late final TextEditingController _nomController;
  late final TextEditingController _professionController;
  late final TextEditingController _bioController;
  String? _photoUrl;
  String? _couvertureUrl;
  bool _chargementPhoto = false;
  bool _chargementCouverture = false;

  @override
  void initState() {
    super.initState();
    _prenomController = TextEditingController(text: widget.membre.prenom);
    _nomController = TextEditingController(text: widget.membre.nom);
    _professionController = TextEditingController(
      text: widget.membre.profession,
    );
    _bioController = TextEditingController(text: widget.membre.bio);
    _photoUrl = widget.membre.photoUrl;
    _couvertureUrl = widget.membre.couvertureUrl;
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _choisirImage({
    required bool couverture,
    required bool depuisCamera,
  }) async {
    final image =
        depuisCamera
            ? await widget.storageService.choisirImageDepuisCamera()
            : await widget.storageService.choisirImageDepuisGalerie();
    if (image == null) {
      return;
    }

    setState(() {
      if (couverture) {
        _chargementCouverture = true;
      } else {
        _chargementPhoto = true;
      }
    });

    final imageUrl = await widget.storageService.addImage(
      image: image,
      dossier: 'membres/${widget.membre.id}',
      nomFichier: couverture ? 'couverture' : 'profil',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (couverture) {
        _couvertureUrl = imageUrl ?? _couvertureUrl;
        _chargementCouverture = false;
      } else {
        _photoUrl = imageUrl ?? _photoUrl;
        _chargementPhoto = false;
      }
    });
  }

  void _enregistrer() {
    widget.firestoreService.updateMember(
      widget.membre.copyWith(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        profession: _professionController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: _photoUrl,
        couvertureUrl: _couvertureUrl,
      ),
    );
    widget.authentificationService.rafraichirMembreConnecte();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _ApercuCouverture(couvertureUrl: _couvertureUrl),
          const SizedBox(height: 12),
          _BoutonsImage(
            titre: 'Changer la couverture',
            chargement: _chargementCouverture,
            onGalerie:
                () => _choisirImage(couverture: true, depuisCamera: false),
            onCamera:
                () => _choisirImage(couverture: true, depuisCamera: true),
          ),
          const SizedBox(height: 20),
          Center(
            child: WidgetImageProfil(
              membre: widget.membre.copyWith(
                photoUrl: _photoUrl,
                couvertureUrl: _couvertureUrl,
              ),
              serviceStorage: widget.storageService,
              rayon: 48,
            ),
          ),
          const SizedBox(height: 12),
          _BoutonsImage(
            titre: 'Changer la photo de profil',
            chargement: _chargementPhoto,
            onGalerie:
                () => _choisirImage(couverture: false, depuisCamera: false),
            onCamera:
                () => _choisirImage(couverture: false, depuisCamera: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prenomController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _professionController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Profession',
              prefixIcon: Icon(Icons.work_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Bio',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _enregistrer,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _ApercuCouverture extends StatelessWidget {
  const _ApercuCouverture({required this.couvertureUrl});

  final String? couvertureUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child:
            couvertureUrl == null || couvertureUrl!.isEmpty
                ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    Icons.landscape_outlined,
                    size: 44,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
                : Image.network(couvertureUrl!, fit: BoxFit.cover),
      ),
    );
  }
}

class _BoutonsImage extends StatelessWidget {
  const _BoutonsImage({
    required this.titre,
    required this.chargement,
    required this.onGalerie,
    required this.onCamera,
  });

  final String titre;
  final bool chargement;
  final VoidCallback onGalerie;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(titre, style: Theme.of(context).textTheme.titleSmall),
        OutlinedButton.icon(
          onPressed: chargement ? null : onGalerie,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Galerie'),
        ),
        OutlinedButton.icon(
          onPressed: chargement ? null : onCamera,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Caméra'),
        ),
        if (chargement)
          const SizedBox(
            width: 32,
            height: 32,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
      ],
    );
  }
}
