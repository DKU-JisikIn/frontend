# 백엔드 연동 가이드

## 1. API 서비스 구조

### 주요 파일 위치
- API 서비스: `lib/services/api_service.dart`
- 인증 서비스: `lib/services/auth_service.dart`
- 데이터 모델: `lib/models/`

### API 베이스 URL
현재 로컬 테스트용으로 설정되어 있습니다:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**⚠️ 백엔드 배포 시 실제 서버 URL로 변경 필요**

## 2. 필요한 API 엔드포인트

### 2.1 인증 관련 API

#### 로그인
- **POST** `/auth/login`
- **Request Body:**
```json
{
  "email": "student@dankook.ac.kr",
  "password": "password123"
}
```
- **Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": "user_id",
      "email": "student@dankook.ac.kr",
      "name": "홍길동",
      "profileImageUrl": "https://example.com/profile.jpg",
      "isVerified": true
    }
  }
}
```

#### 회원가입
- **POST** `/auth/register`
- **Request Body:**
```json
{
  "email": "student@dankook.ac.kr",
  "password": "password123",
  "name": "홍길동",
  // "studentNumber": "32200000",
  // "department": "컴퓨터소프트웨어학과",
  // "affiliation": "학부생"
}
```

#### 비밀번호 변경
- **PUT** `/auth/change-password`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "currentPassword": "old_password",
  "newPassword": "new_password"
}
```

#### 회원탈퇴
- **DELETE** `/auth/delete-account`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "password": "current_password",
  "reason": "서비스를 더 이상 이용하지 않아요"
}
```

### 2.2 질문 관련 API

#### 질문 목록 조회
- **GET** `/questions`
- **Query Parameters:**
  - `category`: 카테고리 (전체, 학사, 장학, 시설, 기숙사, 동아리, 취업, 기타, 공식)
  - `page`: 페이지 번호 (기본값: 1)
  - `limit`: 페이지 크기 (기본값: 20)
  - `sort`: 정렬 기준 (latest, popular, unanswered)

#### 인기 질문 조회
- **GET** `/questions/popular`
- **Query Parameters:**
  - `limit`: 개수 제한 (기본값: 10)
  - `period`: 기간 (week, month, all)

#### 자주 받은 질문 조회
- **GET** `/questions/frequent`

#### 답변받지 못한 질문 조회
- **GET** `/questions/unanswered`
- **Query Parameters:**
  - `limit`: 개수 제한 (기본값: 8)

#### 질문 상세 조회
- **GET** `/questions/{questionId}`

#### 질문 작성
- **POST** `/questions`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "title": "질문 제목",
  "content": "질문 내용",
  "category": "학사",
  "isAnonymous": false
}
```

### 2.3 답변 관련 API

#### 답변 작성
- **POST** `/questions/{questionId}/answers`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "content": "답변 내용",
  "isAnonymous": false
}
```

#### 답변 채택
- **PUT** `/answers/{answerId}/accept`
- **Headers:** `Authorization: Bearer {token}`

### 2.4 통계 관련 API

#### 오늘 질문 수
- **GET** `/stats/questions/today`

#### 오늘 답변 수
- **GET** `/stats/answers/today`

#### 전체 답변 수
- **GET** `/stats/answers/total`

#### 우수 답변자 랭킹
- **GET** `/stats/top-answerers`
- **Query Parameters:**
  - `limit`: 개수 제한 (기본값: 5)

#### 사용자 질문 통계
- **GET** `/stats/user/{userId}/questions`
- **Headers:** `Authorization: Bearer {token}`

### 2.5 사용자 관련 API

#### 프로필 조회
- **GET** `/users/profile`
- **Headers:** `Authorization: Bearer {token}`

#### 프로필 수정
- **PUT** `/users/profile`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "name": "새로운 이름",
  "profileImageUrl": "https://example.com/new-profile.jpg"
}
```

#### 사용자 질문 목록
- **GET** `/users/questions`
- **Headers:** `Authorization: Bearer {token}`
- **Query Parameters:**
  - `filter`: 필터 (all, answered, unanswered)

### 2.6 인증 관련 API

#### 학과/학번 인증
- **POST** `/verification/submit`
- **Headers:** `Authorization: Bearer {token}`
- **Request Body:**
```json
{
  "studentNumber": "32200000",
  "department": "컴퓨터소프트웨어학과",
  "affiliation": "학부생",
  "documentImageUrl": "https://example.com/document.jpg"
}
```

## 3. 데이터 모델

### Question 모델
```dart
class Question {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final int viewCount;
  final int answerCount;
  final bool hasAcceptedAnswer;
  final bool isAnonymous;
  final List<String> tags;
  final String? acceptedAnswerId;
}
```

### Answer 모델
```dart
class Answer {
  final String id;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final int likeCount;
  final bool isAccepted;
  final bool isAnonymous;
  final bool isOfficial;
}
```

### TopAnswerer 모델
```dart
class TopAnswerer {
  final int rank;
  final String userName;
  final String userId;
  final int answerCount;
  final int score;
}
```

## 4. 에러 처리

모든 API 호출은 다음과 같은 에러 응답을 처리할 수 있어야 합니다:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "사용자에게 표시할 메시지"
  }
}
```

### 주요 에러 코드
- `UNAUTHORIZED`: 인증 실패
- `FORBIDDEN`: 권한 없음
- `NOT_FOUND`: 리소스를 찾을 수 없음
- `VALIDATION_ERROR`: 입력 데이터 검증 실패
- `SERVER_ERROR`: 서버 내부 오류

## 5. 보안 고려사항

### JWT 토큰
- 토큰은 `SharedPreferences`에 안전하게 저장됩니다
- 자동 갱신 메커니즘이 구현되어 있습니다
- 토큰 만료 시 자동 로그아웃 처리됩니다

### 민감한 정보 처리
- 비밀번호는 평문으로 전송되지 않습니다
- 프로필 이미지는 CDN을 통해 제공되어야 합니다
- 사용자 신원 정보는 익명화 옵션을 지원합니다

## 6. 테스트 데이터

현재 앱에서 사용하는 테스트 계정:
- 이메일: `test@dankook.ac.kr`
- 비밀번호: `password123`

## 7. 개발 환경 설정

### CORS 설정
프론트엔드가 웹에서도 실행되므로 CORS 설정이 필요합니다:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

### SSL/HTTPS
운영 환경에서는 반드시 HTTPS를 사용해야 합니다.

## 8. 다음 단계

1. 백엔드 서버 구축 및 API 구현
2. 데이터베이스 스키마 설계
3. 인증 시스템 구현
4. 파일 업로드 서비스 구현
5. 푸시 알림 서비스 연동
6. 성능 최적화 및 캐싱
7. 로그 및 모니터링 시스템 구축

## 연락처
프론트엔드 관련 문의사항이 있으시면 연락주세요. 