import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../modeles/commentaire.dart';
import '../modeles/constantes.dart';
import '../modeles/membre.dart';
import '../modeles/notification_membre.dart';
import '../modeles/post.dart';

class ServiceFirestore {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseFirestore.instance;
  }

  final List<Membre> _membres = <Membre>[];
  final List<Post> _posts = <Post>[];
  final List<Commentaire> _commentaires = <Commentaire>[];
  final List<NotificationMembre> _notifications = <NotificationMembre>[];

  Stream<List<Membre>> get membres {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<List<Membre>>.value(_membresTries());
    }

    return firestore
        .collection(Constantes.membres)
        .orderBy(Constantes.nom)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_membreDepuisDoc).toList());
  }

  Stream<List<Post>> get posts {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<List<Post>>.value(_postsTries());
    }

    return firestore
        .collection(Constantes.posts)
        .orderBy(Constantes.dateCreation, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_postDepuisDoc).toList());
  }

  Stream<List<Post>> postsForMember(String membreId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<List<Post>>.value(_postsDuMembre(membreId));
    }

    return firestore
        .collection(Constantes.posts)
        .where(Constantes.auteurId, isEqualTo: membreId)
        .snapshots()
        .map((snapshot) => _trierPosts(snapshot.docs.map(_postDepuisDoc)));
  }

  Stream<Post?> postForId(String postId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<Post?>.value(post(postId));
    }

    return firestore
        .collection(Constantes.posts)
        .doc(postId)
        .snapshots()
        .map((doc) => doc.exists ? _postDepuisDoc(doc) : null);
  }

  Stream<Membre?> membreForId(String membreId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<Membre?>.value(membre(membreId));
    }

    return firestore
        .collection(Constantes.membres)
        .doc(membreId)
        .snapshots()
        .map((doc) => doc.exists ? _membreDepuisDoc(doc) : null);
  }

  Stream<List<Commentaire>> commentairesForPost(String postId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<List<Commentaire>>.value(_commentairesDuPost(postId));
    }

    return firestore
        .collection(Constantes.commentaires)
        .where(Constantes.postId, isEqualTo: postId)
        .snapshots()
        .map(
          (snapshot) =>
              _trierCommentaires(snapshot.docs.map(_commentaireDepuisDoc)),
        );
  }

  Stream<List<NotificationMembre>> notificationsForUser(String membreId) {
    final firestore = _firestore;
    if (firestore == null) {
      return Stream<List<NotificationMembre>>.value(
        _notificationsDuMembre(membreId),
      );
    }

    return firestore
        .collection(Constantes.notifications)
        .where(Constantes.destinataireId, isEqualTo: membreId)
        .snapshots()
        .map(
          (snapshot) =>
              _trierNotifications(snapshot.docs.map(_notificationDepuisDoc)),
        );
  }

  Membre? membre(String membreId) {
    for (final membre in _membres) {
      if (membre.id == membreId) {
        return membre;
      }
    }
    return null;
  }

  Membre? membreParEmail(String email) {
    final emailNettoye = email.trim().toLowerCase();
    for (final membre in _membres) {
      if (membre.email.toLowerCase() == emailNettoye) {
        return membre;
      }
    }
    return null;
  }

  Future<Membre?> membreParEmailFirebase(String email) async {
    final firestore = _firestore;
    if (firestore == null) {
      return membreParEmail(email);
    }

    final snapshot =
        await firestore
            .collection(Constantes.membres)
            .where(Constantes.email, isEqualTo: email.trim().toLowerCase())
            .limit(1)
            .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return _membreDepuisDoc(snapshot.docs.first);
  }

  Future<Membre?> membreFirebase(String membreId) async {
    final firestore = _firestore;
    if (firestore == null) {
      return membre(membreId);
    }

    final doc =
        await firestore.collection(Constantes.membres).doc(membreId).get();
    return doc.exists ? _membreDepuisDoc(doc) : null;
  }

  Post? post(String postId) {
    for (final post in _posts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  int nombreCommentaires(String postId) {
    return _commentaires
        .where((commentaire) => commentaire.postId == postId)
        .length;
  }

  Future<int> nombreCommentairesFirebase(String postId) async {
    final firestore = _firestore;
    if (firestore == null) {
      return nombreCommentaires(postId);
    }

    final snapshot =
        await firestore
            .collection(Constantes.commentaires)
            .where(Constantes.postId, isEqualTo: postId)
            .count()
            .get();
    return snapshot.count ?? 0;
  }

  void addMember(Membre membre) {
    final firestore = _firestore;
    if (firestore == null) {
      _membres.add(membre);
      return;
    }

    unawaited(
      firestore
          .collection(Constantes.membres)
          .doc(membre.id)
          .set(membre.toMap()),
    );
  }

  void updateMember(Membre membre) {
    final firestore = _firestore;
    if (firestore == null) {
      final index = _membres.indexWhere((element) => element.id == membre.id);
      if (index == -1) {
        return;
      }
      _membres[index] = membre;
      return;
    }

    unawaited(
      firestore
          .collection(Constantes.membres)
          .doc(membre.id)
          .set(membre.toMap(), SetOptions(merge: true)),
    );
  }

  void addPost({
    required String auteurId,
    required String contenu,
    String? imageUrl,
  }) {
    final texte = contenu.trim();
    if (texte.isEmpty && imageUrl == null) {
      return;
    }

    final firestore = _firestore;
    final post = Post(
      id: _nouvelId('post'),
      auteurId: auteurId,
      contenu: texte,
      dateCreation: DateTime.now(),
      imageUrl: imageUrl,
    );

    if (firestore == null) {
      _posts.add(post);
      _notifierNouveauPostLocal(auteurId);
      return;
    }

    unawaited(_addPostFirebase(firestore, post));
  }

  void toggleLike({required String postId, required String membreId}) {
    final firestore = _firestore;
    if (firestore != null) {
      unawaited(_toggleLikeFirebase(firestore, postId, membreId));
      return;
    }

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return;
    }

    final post = _posts[index];
    final likes = <String>{...post.likes};
    final dejaAime = likes.contains(membreId);
    dejaAime ? likes.remove(membreId) : likes.add(membreId);

    _posts[index] = post.copyWith(likes: likes);

    if (!dejaAime && post.auteurId != membreId) {
      final auteur = membre(membreId);
      if (auteur != null) {
        _ajouterNotification(
          destinataireId: post.auteurId,
          auteurId: membreId,
          type: 'like',
          message: '${auteur.nomComplet} aime votre post.',
        );
      }
    }
  }

  void addCommentaire({
    required String postId,
    required String auteurId,
    required String contenu,
  }) {
    final texte = contenu.trim();
    if (texte.isEmpty) {
      return;
    }

    final firestore = _firestore;
    if (firestore != null) {
      unawaited(_addCommentaireFirebase(firestore, postId, auteurId, texte));
      return;
    }

    final postCible = post(postId);
    if (postCible == null) {
      return;
    }

    final commentaire = Commentaire(
      id: _nouvelId('commentaire'),
      postId: postId,
      auteurId: auteurId,
      contenu: texte,
      dateCreation: DateTime.now(),
    );
    _commentaires.add(commentaire);

    if (postCible.auteurId != auteurId) {
      final auteur = membre(auteurId);
      if (auteur != null) {
        _ajouterNotification(
          destinataireId: postCible.auteurId,
          auteurId: auteurId,
          type: 'commentaire',
          message: '${auteur.nomComplet} a commenté votre post.',
        );
      }
    }
  }

  void marquerNotificationsLues(String membreId) {
    final firestore = _firestore;
    if (firestore != null) {
      unawaited(_marquerNotificationsLuesFirebase(firestore, membreId));
      return;
    }

    for (var index = 0; index < _notifications.length; index++) {
      final notification = _notifications[index];
      if (notification.destinataireId == membreId) {
        _notifications[index] = notification.copyWith(lue: true);
      }
    }
  }

  Future<void> _addPostFirebase(FirebaseFirestore firestore, Post post) async {
    await firestore.collection(Constantes.posts).doc(post.id).set({
      ...post.toMap(),
      Constantes.dateCreation: FieldValue.serverTimestamp(),
    });

    final auteur = await membreFirebase(post.auteurId);
    if (auteur == null) {
      return;
    }

    final membresSnapshot =
        await firestore.collection(Constantes.membres).get();
    for (final doc in membresSnapshot.docs) {
      if (doc.id == post.auteurId) {
        continue;
      }
      await _ajouterNotificationFirebase(
        firestore,
        destinataireId: doc.id,
        auteurId: post.auteurId,
        type: 'post',
        message: '${auteur.nomComplet} a publié un nouveau post.',
      );
    }
  }

  Future<void> _toggleLikeFirebase(
    FirebaseFirestore firestore,
    String postId,
    String membreId,
  ) async {
    final reference = firestore.collection(Constantes.posts).doc(postId);
    final doc = await reference.get();
    if (!doc.exists) {
      return;
    }

    final post = _postDepuisDoc(doc);
    final dejaAime = post.likes.contains(membreId);
    await reference.update({
      Constantes.likes:
          dejaAime
              ? FieldValue.arrayRemove(<String>[membreId])
              : FieldValue.arrayUnion(<String>[membreId]),
    });

    if (!dejaAime && post.auteurId != membreId) {
      final auteur = await membreFirebase(membreId);
      if (auteur != null) {
        await _ajouterNotificationFirebase(
          firestore,
          destinataireId: post.auteurId,
          auteurId: membreId,
          type: 'like',
          message: '${auteur.nomComplet} aime votre post.',
        );
      }
    }
  }

  Future<void> _addCommentaireFirebase(
    FirebaseFirestore firestore,
    String postId,
    String auteurId,
    String contenu,
  ) async {
    final postDoc =
        await firestore.collection(Constantes.posts).doc(postId).get();
    if (!postDoc.exists) {
      return;
    }

    final commentaire = Commentaire(
      id: _nouvelId('commentaire'),
      postId: postId,
      auteurId: auteurId,
      contenu: contenu,
      dateCreation: DateTime.now(),
    );
    await firestore
        .collection(Constantes.commentaires)
        .doc(commentaire.id)
        .set({
          ...commentaire.toMap(),
          Constantes.dateCreation: FieldValue.serverTimestamp(),
        });

    final postCible = _postDepuisDoc(postDoc);
    if (postCible.auteurId != auteurId) {
      final auteur = await membreFirebase(auteurId);
      if (auteur != null) {
        await _ajouterNotificationFirebase(
          firestore,
          destinataireId: postCible.auteurId,
          auteurId: auteurId,
          type: 'commentaire',
          message: '${auteur.nomComplet} a commenté votre post.',
        );
      }
    }
  }

  Future<void> _marquerNotificationsLuesFirebase(
    FirebaseFirestore firestore,
    String membreId,
  ) async {
    final snapshot =
        await firestore
            .collection(Constantes.notifications)
            .where(Constantes.destinataireId, isEqualTo: membreId)
            .where(Constantes.lue, isEqualTo: false)
            .get();
    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {Constantes.lue: true});
    }
    await batch.commit();
  }

  Future<void> _ajouterNotificationFirebase(
    FirebaseFirestore firestore, {
    required String destinataireId,
    required String auteurId,
    required String type,
    required String message,
  }) {
    final reference = firestore.collection(Constantes.notifications).doc();
    return reference.set({
      Constantes.id: reference.id,
      Constantes.destinataireId: destinataireId,
      Constantes.auteurId: auteurId,
      Constantes.type: type,
      Constantes.message: message,
      Constantes.dateCreation: FieldValue.serverTimestamp(),
      Constantes.lue: false,
    });
  }

  Membre _membreDepuisDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Membre.fromMap({...?doc.data(), Constantes.id: doc.id});
  }

  Post _postDepuisDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Post.fromMap(
      _normaliserDates({...?doc.data(), Constantes.id: doc.id}),
    );
  }

  Commentaire _commentaireDepuisDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return Commentaire.fromMap(
      _normaliserDates({...?doc.data(), Constantes.id: doc.id}),
    );
  }

  NotificationMembre _notificationDepuisDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return NotificationMembre.fromMap(
      _normaliserDates({...?doc.data(), Constantes.id: doc.id}),
    );
  }

  Map<String, Object?> _normaliserDates(Map<String, Object?> map) {
    final date = map[Constantes.dateCreation];
    if (date is Timestamp) {
      map[Constantes.dateCreation] = date.toDate();
    }
    return map;
  }

  void _notifierNouveauPostLocal(String auteurId) {
    final auteur = membre(auteurId);
    if (auteur == null) {
      return;
    }
    for (final destinataire in _membres.where((m) => m.id != auteurId)) {
      _ajouterNotification(
        destinataireId: destinataire.id,
        auteurId: auteurId,
        type: 'post',
        message: '${auteur.nomComplet} a publié un nouveau post.',
      );
    }
  }

  void _ajouterNotification({
    required String destinataireId,
    required String auteurId,
    required String type,
    required String message,
  }) {
    _notifications.add(
      NotificationMembre(
        id: _nouvelId('notification'),
        destinataireId: destinataireId,
        auteurId: auteurId,
        type: type,
        message: message,
        dateCreation: DateTime.now(),
      ),
    );
  }

  List<Membre> _membresTries() {
    return List<Membre>.unmodifiable(
      <Membre>[..._membres]
        ..sort((a, b) => a.nomComplet.compareTo(b.nomComplet)),
    );
  }

  List<Post> _postsTries() {
    return _trierPosts(_posts);
  }

  List<Post> _postsDuMembre(String membreId) {
    return List<Post>.unmodifiable(
      _postsTries().where((post) => post.auteurId == membreId),
    );
  }

  List<Commentaire> _commentairesDuPost(String postId) {
    return _trierCommentaires(_commentaires.where((c) => c.postId == postId));
  }

  List<NotificationMembre> _notificationsDuMembre(String membreId) {
    return _trierNotifications(
      _notifications.where((notification) {
        return notification.destinataireId == membreId;
      }),
    );
  }

  List<Post> _trierPosts(Iterable<Post> posts) {
    return List<Post>.unmodifiable(
      <Post>[...posts]
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation)),
    );
  }

  List<Commentaire> _trierCommentaires(Iterable<Commentaire> commentaires) {
    return List<Commentaire>.unmodifiable(
      <Commentaire>[...commentaires]
        ..sort((a, b) => a.dateCreation.compareTo(b.dateCreation)),
    );
  }

  List<NotificationMembre> _trierNotifications(
    Iterable<NotificationMembre> notifications,
  ) {
    return List<NotificationMembre>.unmodifiable(
      <NotificationMembre>[...notifications]
        ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation)),
    );
  }

  String _nouvelId(String prefixe) {
    return '${prefixe}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
