import 'package:flutter/material.dart';

class StyleChampTexte {
  const StyleChampTexte._();

  static InputDecoration decoration({
    required String label,
    IconData? icone,
    String? aide,
    bool alignerLabel = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: aide,
      alignLabelWithHint: alignerLabel,
      prefixIcon: icone == null ? null : Icon(icone),
      border: const OutlineInputBorder(),
    );
  }
}
