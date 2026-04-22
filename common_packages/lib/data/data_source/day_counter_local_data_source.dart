import 'package:shared_preferences/shared_preferences.dart';

abstract class DayCounterLocalDataSource {
  Future<void> saveSelectedDate(DateTime date);
  Future<DateTime?> getSelectedDate();
  Future<void> clearSelectedDate();
}

class DayCounterLocalDataSourceImpl implements DayCounterLocalDataSource {
  static const String _keySelectedDate = 'selectedDate';

  @override
  Future<void> saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySelectedDate, date.millisecondsSinceEpoch);
  }

  @override
  Future<DateTime?> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keySelectedDate);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<void> clearSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySelectedDate);
  }
}
