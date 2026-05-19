import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import '../widgets/empty_body.dart';
import '../widgets/widget_image_profil.dart';
import 'page_profil.dart';

class PageListeMembres extends StatelessWidget {
  const PageListeMembres({
    super.key,
    required this.membreConnecte,
    required this.authentificationService,
    required this.firestoreService,
    required this.storageService,
  });

  final Membre membreConnecte;
  final ServiceAuthentification authentificationService;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Membre>>(
      stream: firestoreService.membres,
      builder: (context, snapshot) {
        final membres = snapshot.data ?? const <Membre>[];
        if (membres.isEmpty) {
          return const EmptyBody(
            icon: Icons.groups_outlined,
            message: 'Aucun membre inscrit.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: membres.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final membre = membres[index];
            return ListTile(
              leading: WidgetImageProfil(
                membre: membre,
                serviceStorage: storageService,
                rayon: 24,
              ),
              title: Text(membre.nomComplet),
              subtitle: Text(membre.profession),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _ouvrirProfil(context, membre),
            );
          },
        );
      },
    );
  }

  void _ouvrirProfil(BuildContext context, Membre membre) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PageProfil(
              membreId: membre.id,
              membreConnecte: membreConnecte,
              authentificationService: authentificationService,
              firestoreService: firestoreService,
              storageService: storageService,
              afficherAppBar: true,
            ),
      ),
    );
  }
}
