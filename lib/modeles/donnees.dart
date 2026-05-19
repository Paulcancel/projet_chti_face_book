import 'package:intl/intl.dart';

class DateHeure {
  const DateHeure._();

  static String courte(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String relative(DateTime date) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(date);

    if (difference.inMinutes < 1) {
      return "À l'instant";
    }
    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    }
    if (_memeJour(maintenant, date)) {
      return "Aujourd'hui à ${DateFormat('HH:mm').format(date)}";
    }
    if (_memeJour(maintenant.subtract(const Duration(days: 1)), date)) {
      return 'Hier à ${DateFormat('HH:mm').format(date)}';
    }
    return courte(date);
  }

  static bool _memeJour(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class Jargon {
  const Jargon._();

  static const app = "Cht'i Face Bouc";
  static const accueil = "Eul' fil";
  static const publier = "Raconte eun' affaire";
  static const profil = "Min profil";
  static const membres = "Les gins";
  static const notifications = "Les nouvelles";
  static const notifs = "Nouvelles";
  static const deconnexion = "À l'arvoïure";
  static const connexion = "Entre ichi";
  static const inscription = "Fais tin compte";
  static const creerCompte = "Créer tin compte";
  static const seConnecter = "Entrer";
  static const dejaUnCompte = "J'ai déjà min compte";
  static const nouveauCompte = "Créer un compte tout neuf";

  static const like = "Vindidi !";
  static const commentaires = "Caqu'ries";
  static const commentaire = "Caqu'rie";
  static const envoyer = "Envoyer l'caquet";
  static const refresh = "Eun' tiote rincette";
  static const aucunPost = "Rin à raconter pour l'instant.";
  static const aucunCommentaire = "Pas encore d'caquet par ichi.";
  static const aucunMembre = "Y'a cor personne par ichi.";
  static const aucuneNotification = "Pas d'nouvelles pour l'instant.";
  static const membreInconnu = "Un garchon inconnu";
}
