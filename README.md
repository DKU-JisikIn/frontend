# 단국대 도우미 (Dankook University Helper)

단국대학교 교내 정보를 쉽게 찾을 수 있는 Q&A 모바일 애플리케이션입니다.

## 📱 프로젝트 개요

이 앱은 단국대학교 학생들이 학사, 장학금, 교내 프로그램, 취업 등 다양한 교내 정보를 쉽게 찾고 공유할 수 있도록 도와주는 플랫폼입니다. ChatGPT 스타일의 직관적인 UI/UX를 제공하여 사용자 경험을 극대화했습니다.

## ✨ 주요 기능

### 🏠 대시보드 홈화면
- 환영 메시지와 그라데이션 디자인
- 📋 공식 정보 미리보기
- 🔥 인기 질문 (조회수 기준)
- ❓ 자주 받은 질문 (답변 수 기준)
- 🔍 하단 고정 검색바

### 🎪 사이드 메뉴
- 홈, 질문 목록, 새 질문 작성
- 카테고리별 바로가기 (학사, 장학금, 교내프로그램, 취업)

### 📋 질문 관리
- 질문 작성 및 편집
- 카테고리별 필터링
- 태그 시스템 (최대 5개)
- 실시간 검색 기능

### 💬 답변 시스템
- 답변 작성 및 조회
- 채택 답변 시스템
- AI 생성 답변 표시
- 좋아요 기능

### 🎨 UI/UX 특징
- ChatGPT 스타일 다크 테마
- 공식 정보 구분 표시 (초록색 테두리)
- 직관적인 아이콘과 색상 시스템
- iOS 네이티브 디자인 가이드라인 준수

## 🛠 기술 스택

- **프레임워크**: Flutter 3.7.2
- **언어**: Dart
- **데이터베이스**: SQLite (sqflite)
- **상태관리**: Provider
- **UI 컴포넌트**: Material Design 3
- **플랫폼**: iOS (주요 타겟), Android 지원

## 📦 주요 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0
  provider: ^6.1.1
  sqflite: ^2.3.0
  path: ^1.8.3
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
│   └── answer.dart             # 답변 모델
├── services/                    # 비즈니스 로직
│   └── database_service.dart   # 데이터베이스 서비스
├── providers/                   # 상태 관리
│   └── app_provider.dart       # 앱 전역 상태
├── screens/                     # 화면
│   ├── home_screen.dart        # 대시보드 홈화면
│   ├── questions_list_screen.dart # 질문 목록 화면
│   ├── question_detail_screen.dart # 질문 상세 화면
│   └── new_question_screen.dart # 새 질문 작성 화면
└── widgets/                     # 재사용 위젯
    ├── chat_input.dart         # 채팅 입력 위젯
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

## 📊 데이터베이스 스키마

### Questions 테이블
- `id`: 질문 고유 ID
- `title`: 질문 제목
- `content`: 질문 내용
- `userId`: 작성자 ID
- `userName`: 작성자 이름
- `createdAt`: 작성 시간
- `viewCount`: 조회수
- `answerCount`: 답변 수
- `isOfficial`: 공식 자료 여부
- `category`: 카테고리
- `tags`: 태그 목록

### Answers 테이블
- `id`: 답변 고유 ID
- `questionId`: 연결된 질문 ID
- `content`: 답변 내용
- `userId`: 작성자 ID
- `userName`: 작성자 이름
- `createdAt`: 작성 시간
- `likeCount`: 좋아요 수
- `isAccepted`: 채택 여부
- `isAIGenerated`: AI 생성 여부

## 🎯 향후 개발 계획

- [ ] 사용자 인증 시스템
- [ ] AI 답변 자동 생성 (OpenAI API 연동)
- [ ] 푸시 알림 기능
- [ ] 즐겨찾기 시스템
- [ ] 답변 평가 시스템 (좋아요/싫어요)
- [ ] 사용자 프로필 관리
- [ ] 관리자 대시보드
- [ ] 다국어 지원

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 👨‍💻 개발자

- **seoulorigin** - *Initial work* - [GitHub](https://github.com/seoulorigin)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 GitHub Issues를 통해 연락해주세요.

---

**단국대학교 학생들의 편의를 위해 개발된 오픈소스 프로젝트입니다.** 🎓
