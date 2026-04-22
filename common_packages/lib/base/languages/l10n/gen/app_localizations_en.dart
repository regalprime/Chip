// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get name => 'My Chip';

  @override
  String get language => 'English';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get color => 'Color';

  @override
  String get setting => 'Settings';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get toggleDarkMode => 'Toggle dark mode';

  @override
  String get titleDayCounter => 'Counting the days we\'ve been in love';

  @override
  String get contentDayCounter => 'days we\'ve been in love, since';

  @override
  String get pickADate => 'Pick a date';

  @override
  String get clearData => 'Clear data';

  @override
  String dayCounterMessage(int days, String date) {
    return '$days days since $date.';
  }

  @override
  String milestoneReached(int target) {
    return 'Reached $target days!';
  }

  @override
  String milestoneRemaining(int remaining, int target) {
    return '$remaining days left to reach $target days';
  }

  @override
  String get signOut => 'Sign Out';

  @override
  String get profile => 'Profile';
}
