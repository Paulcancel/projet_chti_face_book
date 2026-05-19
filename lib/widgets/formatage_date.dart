import '../modeles/donnees.dart';

class FormatageDate {
  const FormatageDate._();

  static String courte(DateTime date) => DateHeure.courte(date);

  static String relative(DateTime date) => DateHeure.relative(date);
}
