# Mockoon 설정 가이드

## 1. Mockoon 설치

### 1.1 Desktop 앱 설치
- [Mockoon 공식 사이트](https://mockoon.com/download/)에서 다운로드
- Windows/macOS/Linux 지원

### 1.2 CLI 설치 (선택사항)
```bash
npm install -g @mockoon/cli
```

## 2. 기본 설정

### 2.1 새 환경 생성
1. Mockoon 앱 실행
2. "New environment" 클릭
3. 환경 이름: `단비 API`
4. 포트: `3001`
5. Base URL: `http://localhost:3001`

### 2.2 기본 설정
- **Environment name**: 단비 API
- **Port**: 3001
- **Prefix**: `/api`
- **CORS**: 활성화 (모든 origin 허용)

## 3. API 엔드포인트 설정

### 3.1 인증 관련 API

#### 로그인 - POST /api/auth/login

**요청 본문 예제:**
```json
{
  "email": "student@dankook.ac.kr",
  "password": "password123"
}
```

**응답 예제:**
```json
{
  "route": "/auth/login",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,//
    "message": "로그인 성공",
    "token": "jwt_token_example_123456",
    "user": {
      "id": "user_001",//
      "email": "student@dankook.ac.kr",
      "name": "김단국",//
      "nickname": "단국이",
      "profileImageUrl": "",
      "department": "컴퓨터공학과",
      "studentId": "2020****",//
      "isVerified": true,
      "userLevel": 1,
      "userEXP" : 0,
    }
  }
}
```

**필수 필드:**
- `email`: 단국대학교 이메일 주소 (전체 이메일 주소)
- `password`: 계정 비밀번호

#### 로그아웃 - POST /api/auth/logout
```json
{
  "route": "/auth/logout",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,//
    "message": "로그아웃 완료"
  }
}
```

#### 이메일 인증 코드 전송 - POST /api/auth/send-verification
```json
{
  "route": "/auth/send-verification",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "인증번호가 이메일로 전송되었습니다."
  }
}
```

#### 이메일 인증 - POST /api/auth/verify-email
```json
{
  "route": "/auth/verify-email",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "이메일 인증이 완료되었습니다."
  }
}
```

#### 회원가입 - POST /api/auth/register

**요청 본문 예제:**
```json
{
  "email": "newuser@dankook.ac.kr",
  "password": "password123",
  "nickname": "신입생닉네임"
}
```

**응답 예제:**
```json
{
  "route": "/auth/register",
  "method": "POST",
  "status": 201,
  "response": {
    "success": true,
    "message": "회원가입이 완료되었습니다.",
    "user": {
      "id": "user_new_001",//
      "email": "newuser@dankook.ac.kr",
      "name": "새사용자",//
      "nickname": "신입생닉네임",
      "profileImageUrl": "",
      "department": "",
      "studentId": "",
      "isVerified": false,
      "userLevel": 1,
      "userEXP" : 0,
    }
  }
}
```

**필수 필드:**
- `email`: 단국대학교 이메일 주소 (아이디@dankook.ac.kr)
- `password`: 비밀번호 (8자 이상, 영문+숫자 포함)
- `nickname`: 사용자 닉네임 (2-10자, 한글/영문/숫자)

### 3.2 질문 관련 API

#### 질문 목록 조회 - GET /api/questions
```json
{
  "route": "/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q001",
        "title": "2024년 1학기 수강신청 일정이 언제인가요?",
        "content": "수강신청 일정을 알고 싶습니다.",
        "userEmail": "example@dankook.ac.kr",//
        "userNickName": "학사팀",//
        "createdAt": "2024-01-15T09:00:00Z",
        "category": "학사",
        "isOfficial": true,
        "viewCount": 150,
        "answerCount": 1,
        "tags": ["수강신청", "일정", "학사"]
      }
    ]
  }
}
```

#### 특정 질문 조회(상세 페이지) - GET /api/questions/{id}
```json
{
  "route": "/questions/:id",
  "method": "GET",
  "status": 200,
  "response": {
    "id": "q001",
    "title": "2024년 1학기 수강신청 일정이 언제인가요?",
    "content": "수강신청 일정을 알고 싶습니다.",
    "userEmail": "example@dankook.ac.kr",
    "userNickName": "example",
    "createdAt": "2024-01-15T09:00:00Z",
    "updatedAt": "2024-01-15T09:00:00Z",//
    "category": "학사",
    "isOfficial": true,
    "viewCount": 150,
    "answerCount": 1,
    "tags": ["수강신청", "일정", "학사"]
  }
}
```

#### 새 질문 작성 - POST /api/questions
```json
{
  "route": "/questions",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "q001",
    "title": "새로운 질문 제목",
    "content": "새로운 질문 내용",
    "userEmail": "",
    "userNickName": "",//
    "createdAt": "2024-01-20T10:00:00Z",
    "category": "",
    "isOfficial": false,
    "viewCount": 0,
    "answerCount": 0,
    "tags": []
  }
}
```

#### 인기 질문 - GET /api/questions/popular
```json
{
  "route": "/questions/popular",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q002",
        "title": "도서관 이용시간이 어떻게 되나요?",
        "content": "중앙도서관 평일/주말 이용시간을 알고 싶습니다.",
        "userEmail": "",//
        "userNickName": "",//
        "createdAt": "2024-01-19T14:00:00Z",
        "category": "기타",
        "isOfficial": true,
        "viewCount": 234,
        "answerCount": 1,
        "tags": ["도서관", "이용시간"]
      }
    ]
  }
}
```

//#### 자주 받은 질문 - GET /api/questions/frequent
```json
{
  "route": "/questions/frequent",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q003",
        "title": "기숙사 신청은 언제부터인가요?",
        "content": "2024년도 기숙사 신청 일정을 알고 싶습니다.",
        "userEmail": "admin",//
        "userNickName": "생활관팀",//
        "createdAt": "2024-01-18T11:00:00Z",
        "category": "기타",
        "isOfficial": true,
        "viewCount": 189,
        "answerCount": 1,
        "tags": ["기숙사", "신청", "일정"]
      },
    ]
  }
}
```

//#### 공식 질문 - GET /api/questions/official
```json
{
  "route": "/questions/official",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q005",
        "title": "2024년도 등록금 납부 안내",
        "content": "2024년도 1학기 등록금 납부 일정 및 방법 안내입니다.",
        "userId": "admin",//
        "userName": "재무팀",//
        "createdAt": "2024-01-20T09:00:00Z",
        "category": "장학금",
        "isOfficial": true,
        "viewCount": 445,
        "answerCount": 1,
        "tags": ["등록금", "납부", "일정"]
      }
    ]
  }
}
```

#### 답변받지 못한 질문 - GET /api/questions/unanswered
```json
{
  "route": "/questions/unanswered",
  "method": "GET", 
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q006",
        "title": "캠퍼스 내 자전거 주차장 위치가 궁금해요",
        "content": "천안캠퍼스에서 자전거를 세울 수 있는 곳이 어디인지 알고 싶습니다.",
        "userId": "student003",//
        "userName": "박학생",//
        "createdAt": "2024-01-21T13:45:00Z",
        "category": "기타",
        "isOfficial": false,
        "viewCount": 23,
        "answerCount": 0,
        "tags": ["자전거", "주차장", "캠퍼스"]
      },
      {
        "id": "q007",
        "title": "졸업논문 제출 마감일이 언제인가요?",
        "content": "2024년도 전기 졸업예정자 논문 제출 마감일을 알고 싶습니다.",
        "userId": "student004",//
        "userName": "이학생",//
        "createdAt": "2024-01-21T16:20:00Z",
        "category": "학사",
        "isOfficial": false,
        "viewCount": 34,
        "answerCount": 0,
        "tags": ["졸업논문", "마감일", "제출"]
      }
    ]
  }
}
```

// #### 질문 검색 - GET /api/questions/search
```json
{
  "route": "/questions/search",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q001",
        "title": "2024년 1학기 수강신청 일정이 언제인가요?",
        "content": "수강신청 일정을 알고 싶습니다.",
        "userId": "admin",
        "userName": "학사팀",
        "createdAt": "2024-01-15T09:00:00Z",
        "category": "학사",
        "isOfficial": true,
        "viewCount": 150,
        "answerCount": 1,
        "tags": ["수강신청", "일정", "학사"]
      }
    ]
  }
}
```
**쿼리 파라미터**: `q` (검색어)

#### 채팅에서 질문 생성 - POST /api/questions/from-chat
```json
{
  "route": "/questions/from-chat",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "q_chat_001",
    "title": "채팅에서 생성된 질문",
    "content": "채팅 대화를 기반으로 생성된 질문 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-20T16:30:00Z",
    "category": "기타",
    "isOfficial": false,
    "viewCount": 0,
    "answerCount": 0,
    "tags": []
  }
}
```

**Request Body 예시:**
```json
{
  "title": "채팅에서 생성된 질문 제목",
  "content": "채팅에서 생성된 질문 내용",
  "category": "학사"
}
```

### 3.3 답변 관련 API

#### 특정 질문의 답변 목록 - GET /api/questions/{id}/answers
```json
{
  "route": "/questions/:id/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "answers": [
      {
        "id": "a001",
        "questionId": "q001",
        "content": "2024년 1학기 수강신청은 2월 5일부터 시작됩니다.\n자세한 일정은 학사공지를 확인해주세요.",
        "userId": "admin",
        "userName": "학사팀",
        "createdAt": "2024-01-16T10:00:00Z",
        "isAccepted": true,
        "department": "학사처",
        "isVerified": true,
        "userLevel": 5
      }
    ]
  }
}
```

#### 새 답변 작성 - POST /api/answers
```json
{
  "route": "/answers",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "a_new_001",
    "questionId": "q001",
    "content": "새로운 답변 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-20T15:00:00Z",
    "isAccepted": false,
    "userLevel": 2
  }
}
```

#### 답변 채택 - PUT /api/answers/{id}/accept
```json
{
  "route": "/answers/:id/accept",
  "method": "PUT",
  "status": 200,
  "response": {
    "id": "a001",
    "questionId": "q001",
    "content": "답변 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-16T10:00:00Z",
    "isAccepted": true,
    "userLevel": 3
  }
}
```

### 3.4 통계 관련 API

#### 오늘의 질문 수 - GET /api/statistics/today/questions
```json
{
  "route": "/statistics/today/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 5
  }
}
```

#### 오늘의 답변 수 - GET /api/statistics/today/answers
```json
{
  "route": "/statistics/today/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 12
  }
}
```

#### 전체 답변 수 - GET /api/statistics/total/answers
```json
{
  "route": "/statistics/total/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 1547
  }
}
```

#### 우수 답변자 - GET /api/statistics/top-answerers
```json
{
  "route": "/statistics/top-answerers",
  "method": "GET",
  "status": 200,
  "response": {
    "topAnswerers": [
      {
        "id": "user_top1",
        "userName": "김단국",
        "profileImageUrl": "",
        "score": 128,
        "rank": 1,
        "answerCount": 42
      },
      {
        "id": "user_top2",
        "userName": "박대학",
        "profileImageUrl": "",
        "score": 105,
        "rank": 2,
        "answerCount": 35
      }
    ]
  }
}
```

### 3.5 채팅 관련 API

#### 채팅 메시지 처리 - POST /api/chat/process

**시나리오 1: 수강신청 관련 질문**
```json
{
  "route": "/chat/process",
  "method": "POST",
  "status": 200,
  "response": {
    "response": {
      "answer": "2024년 1학기 수강신청은 2월 15일 오전 9시부터 시작됩니다. 수강신청 시스템은 단국대학교 포털사이트(portal.dankook.ac.kr)에서 접속 가능합니다.",
      "confidence": 0.95,
      "source": "official_document",
      "category": "학사"
    },
    "relatedQuestions": [
      {
        "id": "q001",
        "title": "수강신청 시스템 사용법",
        "similarity": 0.87
      },
      {
        "id": "q003",
        "title": "수강신청 변경 및 취소 방법",
        "similarity": 0.75
      }
    ],
    "suggestions": [
      "수강신청 절차가 궁금하시나요?",
      "수강신청 시스템 접속 방법을 알려드릴까요?",
      "수강신청 관련 문의처를 안내해드릴까요?"
    ],
    "actions": {
      "canCreateQuestion": false,
      "hasDirectAnswer": true
    },
    "metadata": {
      "type": "direct_answer",
      "timestamp": "2024-01-20T16:00:05Z",
      "processingTime": 234,
      "aiModel": "university_qa_v1.0"
    }
  }
}
```

**시나리오 2: 새로운 질문 (기존 답변 없음)**
```json
{
  "route": "/chat/process",
  "method": "POST", 
  "status": 200,
  "response": {
    "response": {
      "answer": "죄송합니다. 해당 질문에 대한 정확한 정보를 찾지 못했습니다. 질문을 등록하시면 다른 학생들이나 관리자가 답변해드릴 수 있습니다.",
      "confidence": 0.3,
      "source": "no_match",
      "category": "기타"
    },
    "relatedQuestions": [],
    "suggestions": [
      "질문을 게시판에 등록해보세요",
      "비슷한 다른 질문들을 확인해보세요"
    ],
    "actions": {
      "canCreateQuestion": true,
      "suggestedTitle": "사용자의 질문 제목 자동 생성",
      "suggestedCategory": "기타",
      "suggestedContent": "사용자 메시지를 기반으로 한 질문 내용"
    },
    "metadata": {
      "type": "no_answer",
      "timestamp": "2024-01-20T16:00:05Z",
      "processingTime": 156,
      "aiModel": "university_qa_v1.0"
    }
  }
}
```

**시나리오 3: 장학금 관련 질문**
```json
{
  "route": "/chat/process",
  "method": "POST",
  "status": 200,
  "response": {
    "response": {
      "answer": "2024년 1학기 장학금 신청은 1월 15일부터 2월 10일까지입니다. 성적장학금, 생활장학금, 봉사장학금 등 다양한 종류가 있으며, 단국대학교 장학팀(031-8005-2000)으로 문의하시면 자세한 안내를 받으실 수 있습니다.",
      "confidence": 0.92,
      "source": "official_document",
      "category": "장학금"
    },
    "relatedQuestions": [
      {
        "id": "q010",
        "title": "성적장학금 신청 자격",
        "similarity": 0.89
      },
      {
        "id": "q015",
        "title": "생활장학금 신청 방법",
        "similarity": 0.82
      }
    ],
    "suggestions": [
      "장학금 종류별 자격요건이 궁금하시나요?",
      "장학금 신청 절차를 안내해드릴까요?",
      "장학금 관련 서류가 궁금하시나요?"
    ],
    "actions": {
      "canCreateQuestion": false,
      "hasDirectAnswer": true
    },
    "metadata": {
      "type": "direct_answer",
      "timestamp": "2024-01-20T16:00:05Z",
      "processingTime": 198,
      "aiModel": "university_qa_v1.0"
    }
  }
}
```

**시나리오 4: 일반적인 인사 또는 모호한 질문**
```json
{
  "route": "/chat/process", 
  "method": "POST",
  "status": 200,
  "response": {
    "response": {
      "answer": "안녕하세요! 단국대학교 학생 질문 도우미입니다. 학사, 장학금, 교내프로그램, 취업 등 다양한 주제에 대해 질문해주세요.",
      "confidence": 0.99,
      "source": "system_response",
      "category": "일반"
    },
    "relatedQuestions": [],
    "suggestions": [
      "수강신청 관련 질문하기",
      "장학금 정보 문의하기", 
      "교내 프로그램 알아보기",
      "취업 지원 서비스 문의하기"
    ],
    "actions": {
      "canCreateQuestion": false,
      "hasDirectAnswer": true
    },
    "metadata": {
      "type": "general_response",
      "timestamp": "2024-01-20T16:00:05Z",
      "processingTime": 45,
      "aiModel": "university_qa_v1.0"
    }
  }
}
```

**Request Body 예시:**
```json
{
  "message": "수강신청은 언제 시작하나요?",
  "context": {
    "userId": "user_001",
    "sessionId": "chat_session_123",
    "previousMessages": [
      {
        "role": "user",
        "content": "안녕하세요"
      },
      {
        "role": "assistant",
        "content": "안녕하세요! 무엇을 도와드릴까요?"
      }
    ]
  },
  "metadata": {
    "timestamp": "2024-01-20T16:00:00Z",
    "userAgent": "flutter_app"
  }
}
```

### 3.6 사용자 관련 API

#### 사용자 질문 통계 - GET /api/users/{userId}/question-stats
```json
{
  "route": "/users/:userId/question-stats",
  "method": "GET",
  "status": 200,
  "response": {
    "total": 8,
    "answered": 5,
    "unanswered": 3
  }
}
```
**인증**: JWT 토큰 필요  
**설명**: 특정 사용자가 작성한 질문들의 통계 정보

#### 사용자 질문 목록 - GET /api/users/{userId}/questions
```json
{
  "route": "/users/:userId/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q008",
        "title": "사용자가 작성한 질문 1",
        "content": "사용자가 작성한 첫 번째 질문 내용",
        "userId": "user_001",
        "userName": "김학생",
        "createdAt": "2024-01-20T10:00:00Z",
        "category": "학사",
        "isOfficial": false,
        "viewCount": 15,
        "answerCount": 1,
        "tags": ["질문", "학사"]
      },
      {
        "id": "q009",
        "title": "사용자가 작성한 질문 2", 
        "content": "사용자가 작성한 두 번째 질문 내용",
        "userId": "user_001",
        "userName": "김학생",
        "createdAt": "2024-01-19T14:30:00Z",
        "category": "기타",
        "isOfficial": false,
        "viewCount": 8,
        "answerCount": 0,
        "tags": ["질문", "기타"]
      }
    ]
  }
}
```
**인증**: JWT 토큰 필요  
**쿼리 파라미터**: `filter` (선택사항: 'answered', 'unanswered', 'all')

## 4. 실행 및 테스트

### 4.1 Mockoon 서버 실행
1. Mockoon 앱에서 환경 선택
2. "Start" 버튼 클릭
3. `http://localhost:3001` 서버 실행 확인

### 4.2 필수 API 엔드포인트 체크리스트

다음 **24개의 API 엔드포인트**를 모두 Mockoon에 설정해야 합니다:

#### 인증 관련 (5개)
- [ ] POST `/api/auth/login` - 로그인
- [ ] POST `/api/auth/logout` - 로그아웃  
- [ ] POST `/api/auth/register` - 회원가입
- [ ] POST `/api/auth/send-verification` - 이메일 인증 코드 전송
- [ ] POST `/api/auth/verify-email` - 이메일 인증

#### 질문 관련 (9개)
- [ ] GET `/api/questions` - 질문 목록 조회
- [ ] GET `/api/questions/{id}` - 특정 질문 조회  
- [ ] POST `/api/questions` - 새 질문 작성
- [ ] GET `/api/questions/popular` - 인기 질문 목록
- [ ] GET `/api/questions/frequent` - 자주 받은 질문 목록
- [ ] GET `/api/questions/official` - 공식 질문 목록
- [ ] GET `/api/questions/unanswered` - 답변받지 못한 질문 목록
- [ ] GET `/api/questions/search` - 질문 검색
- [ ] POST `/api/questions/from-chat` - 채팅에서 질문 생성

#### 답변 관련 (4개)
- [ ] GET `/api/questions/{id}/answers` - 특정 질문의 답변 목록
- [ ] POST `/api/answers` - 새 답변 작성
- [ ] PUT `/api/answers/{id}/accept` - 답변 채택

#### 통계 관련 (4개)
- [ ] GET `/api/statistics/today/questions` - 오늘의 질문 수
- [ ] GET `/api/statistics/today/answers` - 오늘의 답변 수
- [ ] GET `/api/statistics/total/answers` - 전체 답변 수
- [ ] GET `/api/statistics/top-answerers` - 우수 답변자 목록

#### 사용자 관련 (2개)
- [ ] GET `/api/users/{userId}/question-stats` - 사용자 질문 통계
- [ ] GET `/api/users/{userId}/questions` - 사용자 질문 목록

**총 24개 엔드포인트 ✅**

### 4.3 Flutter 앱 테스트
1. Flutter 앱 실행
2. 로그인 화면에서 테스트 계정 사용:
   - **이메일**: test@dankook.ac.kr
   - **비밀번호**: password123
3. 각 기능별 API 호출 테스트

### 4.4 API 테스트 도구
#### Postman/Insomnia로 직접 테스트
```bash
# 로그인 테스트
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
  "email": "test@dankook.ac.kr",
  "password": "password123"
}
```

#### cURL로 테스트
```bash
# 질문 목록 조회
curl -X GET http://localhost:3001/api/questions \
  -H "Content-Type: application/json"

# 새 질문 작성
curl -X POST http://localhost:3001/api/questions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token_here" \
  -d '{
    "title": "테스트 질문",
    "content": "테스트 질문 내용",
    "category": "기타"
  }'
```

## 5. 주의사항

### 5.1 CORS 설정
- Mockoon에서 CORS 활성화 필수
- Headers에 다음 추가:
  ```
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
  Access-Control-Allow-Headers: Content-Type, Authorization
  ```

### 5.2 데이터 형식
- 모든 날짜는 ISO 8601 형식 (`2024-01-01T00:00:00Z`)
- JSON 응답 형식 일관성 유지
- 에러 응답도 동일한 구조로 설정

### 5.3 테스트 계정
- **test@dankook.ac.kr**: 프론트엔드에서 로컬 처리
- **다른 계정**: Mockoon API 호출
- **인증번호**: `1234` (테스트용)

## 6. 트러블슈팅

### 6.1 연결 오류
- Mockoon 서버 실행 상태 확인
- 포트 3001 사용 가능 여부 확인
- 방화벽 설정 확인

### 6.2 CORS 오류
- Mockoon에서 CORS 설정 확인
- 프록시 설정 필요 시 flutter 개발 서버 설정

### 6.3 API 응답 오류
- JSON 형식 검증
- 필수 필드 누락 확인
- 상태 코드 일치 확인

## 7. 다음 단계

1. **기본 API 테스트** 완료 후
2. **실제 백엔드 개발** 시작
3. **데이터베이스 연동**
4. **JWT 토큰 인증** 구현
5. **파일 업로드** 기능 추가
6. **실시간 기능** (WebSocket) 추가

---

이 가이드를 따라 설정하면 Flutter 앱의 모든 API 기능을 Mockoon으로 테스트할 수 있습니다! 🚀 