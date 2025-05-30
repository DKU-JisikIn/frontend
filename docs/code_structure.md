# 코드 구조 및 아키텍처

## 개요
단국대 교내정보 Q&A Flutter 앱의 코드 구조와 아키텍처를 설명합니다.

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── constants/               # 상수 정의
├── models/                  # 데이터 모델
│   ├── question.dart       # 질문 모델
│   └── answer.dart         # 답변 모델
├── providers/               # 상태 관리 (현재 사용 안함)
├── screens/                 # 화면 위젯들
│   ├── home_screen.dart    # 홈 화면
│   ├── login_screen.dart   # 로그인 화면
│   ├── signup_screen.dart  # 회원가입 화면
│   ├── profile_screen.dart # 프로필 화면
│   └── ...                 # 기타 화면들
├── services/                # 비즈니스 로직 및 외부 서비스
│   ├── api_service.dart    # API 호출 관리
│   ├── auth_service.dart   # 인증 관리
│   └── theme_service.dart  # 테마 관리
├── theme/                   # UI 테마 및 스타일
│   └── app_theme.dart      # 앱 테마 정의
├── utils/                   # 유틸리티 함수들
└── widgets/                 # 재사용 가능한 위젯들
    ├── common/             # 공통 위젯
    ├── home/               # 홈 화면 전용 위젯
    │   ├── banner_widgets.dart
    │   ├── stats_widgets.dart
    │   ├── home_drawer.dart
    │   └── home_app_bar.dart
    └── auth/               # 인증 관련 위젯
```

## 아키텍처 패턴

### 서비스 기반 아키텍처
- **화면(Screens)**: UI 표시 및 사용자 상호작용
- **서비스(Services)**: 비즈니스 로직 및 데이터 처리
- **위젯(Widgets)**: 재사용 가능한 UI 컴포넌트
- **모델(Models)**: 데이터 구조 정의

### 주요 설계 원칙
1. **단일 책임 원칙**: 각 클래스는 하나의 책임만 가짐
2. **의존성 역전**: 서비스를 통한 데이터 접근
3. **재사용성**: 공통 위젯의 모듈화
4. **가독성**: 명확한 네이밍과 구조

## 주요 컴포넌트

### 1. 서비스 레이어

#### ApiService (`lib/services/api_service.dart`)
- HTTP 요청 관리
- 에러 처리
- 응답 파싱
- 토큰 기반 인증

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  Future<List<Question>> getQuestions({String? category}) async {
    // API 호출 로직
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    // 로그인 API 호출
  }
}
```

#### AuthService (`lib/services/auth_service.dart`)
- 사용자 인증 상태 관리
- 토큰 저장/관리
- 자동 로그인/로그아웃
- 사용자 정보 캐싱

```dart
class AuthService extends ChangeNotifier {
  bool get isLoggedIn => _token != null;
  String? get currentUserEmail => _userEmail;
  
  Future<bool> login(String email, String password) async {
    // 로그인 처리
  }
  
  Future<void> logout() async {
    // 로그아웃 처리
  }
}
```

#### ThemeService (`lib/services/theme_service.dart`)
- 다크/라이트 모드 관리
- 테마 설정 저장
- 동적 테마 변경

```dart
class ThemeService extends ChangeNotifier {
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    // 테마 토글
  }
}
```

### 2. 모델 레이어

#### Question 모델
```dart
class Question {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final DateTime createdAt;
  final int viewCount;
  final int answerCount;
  final bool hasAcceptedAnswer;
  
  // JSON 변환 메서드
  factory Question.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 3. 위젯 레이어

#### 홈 화면 위젯들
- **BannerWidgets**: 상단 배너들 (환영, 공식정보, 인기질문, 자주받은질문)
- **StatsWidgets**: 통계 위젯들 (사용자 통계, 우수 답변자, 오늘 통계, 누적 통계)
- **HomeDrawer**: 네비게이션 드로어
- **HomeAppBar**: 앱바 및 프로필 버튼

#### 공통 위젯들
- **MessageBubble**: 질문 카드 표시
- **CategorySelector**: 카테고리 선택
- **PeriodFilter**: 기간 필터

### 4. 테마 시스템

#### AppTheme (`lib/theme/app_theme.dart`)
- 동적 색상 시스템
- 라이트/다크 모드 지원
- 일관된 디자인 시스템

```dart
class AppTheme {
  static bool get isDarkMode => ThemeService().isDarkMode;
  
