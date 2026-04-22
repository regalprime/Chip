import 'dart:ui';

enum AppLanguage {
  english(Locale('en', 'US')),
  vietnamese(Locale('vi', 'VN'));

  const AppLanguage(this.value);

  final Locale value;
}
