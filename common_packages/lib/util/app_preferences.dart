import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyIsDarkMode = 'isUseDarkMode';
  static const String _keyLanguageCode = 'languageCode';
  static const String _keySelectedDate = 'selectedDate';
  static const String _keyCachedUserUid = 'cachedUserUid';
  static const String _keyCachedUserEmail = 'cachedUserEmail';
  static const String _keyCachedUserDisplayName = 'cachedUserDisplayName';
  static const String _keyCachedUserPhotoUrl = 'cachedUserPhotoUrl';
  static const String _keyReaderFontSize = 'readerFontSize';
  static const String _keyReaderLineHeight = 'readerLineHeight';
  static const String _keyReaderTheme = 'readerTheme';
  static const String _keyDocReadingStates = 'docReadingStates';

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Auth session cache ────────────────────────────────────────────────────

  static Future<void> setCachedUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCachedUserUid, uid);
    await prefs.setString(_keyCachedUserEmail, email);
    if (displayName != null) {
      await prefs.setString(_keyCachedUserDisplayName, displayName);
    }
    if (photoUrl != null) {
      await prefs.setString(_keyCachedUserPhotoUrl, photoUrl);
    }
  }

  static Future<Map<String, String?>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyCachedUserUid);
    if (uid == null) return null;
    return {
      'uid': uid,
      'email': prefs.getString(_keyCachedUserEmail),
      'displayName': prefs.getString(_keyCachedUserDisplayName),
      'photoUrl': prefs.getString(_keyCachedUserPhotoUrl),
    };
  }

  static Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCachedUserUid);
    await prefs.remove(_keyCachedUserEmail);
    await prefs.remove(_keyCachedUserDisplayName);
    await prefs.remove(_keyCachedUserPhotoUrl);
  }

  // ─── Reader settings (global) ──────────────────────────────────────────────

  static Future<void> setReaderSettings({
    double? fontSize,
    double? lineHeight,
    String? theme,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (fontSize != null) await prefs.setDouble(_keyReaderFontSize, fontSize);
    if (lineHeight != null) await prefs.setDouble(_keyReaderLineHeight, lineHeight);
    if (theme != null) await prefs.setString(_keyReaderTheme, theme);
  }

  static Future<Map<String, dynamic>> getReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fontSize': prefs.getDouble(_keyReaderFontSize),
      'lineHeight': prefs.getDouble(_keyReaderLineHeight),
      'theme': prefs.getString(_keyReaderTheme),
    };
  }

  // ─── Document reading state (per document) ────────────────────────────────

  static Future<void> setDocReadingState({
    required String documentId,
    int? currentPage,
    bool? isTextMode,
    double? textScrollOffset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDocReadingStates) ?? '{}';
    final states = Map<String, dynamic>.from(jsonDecode(raw) as Map);

    final existing = states[documentId] as Map<String, dynamic>? ?? {};
    if (currentPage != null) existing['currentPage'] = currentPage;
    if (isTextMode != null) existing['isTextMode'] = isTextMode;
    if (textScrollOffset != null) existing['textScrollOffset'] = textScrollOffset;
    states[documentId] = existing;

    await prefs.setString(_keyDocReadingStates, jsonEncode(states));
  }

  static Future<Map<String, dynamic>?> getDocReadingState(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDocReadingStates);
    if (raw == null) return null;
    final states = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final state = states[documentId];
    if (state == null) return null;
    return Map<String, dynamic>.from(state as Map);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkMode, isDark);
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode) ?? 'en';
  }

  static Future<void> setSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keySelectedDate,
      date.millisecondsSinceEpoch,
    );
  }

  static Future<DateTime?> getSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_keySelectedDate);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
