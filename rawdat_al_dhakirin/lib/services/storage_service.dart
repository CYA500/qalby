// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // مفاتيح التخزين
  static const String _sessionCountKey = 'tasbeeh_session';
  static const String _dailyCountKey = 'tasbeeh_daily';
  static const String _grandTotalKey = 'tasbeeh_grand';
  static const String _lastDayKey = 'last_day';
  static const String _currentDhikrIndexKey = 'current_dhikr';
  static const String _themeKey = 'is_dark_mode';
  static const String _dailyHadithIndexKey = 'daily_hadith';

  // إدارة العدادات
  Future<void> saveCounters({
    required int session,
    required int daily,
    required int grand,
    required int dhikrIndex,
  }) async {
    await _prefs?.setInt(_sessionCountKey, session);
    await _prefs?.setInt(_dailyCountKey, daily);
    await _prefs?.setInt(_grandTotalKey, grand);
    await _prefs?.setInt(_currentDhikrIndexKey, dhikrIndex);
  }

  Map<String, int> getCounters() {
    _checkAndResetDaily();
    return {
      'session': _prefs?.getInt(_sessionCountKey) ?? 0,
      'daily': _prefs?.getInt(_dailyCountKey) ?? 0,
      'grand': _prefs?.getInt(_grandTotalKey) ?? 0,
      'dhikrIndex': _prefs?.getInt(_currentDhikrIndexKey) ?? 0,
    };
  }

  // إعادة تعيين اليومي إذا تغير اليوم
  void _checkAndResetDaily() {
    final today = DateTime.now().day;
    final lastDay = _prefs?.getInt(_lastDayKey) ?? -1;

    if (today != lastDay) {
      _prefs?.setInt(_dailyCountKey, 0);
      _prefs?.setInt(_lastDayKey, today);
      // تحديث حديث اليوم
      final dayOfWeek = DateTime.now().weekday;
      _prefs?.setInt(_dailyHadithIndexKey, dayOfWeek % 7);
    }
  }

  // الوضع المظلم
  Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool(_themeKey, isDark);
  }

  bool getDarkMode() {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  // حديث اليوم
  int getDailyHadithIndex() {
    return _prefs?.getInt(_dailyHadithIndexKey) ?? 
           (DateTime.now().weekday % 7);
  }

  // إعادة تعيين الجلسة
  Future<void> resetSession() async {
    await _prefs?.setInt(_sessionCountKey, 0);
  }

  // إضافة للإجمالي الكبير
  Future<void> addToGrandTotal(int amount) async {
    final current = _prefs?.getInt(_grandTotalKey) ?? 0;
    await _prefs?.setInt(_grandTotalKey, current + amount);
  }
}
