import 'package:flutter/material.dart';

class AppTheme {
  // 기본 색상 정의
  static const Color primaryColor = Color(0xFF6366F1); // 연한 파랑색
  static const Color secondaryColor = Color(0xFF8B5CF6); // 보라색
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFE2E8F0);
  
  // 텍스트 색상
  static final Color primaryTextColor = Colors.grey[800]!;
  static final Color secondaryTextColor = Colors.grey[600]!;
  static final Color hintTextColor = Colors.grey[500]!;
  static final Color lightTextColor = Colors.grey[400]!;
  
  // 메시지 버블 색상
  static const Color userMessageColor = primaryColor;
  static const Color assistantMessageColor = Color(0xFFF1F5F9);
  static const Color assistantMessageBorderColor = borderColor;
  
  // 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 그림자
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, -2),
    ),
  ];
  
  // 테마 데이터
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: TextStyle(color: hintTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: backgroundColor,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: secondaryTextColor,
        textColor: primaryTextColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }
  
  // 커스텀 스타일들
  static TextStyle get headingStyle => TextStyle(
    color: primaryTextColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get subheadingStyle => TextStyle(
    color: secondaryTextColor,
    fontSize: 12,
  );
  
  static TextStyle get bodyStyle => TextStyle(
    color: primaryTextColor,
    fontSize: 14,
    height: 1.4,
  );
  
  static TextStyle get hintStyle => TextStyle(
    color: hintTextColor,
    fontSize: 14,
  );
  
  // 메시지 버블 스타일
  static BoxDecoration userMessageDecoration = const BoxDecoration(
    color: userMessageColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(4),
    ),
  );
  
  static BoxDecoration assistantMessageDecoration = const BoxDecoration(
    color: assistantMessageColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(16),
    ),
    border: Border.fromBorderSide(
      BorderSide(color: assistantMessageBorderColor, width: 1),
    ),
  );
  
  // 입력창 스타일
  static BoxDecoration get inputContainerDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: borderColor),
  );
  
  // 검색바 컨테이너 스타일
  static BoxDecoration get searchBarContainerDecoration => const BoxDecoration(
    color: backgroundColor,
    border: Border(
      top: BorderSide(color: borderColor, width: 1),
    ),
    boxShadow: cardShadow,
  );
  
  // 환영 메시지 컨테이너 스타일
  static BoxDecoration get welcomeContainerDecoration => const BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
} 