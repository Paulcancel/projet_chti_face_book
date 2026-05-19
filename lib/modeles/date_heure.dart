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
