class Commentaire {
  const Commentaire({
    required this.id,
    required this.postId,
    required this.auteurId,
    required this.contenu,
    required this.dateCreation,
  });

  final String id;
  final String postId;
  final String auteurId;
  final String contenu;
  final DateTime dateCreation;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'postId': postId,
      'auteurId': auteurId,
      'contenu': contenu,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  factory Commentaire.fromMap(Map<String, Object?> map) {
    return Commentaire(
      id: map['id'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      auteurId: map['auteurId'] as String? ?? '',
      contenu: map['contenu'] as String? ?? '',
      dateCreation: _dateDepuisMap(map['dateCreation']),
    );
  }

  static DateTime _dateDepuisMap(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}
