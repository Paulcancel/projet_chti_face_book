import 'package:flutter/material.dart';

import '../modeles/donnees.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_authentification.dart';
import '../services_firebase/service_firestore.dart';
import '../services_firebase/service_storage.dart';
import 'page_authentification.dart';
import 'page_navigation.dart';

class ChtiFaceBoucApp extends StatelessWidget {
  const ChtiFaceBoucApp({
    super.key,
    required this.authentificationService,
    required this.firestoreService,
    required this.storageService,
  });

  final ServiceAuthentification authentificationService;
  final ServiceFirestore firestoreService;
  final ServiceStorage storageService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Jargon.app,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F7D6E),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: StreamBuilder<Membre?>(
        stream: authentificationService.authState,
        builder: (context, snapshot) {
          final membre = snapshot.data;
          if (membre == null) {
            return PageAuthentification(
              authentificationService: authentificationService,
            );
          }

          return PageNavigation(
            membreConnecte: membre,
            authentificationService: authentificationService,
            firestoreService: firestoreService,
            storageService: storageService,
          );
        },
      ),
    );
  }
}
