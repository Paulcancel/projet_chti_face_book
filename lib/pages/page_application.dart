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
    const jauneFlandre = Color(0xFFFFCC00);
    const noirLion = Color(0xFF151515);
    const rougeGriffe = Color(0xFFD71920);
    final couleurs = ColorScheme.fromSeed(
      seedColor: jauneFlandre,
      brightness: Brightness.light,
    ).copyWith(
      primary: noirLion,
      onPrimary: jauneFlandre,
      primaryContainer: jauneFlandre,
      onPrimaryContainer: noirLion,
      secondary: rougeGriffe,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFD9D8),
      onSecondaryContainer: const Color(0xFF410004),
      tertiary: jauneFlandre,
      onTertiary: noirLion,
      surface: const Color(0xFFFFFBF0),
      surfaceContainerHighest: const Color(0xFFF4E7C3),
      outlineVariant: const Color(0xFFD6C48A),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Jargon.app,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: couleurs,
        scaffoldBackgroundColor: couleurs.surface,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: jauneFlandre,
          foregroundColor: noirLion,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: couleurs.surface,
          indicatorColor: jauneFlandre,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: noirLion,
            foregroundColor: jauneFlandre,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: rougeGriffe,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: rougeGriffe, width: 2),
          ),
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
