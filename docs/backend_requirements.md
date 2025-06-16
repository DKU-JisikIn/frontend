# 백엔드 개발 요구사항

## 1. 기본 설정

### 1.1 Base URL
- 현재 목업: `https://your-backend-api.com/api`
- **실제 백엔드 URL로 변경 필요** (lib/services/api_service.dart Line 8)

### 1.2 응답 형식
- Content-Type: application/json
- 모든 날짜는 ISO 8601 형식 (2024-01-01T00:00:00Z)
- 페이지네이션: ?page=1&limit=10

## 2. 인증 관련 API

### 2.1 로그인
```
POST /api/auth/login
Request Body:
{
  "email": "test@dankook.ac.kr",
  "password": "password123"
}

Response:
{
  "success": true,
  "message": "로그인 성공",
  "token": "JWT_TOKEN_HERE",
  "user": {
    "id": "user_001",
    "email": "test@dankook.ac.kr",
    "name": "Test User",
    "nickname": "테스트사용자",
    "profileImageUrl": "https://...",
    "department": "컴퓨터공학과",
    "studentId": "2020****",
    "isVerified": true,
    "userLevel": 3
  }
}
```

### 2.2 로그아웃
```
POST /api/auth/logout
Headers: Authorization: Bearer {token}
Response:
{
  "success": true,
  "message": "로그아웃 완료"
}
```

### 2.3 이메일 인증 코드 전송
```
POST /api/auth/send-verification
Request Body:
{
  "email": "student@dankook.ac.kr"
}

Response:
{
  "success": true,
  "message": "인증번호가 이메일로 전송되었습니다."
}
```

### 2.4 이메일 인증 코드 확인
```
POST /api/auth/verify-email
Request Body:
{
  "email": "student@dankook.ac.kr",
  "code": "1234"
}

Response:
{
  "success": true,
  "message": "이메일 인증이 완료되었습니다."
}
```

### 2.5 회원가입
```
POST /api/auth/register
Content-Type: multipart/form-data

Fields:
- email: string
- password: string
- nickname: string
- profileImage: File (optional)
- verificationDocument: File (optional)

Response:
{
  "success": true,
  "message": "회원가입이 완료되었습니다.",
  "user": {
    "email": "student@dankook.ac.kr",
    "nickname": "새로운사용자"
  }
}
```

## 3. 질문 관련 API

### 3.1 질문 목록 조회
```
GET /api/questions?category={category}&search={query}&page={page}&limit={limit}

Response:
{
  "questions": [
    {
      "id": "1",
      "title": "수강신청 일정이 언제인가요?",
      "content": "수강신청 관련 질문입니다.",
      "userId": "user_001",
      "userName": "홍길동",
      "createdAt": "2024-01-01T00:00:00Z",
      "viewCount": 150,
      "answerCount": 3,
      "isOfficial": true,
      "category": "학사",
      "tags": ["수강신청", "일정"]
    }
  ],
  "totalCount": 100,
  "page": 1,
  "limit": 10
}
```

### 3.2 인기 질문 목록
```
GET /api/questions/popular?limit={limit}&period={period}
period: '전체기간' | '일주일'

Response: (질문 목록과 동일한 형식, 조회수 기준 정렬)
```

### 3.3 자주 받은 질문 목록
```
GET /api/questions/frequent?limit={limit}&period={period}

Response: (질문 목록과 동일한 형식, 답변 수 기준 정렬)
```

### 3.4 공식 질문 목록
```
GET /api/questions/official?limit={limit}

Response: (isOfficial=true인 질문들)
```

### 3.5 답변받지 못한 질문 목록
```
GET /api/questions/unanswered?limit={limit}

Response: (answerCount=0인 질문들)
```

### 3.6 질문 검색
```
GET /api/questions/search?q={query}

Response: (제목, 내용에서 검색)
```

### 3.7 특정 질문 조회
```
GET /api/questions/{id}

Response:
{
  "id": "1",
  "title": "...",
  "content": "...",
  // ... 전체 질문 정보
}
```

### 3.8 새 질문 작성
```
POST /api/questions
Headers: Authorization: Bearer {token}
Request Body:
{
  "title": "질문 제목",
  "content": "질문 내용",
  "category": "학사",
  "tags": ["태그1", "태그2"]
}

Response:
{
  "id": "new_question_id",
  "title": "질문 제목",
  "content": "질문 내용",
  "userId": "user_001",
  "userName": "사용자명",
  "createdAt": "2024-01-01T00:00:00Z",
  "viewCount": 0,
  "answerCount": 0,
  "isOfficial": false,
  "category": "학사",
  "tags": ["태그1", "태그2"]
}
```

## 4. 답변 관련 API

### 4.1 특정 질문의 답변 목록
```
GET /api/questions/{questionId}/answers

Response:
{
  "answers": [
    {
      "id": "answer_1",
      "questionId": "question_1",
      "content": "답변 내용",
      "userId": "user_002",
      "userName": "답변자",
      "createdAt": "2024-01-01T00:00:00Z",
      "isAccepted": false,
      "isAIGenerated": false,
      "department": "컴퓨터공학과",
      "studentId": "2020****",
      "isVerified": true,
      "userLevel": 3
    }
  ]
}
```

### 4.2 새 답변 작성
```
POST /api/answers
Headers: Authorization: Bearer {token}
Request Body:
{
  "questionId": "question_1",
  "content": "답변 내용"
}

Response: (답변 객체)
```

