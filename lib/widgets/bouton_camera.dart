import 'package:flutter/material.dart';

class BoutonCamera extends StatelessWidget {
  const BoutonCamera({
    super.key,
    required this.onPressed,
    required this.label,
    this.chargement = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool chargement;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: chargement ? null : onPressed,
      icon:
          chargement
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.image_outlined),
      label: Text(label),
    );
  }
}
