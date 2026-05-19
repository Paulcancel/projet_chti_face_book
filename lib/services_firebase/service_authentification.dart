import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../modeles/membre.dart';
import 'service_firestore.dart';

class ServiceAuthentification {
  ServiceAuthentification(this._firestoreService);

  final ServiceFirestore _firestoreService;
  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseAuth.instance;
  }

  Membre? _membreConnecte;

  Membre? get membreConnecte => _membreConnecte;

  Stream<Membre?> get authState {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges().asyncMap((user) async {
        if (user == null) {
          _membreConnecte = null;
          return null;
        }
        _membreConnecte = await _firestoreService.membreFirebase(user.uid);
        return _membreConnecte;
      });
    }

    return Stream<Membre?>.value(_membreConnecte);
  }

  Future<String?> connecter({
    required String email,
    required String motDePasse,
  }) async {
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: motDePasse,
        );
        return null;
      } on FirebaseAuthException catch (erreur) {
        return _messageAuth(erreur);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    final membre = _firestoreService.membreParEmail(email);
    if (membre == null || membre.motDePasse != motDePasse) {
      return "L'adresse e-mail ou l'mot d'passe, cha colle pas.";
    }
    _membreConnecte = membre;
    return null;
  }

  Future<String?> creerCompte({
    required String email,
    required String motDePasse,
    required String prenom,
    required String nom,
  }) async {
    final auth = _auth;
    if (auth != null) {
      if (motDePasse.length < 6) {
        return "Tin mot d'passe doit avoir au moins 6 caractères.";
      }
      try {
        final credentials = await auth.createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: motDePasse,
        );
        final user = credentials.user;
        if (user == null) {
          return "Pas moyen d'créer tin compte pour l'instant.";
        }

        final membre = Membre(
          id: user.uid,
          email: email.trim().toLowerCase(),
          motDePasse: '',
          prenom: prenom.trim().isEmpty ? 'Tiot' : prenom.trim(),
          nom: nom.trim().isEmpty ? 'Membre' : nom.trim(),
          profession: "Membre Cht'i Face Bouc",
          bio: 'Eul\' profil ié prêt.',
          couleurAvatar: 0xFF8A5A44,
        );
        _firestoreService.addMember(membre);
        _membreConnecte = membre;
        return null;
      } on FirebaseAuthException catch (erreur) {
        return _messageAuth(erreur);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (_firestoreService.membreParEmail(email) != null) {
      return "Y'a déjà quelqu'un avec c'te adresse.";
    }
    if (motDePasse.length < 4) {
      return "Tin mot d'passe doit avoir au moins 4 caractères.";
    }

    final membre = Membre(
      id: 'membre_${DateTime.now().microsecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      motDePasse: motDePasse,
      prenom: prenom.trim().isEmpty ? 'Tiot' : prenom.trim(),
      nom: nom.trim().isEmpty ? 'Membre' : nom.trim(),
      profession: "Membre Cht'i Face Bouc",
      bio: 'Eul\' profil ié prêt.',
      couleurAvatar: 0xFF8A5A44,
    );
    _firestoreService.addMember(membre);
    _membreConnecte = membre;
    return null;
  }

  Future<void> rafraichirMembreConnecte() async {
    final id = _membreConnecte?.id;
    if (id == null) {
      return;
    }
    _membreConnecte = await _firestoreService.membreFirebase(id);
  }

  Future<void> deconnecter() async {
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
      return;
    }
    _membreConnecte = null;
  }

  String _messageAuth(FirebaseAuthException erreur) {
    return switch (erreur.code) {
      'email-already-in-use' => "Y'a déjà quelqu'un avec c'te adresse.",
      'invalid-email' => "L'adresse e-mail, cha va pas.",
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        "L'adresse e-mail ou l'mot d'passe, cha colle pas.",
      'weak-password' => "Tin mot d'passe est trop faiblard.",
      _ => "Pas moyen d'te connecter : ${erreur.message ?? erreur.code}.",
    };
  }
}
