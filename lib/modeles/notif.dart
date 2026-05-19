class NotificationMembre {
  const NotificationMembre({
    required this.id,
    required this.destinataireId,
    required this.auteurId,
    required this.message,
    required this.type,
    required this.dateCreation,
    this.postId,
    this.lue = false,
  });

  final String id;
  final String destinataireId;
  final String auteurId;
  final String message;
  final String type;
  final DateTime dateCreation;
  final String? postId;
  final bool lue;

  NotificationMembre copyWith({bool? lue}) {
    return NotificationMembre(
      id: id,
      destinataireId: destinataireId,
      auteurId: auteurId,
      message: message,
      type: type,
      dateCreation: dateCreation,
      postId: postId,
      lue: lue ?? this.lue,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'destinataireId': destinataireId,
      'auteurId': auteurId,
      'message': message,
      'type': type,
      'dateCreation': dateCreation.toIso8601String(),
      'postId': postId,
      'lue': lue,
    };
  }

  factory NotificationMembre.fromMap(Map<String, Object?> map) {
    return NotificationMembre(
      id: map['id'] as String? ?? '',
      destinataireId: map['destinataireId'] as String? ?? '',
      auteurId: map['auteurId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'notification',
      dateCreation: _dateDepuisMap(map['dateCreation']),
      postId: map['postId'] as String?,
      lue: map['lue'] as bool? ?? false,
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
