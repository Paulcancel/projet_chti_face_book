import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/page_application.dart';
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
