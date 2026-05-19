class Post {
  const Post({
    required this.id,
    required this.auteurId,
    required this.contenu,
    required this.dateCreation,
    this.imageUrl,
    this.likes = const <String>{},
  });

  final String id;
  final String auteurId;
  final String contenu;
  final DateTime dateCreation;
  final String? imageUrl;
  final Set<String> likes;

  int get nombreLikes => likes.length;

  bool estAimePar(String membreId) => likes.contains(membreId);

  Post copyWith({
    String? id,
    String? auteurId,
    String? contenu,
    DateTime? dateCreation,
    String? imageUrl,
    Set<String>? likes,
  }) {
    return Post(
      id: id ?? this.id,
      auteurId: auteurId ?? this.auteurId,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'auteurId': auteurId,
      'contenu': contenu,
      'dateCreation': dateCreation.toIso8601String(),
      'imageUrl': imageUrl,
      'likes': likes.toList(),
    };
  }

  factory Post.fromMap(Map<String, Object?> map) {
    return Post(
      id: map['id'] as String? ?? '',
      auteurId: map['auteurId'] as String? ?? '',
      contenu: map['contenu'] as String? ?? '',
      dateCreation: _dateDepuisMap(map['dateCreation']),
      imageUrl: map['imageUrl'] as String?,
      likes: Set<String>.from((map['likes'] as List<Object?>?) ?? const []),
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
