# 단비 앱 API 문서

## 📋 목차
1. [인증 관련 API](#인증-관련-api)
2. [질문 관련 API](#질문-관련-api)
3. [답변 관련 API](#답변-관련-api)
4. [채팅/AI 관련 API](#채팅ai-관련-api)
5. [통계 관련 API](#통계-관련-api)
6. [사용자 관련 API](#사용자-관련-api)

---

## 인증 관련 API

### 1. 이메일 인증 코드 전송
**POST** `/api/auth/send-verification-code`

**요청:**
```json
{
  "email": "student@dankook.ac.kr"
}
```

**응답:**
```json
{
  "response": {
    "requestId": 12345,
    "message": "인증 코드가 전송되었습니다.",
    "expiresIn": 300
  }
}
```

### 2. 이메일 인증 확인
**POST** `/api/auth/verify-email`

**요청:**
```json
{
  "requestId": 12345,
  "email": "student@dankook.ac.kr",
  "code": "123456"
}
```

**응답:**
```json
{
  "response": {
    "verified": true,
    "message": "이메일 인증이 완료되었습니다."
  }
}
```

### 3. 회원가입
**POST** `/api/auth/register`

**요청:**
```json
{
  "email": "student@dankook.ac.kr",
  "password": "password123",
  "nickname": "단국이"
}
```

**응답:**
```json
{
  "response": {
    "user": {
      "id": "user_123",
      "email": "student@dankook.ac.kr",
      "nickname": "단국이",
      "profileImageUrl": null,
      "createdAt": "2024-01-15T10:30:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

### 4. 로그인
**POST** `/api/auth/login`

**요청:**
```json
{
  "email": "student@dankook.ac.kr",
  "password": "password123"
}
```

**응답:**
```json
{
  "response": {
    "user": {
      "id": "user_123",
      "email": "student@dankook.ac.kr",
      "nickname": "단국이",
      "profileImageUrl": "https://example.com/profile.jpg",
      "department": "컴퓨터공학과",
      "isVerified": true
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

### 5. 로그아웃
**POST** `/api/auth/logout`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**응답:**
```json
{
  "response": {
    "message": "로그아웃되었습니다."
  }
}
```

---

## 질문 관련 API

### 1. 질문 목록 조회
**GET** `/api/questions?category={category}&search={search}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_123",
        "title": "중앙도서관 이용시간 문의",
        "content": "중앙도서관의 평일, 주말 이용시간이 궁금합니다.",
        "category": "기타",
        "userId": "user_123",
        "userName": "단국이",
        "createdAt": "2024-01-15T10:30:00.000Z",
        "viewCount": 15,
        "answerCount": 3,
        "isAnswered": true,
        "isOfficial": false,
        "tags": ["도서관", "이용시간"]
      }
    ],
    "totalCount": 50,
    "page": 1,
    "limit": 20
  }
}
```

### 2. 인기 질문 조회
**GET** `/api/questions/popular?limit={limit}&period={period}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_456",
        "title": "수강신청 방법 문의",
        "content": "수강신청은 어떻게 하나요?",
        "category": "학사",
        "userId": "user_456",
        "userName": "학생A",
        "createdAt": "2024-01-14T09:00:00.000Z",
        "viewCount": 120,
        "answerCount": 8,
        "isAnswered": true,
        "isOfficial": false,
        "tags": ["수강신청", "학사"]
      }
    ]
  }
}
```

### 3. 자주 받은 질문 조회
**GET** `/api/questions/frequent?limit={limit}&period={period}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_789",
        "title": "장학금 신청 기간",
        "content": "장학금 신청은 언제까지인가요?",
        "category": "장학금",
        "userId": "user_789",
        "userName": "학생B",
        "createdAt": "2024-01-13T14:20:00.000Z",
        "viewCount": 89,
        "answerCount": 5,
        "isAnswered": true,
        "isOfficial": true,
        "tags": ["장학금", "신청기간"]
      }
    ]
  }
}
```

### 4. 공식 질문 조회
**GET** `/api/questions/official?limit={limit}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_official_1",
        "title": "2024학년도 1학기 수강신청 안내",
        "content": "수강신청 일정 및 방법을 안내드립니다.",
        "category": "학사",
        "userId": "admin_1",
        "userName": "학사팀",
        "createdAt": "2024-01-10T09:00:00.000Z",
        "viewCount": 500,
        "answerCount": 0,
        "isAnswered": false,
        "isOfficial": true,
        "tags": ["공지", "수강신청"]
      }
    ]
  }
}
```

### 5. 답변받지 못한 질문 조회
**GET** `/api/questions/unanswered?limit={limit}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_unanswered_1",
        "title": "기숙사 신청 문의",
        "content": "기숙사 신청은 어떻게 하나요?",
        "category": "기타",
        "userId": "user_999",
        "userName": "신입생",
        "createdAt": "2024-01-15T16:30:00.000Z",
        "viewCount": 5,
        "answerCount": 0,
        "isAnswered": false,
        "isOfficial": false,
        "tags": ["기숙사", "신청"]
      }
    ]
  }
}
```

### 6. 질문 검색
**GET** `/api/questions/search?q={query}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_search_1",
        "title": "도서관 열람실 예약",
        "content": "도서관 열람실 예약 방법이 궁금합니다.",
        "category": "기타",
        "userId": "user_111",
        "userName": "도서관러버",
        "createdAt": "2024-01-15T11:00:00.000Z",
        "viewCount": 25,
        "answerCount": 2,
        "isAnswered": true,
        "isOfficial": false,
        "tags": ["도서관", "열람실", "예약"]
      }
    ],
    "totalCount": 15,
    "searchTerm": "도서관"
  }
}
```

### 7. 특정 질문 조회
**GET** `/api/questions/{questionId}`

**응답:**
```json
{
  "response": {
    "id": "q_123",
    "title": "중앙도서관 이용시간 문의",
    "content": "중앙도서관의 평일, 주말 이용시간이 궁금합니다.",
    "category": "기타",
    "userId": "user_123",
    "userName": "단국이",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "viewCount": 16,
    "answerCount": 3,
    "isAnswered": true,
    "isOfficial": false,
    "tags": ["도서관", "이용시간"]
  }
}
```

### 8. 새 질문 작성
**POST** `/api/questions`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "title": "중앙도서관 이용시간 문의",
  "content": "중앙도서관의 평일, 주말 이용시간과 휴관일에 대해 자세히 알고 싶습니다.",
  "category": "기타",
  "tags": ["도서관", "이용시간"]
}
```

**응답:**
```json
{
  "response": {
    "id": "q_new_123",
    "title": "중앙도서관 이용시간 문의",
    "content": "중앙도서관의 평일, 주말 이용시간과 휴관일에 대해 자세히 알고 싶습니다.",
    "category": "기타",
    "userId": "user_123",
    "userName": "단국이",
    "createdAt": "2024-01-15T17:30:00.000Z",
    "viewCount": 0,
    "answerCount": 0,
    "isAnswered": false,
    "isOfficial": false,
    "tags": ["도서관", "이용시간"]
  }
}
```

### 9. 채팅에서 질문 생성
**POST** `/api/questions/from-chat`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "title": "AI가 생성한 질문 제목",
  "content": "AI가 생성한 질문 내용",
  "category": "기타"
}
```

**응답:**
```json
{
  "response": {
    "id": "q_chat_123",
    "title": "AI가 생성한 질문 제목",
    "content": "AI가 생성한 질문 내용",
    "category": "기타",
    "userId": "user_123",
    "userName": "단국이",
    "createdAt": "2024-01-15T17:45:00.000Z",
    "viewCount": 0,
    "answerCount": 0,
    "isAnswered": false,
    "isOfficial": false,
    "tags": null
  }
}
```

---

## 답변 관련 API

### 1. 특정 질문의 답변 목록 조회
**GET** `/api/questions/{questionId}/answers`

**응답:**
```json
{
  "response": {
    "answers": [
      {
        "id": "a_123",
        "questionId": "q_123",
        "content": "중앙도서관은 평일 오전 9시부터 오후 10시까지, 주말은 오전 9시부터 오후 6시까지 운영됩니다.",
        "userId": "user_456",
        "userName": "도서관직원",
        "createdAt": "2024-01-15T11:00:00.000Z",
        "likeCount": 5,
        "isAccepted": true,
        "isLiked": false
      }
    ],
    "totalCount": 3
  }
}
```

### 2. 새 답변 작성
**POST** `/api/questions/{questionId}/answers`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "content": "중앙도서관은 평일 오전 9시부터 오후 10시까지 운영됩니다."
}
```

**응답:**
```json
{
  "response": {
    "id": "a_new_123",
    "questionId": "q_123",
    "content": "중앙도서관은 평일 오전 9시부터 오후 10시까지 운영됩니다.",
    "userId": "user_456",
    "userName": "도서관직원",
    "createdAt": "2024-01-15T18:00:00.000Z",
    "likeCount": 0,
    "isAccepted": false,
    "isLiked": false
  }
}
```

### 3. 답변 채택
**PUT** `/api/questions/{questionId}/answers/{answerId}/accept`
**Headers:** `Authorization: Bearer {accessToken}`

**응답:**
```json
{
  "response": {
    "id": "a_123",
    "questionId": "q_123",
    "content": "중앙도서관은 평일 오전 9시부터 오후 10시까지 운영됩니다.",
    "userId": "user_456",
    "userName": "도서관직원",
    "createdAt": "2024-01-15T11:00:00.000Z",
    "likeCount": 5,
    "isAccepted": true,
    "isLiked": false
  }
}
```

### 4. 답변 좋아요/좋아요 취소
**PUT** `/api/answers/{answerId}/like`
**Headers:** `Authorization: Bearer {accessToken}`

**응답:**
```json
{
  "response": {
    "id": "a_123",
    "questionId": "q_123",
    "content": "중앙도서관은 평일 오전 9시부터 오후 10시까지 운영됩니다.",
    "userId": "user_456",
    "userName": "도서관직원",
    "createdAt": "2024-01-15T11:00:00.000Z",
    "likeCount": 6,
    "isAccepted": true,
    "isLiked": true
  }
}
```

---

## 채팅/AI 관련 API

### 1. 채팅 메시지 처리
**POST** `/api/chat/process`

**요청:**
```json
{
  "message": "도서관 이용시간이 궁금해요"
}
```

**응답 (직접 답변 가능한 경우):**
```json
{
  "response": {
    "response": {
      "answer": "중앙도서관은 평일 오전 9시부터 오후 10시까지, 주말은 오전 9시부터 오후 6시까지 운영됩니다."
    },
    "actions": {
      "hasDirectAnswer": true,
      "canCreateQuestion": false
    },
    "relatedQuestions": [
      {
        "id": "q_related_1",
        "title": "도서관 열람실 예약 방법",
        "category": "기타"
      }
    ]
  }
}
```

**응답 (질문 작성 필요한 경우):**
```json
{
  "response": {
    "response": {
      "answer": "해당 질문에 대한 정확한 답변을 찾지 못했습니다. 새로운 질문을 작성해보시겠어요?"
    },
    "actions": {
      "hasDirectAnswer": false,
      "canCreateQuestion": true
    },
    "relatedQuestions": []
  }
}
```

### 2. AI 질문 작성 도우미
**POST** `/api/questions/compose`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "userMessage": "도서관 이용시간이 궁금해요"
}
```

**응답:**
```json
{
  "response": {
    "composedQuestion": {
      "title": "중앙도서관 이용시간 문의",
      "content": "중앙도서관의 평일, 주말 이용시간과 휴관일에 대해 자세히 알고 싶습니다.",
      "category": "기타"
    }
  }
}
```

---

## 통계 관련 API

### 1. 오늘의 질문 수 조회
**GET** `/api/statistics/today/questions`

**응답:**
```json
{
  "response": {
    "count": 15,
    "date": "2024-01-15"
  }
}
```

### 2. 오늘의 답변 수 조회
**GET** `/api/statistics/today/answers`

**응답:**
```json
{
  "response": {
    "count": 28,
    "date": "2024-01-15"
  }
}
```

### 3. 전체 답변 수 조회
**GET** `/api/statistics/total/answers`

**응답:**
```json
{
  "response": {
    "count": 1250
  }
}
```

### 4. 우수 답변자 목록 조회
**GET** `/api/statistics/top-answerers?limit={limit}`

**응답:**
```json
{
  "response": {
    "topAnswerers": [
      {
        "id": "user_top_1",
        "userName": "답변왕",
        "profileImageUrl": "https://example.com/profile1.jpg",
        "score": 95,
        "rank": 1,
        "answerCount": 45,
        "likeCount": 120
      },
      {
        "id": "user_top_2",
        "userName": "도움이",
        "profileImageUrl": "https://example.com/profile2.jpg",
        "score": 88,
        "rank": 2,
        "answerCount": 38,
        "likeCount": 95
      }
    ]
  }
}
```

---

## 사용자 관련 API

### 1. 사용자 질문 통계 조회
**GET** `/api/users/{userId}/question-stats`
**Headers:** `Authorization: Bearer {accessToken}`

**응답:**
```json
{
  "response": {
    "total": 12,
    "answered": 8,
    "unanswered": 4
  }
}
```

### 2. 사용자 질문 목록 조회
**GET** `/api/users/{userId}/questions?filter={filter}`
**Headers:** `Authorization: Bearer {accessToken}`

**응답:**
```json
{
  "response": {
    "questions": [
      {
        "id": "q_user_1",
        "title": "내가 작성한 질문 1",
        "content": "질문 내용입니다.",
        "category": "학사",
        "userId": "user_123",
        "userName": "단국이",
        "createdAt": "2024-01-15T10:30:00.000Z",
        "viewCount": 15,
        "answerCount": 3,
        "isAnswered": true,
        "isOfficial": false,
        "tags": ["학사"]
      }
    ],
    "totalCount": 12,
    "filter": "all"
  }
}
```

### 3. 프로필 업데이트
**PUT** `/api/users/profile`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "nickname": "새로운닉네임",
  "profileImageUrl": "https://example.com/new-profile.jpg"
}
```

**응답:**
```json
{
  "response": {
    "user": {
      "id": "user_123",
      "email": "student@dankook.ac.kr",
      "nickname": "새로운닉네임",
      "profileImageUrl": "https://example.com/new-profile.jpg",
      "department": "컴퓨터공학과",
      "isVerified": true,
      "updatedAt": "2024-01-15T18:30:00.000Z"
    }
  }
}
```

### 4. 학과 인증
**POST** `/api/users/verify-department`
**Headers:** `Authorization: Bearer {accessToken}`

**요청:**
```json
{
  "email": "student@dankook.ac.kr",
  "department": "컴퓨터공학과"
}
```

**응답:**
```json
{
  "response": {
    "verified": true,
    "message": "학과 인증이 완료되었습니다.",
    "department": "컴퓨터공학과"
  }
}
```

### 5. 계정 삭제
**DELETE** `/api/users/account`
**Headers:** `Authorization: Bearer {accessToken}`

**응답:**
```json
{
  "response": {
    "deleted": true,
    "message": "계정이 성공적으로 삭제되었습니다."
  }
}
```

---

## 🔧 공통 에러 응답

### 400 Bad Request
```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "잘못된 요청입니다.",
    "details": "필수 필드가 누락되었습니다."
  }
}
```

### 401 Unauthorized
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "인증이 필요합니다.",
    "details": "유효한 토큰을 제공해주세요."
  }
}
```

### 403 Forbidden
```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "접근 권한이 없습니다.",
    "details": "해당 리소스에 접근할 권한이 없습니다."
  }
}
```

### 404 Not Found
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "리소스를 찾을 수 없습니다.",
    "details": "요청한 질문이 존재하지 않습니다."
  }
}
```

### 500 Internal Server Error
```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "서버 내부 오류가 발생했습니다.",
    "details": "잠시 후 다시 시도해주세요."
  }
}
```

---

## 📝 참고사항

### 카테고리 목록
- `학사`: 수강신청, 성적, 졸업 등
- `장학금`: 장학금 신청, 지급 등
- `교내프로그램`: 동아리, 행사, 프로그램 등
- `취업`: 취업, 인턴, 진로 등
- `기타`: 기타 모든 질문

### 인증 토큰
- 모든 인증이 필요한 API는 `Authorization: Bearer {accessToken}` 헤더 필요
- 토큰 만료 시 401 에러 반환

### 페이지네이션
- 기본 limit: 20
- 최대 limit: 100
- page는 1부터 시작 