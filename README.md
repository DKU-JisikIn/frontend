# 단비 (Dankook University Helper) - Frontend

단국대학교 교내 정보를 쉽게 찾을 수 있는 Q&A 모바일 애플리케이션의 프론트엔드입니다.

## 📱 프로젝트 개요

이 앱은 단국대학교 학생들이 학사, 장학금, 교내 프로그램, 취업 등 다양한 교내 정보를 쉽게 찾고 공유할 수 있도록 도와주는 플랫폼입니다. ChatGPT 스타일의 직관적인 UI/UX를 제공하여 사용자 경험을 극대화했습니다.

## ✨ 주요 기능

### 🏠 대시보드 홈화면
- 환영 메시지와 그라데이션 디자인
- 📋 공식 정보 미리보기
- 🔥 인기 질문 (조회수 기준)
- ❓ 자주 받은 질문 (답변 수 기준)
- 🔍 하단 고정 검색바

### 🤖 AI 채팅 도우미
- ChatGPT 스타일 대화형 인터페이스
- 질문 검색 및 자동 답변
- 새 질문 작성 제안
- 실시간 메시지 처리

### 📋 질문 관리
- 질문 작성 및 편집
- 카테고리별 필터링
- 태그 시스템 (최대 5개)
- 실시간 검색 기능

### 💬 답변 시스템
- 답변 작성 및 조회
- 채택 답변 시스템
- 좋아요 기능

## 🛠 기술 스택

- **프레임워크**: Flutter 3.7.2
- **언어**: Dart
- **UI 컴포넌트**: Material Design 3
- **플랫폼**: iOS (주요 타겟), Android 지원
- **HTTP 클라이언트**: http package

## 📦 주요 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  intl: ^0.19.0
  json_annotation: ^4.8.1
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

## 🏗 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── models/                      # 데이터 모델
│   ├── question.dart           # 질문 모델
│   ├── answer.dart             # 답변 모델
│   └── chat_message.dart       # 채팅 메시지 모델
├── services/                    # API 서비스
│   └── api_service.dart        # 백엔드 API 인터페이스
├── screens/                     # 화면
│   ├── home_screen.dart        # 대시보드 홈화면
│   ├── chat_screen.dart        # AI 채팅 화면
│   ├── questions_list_screen.dart # 질문 목록 화면
│   ├── question_detail_screen.dart # 질문 상세 화면
│   └── new_question_screen.dart # 새 질문 작성 화면
└── widgets/                     # 재사용 위젯
    ├── chat_input.dart         # 채팅 입력 위젯
    ├── chat_message_widget.dart # 채팅 메시지 위젯
    ├── message_bubble.dart     # 메시지 버블
    └── category_selector.dart  # 카테고리 선택기
```

## 🚀 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.7.2 이상
- Dart SDK
- iOS 개발환경 (Xcode)
- Android 개발환경 (Android Studio, 선택사항)

### 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/seoulorigin/taba_project.git
cd taba_project
```

2. 의존성 설치
```bash
flutter pub get
```

3. 코드 생성 (JSON serialization)
```bash
flutter packages pub run build_runner build
```

4. 앱 실행
```bash
flutter run
```

## 🔌 백엔드 연동 가이드

현재 프론트엔드는 목업 데이터로 작동하며, 백엔드 개발자가 다음 API를 구현하면 완전한 기능을 제공할 수 있습니다.

### API 엔드포인트

#### 1. 질문 관련 API
```
GET  /api/questions                    - 질문 목록 조회
GET  /api/questions/{id}               - 특정 질문 조회
POST /api/questions                    - 새 질문 작성
GET  /api/questions/popular            - 인기 질문 목록
GET  /api/questions/frequent           - 자주 받은 질문 목록
GET  /api/questions/official           - 공식 질문 목록
GET  /api/questions/search?q={query}   - 질문 검색
```

#### 2. 답변 관련 API
```
GET  /api/questions/{id}/answers       - 특정 질문의 답변 목록
POST /api/answers                      - 새 답변 작성
PUT  /api/answers/{id}/accept          - 답변 채택
PUT  /api/answers/{id}/like            - 답변 좋아요
```

#### 3. 채팅 관련 API
```
POST /api/chat/process                 - 채팅 메시지 처리 (AI 응답)
```

### 데이터 모델

#### Question 모델
```json
{
  "id": "string",
  "title": "string",
  "content": "string",
  "userId": "string",
  "userName": "string",
  "createdAt": "2024-01-01T00:00:00Z",
  "category": "학사|장학금|교내프로그램|취업|기타",
  "isOfficial": "boolean",
  "viewCount": "number",
  "answerCount": "number",
  "tags": ["string"]
}
```

#### Answer 모델
```json
{
  "id": "string",
  "questionId": "string",
  "content": "string",
  "userId": "string",
  "userName": "string",
  "createdAt": "2024-01-01T00:00:00Z",
  "isAccepted": "boolean",
  "isAIGenerated": "boolean",
  "likeCount": "number"
}
```

#### ChatMessage 모델
```json
{
  "id": "string",
  "content": "string",
  "type": "user|assistant|system",
  "createdAt": "2024-01-01T00:00:00Z",
  "status": "sending|sent|error",
  "metadata": "object"
}
```

### API 연동 방법

1. `lib/services/api_service.dart` 파일에서 `baseUrl` 변경
2. 각 메서드의 TODO 주석 부분을 실제 HTTP 요청으로 대체
3. 에러 핸들링 및 인증 로직 추가

### 예시: 질문 목록 조회 API 연동

```dart
Future<List<Question>> getQuestions({String? category, String? search}) async {
  final uri = Uri.parse('$baseUrl/questions').replace(queryParameters: {
    if (category != null) 'category': category,
    if (search != null) 'search': search,
  });
  
  final response = await http.get(uri);
  
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Question.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load questions');
  }
}
```

## 📊 현재 상태

- ✅ **프론트엔드**: 완성 (목업 데이터로 작동)
- ⏳ **백엔드**: 연동 대기 중
- ⏳ **AI 기능**: 백엔드 API 구현 필요

## 🎯 백엔드 개발 우선순위

1. **기본 CRUD API** (질문, 답변)
2. **검색 및 필터링 API**
3. **AI 채팅 처리 API**
4. **사용자 인증 시스템**
5. **관리자 기능**

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👨‍💻 개발자

- **Frontend**: seoulorigin - [GitHub](https://github.com/seoulorigin)
- **Backend**: 연동 대기 중

## 🤝 백엔드 개발자를 위한 참고사항

- 모든 API는 JSON 형식으로 통신
- 날짜는 ISO 8601 형식 사용
- 페이지네이션: `?page=1&limit=10`
- 에러 응답: `{"error": "message", "code": "ERROR_CODE"}`
- 인증: Bearer Token 방식 권장

---

**프론트엔드 개발 완료. 백엔드 연동을 기다리고 있습니다!** 🚀
