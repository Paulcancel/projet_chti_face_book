import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import 'page_accueil.dart';
import 'page_ecrire_post.dart';
import 'page_liste_membres.dart';
import 'page_notif.dart';
import 'page_profil.dart';

class PageNavigation extends StatefulWidget {
  const PageNavigation({
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
  State<PageNavigation> createState() => _PageNavigationState();
}

class _PageNavigationState extends State<PageNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      PageAccueil(
        membreConnecte: widget.membreConnecte,
        firestoreService: widget.firestoreService,
        storageService: widget.storageService,
      ),
      PageEcrirePost(
        membreConnecte: widget.membreConnecte,
        firestoreService: widget.firestoreService,
        storageService: widget.storageService,
        onPublication: () => setState(() => _index = 0),
      ),
      PageProfil(
        membreId: widget.membreConnecte.id,
        membreConnecte: widget.membreConnecte,
        authentificationService: widget.authentificationService,
        firestoreService: widget.firestoreService,
        storageService: widget.storageService,
      ),
      PageListeMembres(
        membreConnecte: widget.membreConnecte,
        authentificationService: widget.authentificationService,
        firestoreService: widget.firestoreService,
        storageService: widget.storageService,
      ),
      PageNotif(
        membreConnecte: widget.membreConnecte,
        firestoreService: widget.firestoreService,
      ),
    ];

    final titres = <String>[
      'Accueil',
      'Publier',
      'Profil',
      'Membres',
      'Notifications',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titres[_index]),
        actions: <Widget>[
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: widget.authentificationService.deconnecter,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Publier',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Membres',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifs',
          ),
        ],
      ),
    );
  }
}
