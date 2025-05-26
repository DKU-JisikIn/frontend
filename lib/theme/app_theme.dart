import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
  
  // iOS 스타일 그라데이션
  static const LinearGradient primaryGradient = LinearGradient(
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
      // iOS 스타일 폰트 패밀리 설정
      fontFamily: '.SF Pro Text', // iOS San Francisco 폰트
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // iOS 스타일 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          color: primaryTextColor,
          fontSize: 17, // iOS 표준 타이틀 크기
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4, // iOS 스타일 letter spacing
        ),
        iconTheme: IconThemeData(color: primaryTextColor, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // 상태바 아이콘을 어둡게
      ),
      
      // iOS 스타일 버튼
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
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
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // iOS 스타일 둥근 모서리
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          color: hintTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // iOS 스타일 Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: backgroundColor,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      
      // iOS 스타일 Divider
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 0.5, // iOS 스타일 얇은 구분선
        space: 0.5,
      ),
      
      // iOS 스타일 ListTile
      listTileTheme: ListTileThemeData(
        iconColor: secondaryTextColor,
        textColor: primaryTextColor,
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
          color: secondaryTextColor,
        ),
      ),
      
      // iOS 스타일 Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      
      // iOS 스타일 Card
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceColor,
      ),
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
  static BoxDecoration userMessageDecoration = const BoxDecoration(
    color: userMessageColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(4),
    ),
    boxShadow: iosShadow,
  );
  
  static BoxDecoration assistantMessageDecoration = const BoxDecoration(
    color: assistantMessageColor,
    borderRadius: BorderRadius.only(
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
    border: const Border.fromBorderSide(
      BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosShadow,
  );
  
  // 검색바 컨테이너 데코레이션
  static BoxDecoration get searchBarContainerDecoration => const BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    border: Border(
      top: BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosShadow,
  );
  
  // 환영 메시지 컨테이너 데코레이션
  static BoxDecoration get welcomeContainerDecoration => const BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: iosCardShadow,
  );
  
  // 카드 데코레이션
  static BoxDecoration get iosCardDecoration => const BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: borderColor, width: 0.5),
    ),
    boxShadow: iosCardShadow,
  );
} 