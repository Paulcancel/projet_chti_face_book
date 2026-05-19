import 'package:flutter/material.dart';

import '../modeles/membre.dart';
import '../services_firebase/service_storage.dart';

class WidgetImageProfil extends StatelessWidget {
  const WidgetImageProfil({
    super.key,
    required this.membre,
    required this.serviceStorage,
    this.rayon = 28,
  });

  final Membre membre;
  final ServiceStorage serviceStorage;
  final double rayon;

  @override
  Widget build(BuildContext context) {
    final photoUrl = membre.photoUrl;
    return CircleAvatar(
      radius: rayon,
      backgroundColor: serviceStorage.couleurProfil(membre),
      backgroundImage:
          photoUrl == null || photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      child:
          photoUrl == null || photoUrl.isEmpty
              ? Text(
                serviceStorage.texteProfil(membre),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              )
              : null,
    );
  }
}
