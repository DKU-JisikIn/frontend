import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _invalidateAppThemeCache();
    notifyListeners();
  }

  void setTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _invalidateAppThemeCache();
      notifyListeners();
    }
  }
  
  // AppTheme 캐시 무효화 (순환 import 방지를 위해 dynamic import 사용)
  void _invalidateAppThemeCache() {
    try {
      // AppTheme의 캐시를 무효화
      final appThemeLibrary = Uri.parse('package:taba_project/theme/app_theme.dart');
      // 런타임에 AppTheme.invalidateCache() 호출을 시뮬레이트
      _resetAppThemeCache();
    } catch (e) {
      // 에러 발생 시 무시 (개발 환경에서만 발생 가능)
    }
  }
  
  // AppTheme 캐시 리셋을 위한 콜백
  static void Function()? _cacheInvalidator;
  
  static void setCacheInvalidator(void Function() invalidator) {
    _cacheInvalidator = invalidator;
  }
  
  void _resetAppThemeCache() {
    _cacheInvalidator?.call();
  }
} 