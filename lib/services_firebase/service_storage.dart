import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../modeles/membre.dart';

class ServiceStorage {
  const ServiceStorage();

  Color couleurProfil(Membre membre) => Color(membre.couleurAvatar);

  String texteProfil(Membre membre) => membre.initiales;

  bool get firebaseDisponible => Firebase.apps.isNotEmpty;

  Future<XFile?> choisirImageDepuisGalerie() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
  }

  Future<String?> addImage({
    required XFile image,
    required String dossier,
    required String nomFichier,
  }) async {
    if (!firebaseDisponible) {
      return null;
    }

    final reference = FirebaseStorage.instance.ref('$dossier/$nomFichier.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await reference.putData(await image.readAsBytes(), metadata);

    return reference.getDownloadURL();
  }
}
