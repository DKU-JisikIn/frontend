import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../services/theme_service.dart';

class AppTheme {
  // 정적 초기화 블록
  static bool _initialized = false;
  
  static void _ensureInitialized() {
    if (!_initialized) {
      ThemeService.setCacheInvalidator(invalidateCache);
      _initialized = true;
    }
  }
  
  // 라이트 모드 색상 정의
  static const Color lightPrimaryColor = Color(0xFF4FC3F7); // 연한 파랑색
  static const Color lightSecondaryColor = Color(0xFF29B6F6); // 조금 더 진한 파랑색
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightSurfaceColor = Color(0xFFF8FAFC);
  static const Color lightBorderColor = Color(0xFFE2E8F0);
  
  // 다크 모드 색상 정의
  static const Color darkPrimaryColor = Color(0xFF81C6E8); // 밝은 파랑색
  static const Color darkSecondaryColor = Color(0xFF56B3E5); // 중간 파랑색
  static const Color darkBackgroundColor = Color(0xFF121212); // 매우 어두운 배경
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // 어두운 표면
  static const Color darkBorderColor = Color(0xFF2E2E2E); // 어두운 경계선
  
  // 라이트 모드 텍스트 색상
  static final Color lightPrimaryTextColor = Colors.grey[800]!;
  static final Color lightSecondaryTextColor = Colors.grey[600]!;
  static final Color lightHintTextColor = Colors.grey[500]!;
  static final Color lightLightTextColor = Colors.grey[400]!;
  
  // 다크 모드 텍스트 색상
  static const Color darkPrimaryTextColor = Color(0xFFE0E0E0);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
  static const Color darkHintTextColor = Color(0xFF808080);
  static const Color darkLightTextColor = Color(0xFF606060);
  
  // 캐시된 테마 상태
  static bool? _cachedIsDarkMode;
  
  // 현재 테마 상태를 캐시하여 성능 향상
  static bool get _isDarkMode {
    _ensureInitialized();
    _cachedIsDarkMode ??= ThemeService().isDarkMode;
    return _cachedIsDarkMode!;
  }
  
  // 테마 캐시 무효화 (테마 변경 시 호출)
  static void invalidateCache() {
    _cachedIsDarkMode = null;
  }
  
  // 현재 테마에 따른 색상 반환 - 캐시된 값 사용
  static Color get primaryColor {
    _ensureInitialized();
    return _isDarkMode ? darkPrimaryColor : lightPrimaryColor;
  }
  
  static Color get secondaryColor {
    _ensureInitialized();
    return _isDarkMode ? darkSecondaryColor : lightSecondaryColor;
  }
  
  static Color get backgroundColor {
    _ensureInitialized();
    return _isDarkMode ? darkBackgroundColor : lightBackgroundColor;
  }
  
  static Color get surfaceColor {
    _ensureInitialized();
    return _isDarkMode ? darkSurfaceColor : lightSurfaceColor;
  }
  
  static Color get borderColor {
    _ensureInitialized();
    return _isDarkMode ? darkBorderColor : lightBorderColor;
  }
  
  static Color get primaryTextColor {
    _ensureInitialized();
    return _isDarkMode ? darkPrimaryTextColor : lightPrimaryTextColor;
  }
  
  static Color get secondaryTextColor {
    _ensureInitialized();
    return _isDarkMode ? darkSecondaryTextColor : lightSecondaryTextColor;
  }
  
  static Color get hintTextColor {
    _ensureInitialized();
    return _isDarkMode ? darkHintTextColor : lightHintTextColor;
  }
  
  static Color get lightTextColor {
    _ensureInitialized();
    return _isDarkMode ? darkLightTextColor : lightLightTextColor;
  }
  
  // 메시지 버블 색상
  static Color get userMessageColor {
    _ensureInitialized();
    return primaryColor;
  }
  
