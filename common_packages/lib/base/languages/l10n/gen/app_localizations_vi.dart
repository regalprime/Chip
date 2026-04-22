// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get name => 'My Chip';

  @override
  String get language => 'Tiếng Việt';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get color => 'Màu sắc';

  @override
  String get setting => 'Cài đặt';

  @override
  String get changeLanguage => 'Thay đổi ngôn ngữ';

  @override
  String get toggleDarkMode => 'Bật/Tắt chế độ tối';

  @override
  String get titleDayCounter => 'Đếm ngày chúng ta đã yêu nhau';

  @override
  String get contentDayCounter => 'ngày chúng ta đã yêu nhau, từ lúc';

  @override
  String get pickADate => 'Chọn ngày';

  @override
  String get clearData => 'Xoá dữ liệu';

  @override
  String dayCounterMessage(int days, String date) {
    return 'Đã được $days ngày kể từ $date.';
  }

  @override
  String milestoneReached(int target) {
    return 'Đã đạt $target ngày!';
  }

  @override
  String milestoneRemaining(int remaining, int target) {
    return 'Còn $remaining ngày nữa để đạt $target ngày';
  }

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get profile => 'Hồ sơ';
}
