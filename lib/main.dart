import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'modeles/membre.dart';
import 'pages/page_authentification.dart';
import 'pages/page_navigation.dart';
import 'services_firebase/service_authentification.dart';
import 'services_firebase/service_firestore.dart';
import 'services_firebase/service_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object {
    // Le projet reste utilisable en mode démo tant que FlutterFire n'est pas configuré.
  }

  final firestoreService = ServiceFirestore();
  final authentificationService = ServiceAuthentification(firestoreService);
  const storageService = ServiceStorage();

  runApp(
    ChtiFaceBoucApp(
      authentificationService: authentificationService,
      firestoreService: firestoreService,
      storageService: storageService,
    ),
  );
}

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
      title: "Cht'i Face Bouc",
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