  static Color get assistantMessageColor {
    _ensureInitialized();
    return _isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF1F5F9);
  }
  
  static Color get assistantMessageBorderColor {
    _ensureInitialized();
    return borderColor;
  }
  
  // iOS 스타일 그라데이션
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // iOS 스타일 그림자 (더 부드럽고 자연스러움)
  static const List<BoxShadow> iosShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 6,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  // iOS 스타일 카드 그림자
  static const List<BoxShadow> iosCardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  // 테마 데이터
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      // iOS 스타일 폰트 패밀리 설정
      fontFamily: '.SF Pro Text', // iOS San Francisco 폰트
      primarySwatch: Colors.blue,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      
      // iOS 스타일 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        foregroundColor: lightPrimaryTextColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: lightPrimaryTextColor,
          fontSize: 17, // iOS 표준 타이틀 크기
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4, // iOS 스타일 letter spacing
        ),
        iconTheme: IconThemeData(color: lightPrimaryTextColor, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // 상태바 아이콘을 어둡게
      ),
      
      // iOS 스타일 버튼
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // iOS 스타일 둥근 모서리
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      
      // iOS 스타일 입력 필드
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // iOS 스타일 둥근 모서리
          borderSide: BorderSide(color: lightBorderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBorderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPrimaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          color: lightHintTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // iOS 스타일 Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      
      // iOS 스타일 Divider
      dividerTheme: DividerThemeData(
        color: lightBorderColor,
        thickness: 0.5, // iOS 스타일 얇은 구분선
        space: 0.5,
      ),
      
      // iOS 스타일 ListTile
      listTileTheme: ListTileThemeData(
        iconColor: lightSecondaryTextColor,
        textColor: lightPrimaryTextColor,
        titleTextStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightSecondaryTextColor,
          letterSpacing: -0.2,
        ),
      ),
      
      // 기타 테마 설정
      useMaterial3: true,
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // iOS 스타일 폰트 패밀리 설정
      fontFamily: '.SF Pro Text', // iOS San Francisco 폰트
      primarySwatch: Colors.blue,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      
      // iOS 스타일 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: darkPrimaryTextColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: darkPrimaryTextColor,
          fontSize: 17, // iOS 표준 타이틀 크기
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4, // iOS 스타일 letter spacing
        ),
        iconTheme: IconThemeData(color: darkPrimaryTextColor, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.light, // 상태바 아이콘을 밝게
      ),
      
      // iOS 스타일 버튼
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // iOS 스타일 둥근 모서리
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      
      // iOS 스타일 입력 필드
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // iOS 스타일 둥근 모서리
          borderSide: BorderSide(color: darkBorderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          color: darkHintTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // iOS 스타일 Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      
      // iOS 스타일 Divider
      dividerTheme: DividerThemeData(
        color: darkBorderColor,
        thickness: 0.5, // iOS 스타일 얇은 구분선
        space: 0.5,
      ),
      
      // iOS 스타일 ListTile
      listTileTheme: ListTileThemeData(
        iconColor: darkSecondaryTextColor,
        textColor: darkPrimaryTextColor,
        titleTextStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkSecondaryTextColor,
          letterSpacing: -0.2,
        ),
      ),
      
      // 기타 테마 설정
      useMaterial3: true,
    );
  }
  
  // 텍스트 스타일들
  static TextStyle get headingStyle => TextStyle(
    fontFamily: '.SF Pro Display',
    color: primaryTextColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
  
  static TextStyle get subheadingStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    color: secondaryTextColor,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get bodyStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    color: primaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static TextStyle get hintStyle => TextStyle(
    fontFamily: '.SF Pro Text',
    color: hintTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  // 메시지 버블 데코레이션
  static BoxDecoration get userMessageDecoration => BoxDecoration(
    color: userMessageColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(4),
    ),
    boxShadow: iosShadow,
  );
  
  static BoxDecoration get assistantMessageDecoration => BoxDecoration(
    color: assistantMessageColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(18),
    ),
    border: Border.fromBorderSide(
      BorderSide(color: assistantMessageBorderColor, width: 0.5),
    ),
    boxShadow: iosShadow,
  );
  
  // 입력창 데코레이션
  static BoxDecoration get inputContainerDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(25),
    border: Border.fromBorderSide(
      BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosShadow,
  );
  
  // 검색바 컨테이너 데코레이션
  static BoxDecoration get searchBarContainerDecoration => BoxDecoration(
    color: backgroundColor,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    border: Border(
      top: BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosShadow,
  );
  
  // 환영 메시지 컨테이너 데코레이션
  static BoxDecoration get welcomeContainerDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    boxShadow: iosCardShadow,
  );
  
  // 카드 데코레이션
  static BoxDecoration get iosCardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosCardShadow,
  );
} 