class Membre {
  const Membre({
    required this.id,
    required this.email,
    required this.motDePasse,
    required this.prenom,
    required this.nom,
    required this.profession,
    required this.bio,
    required this.couleurAvatar,
    this.photoUrl,
    this.couvertureUrl,
  });

  final String id;
  final String email;
  final String motDePasse;
  final String prenom;
  final String nom;
  final String profession;
  final String bio;
  final int couleurAvatar;
  final String? photoUrl;
  final String? couvertureUrl;

  String get nomComplet => '$prenom $nom';

  String get initiales {
    final premiere = prenom.isNotEmpty ? prenom[0] : '';
    final seconde = nom.isNotEmpty ? nom[0] : '';
    return '$premiere$seconde'.toUpperCase();
  }

  Membre copyWith({
    String? id,
    String? email,
    String? motDePasse,
    String? prenom,
    String? nom,
    String? profession,
    String? bio,
    int? couleurAvatar,
    String? photoUrl,
    String? couvertureUrl,
  }) {
    return Membre(
      id: id ?? this.id,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      profession: profession ?? this.profession,
      bio: bio ?? this.bio,
      couleurAvatar: couleurAvatar ?? this.couleurAvatar,
      photoUrl: photoUrl ?? this.photoUrl,
      couvertureUrl: couvertureUrl ?? this.couvertureUrl,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'motDePasse': motDePasse,
      'prenom': prenom,
      'nom': nom,
      'profession': profession,
      'bio': bio,
      'couleurAvatar': couleurAvatar,
      'photoUrl': photoUrl,
      'couvertureUrl': couvertureUrl,
    };
  }

  factory Membre.fromMap(Map<String, Object?> map) {
    return Membre(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      motDePasse: map['motDePasse'] as String? ?? '',
      prenom: map['prenom'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      couleurAvatar: map['couleurAvatar'] as int? ?? 0xFF2F7D6E,
      photoUrl: map['photoUrl'] as String?,
      couvertureUrl: map['couvertureUrl'] as String?,
    );
  }
}
