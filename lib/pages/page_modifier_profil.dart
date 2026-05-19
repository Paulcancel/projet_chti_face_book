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
  bool _chargementPhoto = false;

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
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final image = await widget.storageService.choisirImageDepuisGalerie();
    if (image == null) {
      return;
    }

    setState(() => _chargementPhoto = true);
    final photoUrl = await widget.storageService.addImage(
      image: image,
      dossier: 'membres/${widget.membre.id}',
      nomFichier: 'profil',
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _photoUrl = photoUrl ?? _photoUrl;
      _chargementPhoto = false;
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
          Center(
            child: WidgetImageProfil(
              membre: widget.membre.copyWith(photoUrl: _photoUrl),
              serviceStorage: widget.storageService,
              rayon: 48,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _chargementPhoto ? null : _choisirPhoto,
            icon:
                _chargementPhoto
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.photo_camera_outlined),
            label: const Text('Changer la photo'),
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