  // 동적 색상들
  static Color get backgroundColor => isDarkMode ? darkBackgroundColor : lightBackgroundColor;
  static Color get primaryTextColor => isDarkMode ? darkPrimaryTextColor : lightPrimaryTextColor;
  
  // 컴포넌트 스타일들
  static BoxDecoration get iosCardDecoration => ...;
  static TextStyle get headingStyle => ...;
}
```

## 상태 관리

### ChangeNotifier 패턴
- AuthService: 인증 상태
- ThemeService: 테마 상태
- 각 화면: 로컬 상태 (setState)

### 데이터 흐름
1. **사용자 액션** → 화면 위젯
2. **화면 위젯** → 서비스 호출
3. **서비스** → API 호출
4. **API 응답** → 모델 파싱
5. **모델 데이터** → UI 업데이트

## 코드 컨벤션

### 네이밍 규칙
- **클래스**: PascalCase (예: `HomeScreen`, `ApiService`)
- **메서드/변수**: camelCase (예: `loadData`, `isLoading`)
- **상수**: SCREAMING_SNAKE_CASE (예: `API_TIMEOUT`)
- **파일**: snake_case (예: `home_screen.dart`)

### 파일 구조
- 각 화면은 별도 파일
- 관련 위젯들은 폴더로 그룹화
- 서비스는 기능별로 분리
- 모델은 도메인별로 분리

### 주석 규칙
```dart
/// 질문 목록을 API에서 가져옵니다.
/// 
/// [category] 카테고리 필터 (선택사항)
/// [page] 페이지 번호 (기본값: 1)
/// 
/// 반환값: Question 객체 리스트
/// 예외: ApiException - API 호출 실패 시
Future<List<Question>> getQuestions({String? category, int page = 1}) async {
  // 구현 내용
}
```

## 성능 최적화

### 위젯 최적화
- `const` 생성자 사용
- 불필요한 rebuild 방지
- 메모리 누수 방지 (dispose 메서드)

### 네트워킹 최적화
- HTTP 클라이언트 재사용
- 응답 캐싱
- 에러 재시도 로직

### 메모리 관리
- 컨트롤러 해제
- 스트림 구독 해제
- 이미지 캐싱

## 테스트 전략

### 단위 테스트
- 서비스 로직 테스트
- 모델 변환 테스트
- 유틸리티 함수 테스트

### 위젯 테스트
- 화면 렌더링 테스트
- 사용자 상호작용 테스트
- 상태 변화 테스트

### 통합 테스트
- 전체 플로우 테스트
- API 연동 테스트

## 보안 고려사항

### 데이터 보안
- 토큰 안전 저장 (SharedPreferences)
- 민감한 정보 로깅 방지
- 네트워크 통신 암호화

### 코드 보안
- API 키 하드코딩 방지
- 디버그 정보 제거
- 코드 난독화

## 확장성 고려사항

### 새로운 기능 추가
1. 모델 정의 (`lib/models/`)
2. API 서비스 메서드 추가 (`lib/services/api_service.dart`)
3. 화면 위젯 생성 (`lib/screens/`)
4. 필요시 공통 위젯 생성 (`lib/widgets/`)

### 새로운 화면 추가
```dart
// 1. 화면 클래스 생성
class NewScreen extends StatefulWidget {
  const NewScreen({super.key});
  
  @override
  State<NewScreen> createState() => _NewScreenState();
}

// 2. 상태 클래스 구현
class _NewScreenState extends State<NewScreen> {
  // 필요한 서비스 인스턴스
  final ApiService _apiService = ApiService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('새 화면', style: AppTheme.headingStyle),
      ),
      body: // UI 구현
    );
  }
}
```

## 디버깅 및 로깅

### 로그 레벨
- `DEBUG`: 개발 시 상세 정보
- `INFO`: 일반적인 정보
- `WARNING`: 경고 사항
- `ERROR`: 오류 정보

### 개발 도구
- Flutter Inspector
- Dart DevTools
- 네트워크 모니터링
- 성능 프로파일링

## 배포 고려사항

### 환경 설정
- 개발/스테이징/운영 환경 분리
- API URL 환경별 설정
- 앱 아이콘 및 이름 설정

### 빌드 최적화
- 코드 분할
- 이미지 최적화
- 번들 크기 최소화

이 문서는 개발팀의 코드 이해와 유지보수를 위한 가이드입니다. 