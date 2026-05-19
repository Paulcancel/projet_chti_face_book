import 'package:flutter/material.dart';

import '../modeles/donnees.dart';
import '../modeles/membre.dart';
import '../services_firebase/service_storage.dart';
import 'avatar.dart';

class EnteteMembre extends StatelessWidget {
  const EnteteMembre({
    super.key,
    required this.membre,
    required this.date,
    required this.serviceStorage,
  });

  final Membre membre;
  final DateTime date;
  final ServiceStorage serviceStorage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        WidgetImageProfil(
          membre: membre,
          serviceStorage: serviceStorage,
          rayon: 23,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                membre.nomComplet,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                DateHeure.relative(date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