### 4.3 답변 채택
```
PUT /api/answers/{answerId}/accept
Headers: Authorization: Bearer {token}

Response:
{
  "id": "answer_1",
  "isAccepted": true,
  // ... 기타 답변 정보
}
```

## 5. 채팅/AI 관련 API

### 5.1 채팅 메시지 처리
```
POST /api/chat/process
Headers: Authorization: Bearer {token}
Request Body:
{
  "message": "사용자 메시지",
  "context": "이전 대화 맥락 (optional)"
}

Response:
{
  "response": "AI 응답 메시지",
  "suggestions": ["추천 질문1", "추천 질문2"],
  "canCreateQuestion": true,
  "metadata": {
    "category": "학사",
    "keywords": ["수강신청", "일정"]
  }
}
```

### 5.2 채팅에서 질문 생성
```
POST /api/questions/from-chat
Headers: Authorization: Bearer {token}
Request Body:
{
  "title": "질문 제목",
  "content": "질문 내용",
  "category": "학사"
}

Response: (새로 생성된 질문 객체)
```

## 6. 통계 관련 API

### 6.1 오늘의 질문 수
```
GET /api/statistics/today/questions

Response:
{
  "count": 15
}
```

### 6.2 오늘의 답변 수
```
GET /api/statistics/today/answers

Response:
{
  "count": 28
}
```

### 6.3 전체 답변 수
```
GET /api/statistics/total/answers

Response:
{
  "count": 1234
}
```

### 6.4 우수 답변자 순위
```
GET /api/statistics/top-answerers?limit={limit}

Response:
{
  "topAnswerers": [
    {
      "id": "user_001",
      "userName": "김단국",
      "profileImageUrl": "https://...",
      "score": 128,
      "rank": 1,
      "answerCount": 42
    }
  ]
}
```

## 7. 사용자 관련 API

### 7.1 사용자 질문 통계
```
GET /api/users/{userId}/question-stats
Headers: Authorization: Bearer {token}

Response:
{
  "total": 10,
  "answered": 7,
  "unanswered": 3
}
```

### 7.2 사용자 질문 목록
```
GET /api/users/{userId}/questions?filter={filter}
Headers: Authorization: Bearer {token}
filter: 'all' | 'answered' | 'unanswered'

Response: (질문 목록 형식)
```

## 8. 카테고리 정의

다음 카테고리들을 지원해야 합니다:
- **학사**: 수강신청, 성적, 졸업요건, 학사일정 등
- **장학금**: 국가장학금, 교내장학금, 신청방법 등
- **교내프로그램**: 동아리, 교환학생, 각종 프로그램 등
- **취업**: 취업박람회, 인턴십, 진로 관련 등
- **기타**: 도서관, 학식, 시설 이용 등

## 9. 데이터 모델

### 9.1 Question 모델
```typescript
interface Question {
  id: string;
  title: string;
  content: string;
  userId: string;
  userName: string;
  createdAt: string; // ISO 8601
  viewCount: number;
  answerCount: number;
  isOfficial: boolean;
  category: string;
  tags: string[];
}
```

### 9.2 Answer 모델
```typescript
interface Answer {
  id: string;
  questionId: string;
  content: string;
  userId: string;
  userName: string;
  createdAt: string; // ISO 8601
  likeCount: number;
  isAccepted: boolean;
  isAIGenerated: boolean;
  isLiked: boolean; // 현재 사용자 기준
  department?: string;
  studentId?: string; // 일부만 표시 (예: 2020****)
  isVerified: boolean;
  userLevel: number; // 1-5
}
```

### 9.3 User 모델
```typescript
interface User {
  id: string;
  email: string;
  name: string;
  nickname: string;
  profileImageUrl?: string;
  department?: string;
  studentId?: string;
  isVerified: boolean;
  userLevel: number;
  createdAt: string;
}
```

## 10. 보안 요구사항

### 10.1 인증
- JWT 토큰 기반 인증
- 토큰 유효기간: 24시간 (권장)
- Refresh Token 지원 권장

### 10.2 권한
- 질문 작성: 로그인 사용자
- 답변 작성: 로그인 사용자  
- 답변 채택: 질문 작성자만
- 공식 답변: 관리자/교직원만

### 10.3 이메일 제한
- 단국대학교 이메일만 허용 (@dankook.ac.kr)
- 이메일 인증 필수

## 11. 기타 주의사항

### 11.1 파일 업로드
- 프로필 이미지: JPG, PNG, 최대 5MB
- 인증 서류: PDF, JPG, PNG, 최대 10MB

### 11.2 텍스트 제한
- 질문 제목: 최대 100자
- 질문 내용: 최대 2000자
- 답변 내용: 최대 1000자
- 닉네임: 2-20자

### 11.3 Rate Limiting
- 질문 작성: 사용자당 하루 10개
- 답변 작성: 사용자당 분당 5개
- 좋아요: 사용자당 분당 30개

### 11.4 현재 목업 데이터
- 테스트 계정: test@dankook.ac.kr / password123
- 인증번호: 1234 (고정)
- 프론트엔드에서 임시로 사용 중인 목업 데이터는 백엔드 구현 후 제거 예정

## 12. 우선순위

### Phase 1 (필수)
1. 인증 API (로그인, 회원가입, 이메일 인증)
2. 질문 CRUD API
3. 답변 CRUD API
4. 기본 통계 API

### Phase 2 (중요)
1. 채팅/AI API
2. 파일 업로드
3. 우수 답변자 시스템
4. 상세 통계

### Phase 3 (부가)
1. 알림 시스템
2. 관리자 기능
3. 고급 검색
4. 추천 시스템 